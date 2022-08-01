# MySQLite

[![PSGallery Version](https://img.shields.io/powershellgallery/v/MySQLite.png?style=for-the-badge&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/MySQLite/) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/MySQLite.png?style=for-the-badge&label=Downloads)](https://www.powershellgallery.com/packages/MySQLite/)

A set of PowerShell functions for working with SQLite database files. The goal of the module is to integrate the use of SQLite databases into daily PowerShell work or module development where a lightweight database would be beneficial. You might use this module as a library in your PowerShell projects.

## Background

I started work on this module years ago and had it almost complete except for managing the assembly to provide the .NET interface. After letting the project remain idle, I happened across a [similar module by Tobias Weltner](https://github.com/TobiasPSP/ReallySimpleDatabase). He had a brilliant technique to manage the .NET assembly which I freely "borrowed." With this missing piece, I dusted off my module, polished it, and published to the PowerShell Gallery.

## Installation

This module should work on 64-bit versions of Windows PowerShell and PowerShell 7 running on a Windows platform. __The module is not supported on non-Windows platforms.__

You can install this module from the PowerShell Gallery.

```powershell
Install-Module -name MySQLite -repository PSGallery
```

## Commands

+ [ConvertFrom-MySQLiteDB](docs/ConvertFrom-MySQLiteDB.md)
+ [ConvertTo-MySQLiteDB](docs/ConvertTo-MySQLiteDB.md)
+ [Get-MySQLiteDB](docs/Get-MySQLiteDB.md)
+ [Get-MySQLiteTable](docs/Get-MySQLiteTable.md)
+ [Invoke-MySQLiteQuery](docs/Invoke-MySQLiteQuery.md)
+ [New-MySQLiteDB](docs/New-MySQLiteDB.md)
+ [New-MySQLiteDBTable](docs/New-MySQLiteDBTable.md)
+ [Export-MySQLiteDB](docs/Export-MySQLiteDB.md)
+ [Import-MySQLiteDB](docs/Import-MySQLiteDB.md)

## Converting PowerShell Output

The primary benefit of this module is storing results of a PowerShell expression or script into a SQLite database file and later retrieving it back into PowerShell as the original objects, or as close as possible.

For example, you might have code like this that creates a dataset.

```powershell
$computers= "win10","dom1","srv1","srv2","thinkx1-jh"

$data = Get-CimInstance win32_operatingsystem -ComputerName $computers |
Select-Object @{Name="Computername";Expression={$_.CSName}},
@{Name="OS";Expression = {$_.caption}},InstallDate,Version,
@{Name="IsServer";Expression={ If ($_.caption -match "server") {$True} else {$False}}}
```

Using `ConvertTo-MySQLiteDB` you can easily dump this into a database file.

```powershell
$data | ConvertTo-MySQLiteDB -Path c:\work\Inventory.db -TableName OS -TypeName myOS -force
```

Run [Get-MySqLiteDB](docs/Get-MySQLiteDB.md) to view the database file.

```powershell
PS C:\>  Get-MySQLiteDB -Path C:\work\Inventory.db

Path                 FileName     Size  Modified              Tables
----                 --------     ----  --------              ------
C:\work\Inventory.db Inventory.db 24576 7/20/2022 12:20:49 PM {Metadata, propertymap_myos, OS}
```

Or drill down to get table details.

```powershell
PS C:\> Get-MySQLiteTable -Path C:\work\Inventory.db -Detail

   Database: C:\work\Inventory.db Table:Metadata

ColumnIndex ColumnName   ColumnType
----------- ----------   ----------
0           Author       TEXT
1           Created      TEXT
2           Computername TEXT
3           Comment      TEXT

   Database: C:\work\Inventory.db Table:propertymap_myos

ColumnIndex ColumnName   ColumnType
----------- ----------   ----------
0           Computername Text
1           OS           Text
2           InstallDate  Text
3           Version      Text
4           IsServer     Text

   Database: C:\work\Inventory.db Table:OS

ColumnIndex ColumnName   ColumnType
----------- ----------   ----------
0           Computername Text
1           OS           Text
2           InstallDate  Text
3           Version      Text
4           IsServer     Int
```

As you can see, the database file will include a table called `propertymap_myOS` which contains a mapping of properties to types.

```powershell
PS C:\> Invoke-MySQLiteQuery -Path C:\work\Inventory.db -query "Select * from propertymap_myos" -as Hashtable

Name                           Value
----                           -----
Computername                   System.String
OS                             System.String
InstallDate                    System.DateTime
Version                        System.String
IsServer                       System.Boolean
```

You can then query the data.

```powershell
PS C:\> Invoke-MySQLiteQuery "Select * from os where IsServer = 1" -path C:\work\Inventory.db

Computername : DOM1
OS           : Microsoft Windows Server 2019 Standard Evaluation
InstallDate  : 5/24/2022 3:07:58 PM
Version      : 10.0.17763
IsServer     : 1

Computername : SRV2
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 5/24/2022 3:16:44 PM
Version      : 10.0.14393
IsServer     : 1

Computername : SRV1
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 5/24/2022 3:16:51 PM
Version      : 10.0.14393
IsServer     : 1
```

Or dump it back out to PowerShell in its original format.

```powershell
PS C:\> ConvertFrom-MySQLiteDB -Path C:\work\Inventory.db -TableName OS -PropertyTable propertymap_myos

Computername : DOM1
OS           : Microsoft Windows Server 2019 Standard Evaluation
InstallDate  : 5/24/2022 3:07:58 PM
Version      : 10.0.17763
IsServer     : True

Computername : THINKX1-JH
OS           : Microsoft Windows 11 Pro
InstallDate  : 5/17/2022 2:54:52 PM
Version      : 10.0.22622
IsServer     : False
...
```

The remaining commands can be used to create SQLite files on a more granular basis.

## Learn More

If you want to learn more about SQLite databases, take a look at <https://www.sqlite.org/index.html> and <http://www.sqlitetutorial.net/>.
