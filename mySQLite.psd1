# Module manifest for module 'mySQLite'

@{

    RootModule             = 'mySQLite.psm1'
    ModuleVersion          = '0.13.0'
    CompatiblePSEditions   = @("Desktop","Core")
    GUID                   = '49ac2120-f30e-4244-ac8b-4d18fa9ae9aa'
    Author                 = 'Jeff Hicks'
    CompanyName            = 'JDH Information Technology Solutions, Inc.'
    Copyright              = '(c) 2019-2024 JDH Information Technology Solutions, Inc.'
    Description            = 'A set of PowerShell commands for working with SQLite database files. This is a simple alternative to installing any version of SQL Server on your desktop. Note that this module will only work on x64 versions Windows and Linux platforms.'
    PowerShellVersion      = '5.1'
    DotNetFrameworkVersion = '4.6'
    ProcessorArchitecture  = 'AMD64'
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
            # ReleaseNotes = ''
        }
    }

}

