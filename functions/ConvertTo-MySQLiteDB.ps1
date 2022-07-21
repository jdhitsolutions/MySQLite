Function ConvertTo-MySQLiteDB {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("todb", 'ConvertTo-DB')]
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
        Write-Verbose "[$((Get-Date).TimeOfDay)] $($myinvocation.mycommand)"
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
                    ForEach-Object -Begin {
                        $prop = [ordered]@{}
                    } -Process {
                        $prop.Add($_.Name, "Text")
                    }

                    if ($Typename) {
                        $name = "propertymap_{0}" -f ($typename.tolower())
                    }
                    else {
                        $name = "propertymap_{0}" -f ($object.psobject.typenames[0].replace(".", "_"))
                    }
                    Write-Verbose "[$((Get-Date).TimeOfDay)] $name"
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

                Write-Verbose "[$((Get-Date).TimeOfDay)]  Creating property hashtable"
                #get the property names and types
                $properties = $object.psobject.properties
                $thash = [ordered]@{}
                Foreach ($prop in $properties) {
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
                    $thash.Add($prop.Name, $sqltype)
                } #foreach prop

                if ($pscmdlet.ShouldProcess($tablename, "Create table")) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Creating table $Tablename"
                    $newTblParams.ColumnProperties = $thash
                    $newtblParams.tablename = $Tablename
                    New-MySQLiteDBTable @newtblParams
                }

                Write-Verbose "[$((Get-Date).TimeOfDay)] Inserting the first object into the table"
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
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"
    } #end

}
