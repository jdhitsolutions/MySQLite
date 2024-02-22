---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3aRRJNd
schema: 2.0.0
---

# Close-MySQLiteDB

## SYNOPSIS

Close a SQLite database file.

## SYNTAX

```yaml
Close-MySQLiteDB [-Connection] <SQLiteConnection> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If you are creating your own solutions using the MySQLite module, you might need to open and close the database file. If you use Invoke-MySQLite to insert or update data, that command will handle opening and closing the file.

## EXAMPLES

### Example 1

```shell
PS C:\> $connection = Open-MySQLiteDB -Path C:\work\test2.db
PS C:\> Close-mySQLiteDB $connection
```

After opening the connection and making any changes, you should close the connection.

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

### -Connection

Enter a connection object.

```yaml
Type: SQLiteConnection
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru

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

### System.Data.SQLite.SQLiteConnection

## OUTPUTS

### None

### System.Data.SQLite.SQLiteConnection

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Open-MySQLiteDB](Open-MySQLiteDB.md)
