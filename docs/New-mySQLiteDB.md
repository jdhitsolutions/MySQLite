---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version:
schema: 2.0.0
---

# New-MySQLiteDB

## SYNOPSIS

Create a new SQLite database file

## SYNTAX

```yaml
New-MySQLiteDB [-Path] <String> [-Force] [-Comment <String>] [-Passthru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

This command will create a new SQLite database file. It won't create any tables other than a Metadata table with information about who created the database and when. You can use the -Comment parameter to include a description or additional information into the Metadata table.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-MySQLiteDB c:\work\test.db
```

Create a new database file in C:\Work.

### Example 3

```powershell
PS C:\> New-MySQLiteDB c:\work\test2.db -Comment "This is for scripting stuff" -passthru -force | Invoke-MySQLiteQuery -query "Select * from metadata"

Author         Created               Computername Comment
------         -------               ------------ -------
BOVINE320\Jeff 3/13/2019 12:54:59 PM BOVINE320    This is for scripting stuff
```

Create a new database file in C:\Work and add a comment. Overwrite the file if it already exists and write the

## PARAMETERS

### -Comment

Enter a comment to be inserted into the database's metadata table.

```yaml
Type: String
Parameter Sets: (All)
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

### -Force

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

### -Passthru

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

Enter the path to the SQLite database file you want to create.

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

### None

### System.IO.Fileinfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MySQLiteDB](Get-MySQLiteDB.md)

[New-MySQLiteDBTable](New-MySQLiteDBTable.md)
