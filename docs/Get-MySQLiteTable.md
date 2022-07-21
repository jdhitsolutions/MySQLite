---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3PpKHxY
schema: 2.0.0
---

# Get-MySQLiteTable

## SYNOPSIS

Get information about tables in a SQLite database.

## SYNTAX

### file (Default)

```yaml
Get-MySQLiteTable [-Path] <String> [-Detail] [<CommonParameters>]
```

### connection

```yaml
Get-MySQLiteTable [[-Connection] <SQLiteConnection>] [-KeepAlive] [-Detail] [<CommonParameters>]
```

## DESCRIPTION

Use this command to discover table names and layout in a SQLite database file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-MySQLiteTable -Path c:\work\vm2.db

Source         Name
------         ----
C:\work\vm2.db {Metadata, PropertyMap, virtualmachines, Switches}
```

Basic information about available tables.

### Example 2

```powershell
PS C:\> Get-MySQLiteTable -Path c:\work\vm2.db -Detail

   Database C:\work\vm2.db Table:Metadata

ColumnIndex ColumnName   ColumnType
----------- ----------   ----------
0           Author       TEXT
1           Created      TEXT
2           Computername TEXT
3           Comment      TEXT


   Database C:\work\vm2.db Table:PropertyMap

ColumnIndex ColumnName     ColumnType
----------- ----------     ----------
0           Name
1           State
2           Runtime
3           SizeGB
4           VMSwitch
5           MemoryMB
6           MemoryDemandMB
7           IPAddress
8           Date
9           ComputerName


   Database C:\work\vm2.db Table:virtualmachines

ColumnIndex ColumnName     ColumnType
----------- ----------     ----------
0           Name           Text
1           State          Blob
2           Runtime        Blob
3           SizeGB         Real
4           VMSwitch       Text
5           MemoryMB       Real
6           MemoryDemandMB Real
7           IPAddress      Text
8           Date           Text
9           ComputerName   Text


   Database C:\work\vm2.db Table:Switches

ColumnIndex ColumnName ColumnType
----------- ---------- ----------
0           Name
```

Get a detailed report on tables in the specified file.

## PARAMETERS

### -Connection

Specify an existing open database connection.

```yaml
Type: SQLiteConnection
Parameter Sets: connection
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Detail

Display formatted detail results.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeepAlive

Do not close the database connection.

```yaml
Type: SwitchParameter
Parameter Sets: connection
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Enter the path to the SQLite database file.

```yaml
Type: String
Parameter Sets: file
Aliases: database, fullname

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

### PSCustomObject

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-MySQLiteDBTable](New-MySQLiteDBTable.md)
