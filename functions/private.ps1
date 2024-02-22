
#region Private functions
Function resolvedb {
    [cmdletbinding()]
    Param([string]$Path)

    Write-Verbose "[$((Get-Date).TimeOfDay)] ResolveDB Resolving $path"
    #resolve or convert path into a full filesystem path
    $path = $ExecutionContext.SessionState.path.GetUnresolvedProviderPathFromPSPath($path)
    [PSCustomObject]@{
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
        [string]$TableName
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Starting $($MyInvocation.MyCommand)"
    } #begin

    Process {
        #9/9/2022 Need to insert property names with a dash in []
        #this should fix Issue #14 JDH
        $list = [System.Collections.Generic.list[string]]::new()
        foreach ($n in $InputObject.PSObject.properties.name) {
            if ($n -match "^\S+\-\S+$") {
            #   write-host "REPLACE DASHED $n" -ForegroundColor RED
                $n =   "[{0}]" -f $matches[0]
            }
            # Write-host "ADDING $n" -ForegroundColor CYAN
            $list.add($n)
        }
        $names = $list -join ","
        #$names = $InputObject.PSObject.Properties.name -join ","

        $InputObject.PSObject.Properties | ForEach-Object -Begin {
            $arr = [System.Collections.Generic.list[string]]::new()
        } -Process {
            if ($_.TypeNameOfValue -match "String|Int\d{2}|Double|DateTime|Long") {
                #9/12/2022 need to escape values that might have single quote
                $v = $_.Value -replace "'","''"
                $arr.Add(@(, $v))
            }
            elseif ($_.TypeNameOfValue -match "Boolean") {
                #turn Boolean into an INT
                $arr.Add(@(, ($_.value -as [int])))
            }
            else {
                #only create an entry if there is a value
                if ($null -ne $_.value) {
                    Write-Verbose "[$((Get-Date).TimeOfDay)] Creating cliXML for a blob"
                    $in = ($_.value | ConvertTo-CliXml) -replace "'","''"
                    $arr.Add(@(, "$($in)"))
                }
                else {
                    $arr.Add("")
                }
            }
        }
        $values = $arr -join "','"
        #   If ($names.split(".").count -eq ($values -split "','").count) {
        "Insert Into $TableName ($names) values ('$values')"
        #$global:q= "Insert Into $TableName ($names) values ('$values')"
        #$global:n = $names
        #$global:v = $values
        #  }
        # else {
        #    Write-Warning "There is a mismatch between the number of column headings ($($names.split(".").count)) and values ($(($values -split "','").count))"
        # }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($MyInvocation.MyCommand)"

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
        [text.encoding]::UTF8.GetString($bytes) | Out-File -FilePath $tmpfile -Encoding utf8
        Import-Clixml -Path $tmpFile
        if (Test-Path $tmpfile) {
            Remove-Item $tmpFile
        }
    }
}

# cliXML functions added 20 Feb 2023 from Issue #16
# functions authored by https://github.com/SeSeKenny
function ConvertTo-CliXml {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Object
    )
    begin {
        $Objects=@()
    }
    process {
        $Objects+=$Object
    }
    end {
        if ($Objects.Count -eq 1) {$Objects=$Objects[0]}
        [System.Management.Automation.PSSerializer]::Serialize($Objects)
    }
}

function ConvertFrom-CliXml {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $Object
    )
    begin {
        $Objects=@()
    }
    process {
        $Objects+=$Object
    }
    end {
        [System.Management.Automation.PSSerializer]::Deserialize($Objects)
    }
}

#endregion
