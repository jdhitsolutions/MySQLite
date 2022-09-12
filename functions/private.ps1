
#region Private functions
Function resolvedb {
    [cmdletbinding()]
    Param([string]$Path)

    Write-Verbose "[$((Get-Date).TimeOfDay)] ResolveDB Resolving $path"
    #resolve or convert path into a full filesystem path
    $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)
    [pscustomobject]@{
        Path   = $path
        Exists = Test-Path -Path $path
    }
    Write-Verbose "[$((Get-Date).TimeOfDay)] ResolveDB Resolved to $Path"
}
Function opendb {
    [cmdletbinding()]
    Param([string]$Path)

    $ConnectionString = "Data Source=$Path;Version=3"
    Write-Verbose "[$((Get-Date).TimeOfDay)] OpenDB Using connection string: $ConnectionString"
    $connection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
    $connection.Open()
    $connection
}


Function closedb {
    [cmdletbinding()]
    Param(
        [System.Data.SQLite.SQLiteConnection]$connection,
        [System.Data.SQLite.SQLiteCommand]$cmd
    )
    if ($connection.state -eq 'Open') {
        Write-Verbose "[$((Get-Date).TimeOfDay)] CloseDB Closing database connection"
        if ($cmd) {
            $cmd.Dispose()
        }
        $connection.close()
        $connection.Dispose()
    }
}
Function buildquery {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory)]
        [object]$InputObject,
        [parameter(Mandatory)]
        [string]$Tablename
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        #9/9/2022 Need to insert property names with a dash in []
        #this should fix Issue #14 JDH
        $list = [System.Collections.Generic.list[string]]::new()
        foreach ($n in $InputObject.psobject.properties.name) {
            if ($n -match "^\S+\-\S+$") {
             #   write-host "REPLACE DASHED $n" -ForegroundColor RED
                $n =   "[{0}]" -f $matches[0]
            }
           # Write-host "ADDING $n" -ForegroundColor CYAN
            $list.add($n)
        }
        $names = $list -join ","
        #$names = $InputObject.psobject.Properties.name -join ","

        $inputobject.psobject.Properties | ForEach-Object -Begin {
            $arr = [System.Collections.Generic.list[string]]::new()
        } -Process {
            if ($_.TypeNameofValue -match "String|Int\d{2}|Double|Datetime|Long") {
                #9/12/2022 need to escape values that might have single quote
                $v = $_.Value -replace "'","''"
                $arr.Add(@(, $v))
            }
            elseif ($_.TypeNameofValue -match "Boolean") {
                #turn Boolean into an INT
                $arr.Add(@(, ($_.value -as [int])))
            }
            else {
                #only create an entry if there is a value
                if ($null -ne $_.value) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Creating cliXML for a blob"
                    #create a temporary cliXML file
                    $out = [system.io.path]::GetTempFileName()
                    #9/11/2022 This is a potential problem.
                    # https://stackoverflow.com/questions/27761453/how-to-properly-escape-single-quotes-in-sqlite-insert-statement-ios
                    $_.value | Export-Clixml -Path $out -Encoding UTF8 #-Depth 1
                    #for testing
                    # Copy-Item -path $out -Destination d:\temp\out.xml
                    $in = (Get-Content -Path $out -Encoding UTF8 -ReadCount 0 -Raw) -replace "'","''"
                    $arr.Add(@(, "$($in)"))
                    Remove-Item -Path $out
                }
                else {
                    $arr.Add("")
                }
            }
        }
        $values = $arr -join "','"
      #   If ($names.split(".").count -eq ($values -split "','").count) {
             "Insert Into $Tablename ($names) values ('$values')"
             #$global:q= "Insert Into $Tablename ($names) values ('$values')"
             #$global:n = $names
             #$global:v = $values
       #  }
        # else {
        #    Write-Warning "There is a mismatch between the number of column headings ($($names.split(".").count)) and values ($(($values -split "','").count))"
        # }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"

    } #end

} #close buildquery

Function OLD-buildquery {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory)]
        [object]$InputObject,
        [parameter(Mandatory)]
        [string]$Tablename
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        $names = $InputObject.psobject.Properties.name -join ","

        $inputobject.psobject.Properties | ForEach-Object -Begin { $arr = @() } -Process {
            if ($_.TypeNameofValue -match "String|Int\d{2}|Double|Datetime|long") {
                $arr += @(, $_.Value)
            }
            elseif ($_.TypeNameofValue -match "Boolean") {
                #turn Boolean into an INT
                $arr += @(, ($_.value -as [int]))
            }
            else {
                #only create an entry if there is a value
                if ($null -ne $_.value) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Creating cliXML for a blob"
                    #create a temporary cliXML file
                    $out = [system.io.path]::GetTempFileName()
                    $_.value | Export-Clixml -Path $out -Encoding UTF8
                    $in = Get-Content -Path $out -Encoding UTF8 -ReadCount 0 -Raw
                    $arr += @(, "$($in)")
                    Remove-Item -Path $out
                }
                else {
                    $arr += ""
                }
            }
        }
        $values = $arr -join "','"

        "Insert Into $Tablename ($names) values ('$values')"

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"

    } #end

} #close buildquery
Function frombytes {
    [cmdletbinding()]
    Param([byte[]]$Bytes)

    #only process if there are bytes
    # Issue #3 7/20/2022 JDH
    if ($bytes.count -gt 0) {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Converting from bytes to object"
        $tmpFile = [system.io.path]::GetTempFileName()
        [text.encoding]::UTF8.getstring($bytes) | Out-File -FilePath $tmpfile -Encoding utf8
        Import-Clixml -Path $tmpFile
        if (Test-Path $tmpfile) {
            Remove-Item $tmpFile
        }
    }
}
#endregion