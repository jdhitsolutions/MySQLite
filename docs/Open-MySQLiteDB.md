---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3PEe13G
schema: 2.0.0
---

# Open-MySQLiteDB

## SYNOPSIS

Open a SQLite database file.

## SYNTAX

```yaml
Open-MySQLiteDB [-Path] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If you are creating your own solutions using the MySQLite module, you might need to open and close the database file. If you use Invoke-MySQLite to insert or update data, that command will handle opening and closing the file.

## EXAMPLES

### Example 1

```powershell
PS C:\> $connection = Open-MySQLiteDB -Path C:\work\test2.db
PS C:\> $connection

PoolCount         : 0
ConnectionString  : Data Source=C:\work\test2.db;Version=3
DataSource        : test2
FileName          : C:\work\test2.db
Database          : main
DefaultTimeout    : 30
BusyTimeout       : 0
WaitTimeout       : 30000
PrepareRetries    : 3
ProgressOps       : 0
ParseViaFramework : False
Flags             : Default
DefaultDbType     :
DefaultTypeName   :
VfsName           :
OwnHandle         : True
ServerVersion     : 3.28.0
LastInsertRowId   : 0
Changes           : 0
AutoCommit        : True
MemoryUsed        : 133912
MemoryHighwater   : 312684
State             : Open
ConnectionTimeout : 15
CanCreateBatch    : False
Site              :
Container         :
```

You can use the open connection object with commands in the mySQLite module that have a connection parameter.

## PARAMETERS

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

### -Path

The path to the SQLite database file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: database

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### None

## OUTPUTS

### System.Data.SQLite.SQLiteConnection

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Close-MySQLiteDB](Close-MySQLiteDB.md)
