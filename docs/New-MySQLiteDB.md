---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3aR8NCO
schema: 2.0.0
---

# New-MySQLiteDB

## SYNOPSIS

Create a new SQLite database file

## SYNTAX

```yaml
New-MySQLiteDB [-Path] <String> [-Force] [-Comment <String>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command will create a new SQLite database file. It won't create any tables other than a Metadata table with information about who created the database and when. You can use the -Comment parameter to include a description or additional information into the Metadata table.

When you create a new database with this command, PowerShell will retain a lock on the file for a few minutes until the garbage collector releases it. If you need to work with the new database immediately outside of PowerShell, you will need to wait a few minutes, or manually invoke garbage collection by running [System.GC]::Collect().

## EXAMPLES

### Example 1

```shell
PS C:\> New-MySQLiteDB c:\work\test.db
```

Create a new database file in C:\Work.

### Example 2

```shell
PS C:\> New-MySQLiteDB c:\work\test2.db -Comment "This is for scripting stuff" -PassThru -force | Invoke-MySQLiteQuery -query "Select * from metadata"

Author          Created               Computername Comment
------          -------               ------------ -------
THINKX1-JH\Jeff 7/20/2022 12:34:39 PM THINKX1-JH   This is for scripting stuff
```

Create a new database file in C:\Work and add a comment. Overwrite the file if it already exists and send the result to Invoke-MySQLiteQuery to display metadata information.

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

### System.IO.FileInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-MySQLiteDB](Get-MySQLiteDB.md)

[New-MySQLiteDBTable](New-MySQLiteDBTable.md)
