# MySQLite

A set of PowerShell functions for working with SQLite database files. This module will only work on 64bit Windows platforms at this time. It should load and work in both Windows PowerShell and PowerShell 7. The goal of the module is to integrate the use of SQLite databases into daily PowerShell work or module development where a lightweight database would be beneficial.

## Commands

+ [ConvertFrom-MySQLiteDB](docs/ConvertFrom-MySQLiteDB.md)
+ [ConvertTo-MySQLiteDB](docs/ConvertTo-MySQLiteDB.md)
+ [Get-MySQLiteDB](docs/Get-MySQLiteDB.md)
+ [Get-mySQLiteTable](docs/Get-mySQLiteTable.md)
+ [Invoke-MySQLiteQuery](docs/Invoke-MySQLiteQuery.md)
+ [New-MySQLiteDB](docs/New-MySQLiteDB.md)
+ [New-MySQLiteDBTable](docs/New-MySQLiteDBTable.md)

## Converting PowerShell

The primary benefit of this module is storing results of a PowerShell expression or script into a SQLite database file and later retrieving it back into PowerShell as the original objects, or as close as possible.

For example, you might have code like this that creates a dataset.

```powershell
$computers= "win10","dom1","srv1","srv2","thinkp1","bovine320"

$data = Get-CimInstance win32_operatingsystem -ComputerName $computers |
Select-Object @{Name="Computername";Expression={$_.CSName}},
@{Name="OS";Expression = {$_.caption}},InstallDate,Version,
@{Name="IsServer";Expression={ If ($_.caption -match "server") {$True} else {$False}}}
```

Using `ConvertTo-MySQLiteDB` you can easily dump this into a database file.

```powershell
$data | ConvertTo-MySQLiteDB -Path c:\work\Inventory.db -TableName OS -TypeName myOS -force
```

This process will create a table called propertymap_myOS which contains a mapping of properties to types.

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

You can always query the data.

```powershell
PS C:\> Invoke-MySQLiteQuery "Select * from os where IsServer = 1" -path C:\work\Inventory.db


Computername : SRV2                                                                                                             OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:32 PM
Version      : 10.0.14393
IsServer     : 1

Computername : SRV1
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:33 PM
Version      : 10.0.14393
IsServer     : 1

Computername : SRV4
OS           : Microsoft Windows Server 2019 Standard
InstallDate  : 1/17/2019 8:32:37 AM
Version      : 10.0.17763
IsServer     : 1

Computername : DOM1
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:47:42 PM
Version      : 10.0.14393
IsServer     : 1
```

Or dump it back out to PowerShell in its original format.

```powershell
PS C:\> ConvertFrom-MySQLiteDB -Path C:\work\Inventory.db -TableName OS -PropertyTable propertymap_myos


Computername : SRV2
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:32 PM
Version      : 10.0.14393
IsServer     : True

Computername : SRV1
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:33 PM
Version      : 10.0.14393
IsServer     : True

Computername : WIN10
OS           : Microsoft Windows 10 Enterprise Evaluation
InstallDate  : 10/26/2020 6:56:25 PM
Version      : 10.0.18363
IsServer     : False
...
```

_Last updated 2021-01-14 18:13:07Z_
