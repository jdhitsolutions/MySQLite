
#region Private functions
function resolvedb {
    [cmdletbinding()]
    Param([string]$Path)

    #resolve or convert path into a full filesystem path
    $path = $executioncontext.sessionstate.path.GetUnresolvedProviderPathFromPSPath($path)
    [pscustomobject]@{
        Path   = $path
        Exists = Test-Path -path $path
    }
}
Function opendb {
    [cmdletbinding()]
    Param([string]$Path)

    $ConnectionString = "Data Source=$Path;Version=3"
    Write-Verbose "[$((Get-Date).TimeofDay) BEGIN] OpenDB Using connection string: $ConnectionString"
    $connection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
    $connection.Open()
    $connection
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
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        $names = $InputObject.psobject.Properties.name -join ","
        $inputobject.psobject.Properties | ForEach-Object -Begin { $arr = @()} -process {
            if ($_.TypeNameofValue -match "String|Int\d{2}|Double|Boolean|Datetime|long") {
                $arr += @(, $_.Value)
            }
            else {
                #create a temporary cliXML file
                $out = [system.io.path]::GetTempFileName()
                $_.value | Export-clixml -path $out -encoding UTF8
                $in = Get-Content -path $out -Encoding UTF8 -ReadCount 0 -raw
                $arr += @(, "$($in)")
                remove-item -path $out
            }
        }
        $values = $arr -join "','"

        "Insert Into $Tablename ($names) values ('$values')"

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close buildquery

#endregion