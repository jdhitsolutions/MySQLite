
#region public functions

Function Convert-MySQLiteDB {
    [cmdletbinding()]
    [alias('Export-DB')]
    [outputtype("Object")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [alias("database", "fullname")]
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the table with data to import")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing database $Path "
        $file = resolvedb -Path $path
        if ($file.exists) {
            $connection = opendb -Path $file.path
        }
        else {
            Throw "Failed to find database file $($file.path)"
        }
        #verify table exists
        $tables = Get-mySQLiteTable -connection $connection -KeepAlive
        if ($tables.name -contains $tablename) {
            $query = "Select * from $tablename"
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Importing from table $Tablename"
            $raw = Invoke-mySQLiteQuery -connection $connection -Query $query -As object -KeepAlive
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($raw.count) items"

            #use propertymap table if it exists
            if ($tables.name -contains "PropertyMap") {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting property map"
                $map = Invoke-mySQLiteQuery -Connection $connection -Query "Select * from propertymap" -KeepAlive -as Hashtable
                foreach ($item in $raw) {
                    $tmpHash = [ordered]@{}
                    foreach ($key in $map.keys) {
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ...$key"
                        $name = $key
                        #if value of the raw object is byte[], assume it is an exported clixml file
                        if ($item.$key.gettype().name -eq 'Byte[]') {
                            $v = frombytes $item.$key
                        }
                        else {
                            $v = $item.$key
                        }
                        $value = $v -as $($($map[$key] -as [type]))
                        $tmpHash.Add($name,$value)
                    }
                    New-Object -typename PSObject -property $tmpHash
                }
            }
            else {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Writing raw objects to the pipeline"
                $raw
            }
        }
        else {
            Write-Warning "Failed to find a table called $Tablename in $($file.path)"
        }

    } #process

    End {
        closedb $connection
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Convert-MySQLiteDB

Function Get-mySQLiteTable {
    [cmdletbinding(DefaultParameterSetName = "file")]
    [Alias("gtb", "Get-DBTable")]
    [outputtype("PSCustomObject")]

    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName, ParameterSetName = "file")]
        [ValidateNotNullOrEmpty()]
        [alias("database", "fullname")]
        [string]$Path,
        [Parameter(Position = 0, HelpMessage = "Specify an existing open database connection.", ParameterSetName = "connection")]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(HelpMessage = "Do not close the connection.", ParameterSetName = "connection")]
        [switch]$KeepAlive
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        if ($pscmdlet.ParameterSetName -eq 'file') {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting tables from $Path"
            $db = resolvedb -Path $path
            if ($db.exists) {
                Invoke-mySQLiteQuery -Path $db.path -query "Select Name from sqlite_master where type='table'"
            }
            else {
                Write-Warning "Failed to find $($db.path)"
            }
        } #if file parameter set
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using an existing connection $($connection.ConnectionString)"
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] KeepAlive is $KeepAlive"
            Invoke-mySQLiteQuery -connection $Connection -query "Select Name from sqlite_master where type='table'" -KeepAlive:$KeepAlive
        }
    } #process

    End {
        if ($connection -AND (-Not $KeepAlive)) {
            closedb -connection $connection
        }

        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-mySQLiteTable

Function ConvertTo-mySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("todb", 'Convert-DB')]
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
                        "Int32$"            {$sqltype = "Int" }
                        "Int64$"            {$sqltype = "Real"}
                        "^System.Double$"   {$sqltype = "Real"}
                        "^System.DateTime"  {$sqltype = "Text"}
                        "^System.String$"   {$sqltype = "Text"}
                        "^System.Boolean$"  {$sqltype = "Text"}
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

} #close Convert-mySQLiteDB

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

                $ds = New-Object System.Data.DataSet
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
                    $cols = $keys | Select-Object -skip 1
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
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "file")]
    [alias("iq")]
    [outputtype("None", "PSCustomObject", "System.Data.Datatable")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ParameterSetName = "file", ValueFromPipelineByPropertyName)]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Position = 0, HelpMessage = "Specify an existing open database connection.", ParameterSetName = "connection")]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(Position = 1, Mandatory, HelpMessage = "Enter a SQL query string")]
        [string]$Query,
        [Parameter(HelpMessage = "Keep the connection alive.",ParameterSetName = "connection")]
        [switch]$KeepAlive,
        [Parameter(HelpMessage = "Write the results of a Select query in the specified format")]
        [ValidateSet("Object","Datatable","Hashtable")]
        [string]$As = "object"
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"

    } #begin
    Process {
        if ($pscmdlet.ParameterSetName -eq 'file') {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using file $path"
            $file = resolvedb -path $path

            If ($file.exists) {
                $connection = opendb -Path $path
            }
            else {
                Write-Warning "Cannot find the database file $path."
            }
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using existing connection $($connection.ConnectionString)"
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] KeepAlive is $KeepAlive"
        }

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
        if ($connection.state -eq 'Open' -OR $PSBoundparameters.ContainsKey("WhatIf")) {

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = $query

            if ($pscmdlet.ShouldProcess($query)) {
                #determine what method to invoke based on the query
                Switch -regex ($query) {
                    "^Select (\w+|\*)|(@@\w+ AS)" {
                        if ($As -eq "datatable") {
                            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Datatable"
                            $ds = New-Object System.Data.DataSet
                            $da = New-Object System.Data.SQLite.SQLiteDataAdapter($cmd)
                            [void]$da.fill($ds)
                            $ds.Tables
                        }
                        else {
                            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] ExecuteReader"
                            $reader = $cmd.executereader()
                            #convert datarows to a custom object
                            while ($reader.read()) {

                                $h = [ordered]@{}
                                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                                    $col = $reader.getname($i)

                                    $h.add($col, $reader.getvalue($i))
                                } #for

                                if ($as -eq "hashtable") {
                                    $h
                                }
                                else {
                                    New-Object -TypeName psobject -Property $h
                                }

                            } #while

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
        #if the connection was passed as a parameter, do not close it. The generating command is responsible
        if ( (($connection.state -eq 'Open') -AND ($pscmdlet.ParameterSetName -eq 'file')) -OR (($connection.state -eq 'Open') -AND (-Not $KeepAlive)) ) {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            closedb -connection $connection -cmd $cmd
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end
} #close invoke-mysqlitequery

#endregion