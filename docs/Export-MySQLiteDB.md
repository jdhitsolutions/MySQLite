---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3PQzsPD
schema: 2.0.0
---

# Export-MySQLiteDB

## SYNOPSIS

Export a SQLite database file

## SYNTAX

```yaml
Export-MySQLiteDB [-Path] <String> [-Destination] <String> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command is provided as backup mechanism for a SQLite database file. The function will export all tables and data to a JSON file. Use Import-MySQLiteDB to restore the database using the JSON file.

## EXAMPLES

### Example 1

```shell
PS C:\> Export-MySQLiteDB -path c:\work\inventory.db -destination d:\inventory.json
```

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

### -Destination

The destination path for the exported JSON file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
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

### -Path

The path to the SQLite database file. The file name must have one of the following extensions: .db | .db3 | .s3db | .sl3 | .sqlite | .sqlite3

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

### None

### System.IO.FileInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Import-MySQLiteDB](Import-MySQLiteDB.md)

[Get-MySQLiteDB](Get-MySQLiteDB.md)
