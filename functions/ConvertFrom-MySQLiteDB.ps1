Function ConvertFrom-MySQLiteDB {
    [cmdletbinding(DefaultParameterSetName = "table")]
    [alias('ConvertFrom-DB')]
    [OutputType("Object")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the path to the SQLite database file.",
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [alias("database", "fullname")]
        [string]$Path,
        [Parameter(
            Mandatory,
            HelpMessage = "Enter the name of the table with data to import"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$TableName,
        [Parameter(
            Mandatory,
            HelpMessage = "Enter the name of the property map table",
            ParameterSetName = "table"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyTable,
        [Parameter(
            Mandatory,
            HelpMessage = "Enter an optional hashtable of property names and types.",
            ParameterSetName = "hash"
        )]
        [hashtable]$PropertyMap,
        [Parameter(
            HelpMessage = "Enter a typename to insert",
            ParameterSetName = "hash"
        )]
        [Parameter(ParameterSetName = "table")]
        [string]$TypeName,
        [Parameter(
            HelpMessage = "Write raw objects to the pipeline.",
            ParameterSetName = "raw"
        )]
        [switch]$RawObject
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Using path $Path "
        $file = resolvedb -Path $path
        if ($file.exists) {
            $connection = opendb -Path $file.path
        }
        else {
            Throw "Failed to find database file $($file.path)"
        }
        #verify table exists
        Write-Verbose "[$((Get-Date).TimeOfDay)] Verify table $TableName"
        $tables = Get-MySQLiteTable -Connection $connection -KeepAlive
        if ($tables.name -contains $TableName) {
            $query = "Select * from $TableName"
            Write-Verbose "[$((Get-Date).TimeOfDay)] Found $TableName"
            Try {
                [array]$raw = Invoke-MySQLiteQuery -Connection $connection -Query $query -As object -KeepAlive -ErrorAction stop
            }
            Catch {
                Write-Warning $_.exception.message
                closedb $connection
                Throw $_
                #bail out
                return
            }
            Write-Verbose "[$((Get-Date).TimeOfDay)] Found $($raw.count) item(s)"

            <#
                find a mapping table using this priority list
                1. PropertyMap parameter
                2. A table called PropertyMap_TableName

                if nothing found then write a default custom object
            #>
            switch ($PSCmdlet.ParameterSetName) {
                "hash" {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] User specified property map"
                    $map = $PropertyMap
                    If ($TypeName) {
                        $oTypename = $TypeName
                    }
                }
                "table" {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Using property table $PropertyTable"
                    $map = Invoke-MySQLiteQuery -Connection $connection -Query "Select * from $PropertyTable" -KeepAlive -As Hashtable
                    if ($typename) {
                        $oTypename = $TypeName
                    }
                    elseif ($PropertyTable -match "_") {
                        #get the typename from the property table name
                        $oTypename = $PropertyTable.split("_", 2)[1].replace("_", ".")
                    }
                }
                "raw" {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Writing raw objects to the pipeline"
                    $raw
                }
            }

            if ($map) {
                #$global:m = $map
                #$global:raw = $raw
                foreach ($item in $raw) {
                    # used for testing and development
                    # $global:it =$item
                    $tmpHash = [ordered]@{}

                    foreach ($key in $map.keys) {
                        Write-Verbose "[$((Get-Date).TimeOfDay)] Adding key $key [$($item.$key.GetType().name)]"
                        Write-Verbose "[$((Get-Date).TimeOfDay)] Using type $($map[$key])"
                        $name = $key
                        if ($null -eq $item.$key) {
                            Write-Verbose "[$((Get-Date).TimeOfDay)] $name is null"
                            $value = $null
                        }
                        elseif ($item.$key.GetType().name -eq 'Byte[]') {
                            #if value of the raw object is byte[], assume it is an exported clixml file
                            #the imported cliXML should have the correct type information
                            $value = frombytes $item.$key
                        }
                        else {
                            $v = $item.$key
                            $value = $v -as $($($map[$key] -as [type]))
                        }
                        $tmpHash.Add($name, $value)
                    } #foreach key

                    $no = New-Object -TypeName PSObject -Property $tmpHash
                    #9/12/2022 Insert the typename directly - JDH
                    if ($oTypename) {
                        Write-Verbose "[$((Get-Date).TimeOfDay)] Adding typename $oTypename"
                        $no.PSObject.TypeNames.Insert(0,$oTypename)
                    }
                    $no
                } #foreach item
            } #if $map
        } #if table found
        else {
            Write-Warning "Failed to find a table called $TableName $($file.path)"
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Closing database connection"
        closedb -connection $connection
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"
    } #end
}
