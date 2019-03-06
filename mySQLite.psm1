

Add-Type -Path $PSScriptRoot\assembly\system.data.sqlite.dll
<#
if ($PSEdition -eq 'Desktop') {
    Add-Type -Path $PSScriptRoot\assembly\windows\system.data.sqlite.dll
}
else {
    Add-Type -Path $PSScriptRoot\assembly\core\system.data.sqlite.dll
}
 #>
Function New-mySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("New-DB")]
    [outputtype("None", "System.IO.Fileinfo")]
    Param(
        [Parameter(Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [ValidateNotNullOrEmpty()]
        [alias("database")]
        [string]$Path,
        [switch]$Force,
        [Parameter(HelpMessage = "Enter a comment to be inserted into the database's metadata table")]
        [string]$Comment,
        #write the database file to the pipeline
        [switch]$Passthru
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
        #resolve or convert path into a full filesystem path
        $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)
        If ((Test-Path -Path $path) -AND (-not $Force)) {
            Write-Warning "The database file $path exists. Use -Force to overwrite the file."
        }
        else {
            If ((Test-Path $path) -AND $Force) {
                Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Removing previous database at $Path"
                Remove-Item -Path $path
            }
            $ConnectionString = "Data Source=$Path;Version=3"
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Using connection string: $ConnectionString"
            $connection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
            if ($pscmdlet.ShouldProcess($Path, "Open Database")) {
                $connection.Open()
            }

            #This data will be inserted into a new Metadata table
            $meta = @{
                Author   = "$([System.Environment]::UserDomainName)\$([System.Environment]::userName)"
                Created  = (Get-Date -format "yyyy-MM-dd hh:mm:ss.sss")
                Computer = [system.Environment]::machinename
                Comment  = $Comment
            }
        }
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing new database: $Path"
        if ($connection.state -eq 'Open' -OR $PSBoundparameters.ContainsKey("WhatIf")) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding Metadata table"

            [string]$query = "CREATE TABLE Metadata (Author TEXT,Created TEXT,Computername TEXT,Comment TEXT);"

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = $query
            if ($pscmdlet.ShouldProcess($query)) {
                [void]$cmd.ExecuteNonQuery()
            }

            $query = "Insert Into Metadata (Author,Created,Computername,Comment) Values ('$($meta.author)','$($meta.created)','$($meta.computer)','$($meta.comment)')"

            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
            $cmd.CommandText = $query
            if ($pscmdlet.ShouldProcess($query)) {
                [void]$cmd.ExecuteNonQuery()
            }
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] There is no open database connection"
        }
    } #process
    End {
        if ($connection.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            $connection.close()
            $connection.Dispose()
        }
        if ($Passthru -AND (Test-Path $Path)) {
            Get-Item -path $path
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

}

Function New-mySQLiteDBTable {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("New-DBTable")]
    [outputtype("None")]
    Param(
        [Parameter(Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [Alias("fullname","database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the new table. Table names are technically case-sensitive.")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,
        [parameter(Mandatory, HelpMessage = "Enter an ordered hashtable of column definitions")]
        [System.Collections.Specialized.OrderedDictionary]$TableProperties,
        [Parameter(HelpMessage = "Overwrite an existing table. This could result in data loss.")]
        [switch]$Force
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
        #resolve or convert path into a full filesystem path
        $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)

        If (Test-Path -Path $path) {
            $ConnectionString = "Data Source=$Path;Version=3"
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Using connection string: $ConnectionString"
            $connection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
            $connection.Open()
        }
        else {
            Write-Warning "Cannot find the database file $path exists"
        }
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing new database: $Path"
        if ($connection.state -eq 'Open' -OR $PSBoundparameters.ContainsKey("WhatIf")) {

            $cmd = $connection.CreateCommand()
            #test if table already exists
            if (-not $Force) {
                $cmd.CommandText = "SELECT name FROM sqlite_master WHERE type='table' AND name='$Tablename' COLLATE NOCASE;"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Testing for table $Tablename"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $($cmd.CommandText)"

                $ds = New-Object system.Data.DataSet
                $da = New-Object System.Data.SQLite.SQLiteDataAdapter($cmd)
                [void]$da.fill($ds)

                if ($ds.Tables.rows.name -contains $Tablename) {
                    Write-Warning "The table $Tablename already exists. Use -Force to overwrite it."
                    $tableFree = $False
                }
            } #if -not -Force
            else {
                #drop the table
                $query = "DROP TABLE IF EXISTS $Tablename;"
                $cmd.CommandText = $query
                if ($pscmdlet.ShouldProcess($query)) {
                    [void]$cmd.ExecuteNonQuery()
                }
                $tablefree = $True
            }

            If ($TableFree ) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding Table: $Tablename"
                [string]$query = "CREATE TABLE $tablename "

                $keys = $tableproperties.Keys
                $primary = $keys | Select-Object -first 1`
                $primaryType = $tableproperties.item($Primary)
                $cols = $keys | Select-object -skip 1
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Setting Primary Key: $primary <$PrimaryType>"
                $query += "($Primary $PrimaryType PRIMARY KEY"
                foreach ($col in $cols) {
                    $colType = $tableproperties.item($col)
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding column $col <$colType>"
                    $query += ",$col $coltype"
                }
                $query += ");"

                $cmd = $connection.CreateCommand()
                $cmd.CommandText = $query
                if ($pscmdlet.ShouldProcess($query)) {
                    [void]$cmd.ExecuteNonQuery()
                }
            }
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] There is no open database connection"

        }
    } #process
    End {
        if ($connection.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            $connection.close()
            $connection.Dispose()
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

}

Function Invoke-mySQLiteQuery {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iq")]
    [outputtype("None", "PSCustomObject")]
    Param(
        [Parameter(Position = 0,Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [Alias("fullname","database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Position = 1,Mandatory, HelpMessage = "Enter a SQL query string")]
        [string]$Query
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
        #resolve or convert path into a full filesystem path
        $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)

        If (Test-Path -Path $path) {
            $ConnectionString = "Data Source=$Path;Version=3"
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Using connection string: $ConnectionString"
            $connection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
            $connection.Open()
        }
        else {
            Write-Warning "Cannot find the database file $path exists"
        }

    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
        if ($connection.state -eq 'Open' -OR $PSBoundparameters.ContainsKey("WhatIf")) {

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = $query

            if ($pscmdlet.ShouldProcess($query)) {
                #determine what method to invoke based on the query
                Switch -regex ($query) {
                    "^Select (\w+|\*)|(@@\w+ AS)" {
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ExecuteReader"
                        $reader = $cmd.executereader()
                        $out = @()
                        #convert datarows to a custom object
                        while ($reader.read()) {

                            $h = [ordered]@{}
                            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                                $col = $reader.getname($i)

                                $h.add($col, $reader.getvalue($i))
                            } #for
                            $out += New-Object -TypeName psobject -Property $h
                        } #while

                        $out
                        $reader.close()
                        Break
                    }
                    "@@" {
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ExecuteScalar"
                        [void]$cmd.ExecuteScalar()
                        Break
                    }
                    Default {
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ExecuteNonQuery"
                        #modify query to use Transactions
                        $Revised = "BEGIN TRANSACTION;$($cmd.CommandText);COMMIT;"
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using Transactions: $Revised"
                        $cmd.CommandText = $revised
                        [void]$cmd.ExecuteNonQuery()
                        Break
                    }
                } #switch
            } #if Whatif
        }
    } #process
    End {
        if ($connection.state -eq 'Open') {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            $cmd.Dispose()
            $connection.close()
            $connection.Dispose()
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

}

