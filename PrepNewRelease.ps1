#requires -module ChangeLogManagement

#get module version from manifest
$moduleName = Split-Path $PSScriptRoot -Leaf
$data = Import-PowerShellDataFile .\$moduleName.psd1
$ver = $data.ModuleVersion

Write-Host "Building release for $moduleName version $ver. Has help been updated? Are you ready to continue?" -ForegroundColor Cyan
Pause
#FirstRelease="https://github.com/pluralsight/$moduleName/tree/v{CUR}";

Update-Changelog -ReleaseVersion $ver -LinkMode Automatic -LinkPattern @{
NormalRelease="https://github.com/jdhitsolutions/MySQLite/compare/v{PREV}..v{CUR}";
Unreleased ="https://github.com/jdhitsolutions/MySQLite/compare/v{CUR}..HEAD"
}

#verify and touch-up change log
code $PSScriptRoot\changelog.md

$msg = @"
Next steps:
    - Finalize change log
    - Run New-ReleaseChangeLog.ps1
    - git add .
    - git commit -m "v<Version>"
    - publish project
    - push release
"@
Write-Host  $msg -foreground yellow
