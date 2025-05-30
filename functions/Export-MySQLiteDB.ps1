Function Export-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The path to the SQLite database file"
        )]
        [ValidatePattern("\.((sqlite(3)?)|(db(3)?)|(sl3)|(s3db))$")]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter(
            Mandatory,
            Position = 1,
            HelpMessage = "The destination path for the exported JSON file"
        )]
        [ValidatePattern("\.json$")]
        [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [string]$Destination,

        [switch]$PassThru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Opening a connection to $Path"
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
        }
        Try {
            #always open the database
            $conn = Open-MySQLiteDB -Path $path -ErrorAction Stop -WhatIf:$False
        }
        Catch {
            Throw $_
        }
    } #begin

    Process {
        if ($conn.state -eq 'open') {
            #initialize a hashtable
            $hash = @{}
            $tableInfo = @()
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting tables"
            $tables = (Get-MySQLiteTable -Connection $conn -KeepAlive -ErrorAction Stop).Name
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Exporting $Path"
            foreach ($table in $tables) {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting table schema"
                $schema =  Invoke-MySQLiteQuery -Query "pragma table_Info($table)" -Connection $conn -KeepAlive  |
                Select-Object -Property Name,Type,notnull,dflt_value,pk
                $query = "Select * from $table"
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] $query"
                Try {
                    $data = Invoke-MySQLiteQuery -Query $query -Connection $conn -KeepAlive -ErrorAction Stop
                    $details = [PSCustomObject]@{
                        Name = $table
                        Schema = $schema
                        Data = $data
                    }
                    $tableInfo += $details
                    #Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Adding $table to hashtable"
                    #$hash.add($table, $details)
                   # $hash.add($table, $data)
                }
                Catch {
                    Write-Warning "There was an error invoking the last query."
                    Close-MySQLiteDB -Connection $conn
                    Throw $_
                }
            }

            $hash.add('Tables', $tableInfo)
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Saving to $Destination"
            if ($PSCmdlet.ShouldProcess($Destination, "Export database $path")) {
                [PSCustomObject]$hash | ConvertTo-Json -Depth 100 | Set-Content -Path $destination -Encoding utf8
                if ($PassThru) {
                    Get-Item -Path $Destination
                }
            } #whatIf
        }
    } #process

    End {
        if ($conn.state -eq 'open') {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Closing database connection."
        }
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Export-MySQLiteDB