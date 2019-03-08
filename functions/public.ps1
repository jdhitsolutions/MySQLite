
#region public functions

Function Get-mySQLiteTable {
    [cmdletbinding()]
    [Alias("gtb", "Get-DBTable")]
    [outputtype("PSCustomObject")]

    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [ValidateNotNullOrEmpty()]
        [alias("database")]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting tables from $Path"
        $db = resolvedb -Path $path
        if ($db.exists) {
            Invoke-mySQLiteQuery -Path $db.path -query "Select Name from sqlite_master where type='table'"
        }
        else {
            Write-Warning "Failed to find $($db.path)"
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-mySQLiteTable

Function Export-mySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("todb",'Export-DB')]
    [outputtype("None")]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "What object do you want to create")]
        [object[]]$Inputobject,
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [ValidateNotNullOrEmpty()]
        [alias("database")]
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the new table. Table names are technically case-sensitive.")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,
        [switch]$Append
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

        if ($Append) {
            $file = resolvedb -Path $path
            if ($file.exists) {
                $db = opendb -Path $file.path
            }
            else {
                Throw "Failed to find database file $($file.path)"
            }
        }
        else {
            $newParams = @{
                Path     = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)
                Force    = $True
                Passthru = $True
            }
            Try {
                if ($PSCmdlet.ShouldProcess($Path, "Create Database")) {
                    $db = New-mySQLiteDB @newParams
                    Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Created database at $($db.fullname)"
                }
            }
            Catch {
                Throw $_
            }
        }

    } #begin

    Process {

        foreach ($object in $Inputobject) {

            if ($TableExists) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding object to the table"
                $query = buildquery -InputObject $object -Tablename $TableName
                if ($pscmdlet.ShouldProcess("object", "Add to table $Tablename")) {
                    Invoke-mySQLiteQuery -Path $Path -Query $query
                }
            }
            else {
                # http://www.sqlitetutorial.net/sqlite-data-types/
                #convert types as necessary. Table types can be Text, Int, Real or Blob
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating property map table"
                if ($PSCmdlet.ShouldProcess("PropertyMap", "Create Table")) {
                    New-mySQLiteDBTable -Path $path -TableName PropertyMap -ColumnNames $object.psobject.properties.name
                }
                $names = $object.psobject.properties.name -join ","
                $values = $object.psobject.properties.TypeNameofValue -join "','"
                $query = "Insert Into PropertyMap ($names) values ('$values')"
                if ($PSCmdlet.ShouldProcess($query, "Run query")) {
                    Invoke-mySQLiteQuery -Path $Path -Query $query
                }

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating property hashtable"
                #get the property names and types
                $properties = $object.psobject.properties
                $thash = [ordered]@{}
                Foreach ($prop in $properties) {
                    Switch -Regex ($prop.TypeNameofValue) {
                        "Int32$" { $sqltype = "Int" }
                        "Int64$" {$sqltype = "Real"}
                        "^System.Double$" { $sqltype = "Real"}
                        "^System.DateTime" {$sqltype = "Text"}
                        "^System.String$" {$sqltype = "Text"}
                        "^System.Boolean$" {$sqltype = "Text"}
                        default {
                            $sqltype = "Blob"
                        }
                    } #switch
                    $thash.Add($prop.Name, $sqltype)
                } #foreach prop
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating table: $Tablename"
                if ($pscmdlet.ShouldProcess($tablename, "Create table")) {
                    New-mySQLiteDBTable -Path $path -TableName $TableName -columnProperties $thash
                }

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Inserting the first object into the table"
                #insert the first object into the new table
                $query = buildquery -InputObject $object -Tablename $TableName

                if ($pscmdlet.ShouldProcess("object", "Insert first object")) {
                    Invoke-mySQLiteQuery -Path $Path -Query $query
                }
                $TableExists = $True
            }
        } #foreach object
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Export-mySQLiteDB

Function New-mySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("New-DB", "ndb")]
    [outputtype("None", "System.IO.Fileinfo")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
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

        $db = resolvedb $Path

        If (($db.exists) -AND (-not $Force)) {
            Write-Warning "The database file $path exists. Use -Force to overwrite the file."
        }
        else {
            If (($db.exists) -AND $Force) {
                Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Removing previous database at $($db.path)"
                Remove-Item -Path $db.path
            }

            if ($pscmdlet.ShouldProcess($Path, "Open Database")) {
                $connection = opendb $db.path
            }

            #This data will be inserted into a new Metadata table
            $meta = @{
                Author   = "$([System.Environment]::UserDomainName)\$([System.Environment]::userName)"
                Created  = (Get-Date).ToString() #(Get-Date -format "yyyy-MM-dd hh:mm:ss.sss")
                Computer = [system.Environment]::machinename
                Comment  = $Comment
            }
        }
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing new database: $($db.Path)"
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
        if ($Passthru -AND (Test-Path $db.path)) {
            Get-Item -path $db.path
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #new-mysqlitedb

Function New-mySQLiteDBTable {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "typed")]
    [alias("New-DBTable", "ndbt")]
    [outputtype("None")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the new table. Table names are technically case-sensitive.")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,
        [parameter(Mandatory, HelpMessage = "Enter an ordered hashtable of column definitions", ParameterSetName = "typed")]
        [System.Collections.Specialized.OrderedDictionary]$ColumnProperties,
        [parameter(Mandatory, HelpMessage = "Enter an array of column names.", ParameterSetName = "untyped")]
        [string[]]$ColumnNames,
        [Parameter(HelpMessage = "Overwrite an existing table. This could result in data loss.")]
        [switch]$Force
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
    } #begin
    Process {
        $db = resolvedb -path $Path

        If ($db.exists) {
            $connection = opendb $db.path
        }
        else {
            Write-Warning "Cannot find the database file $($db.path)."
        }
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing database: $($db.Path)"
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
                else {
                    $TableFree = $True
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

                if ($pscmdlet.ParameterSetName -eq 'typed') {
                    $keys = $ColumnProperties.Keys
                    $primary = $keys | Select-Object -first 1`
                    $primaryType = $ColumnProperties.item($Primary)
                    $cols = $keys | Select-object -skip 1
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Setting Primary Key: $primary <$PrimaryType>"
                    $query += "($Primary $PrimaryType PRIMARY KEY"
                    foreach ($col in $cols) {
                        $colType = $ColumnProperties.item($col)
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding column $col <$($coltype)>"
                        $query += ",$col $coltype"
                    }
                    $query += ");"
                }
                else {
                    $keys = $ColumnNames -join ","
                    $query += "($($keys))"
                }

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
} #new-mysqlitedbtable

Function Invoke-mySQLiteQuery {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iq")]
    [outputtype("None", "PSCustomObject", "System.Data.Datatable")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.")]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Position = 1, Mandatory, HelpMessage = "Enter a SQL query string")]
        [string]$Query,
        [Parameter(HelpMessage = "Write the results of a Select query as a System.Data.Datatable")]
        [switch]$AsDataTable
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
        #resolve or convert path into a full filesystem path
        $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)

        If (Test-Path -Path $path) {
            $connection = opendb -Path $path
        }
        else {
            Write-Warning "Cannot find the database file $path."
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
                        if ($AsDataTable) {
                            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Datatable"
                            $ds = New-Object System.Data.DataSet
                            $da = New-Object System.Data.SQLite.SQLiteDataAdapter($cmd)
                            $da.fill($ds)
                            $ds.Tables
                        }
                        else {
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
                        }
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
} #close invoke-mysqlitequery

#endregion