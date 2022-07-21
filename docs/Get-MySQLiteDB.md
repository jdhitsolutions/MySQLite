---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3PHa8ed
schema: 2.0.0
---

# Get-MySQLiteDB

## SYNOPSIS

Get information about a SQLite database

## SYNTAX

```yaml
Get-MySQLiteDB [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Use this command to retrieve information about a SQLite database file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-MySQLiteDB -Path C:\work\test.db

Path            FileName Size  Modified             Tables
----            -------- ----  --------             ------
C:\work\test.db test.db  33792 3/13/2020 3:22:00 PM {Metadata, PropertyMap, Domain, Data...}
```

Get information for a single database.

### Example 2

```powershell
PS C:\> dir c:\work\*.db | Get-MySQLiteDB | Sort-Object Size -Descending

Path                   FileName       Size   Modified              Tables
----                   --------       ----   --------              ------
C:\work\northwindEF.db northwindEF.db 830464 5/27/2016 1:50:13 PM  {Regions, PreviousEmployees, Employees, sqlite_se...
C:\work\foo.db         foo.db         35840  3/13/2019 3:15:37 PM  {Metadata, PropertyMap, process, propertymap_mySe...
C:\work\test.db        test.db        33792  3/13/2019 3:22:00 PM  {Metadata, PropertyMap, Domain, Data...}
C:\work\vm2.db         vm2.db         14336  3/13/2019 3:57:23 PM  {Metadata, PropertyMap, virtualmachines, Switches}
C:\work\vm.db          vm.db          10240  3/8/2019 2:40:40 PM   {Metadata, PropertyMap, virtualmachines}
C:\work\a.db           a.db           9216   3/12/2019 7:34:18 PM  {Metadata, propertymap_myService, services}
C:\work\test2.db       test2.db       2048   3/13/2019 12:54:59 PM Metadata
```

Get information for multiple database files sorted by size.

### Example 3

```powershell
PS C:\> Get-MySQLiteDB c:\work\vm2.db | Select-object -Property *


DatabaseName  : main
Tables        : {Metadata, PropertyMap, virtualmachines, Switches}
PageSize      : 1024
PageCount     : 14
Encoding      : UTF-8
FileName      : vm2.db
Path          : C:\work\vm2.db
Size          : 14336
Created       : 3/8/2019 2:49:43 PM
Modified      : 3/13/2019 3:57:23 PM
Age           : 00:12:53.1287578
SQLiteVersion : 3.8.8.3
```

Get all properties of a SQLite database file.

## PARAMETERS

### -Path

Enter the path to the SQLite database file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: fullname, database

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### MySQLiteDB

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-MySQLiteDB](New-MySQLiteDB.md)

[Get-MySQLiteTable](Get-MySQLiteTable.md)
