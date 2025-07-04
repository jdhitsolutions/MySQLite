# MySQLite

[![PSGallery Version](https://img.shields.io/powershellgallery/v/MySQLite.png?style=for-the-badge&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/MySQLite/) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/MySQLite.png?style=for-the-badge&label=Downloads)](https://www.powershellgallery.com/packages/MySQLite/) ![GitHub license](https://img.shields.io/github/license/jdhitsolutions/MySQLite?style=for-the-badge)

![database server](images/db.png)

A set of PowerShell functions for working with SQLite database files. The goal of the module is to integrate the use of SQLite databases into daily PowerShell work or module development where a lightweight database would be beneficial. You might use this module as a library in your PowerShell projects.

## Background

I started work on this module years ago and had it almost complete except for managing the assembly to provide the .NET interface. After letting the project remain idle, I happened across a [similar module by Tobias Weltner](https://github.com/TobiasPSP/ReallySimpleDatabase). He had a brilliant technique to manage the .NET assembly which I freely "borrowed." With this missing piece, I dusted off my module, polished it, and published it to the PowerShell Gallery.

## Module Installation

This module should work on 64-bit versions of Windows PowerShell 5.1 and PowerShell 7 running on Windows or Linux platforms. __The module is not supported on MacOS.__

> :raised_hand: I would love to be able to support MacOS on PowerShell 7. Please see [Issue #21](https://github.com/jdhitsolutions/mysqlite/issues/21). As of version 1.0.0, this module is supported on ARM versions Windows. As with MacOS, I would love to be able to support ARM versions of Linux but I don't have the infrastructure for proper development and testing. I am open to contributions to make this module work on ARM Linux.

You can install this module from the PowerShell Gallery.

```powershell
Install-Module -name MySQLite -repository PSGallery
```

```powershell
Install-PSResource -name MySQLite -repository PSGallery
```

## Module Commands

- [ConvertTo-MySQLiteDB](docs/ConvertTo-MySQLiteDB.md)
- [ConvertFrom-MySQLiteDB](docs/ConvertFrom-MySQLiteDB.md)
- [Convert-MySQLiteByteArray](docs/Convert-MySQLiteByteArray.md)
- [Get-MySQLiteDB](docs/Get-MySQLiteDB.md)
- [Get-MySQLiteTable](docs/Get-MySQLiteTable.md)
- [Invoke-MySQLiteQuery](docs/Invoke-MySQLiteQuery.md)
- [New-MySQLiteDB](docs/New-MySQLiteDB.md)
- [New-MySQLiteDBTable](docs/New-MySQLiteDBTable.md)
- [Export-MySQLiteDB](docs/Export-MySQLiteDB.md)
- [Import-MySQLiteDB](docs/Import-MySQLiteDB.md)
- [Get-SQLiteVersion](docs/Get-SQLiteVersion.md)

## Converting PowerShell Output

The primary benefit of this module is storing the results of a PowerShell expression or script into a SQLite database file and later retrieving it back into PowerShell as the original objects, or as close as possible.

For example, you might have code like this that creates a dataset.

```powershell
$computers= "win10","dom1","srv1","srv2","thinkx1-jh"

$data = Get-CimInstance Win32_OperatingSystem -ComputerName $computers |
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
PS C:\>  Get-MySQLiteDB -Path C:\work\Inventory.db | Format-List

DatabaseName    : main
Tables          : {Metadata, propertymap_myos, OS}
PageSize        : 4096
PageCount       : 6
LastInsertRowID : 0
Encoding        : UTF-8
FileName        : Inventory.db
Path            : C:\work\Inventory.db
Size            : 24576
MemoryUsed      : 210367
Created         : 1/14/2021 1:26:24 PM
Modified        : 2/21/2023 3:31:27 PM
Age             : 828.23:55:12.7271289
SQLiteVersion   : 3.42.0
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

You also use `Invoke-MySQLiteQuery`.

```powershell
PS C:\> Invoke-MySQLiteQuery -path D:\temp\sales2.db -Query "Select name,sid,SamAccountName,members from grp"

Name  SID                  SamAccountName Members
----  ---                  -------------- -------
Sales {60, 79, 98, 106...} Sales          {60, 79, 98, 106...}
```

Nested objects will be stored as byte arrays. You can restore these properties on a granular basis using `Convert-MySQLiteByteArray`.

```powershell
PS C:\> Invoke-MySQLiteQuery -path D:\temp\sales2.db -Query "Select name,sid,samaccountname,members from grp" | Select-Object Name,SamAccountName,
@{Name="SID";Expression={Convert-MySQLiteByteArray $_.sid}},
@{Name="Members";Expression={Convert-MySQLiteByteArray $_.Members}}

Name  SamAccountName SID                                          Members
----  -------------- ---                                          -------
Sales Sales          S-1-5-21-3554402041-35902484-4286231435-1147 {CN=SamanthaS,OU=Sales,DC=Compa...
```

> :warning: Storing objects in a database requires serializing nested objects. This is accomplished by converting objects to cliXML and storing that information as an array of bytes in the database. To convert back, the data must be converted to the original clixml string, deserialized, and then re-imported. This process is not guaranteed to be 100% error free. The converted object property should be the deserialized version of the original property.

The remaining commands can be used to create SQLite files on a more granular basis.

## Malformed Queries

SQLite can be unforgiving when it comes to queries that might involve odd characters, especially quotes. The module commands will not attempt to validate your queries or syntax. It is up to you to handle that process. Here's an example.

A command like this will fail.

```powershell
$Name= "Carol'sPC"
Invoke-MySQLiteQuery -Path C:\temp\inventory.db -Query "Insert Into OS (Computername,OS,InstallDate,Version,IsServer) values ('$Name','Microsoft Windows 11 Pro','$(Get-Date)','11.0.0','0')"
```

SQLite doesn't like the single quote in the computer name. You need to escape it.

```powershell
$Name=  $name.Replace("'","''")
```

Now the query will work as expected. It is assumed that you know the data you want to work with and know how to handle potential issues.

## Creating a New Database

You can create a new database file with the `New-MySQLiteDB` command.

```powershell
New-MySQLiteDB -Path c:\work\data.db -Comment "work data and reporting"
```

When you create a new database with this command, PowerShell will retain a lock on the file for a few minutes until the garbage collector releases it. If you need to work with the new database immediately ___outside___ of PowerShell, you will need to wait a few minutes, or manually invoke garbage collection by running:

```powershell
[System.GC]::Collect()
```

Once created you can view the database.

```powershell
PS C:\> Get-MySQLiteDB -Path c:\work\data.db

Path            FileName Size Modified             Tables
----            -------- ---- --------             ------
C:\work\data.db data.db  8192 2/22/2024 9:41:50 AM Metadata
```

You can add tables to the database.

```powershell
PS C:\> New-MySQLiteDBTable -Path C:\work\data.db -TableName ComputerNames -ColumnNames "Name","Date","Version"
PS C:\> Invoke-MySQLiteQuery c:\work\data.db -query "Pragma table_info(ComputerNames)" | Select cid,name

cid name
--- ----
  0 Name
  1 Date
  2 Version

PS C:\> Get-MySQLiteTable -Path C:\work\data.db -Detail

   Database: C:\work\data.db Table:Metadata

ColumnIndex ColumnName   ColumnType
----------- ----------   ----------
0           Author       TEXT
1           Created      TEXT
2           Computername TEXT
3           Comment      TEXT

   Database: C:\work\data.db Table:ComputerNames

ColumnIndex ColumnName ColumnType
----------- ---------- ----------
0           Name
1           Date
2           Version
```

And then add data to the table.

```powershell
PS C:\> $q = "Insert into ComputerNames Values ('$env:computername','$(Get-Date)','$($PSVersionTable.OS)')"
PS C:\> Invoke-MySQLiteQuery -Path c:\work\data.db -Query $q
PS C:\> Invoke-MySQLiteQuery -Path c:\work\data.db -Query "Select * from ComputerNames"

Name     Date                Version
----     ----                -------
PROSPERO 02/22/2024 09:59:55 Microsoft Windows 10.0.22631
```

## Sample Databases

I have provided several sample database files in the [Samples](samples) folder.

## Resources

If you want to learn more about SQLite databases, take a look at <https://www.sqlite.org/index.html> and <http://www.sqlitetutorial.net/>.

You might also be interested in the [DB Browser for SQLite](https://sqlitebrowser.org/) application.

![DBBrowser for SQLite](images/dbbrowser.png)

This is a free, open source tool that allows you to view and edit SQLite database files. It is available for Windows, MacOS, and Linux.

## Related Modules

If you would like to see how this module can be used in other tools, take a look at my [PSWorkItem](https://github.com/jdhitsolutions/PSWorkItem) and [PSReminderLite](https://github.com/jdhitsolutions/PSReminderLite) modules. If you have written something that incorporates this module, I'd love to hear about it. Post a description and link the [Discussions section of this repository](https://github.com/jdhitsolutions/MySQLite/discussions).
