---
external help file: mySQLite-help.xml
Module Name: mySQLite
online version: https://jdhitsolutions.com/yourls/b1e4cd
schema: 2.0.0
---

# Import-MySQLiteDB

## SYNOPSIS

Import a SQLite database backup

## SYNTAX

```yaml
Import-MySQLiteDB [-Path] <String> [-Destination] <String> [-Force] [-UseExisting] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If you exported a SQLite database to a JSON file using Export-MySQLiteDB, you can use this file to import the data and recreate the file. If you want to restore an existing file, it is recommended that you restore the file in a different location, verify the new database, and then copy over the existing file.

If you exported a database prior to version 1.0.0, you will need to re-export it to use this function. The export process has changed to create a different JSON file format

## EXAMPLES

### Example 1

```powershell
PS C:\> Import-MySQLiteDB -path c:\work\inventory.json -destination d:\temp\inventory.db.
```

## PARAMETERS

### -Destination

The destination path for the imported database file. It must have a .db file extension.

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

### -Force

Overwrite the destination database file if it exists.

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

The path to the exported JSON file.

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

### -UseExisting

Use an existing database file. If you append to an existing database, the metadata and propertymap tables will not be updated.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Append

Required: False
Position: Named
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

### System.IO.FileInfo

## NOTES

Learn more about PowerShell: https://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Export-MySQLiteDB](Export-MySQLiteDB.md)

[Get-MySQLiteDB](Get-MySQLiteDB.md)
