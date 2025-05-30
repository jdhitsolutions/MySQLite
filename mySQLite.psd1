# Module manifest for module 'mySQLite'

@{

    RootModule             = 'mySQLite.psm1'
    ModuleVersion          = '1.0.0'
    CompatiblePSEditions   = @("Desktop","Core")
    GUID                   = '49ac2120-f30e-4244-ac8b-4d18fa9ae9aa'
    Author                 = 'Jeff Hicks'
    CompanyName            = 'JDH Information Technology Solutions, Inc.'
    Copyright              = '(c) 2019-2025 JDH Information Technology Solutions, Inc.'
    Description            = 'A set of PowerShell commands for working with SQLite database files. This is a simple alternative to installing any version of SQL Server on your desktop. Note that this module will only work on x64 versions Windows and Linux platforms.'
    PowerShellVersion      = '5.1'
    DotNetFrameworkVersion = '4.6'
    #ProcessorArchitecture  = 'AMD64'
    FormatsToProcess       = @(
        'formats\mySQLiteDB.format.ps1xml',
        'formats\mySQLiteTableDetail.format.ps1xml'
    )
    FunctionsToExport      = @(
        'Invoke-MySQLiteQuery',
        'New-MySQLiteDB',
        'New-MySQLiteDBTable',
        'ConvertTo-MySQLiteDB',
        'Get-MySQLiteTable',
        'ConvertFrom-MySQLiteDB',
        'Get-MySQLiteDB',
        'Open-MySQLiteDB',
        'Close-MySQLiteDB',
        'Export-MySQLiteDB',
        'Import-MySQLiteDB',
        'Convert-MySQLiteByteArray',
        'Get-SQLiteVersion'
    )
    CmdletsToExport        = @()
    AliasesToExport        = @(
        'New-DB',
        'ndb',
        'New-DBTable',
        'ndbt',
        'iq',
        'todb',
        'gtb',
        'Get-DBTable',
        'ConvertTo-DB',
        'ConvertFrom-DB',
        'Get-DB',
        'Open-DB',
        'Close-DB'
    )
    PrivateData            = @{
        PSData = @{
            Tags       = @('sqlite', 'database','linux')
            LicenseUri = 'https://github.com/jdhitsolutions/MySQLite/blob/master/License.txt'
            ProjectUri = 'https://github.com/jdhitsolutions/MySQLite'
            # IconUri = ''
            ReleaseNotes = @"
# Changelog for MySQLite

## v[1.0.0] - 2025-05-30 15:30:33

### Added

- Added assembly for ARM64 on Windows.
- Added new sample database `ProcessData.db` to the `samples` folder.

### Changed

- Updated `Import-MySqliteDB` and `Export-MySqliteDB` to better handle importing exported databases. __Breaking changes as the export process creates a different JSON file.__
- Changed `Write-Verbose` commands to 'Write-Debug` in private helper functions.
- Revised the PRAGMA query `Get-MySqliteDB` to get all database information in a single query.
- Updated`Get-MySqliteDB` to display missing database information and extended the custom object to include a few more properties.
- Updated verbose messaging.
- Updated online help links.
- Updated `README.md`.

### Fixed

- Updated error handling in `Invoke-MySqliteQuery` to write errors instead of warnings. __This is a breaking change__. [[Issue #25](https://github.com/jdhitsolutions/mySQLite/issues/25)]
- Updated `Get-MySqliteDB` to handle database files stored in OneDrive. [[Issue #27](https://github.com/jdhitsolutions/mySQLite/issues/27)]
"@
        }
    }

}

