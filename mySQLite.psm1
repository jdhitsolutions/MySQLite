
#todo: add Append option to Export-mySQLiteDB
#todo: create an Import-mySQLiteDB command

Add-Type -Path $PSScriptRoot\assembly\system.data.sqlite.dll

get-childitem $psscriptroot\functions\*.ps1 |
Foreach-Object {
    . $_.fullname
}

<#
if ($PSEdition -eq 'Desktop') {
    Add-Type -Path $PSScriptRoot\assembly\windows\system.data.sqlite.dll
}
else {
    Add-Type -Path $PSScriptRoot\assembly\core\system.data.sqlite.dll
}
 #>


