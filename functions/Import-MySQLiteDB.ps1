

Function Import-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The path to the exported JSON file"
        )]
        [ValidatePattern("\.json$")]
        [ValidateScript({ Test-Path $_ })]

        [string]$Path,

        [Parameter(
            Mandatory,
            Position = 1,
            HelpMessage = "The destination path for the imported database file"
        )]
        [ValidatePattern("\.db$")]
        [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [string]$Destination,

        [Parameter(HelpMessage = "Overwrite the destination file if it exists.")]
        [switch]$Force,

        [switch]$Passthru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Importing database data from $Path "
        if ($pscmdlet.ShouldProcess($Destination, "Creating database file")) {
            Try {
                New-MySQLiteDB -Path $destination -Force:$Force -ErrorAction Stop
                $conn = Open-MySQLiteDB -Path $destination -ErrorAction Stop
            }
            Catch {
                Throw $_
            }
        }
        If ($conn.state -eq 'Open' -AND (-Not $WhatIfPreference)) {

            $data = Get-Content -Path $Path -Encoding UTF8 | ConvertFrom-Json

            $data.psobject.properties | ForEach-Object {
                $table = $_.name
                Write-Host "defining $table" -fore green
                Write-Host "processing $($_.value.count) items" -fore green
                $props = $_.value[0].psobject.properties.name
                New-MySQLiteDBTable -Connection $conn -TableName $_.name -ColumnNames $props -Force -KeepAlive
                $_.value | ForEach-Object {
                    $q = buildquery -InputObject $_ -TableName $table
                    Write-Host $q -ForegroundColor green
                    Invoke-MySQLiteQuery -Query $q -Connection $conn -KeepAlive
                } #foreach value
            } #foreach data object property
            if ($passthru) {
                Get-Item -path $Destination
            }
        } #if state is open
        elseif (-Not $WhatIfPreference) {
            Write-Warning "The database file $Destination is not open. Detected state $($conn.state)."
        }

    } #process

    End {
        if ($conn.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            Close-MySQLiteDB -Connection $conn
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Import-MySQLiteDB