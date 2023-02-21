Function ConvertTo-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("todb", 'ConvertTo-DB')]
    [OutputType("None")]
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
        [Parameter(HelpMessage = "Specify the column name to use as the primary key or index. Otherwise, the first detected property will be used.")]
        [string]$Primary,
        [Parameter(HelpMessage = "Enter a typename for your converted objects. If you don't specify one, it will be auto-detected.")]
        [ValidatePattern("^\w+$")]
        [string]$TypeName,
        [switch]$Append,
        [switch]$Force
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($MyInvocation.MyCommand)"
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
                PassThru    = $True
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
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Opening database $($db.fullname)"
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
                Write-Verbose "[$((Get-Date).TimeOfDay)] Adding object to the table"
                $iqParams.query = buildquery -InputObject $object -Tablename $TableName
                if ($PSCmdlet.ShouldProcess("object", "Add to table $TableName")) {
                    Invoke-MySQLiteQuery @iqParams
                }
            }
            else {
                # http://www.sqlitetutorial.net/sqlite-data-types/
                # https://www.sqlite.org/datatype3.html
                #convert types as necessary. Table types can be Text, Int, Real or Blob
                if ($PSCmdlet.ShouldProcess("PropertyMap", "Create Table")) {

                    $object.PSObject.properties |
                    ForEach-Object -Begin {
                        $prop = [ordered]@{}
                    } -Process {
                        $prop.Add($_.Name, "Text")
                    }
                    if ($Typename) {
                        $name = "propertymap_{0}" -f ($typename.tolower())
                    }
                    else {
                        $name = "propertymap_{0}" -f ($object.PSObject.typenames[0].replace(".", "_"))
                    }

                    Write-Verbose "[$((Get-Date).TimeOfDay)] $name"
                    $thash | Out-String | Write-Verbose
                    $newTblParams = @{
                        Connection       = $Connection
                        KeepAlive        = $True
                        TableName        = $Name
                        ColumnProperties = $prop
                    }

                    #create propertymap table
                    New-MySQLiteDBTable @newTblParams
                    Write-Verbose "[$((Get-Date).TimeOfDay)] PropertyMap table created"
                } #WhatIf propertyMap table

                #$names = $object.PSObject.properties.name -join ","
                $list = [System.Collections.Generic.list[string]]::new()
                foreach ($n in $Object.PSObject.properties.name) {
                    if ($n -match "^\S+\-\S+$") {
                        # write-host "REPLACE DASHED $n" -ForegroundColor RED
                        $n = "[{0}]" -f $matches[0]
                    }
                    #  Write-host "ADDING $n" -ForegroundColor CYAN
                    $list.add($n)
                }
                $names = $list -join ","
                $values = $object.PSObject.properties.TypeNameofValue -join "','"
                $iqParams.query = "Insert Into $Name ($names) values ('$values')"
                if ($PSCmdlet.ShouldProcess($query, "Run query: Insert Into $Name")) {
                    Invoke-MySQLiteQuery @iqParams
                }
                Write-Verbose "[$((Get-Date).TimeOfDay)] Creating object hashtable"
                #get the property names and types
                $properties = $object.PSObject.properties
                $thash = [ordered]@{}
                Foreach ($prop in $properties) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Detecting property type for $($prop.name) [$($prop.TypeNameOfValue)]"
                    Switch -Regex ($prop.TypeNameofValue) {
                        "Int32$" { $sqltype = "Int" }
                        "Int64$" { $sqltype = "Real" }
                        "^System.Double$" { $sqltype = "Real" }
                        "^System.DateTime" { $sqltype = "Text" }
                        "^System.String$" { $sqltype = "Text" }
                        "^System.Boolean$" { $sqltype = "Int" }
                        default {
                            $sqltype = "Blob"
                        }
                    } #switch

                    #handle names with dashes
                    if ($prop.name -match "^\S+\-\S+$") {
                        $n = $n = "[{0}]" -f $matches[0]
                    }
                    else {
                        $n = $prop.name
                    }
                    $thash.Add($n, $sqltype)
                } #foreach prop

                if ($PSCmdlet.ShouldProcess($TableName, "Create table")) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Creating table $TableName"
                    if ($PSBoundParameters.ContainsKey("Primary")) {
                        $newTblParams.Add("Primary", $Primary)
                    }
                    $newTblParams.ColumnProperties = $thash
                    $newtblParams.tablename = $TableName
                    New-MySQLiteDBTable @newTblParams
                }

                Write-Verbose "[$((Get-Date).TimeOfDay)] Inserting the first object into the table $TableName"
                #insert the first object into the new table
                $iqParams.query = buildquery -InputObject $object -Tablename $TableName

                if ($PSCmdlet.ShouldProcess("object", "Insert first object")) {
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
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"
    } #end

}
