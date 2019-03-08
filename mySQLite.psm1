

Add-Type -Path $PSScriptRoot\assembly\system.data.sqlite.dll

Get-ChildItem -path $psscriptroot\functions\*.ps1 |
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


