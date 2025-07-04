Function Invoke-MySQLiteQuery {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "file")]
    [alias("iq")]
    [OutputType("None", "PSCustomObject", "System.Data.Datatable", "Hashtable")]
    Param(
        [Parameter(
            Position = 1,
            Mandatory,
            HelpMessage = "Enter the path to the SQLite database file.",
            ParameterSetName = "file",
            ValueFromPipelineByPropertyName
        )]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            HelpMessage = "Specify an existing open database connection.",
            ParameterSetName = "connection"
        )]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter a SQL query string"
        )]
        [string]$Query,
        [Parameter(
            HelpMessage = "Keep the connection alive.",
            ParameterSetName = "connection"
        )]
        [switch]$KeepAlive,
        [Parameter(HelpMessage = "Write the results of a Select query in the specified format")]
        [ValidateSet("Object", "Datatable", "Hashtable")]
        [string]$As = "object"
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Detected culture $(Get-Culture)"
        }
        $exceptionDelegate = {
            param([System.Management.Automation.ErrorRecord]$errRecord)
            # if inner exception is System.Data.SQLite.SQLiteException (0x800007BF): SQL logic, help user by telling them what the error is
            if ($errRecord.Exception.InnerException -is [System.Data.SQLite.SQLiteException]) {
                $errTxt = $errRecord.Exception.InnerException.Message -split "`n"
                Write-Error $errTxt[0]
                $syntaxErr = $errTxt[1] | Select-String -Pattern '(?<=")[^"]+(?=")'
                if ($syntaxErr) {
                    $syntaxErr = $syntaxErr.Matches.Value
                    # highlight offending token
                    $query -replace ([regex]::Escape($syntaxErr)), "`e[7m`$0`e[0;93m" | Write-Error
                    # generate a pointer caret to the offending token
                    ' ' * $query.IndexOf($syntaxErr) + '^' | Write-Error
                }
                else {
                    Write-Error $errTxt[1]
                }
            }
            else {
                Write-Error $_.Exception.Message
            }
        }
    } #begin
    Process {
        if ($PSCmdlet.ParameterSetName -eq 'file') {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Using file $path"
            $file = resolvedb -path $path

            If ($file.exists) {
                $connection = opendb -Path $file.path
            }
            else {
                Write-Warning "Cannot find the database file: $($file.path)."
            }
        }
        else {
            if ($MyInvocation.CommandOrigin -eq 'Runspace') {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Using connection $($connection.ConnectionString)"
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] KeepAlive is $KeepAlive"
            }
        }

        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Invoke query '$query'"
        if ($connection.state -eq 'Open') {

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = $query

            #determine what method to invoke based on the query
            Switch -regex ($query) {
                "^([Ss]elect (\w+|\*)|(@@\w+ AS))|([Pp]ragma \w+)" {
                    #   "^Select (\w+|\*)|(@@\w+ AS)" {
                    if ($As -eq "datatable") {
                        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Datatable output"
                        $ds = New-Object System.Data.DataSet
                        $da = New-Object System.Data.SQLite.SQLiteDataAdapter($cmd)
                        [void]$da.fill($ds)
                        $ds.Tables
                    }
                    else {
                        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ExecuteReader"
                        try {
                            $reader = $cmd.ExecuteReader()
                        }
                        catch [System.Management.Automation.MethodInvocationException] {
                            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Caught MethodInvocationException"
                            $global:e = $_
                            #$exceptionDelegate.Invoke($_)
                            & $exceptionDelegate $_
                            return
                        }
                        #convert datarows to a custom object
                        while ($reader.read()) {
                            $h = [ordered]@{}
                            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                                $col = $reader.GetName($i)

                                $h.add($col, $reader.GetValue($i))
                            } #for

                            if ($as -eq "hashtable") {
                                $h
                            }
                            else {
                                New-Object -TypeName PSObject -Property $h
                            }
                        } #while

                        $reader.close()
                    }
                    Break
                }
                "@@" {
                    Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ExecuteScalar"
                    [void]$cmd.ExecuteScalar()
                    Break
                }
                Default {
                    if ($PSCmdlet.ShouldProcess($query)) {
                        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] ExecuteNonQuery"
                        #modify query to use Transactions
                        $Revised = "BEGIN TRANSACTION;$($cmd.CommandText);COMMIT;"
                        Write-Verbose "[$((Get-Date).TimeOfDay)] $Revised"
                        $cmd.CommandText = $revised
                        #$global:sqlcmd = $cmd
                        try {
                            [void]$cmd.ExecuteNonQuery()
                        }
                        catch [System.Management.Automation.MethodInvocationException] {
                            #$exceptionDelegate.Invoke($_)
                            & $exceptionDelegate $_
                        }
                        catch {
                            Write-Warning $_.Exception.message
                        }
                    }
                } #WhatIf
            } #switch
        }
    } #process
    End {
        #if the connection was passed as a parameter, do not close it. The generating command is responsible for managing the connection.
        if ( (($connection.state -eq 'Open') -AND ($PSCmdlet.ParameterSetName -eq 'file')) -OR (($connection.state -eq 'Open') -AND (-Not $KeepAlive)) ) {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Closing database connection"
            closedb -connection $connection -cmd $cmd
        }
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end
}
