Function Import-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = 'The path to the exported JSON file'
        )]
        [ValidatePattern('\.json$')]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter(
            Position = 1,
            Mandatory,
            HelpMessage = 'The destination path for the imported database file'
        )]
        [ValidatePattern('\.db$')]
        [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [string]$Destination,

        [Parameter(HelpMessage = 'Overwrite the destination file if it exists.')]
        [switch]$Force,

        [Parameter(HelpMessage = 'Use an existing database file.')]
        [Alias('Append')]
        [Switch]$UseExisting,

        [switch]$PassThru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
        }
    } #begin

    Process {
        $Path = Convert-Path -Path $Path
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] $Importing database data from $Path "
        if (-Not $UseExisting -AND $PSCmdlet.ShouldProcess($Destination, 'Creating database file')) {
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
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($data.Tables.count) tables to import"
            #July 18 2023 Do not import system tables
            # $data.PSObject.properties | Where {$_.Name -ne 'sqlite_sequence'} | ForEach-Object {
            $data.Tables | where { $_.Name -ne 'sqlite_sequence' } | ForEach-Object {
                $table = $_.name
                #recreate metadata from the import if found
                If ($table -eq 'metadata' -AND (-Not $UseExisting)) {
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Dropping and re-importing metadata"
                    $query = 'DROP TABLE metadata'
                    Invoke-MySQLiteQuery -Query $query -Connection $conn -KeepAlive -ErrorAction Stop
                }
                #recreate the table if not using an existing database
                if (-Not $UseExisting) {
                    #Get primary key
                    $pk = $_.schema | Where-Object { $_.pk -eq 1 }
                    $query = @"
CREATE TABLE "$($table)" (
 $(
     ($_.schema | ForEach-Object {
         if ([bool]$_.notNull) {
             $notNull = 'NOT NULL'
         } else {
             $notNull = ''
         }
         if ($_.dflt_value) {
             $default = "DEFAULT $($_.dflt_value)"
         } else {
             $default = ''
         }
         ('{0} {1} {2} {3}' -f $_.name, $_.type,$notNull,$default).Trim()
     }) -join ','
 )
$(
 if ($pk) {
     ",PRIMARY KEY(""$($pk.name)"")"
 } else {
     ''
 }
)
)
"@
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Creating table $table"
                    Write-Verbose $query
                    Invoke-MySQLiteQuery -Query $query -Connection $conn -KeepAlive -ErrorAction Stop
                }
                else {
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Using existing table $table"
                }
                #July 18 2023 skip empty tables
                if ($_.data) {
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Importing data for $table"
                    <#
                    $props = $_.value[0].PSObject.properties.name
                    Write-Verbose "$((Get-Date).TimeOfDay) PROCESS] Processing $($_.value.count) items"
                    New-MySQLiteDBTable -Connection $conn -TableName $_.name -ColumnNames $props -Force -KeepAlive
                    $_.value | ForEach-Object {
                        $q = buildquery -InputObject $_ -TableName $table
                        Write-Verbose $q
                        Invoke-MySQLiteQuery -Query $q -Connection $conn -KeepAlive
                    } #foreach data item
                    #>

                    #skip metadata and propertymaps if appending
                    if ($table -match 'metadata|propertymap' -and $UseExisting) {
                        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Skipping metadata import"
                    }
                    Else {
                        $_.data | ForEach-Object {
                            $q = buildquery -InputObject $_ -TableName $table
                            Write-Verbose $q
                            Invoke-MySQLiteQuery -Query $q -Connection $conn -KeepAlive -ErrorAction Stop
                            Clear-Variable -Name q
                        }
                    } #foreach data item
                }
                else {
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] No data found for $table"
                }
            } #foreach data object property
            if ($PassThru) {
                Get-Item -Path $Destination
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