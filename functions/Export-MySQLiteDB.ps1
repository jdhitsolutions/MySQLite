

Function Export-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The path to the SQLite database file"
        )]
        [ValidatePattern("\.db$")]
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

        [switch]$Passthru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Opening a connection to $Path"
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
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting tables"
            $tables = (Get-MySQLiteTable -Connection $conn -KeepAlive -ErrorAction Stop).Name
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Exporting $Path"
            foreach ($table in $tables) {
                $query = "Select * from $table"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
                Try {
                    $data = Invoke-MySQLiteQuery -Query $query -Connection $conn -KeepAlive -ErrorAction Stop
                    $hash.add($table, $data)
                }
                Catch {
                    Write-Warning "There was an error invoking the last query."
                    Close-MySQLiteDB -Connection $conn
                    Throw $_
                }
            }
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Saving to $Destination"
            if ($PSCmdlet.ShouldProcess($Destination, "Export database $path")) {
                $hash | ConvertTo-Json -Depth 100 | Set-Content -Path $destination -Encoding utf8
                if ($passthru) {
                    Get-Item -Path $Destination
                }
            } #whatif
        }
    } #process

    End {
        if ($conn.state -eq 'open') {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection."
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Export-MySQLiteDB