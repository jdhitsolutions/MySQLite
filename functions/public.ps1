
#region public functions

Function Open-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Open-DB")]
    [OutputType("System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(Mandatory)]
        [alias("database")]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        $db = resolvedb $Path
        if ($db.exists) {
            if ($pscmdlet.shouldprocess($db.path)) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Opening connection to $Path "
                opendb $db.path
            }
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Open-MySQLiteDB

Function Close-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("Close-DB")]
    [OutputType("None", "System.Data.SQLite.SQLiteConnection")]

    Param(
        [Parameter(Mandatory, HelpMessage = "Enter a connection object", ValueFromPipeline)]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [switch]$Passthru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Closing connection to $($connection.DataSource)"
        if ($pscmdlet.ShouldProcess($Connection.DataSource)) {
            $connection.close()
            if ($passthru) {
                $connection
            }

            $connection.Dispose()
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Close-MySQLiteDB

Function ConvertFrom-MySQLiteDB {
    [cmdletbinding(DefaultParameterSetName = "table")]
    [alias('ConvertFrom-DB')]
    [outputtype("Object")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [alias("database", "fullname")]
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the table with data to import")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,
        [Parameter(Mandatory, HelpMessage = "Enter the name of the property map table", ParameterSetName = "table")]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyTable,
        [Parameter(Mandatory, HelpMessage = "Enter an optional hashtable of property names and types.", ParameterSetName = "hash")]
        [hashtable]$PropertyMap,
        [Parameter(HelpMessage = "Enter a typename to insert", ParameterSetName = "hash")]
        [Parameter(ParameterSetName = "table")]
        [string]$TypeName,
        [Parameter(HelpMessage = "Write raw objects to the pipeline.", ParameterSetName = "raw")]
        [switch]$RawObject
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
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Verifying table $tablename"
        $tables = Get-MySQLiteTable -connection $connection -KeepAlive
        if ($tables.name -contains $tablename) {
            $query = "Select * from $tablename"
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Importing from table $Tablename"
            Try {
                $raw = Invoke-MySQLiteQuery -connection $connection -Query $query -As object -KeepAlive -ErrorAction stop
            }
            Catch {
                Write-Warning $_.exception.message
                closedb $connection
                Throw $_
                #bail out
                return
            }
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($raw.count) items"

            <#
                find a mapping table using this priority list
                1. PropertyMap parameter
                2. A table called PropertyMap_tablename

                if nothing found then write a default custom object
            #>
            switch ($pscmdlet.ParameterSetName) {
                "hash" {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] User specified property map"
                    $map = $PropertyMap
                    If ($TypeName) {
                        $oTypename = $TypeName
                    }
                }
                "table" {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting property map from $PropertyTable"
                    $map = Invoke-MySQLiteQuery -Connection $connection -Query "Select * from $propertytable" -KeepAlive -as Hashtable
                    if ($typename) {
                        $oTypename = $TypeName
                    }
                    elseif ($PropertyTable -match "_") {
                        #get the typename from the property table name
                        $oTypename = $PropertyTable.split("_", 2)[1].replace("_", ".")
                    }

                }
                "raw" {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Writing raw objects to the pipeline"
                    $raw
                }
            }

            if ($map) {
                foreach ($item in $raw) {
                    $tmpHash = [ordered]@{}
                    if ($oTypename) {
                        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Inserting typename $oTypename"
                        $tmpHash.Add("PSTypename", $oTypename)
                    }
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
                        $tmpHash.Add($name, $value)
                    } #foreach key
                    New-Object -typename PSObject -property $tmpHash
                } #foreach item
            } #if $map
        } #if table found
        else {
            Write-Warning "Failed to find a table called $Tablename in $($file.path)"
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
        closedb -connection $connection
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close ConvertFrom-MySQLiteDB

Function Get-MySQLiteTable {
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
        [switch]$KeepAlive,
        [switch]$Detail
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        $iqParams = @{
            query = "Select Name from sqlite_master where type='table'"
        }
        if ($pscmdlet.ParameterSetName -eq 'file') {
            $db = resolvedb -Path $path
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting tables from $($db.Path)"
            if ($db.exists) {
                $iqParams.Add("Path", $db.path)
                $source = $db.path
            }
            else {
                Write-Warning "Failed to find $($db.path)"
            }
        } #if file parameter set
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using an existing connection $($connection.ConnectionString)"
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] KeepAlive is $KeepAlive"
            $iqParams.Add("Connection", $Connection)
            $iqParams.Add("KeepAlive", $KeepAlive)
            #parse out the path from the connection
            $source = $connection.ConnectionString.split("=", 2)[1].split(";")[0]

        }
        $tablenames = Invoke-MySQLiteQuery @iqParams
        if ($tablenames) {

            if ($Detail) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting table details"
                foreach ($item in $Tablenames.name) {
                    $iqParams.query = "PRAGMA table_info($item)"
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $($iqparams.query)"
                    $details = Invoke-MySQLiteQuery @iqParams
                    foreach ($tbl in $details) {
                        [pscustomobject]@{
                            PSTypename  = "MySQLiteTableDetail"
                            Source      = $Source
                            Table       = $item
                            ColumnIndex = $tbl.cid
                            ColumnName  = $tbl.name
                            ColumnType  = $tbl.type
                        }
                    } #foreach tbl
                } #foreach item
            }
            else {
                [pscustomobject]@{
                    Source = $source
                    Name   = $Tablenames.name
                }

            }
        }
        else {
            Write-Warning "No tables found in $source"
        }
    } #process

    End {
        if ($connection -AND (-Not $KeepAlive)) {
            closedb -connection $connection
        }

        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-MySQLiteTable

Function ConvertTo-MySQLiteDB {
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
        [Parameter(HelpMessage = "Enter a typename for your converted objects. If you don't specify one, it will be auto-detected.")]
        [ValidatePattern("^\w+$")]
        [string]$TypeName,
        [switch]$Append,
        [switch]$Force
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        $file = resolvedb -Path $path
        if ($Append) {
            if ($file.exists) {
                $connection = opendb -Path $file.path
            }
            else {
                Throw "Failed to find database file $($file.path)"
            }
        }
        else {
            $newParams = @{
                Path        = $file.path
                Force       = $Force
                Passthru    = $True
                ErrorAction = "Stop"
            }
            Try {
                if ($PSCmdlet.ShouldProcess($Path, "Create Database")) {
                    Try {
                        $db = New-MySQLiteDB @newParams
                    }
                    Catch {
                        Throw $_
                        #bail out
                        return
                    }
                    Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Created database at $($db.fullname)"
                    $connection = opendb $db.fullname
                }
            }
            Catch {
                Throw $_
            }
        }

    } #begin

    Process {
        $iqParams = @{
            Connection = $Connection
            KeepAlive  = $True
            Query      = $null
        }

        foreach ($object in $Inputobject) {

            if ($TableExists) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding object to the table"
                $iqParams.query = buildquery -InputObject $object -Tablename $TableName
                if ($pscmdlet.ShouldProcess("object", "Add to table $Tablename")) {
                    Invoke-MySQLiteQuery @iqParams
                }
            }
            else {
                # http://www.sqlitetutorial.net/sqlite-data-types/
                # https://www.sqlite.org/datatype3.html
                #convert types as necessary. Table types can be Text, Int, Real or Blob
                if ($PSCmdlet.ShouldProcess("PropertyMap", "Create Table")) {
                    $object.psobject.properties |
                        foreach-object -begin {
                        $prop = [ordered]@{}
                    } -process {
                        $prop.Add($_.Name, "Text")
                    }

                    if ($Typename) {
                        $name = "propertymap_{0}" -f ($typename.tolower())
                    }
                    else {
                        $name = "propertymap_{0}" -f ($object.psobject.typenames[0].replace(".", "_"))
                    }
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating property map table $name"
                    $prop | Out-String | Write-Verbose
                    $newTblParams = @{
                        Connection       = $Connection
                        KeepAlive        = $True
                        TableName        = $Name
                        ColumnProperties = $prop
                    }
                    New-MySQLiteDBTable @newTblParams
                }

                $names = $object.psobject.properties.name -join ","
                $values = $object.psobject.properties.TypeNameofValue -join "','"
                $iqParams.query = "Insert Into $Name ($names) values ('$values')"
                if ($PSCmdlet.ShouldProcess($query, "Run query")) {
                    Invoke-MySQLiteQuery @iqParams
                }

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating property hashtable"
                #get the property names and types
                $properties = $object.psobject.properties
                $thash = [ordered]@{}
                Foreach ($prop in $properties) {
                    Switch -Regex ($prop.TypeNameofValue) {
                        "Int32$" {$sqltype = "Int" }
                        "Int64$" {$sqltype = "Real"}
                        "^System.Double$" {$sqltype = "Real"}
                        "^System.DateTime" {$sqltype = "Text"}
                        "^System.String$" {$sqltype = "Text"}
                        "^System.Boolean$" {$sqltype = "Int"}
                        default {
                            $sqltype = "Blob"
                        }
                    } #switch
                    $thash.Add($prop.Name, $sqltype)
                } #foreach prop

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating table: $Tablename"
                if ($pscmdlet.ShouldProcess($tablename, "Create table")) {
                    $newTblParams.ColumnProperties = $thash
                    $newtblParams.tablename = $Tablename
                    New-MySQLiteDBTable @newtblParams
                }

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Inserting the first object into the table"
                #insert the first object into the new table
                $iqParams.query = buildquery -InputObject $object -Tablename $TableName

                if ($pscmdlet.ShouldProcess("object", "Insert first object")) {
                    Invoke-MySQLiteQuery @iqParams
                }
                $TableExists = $True
            }
        } #foreach object
    } #process

    End {
        if ($connection.State -eq "open") {
            closedb -connection $connection
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Convert-MySQLiteDB

Function New-MySQLiteDB {
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
            throw "The database file $path exists."
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

            if ($pscmdlet.ShouldProcess($query)) {
                $cmd = $connection.CreateCommand()
                $cmd.CommandText = $query
                [void]$cmd.ExecuteNonQuery()
            }

            $query = "Insert Into Metadata (Author,Created,Computername,Comment) Values ('$($meta.author)','$($meta.created)','$($meta.computer)','$($meta.comment)')"

            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
            if ($pscmdlet.ShouldProcess($query)) {
                $cmd.CommandText = $query
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

} #new-MySQLitedb

Function New-MySQLiteDBTable {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "filetyped")]
    [alias("New-DBTable", "ndbt")]
    [outputtype("None")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName, ParameterSetName = "filetyped")]
        [Parameter(ParameterSetName = "filenamed")]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(HelpMessage = "Specify an existing open database connection.", ParameterSetName = "cnxtyped")]
        [Parameter(ParameterSetName = "cnxnamed")]
        [ValidateNotNullOrEmpty()]
        [System.Data.SQLite.SQLiteConnection]$Connection,

        [Parameter(Mandatory, HelpMessage = "Enter the name of the new table. Table names are technically case-sensitive.")]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,

        [parameter( HelpMessage = "Enter an ordered hashtable of column definitions", ParameterSetName = "filetyped")]
        [Parameter(ParameterSetName = "cnxtyped")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Specialized.OrderedDictionary]$ColumnProperties,

        [parameter( HelpMessage = "Enter an array of column names.", ParameterSetName = "cnxnamed")]
        [Parameter(ParameterSetName = "filenamed")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ColumnNames,

        [Parameter(HelpMessage = "Overwrite an existing table. This could result in data loss.")]
        [switch]$Force,

        [Parameter(HelpMessage = "Keep an existing connection open.", ParameterSetName = "cnxtyped")]
        [Parameter(ParameterSetName = "cnxnamed")]
        [switch]$KeepAlive
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] Starting $($myinvocation.mycommand)"
    } #begin
    Process {

        if ($Path) {

            $db = resolvedb -path $Path

            If ($db.exists) {
                $connection = opendb $db.path
            }
            else {
                Write-Warning "Cannot find the database file $($db.path)."
            }
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing database: $($db.Path)"
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using an existing connection"
        }
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

                if ($pscmdlet.ParameterSetName -match 'typed') {
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
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $query"
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
        if ($connection.state -eq 'Open' -AND (-Not $KeepAlive)) {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            closedb -connection $connection -cmd $cmd
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end
} #new-MySQLitedbtable

Function Invoke-MySQLiteQuery {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = "file")]
    [alias("iq")]
    [outputtype("None", "PSCustomObject", "System.Data.Datatable", "Hashtable")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ParameterSetName = "file", ValueFromPipelineByPropertyName)]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Position = 0, HelpMessage = "Specify an existing open database connection.", ParameterSetName = "connection")]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(Position = 1, Mandatory, HelpMessage = "Enter a SQL query string")]
        [string]$Query,
        [Parameter(HelpMessage = "Keep the connection alive.", ParameterSetName = "connection")]
        [switch]$KeepAlive,
        [Parameter(HelpMessage = "Write the results of a Select query in the specified format")]
        [ValidateSet("Object", "Datatable", "Hashtable")]
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
                $connection = opendb -Path $file.path
            }
            else {
                Write-Warning "Cannot find the database file $file.path."
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
                    "^([Ss]elect (\w+|\*)|(@@\w+ AS))|([Pp]ragma \w+)" {
                        #   "^Select (\w+|\*)|(@@\w+ AS)" {
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
} #close invoke-MySQLitequery


Function Get-MySQLiteDB {
    [cmdletbinding()]
    [alias('Get-DB')]
    [OutputType('MySQLiteDB')]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the path to the SQLite database file.", ValueFromPipelineByPropertyName)]
        [Alias("fullname", "database")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {

        $file = resolvedb -path $path

        If ($file.exists) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting database information from $($file.path)"
            $thisdb = Get-Item -path $file.path

            $connection = opendb -Path $file.path

            $tables = Get-MySQLiteTable -Connection $connection -KeepAlive | Select-Object -ExpandProperty Name
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($tables.count) Tables"

            $pgsize = (Invoke-MySQLiteQuery -connection $connection -query "PRAGMA page_size" -KeepAlive ).page_size
            $pgcount = (Invoke-MySQLiteQuery -connection $connection -query "PRAGMA page_count" -KeepAlive ).page_count
            $encoding = (Invoke-MySQLiteQuery -connection $connection -query "PRAGMA encoding" -KeepAlive).encoding

            [pscustomobject]@{
                PSTypename    = "MySQLiteDB"
                DatabaseName  = $connection.Database
                Tables        = $tables
                PageSize      = $pgsize
                PageCount     = $pgcount
                Encoding      = $encoding
                FileName      = $thisdb.name
                Path          = $File.path
                Size          = $thisdb.length
                Created       = $thisdb.Creationtime
                Modified      = $thisdb.LastWriteTime
                Age           = (Get-Date) - $thisdb.LastWriteTime
                SQLiteVersion = $connection.serverversion
            }
        }
        else {
            Write-Warning "Cannot find the database file $path."
        }

    } #process

    End {
        if ($connection.open) {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Closing database connection"
            closedb -connection $connection
        }
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-MySQLiteDB

#endregion