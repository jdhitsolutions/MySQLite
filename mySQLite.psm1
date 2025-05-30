if ($IsMacOS) {
    Write-Warning 'The module is unsupported on this platform. See https://github.com/jdhitsolutions/mysqlite/issues/21 for how you can help.'
    Return
}

if ($PSEdition -eq 'Desktop' ) {
    Add-Type -Path "$PSScriptRoot\assembly\net46\System.Data.SQLite.dll"
}
elseif ($IsWindows) {
    $OSArch = (Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture
    if ($OSArch -match 'ARM') {
        #Write-Host "Loading $PSScriptRoot\assembly\arm64\System.Data.SQLite.dll"
        Add-Type -Path "$PSScriptRoot\assembly\arm64\System.Data.SQLite.dll"
    }
    else {
        Add-Type -Path "$PSScriptRoot\assembly\net20\System.Data.SQLite.dll"
    }
}
elseif ($IsLinux -AND $((uname -m) -match "aarch64|arm")) {-pa
    Write-Warning "This module is not supported on ARM64 Linux yet."
    return
}
elseif ($isLinux) {
    Add-Type -Path "$PSScriptRoot\assembly\linux-x64\System.Data.SQLite.dll"
}
Else {
    #This should never get called
    Write-Warning 'This is an unsupported platform.'
    return
}

Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 |
ForEach-Object {
    . $_.FullName
}

#define a regex pattern to match database file extensions
#[regex]$rxExtension = "\.((sqlite(3)?)|(db(3)?)|(sl3)|(s3db))$"