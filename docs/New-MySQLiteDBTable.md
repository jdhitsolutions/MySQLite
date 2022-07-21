---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3aZEwBP
schema: 2.0.0
---

# New-MySQLiteDBTable

## SYNOPSIS

## SYNTAX

### filetyped (Default)

```yaml
New-MySQLiteDBTable -Path <String> -TableName <String> [-ColumnProperties <OrderedDictionary>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### filenamed

```yaml
New-MySQLiteDBTable [-Path <String>] -TableName <String> [-ColumnNames <String[]>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### cnxnamed

```yaml
New-MySQLiteDBTable [-Connection <SQLiteConnection>] -TableName <String> [-ColumnNames <String[]>] [-Force] [-KeepAlive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### cnxtyped

```yaml
New-MySQLiteDBTable [-Connection <SQLiteConnection>] -TableName <String>
[-ColumnProperties <OrderedDictionary>] [-Force] [-KeepAlive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command will create a new table in a SQLite database file. You need to specify a table name. When you define the table you also need to specify the column names. You can do this with an array of names, in which case the column values will not be treated as any particular type. When you insert data into the table SQLite will automatically determine a type.

Or you can use an ordered hashtable of column names and types. The first key will be set as the Primary key.

Normally you will specify a path but in scripted projects, you may have an existing connection and wish to re-use it to avoid file I/O overhead. In any event, the database must already have been created.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-MySQLiteDBTable -Path c:\work\test.db -TableName Data -ColumnNames "Name","Date","Size"
```

This adds a new table to the database file c:\work\test.db called Data. The table will have 3 columns and any data inserted into it will be automatically typed.

### Example 2

```powershell
PS C:\> $h = [ordered]@{ID="Int";Name="Text";Workingset="Int";VirtualMemorySize="Int";Date="text"}
PS C:\> New-MySQLiteDBTable -Path c:\work\test.db -TableName Proc -ColumnProperties $h
PS C:\> Invoke-MySQLiteQuery c:\work\test.db -query "Pragma table_info(proc)" | Select-Object Cid,Name,Type

cid name              type
--- ----              ----
  0 ID                Int
  1 Name              Text
  2 Workingset        Int
  3 VirtualMemorySize Int
  4 Date              text
```

The first command creates an ordered hashtable of column names and types. The second command creates a new table called Proc and the last command validates the new table. The cid property is the column index number.

Note that SQLite has a limited number of supported types. See https://www.sqlite.org/datatype3.html for more information.

## PARAMETERS

### -ColumnNames

```yaml
Type: String[]
Parameter Sets: filenamed, cnxnamed
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColumnProperties

Enter an ordered hashtable of column definitions. See https://www.sqlite.org/datatype3.html for more information about supported types.

```yaml
Type: OrderedDictionary
Parameter Sets: filetyped, cnxtyped
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Connection

```yaml
Type: SQLiteConnection
Parameter Sets: cnxnamed, cnxtyped
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Overwrite an existing table. This could result in data loss.

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

If using a connection, keep the connection open and alive when the command finishes.

```yaml
Type: SwitchParameter
Parameter Sets: cnxnamed, cnxtyped
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
Parameter Sets: filetyped
Aliases: fullname, database

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: filenamed
Aliases: fullname, database

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TableName

Enter the name of the new table. Table names are technically case-sensitive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-MySQLiteDB](New-MySQLiteDB.md)

[Get-MySQLiteTable](Get-MySQLiteTable)
