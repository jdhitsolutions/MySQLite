Function Import-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "The path to the exported JSON file"
        )]
        [ValidatePattern("\.json$")]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter(
            Position = 1,
            Mandatory,
            HelpMessage = "The destination path for the imported database file"
        )]
        [ValidatePattern("\.db$")]
        [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [string]$Destination,

        [Parameter(HelpMessage = "Overwrite the destination file if it exists.")]
        [switch]$Force,

        [Parameter(HelpMessage = "Use an existing database file.")]
        [Alias("Append")]
        [Switch]$UseExisting,

        [switch]$PassThru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] $Importing database data from $Path "
        if (-Not $UseExisting -AND $PSCmdlet.ShouldProcess($Destination, "Creating database file")) {
            Try {
                New-MySQLiteDB -Path $destination -Force:$Force -ErrorAction Stop
            }
            Catch {
                Throw $_
            }
        }
        $conn = Open-MySQLiteDB -Path $destination -ErrorAction Stop
        If ($conn.state -eq 'Open' -AND (-Not $WhatIfPreference)) {

            $data = Get-Content -Path $Path -Encoding UTF8 | ConvertFrom-Json

            #July 18 Do not import system tables
            $data.PSObject.properties | Where {$_.Name -ne 'sqlite_sequence'} | ForEach-Object {
                $table = $_.name
                #July 18 skip empty tables
                if ($_.Value) {
                    Write-Verbose "Defining $table"
                    $props = $_.value[0].PSObject.properties.name
                    Write-Verbose "Processing $($_.value.count) items"
                    New-MySQLiteDBTable -Connection $conn -TableName $_.name -ColumnNames $props -Force -KeepAlive
                    $_.value | ForEach-Object {
                        $q = buildquery -InputObject $_ -TableName $table
                        Write-Verbose $q
                        Invoke-MySQLiteQuery -Query $q -Connection $conn -KeepAlive
                    } #foreach value
                }
                else {
                    Write-Verbose "No data found for $table"
                }
            } #foreach data object property
            if ($PassThru) {
                Get-Item -path $Destination
            }
        } #if state is open
        elseif (-Not $WhatIfPreference) {
            Write-Warning "The database file $Destination is not open. Detected state $($conn.state)."
        }

    } #process

    End {
        if ($conn.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Closing database connection"
            Close-MySQLiteDB -Connection $conn
        }
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Import-MySQLiteDB