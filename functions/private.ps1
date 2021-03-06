
#region Private functions
Function resolvedb {
    [cmdletbinding()]
    Param([string]$Path)

    Write-Verbose "ResolveDB Resolving $path"
    #resolve or convert path into a full filesystem path
    $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)
    [pscustomobject]@{
        Path   = $path
        Exists = Test-Path -Path $path
    }
    Write-Verbose "ResolveDB Resolved to $Path"
}
Function opendb {
    [cmdletbinding()]
    Param([string]$Path)

    $ConnectionString = "Data Source=$Path;Version=3"
    Write-Verbose "OpenDB Using connection string: $ConnectionString"
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
        Write-Verbose "CloseDB Closing database connection"
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
        Write-Verbose "Starting $($myinvocation.mycommand)"

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
                if ($_.value -ne $null) {
                    Write-Verbose "Creating cliXML for a blob"
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
        Write-Verbose "Ending $($myinvocation.mycommand)"

    } #end

} #close buildquery

Function frombytes {
    [cmdletbinding()]
    Param([byte[]]$Bytes)

    Write-Verbose "Converting from bytes to object"
    $tmpFile = [system.io.path]::GetTempFileName()
    [text.encoding]::UTF8.getstring($bytes) | Out-File -FilePath $tmpfile -Encoding utf8
    Import-Clixml -Path $tmpFile
    if (Test-Path $tmpfile) {
        Remove-Item $tmpFile
    }
}
#endregion