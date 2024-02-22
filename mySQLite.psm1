if ($IsMacOS) {
    Write-Warning 'The module is unsupported on this platform. See https://github.com/jdhitsolutions/mysqlite/issues/21 for how you can help.'
    Return
}

if ($PSEdition -eq 'Desktop' ) {
    Add-Type -Path "$PSScriptRoot\assembly\net46\System.Data.SQLite.dll"
}
elseif ($IsWindows) {
    Add-Type -Path "$PSScriptRoot\assembly\net20\System.Data.SQLite.dll"
}
elseif ($IsLinux) {
    Add-Type -Path "$PSScriptRoot\assembly\linux-x64\System.Data.SQLite.dll"
}
Else {
    #this should never get called
    Write-Warning 'This is an unsupported platform.'
}

Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 |
ForEach-Object {
    . $_.FullName
}

#define a regex pattern to match database file extensions
#[regex]$rxExtension = "\.((sqlite(3)?)|(db(3)?)|(sl3)|(s3db))$"