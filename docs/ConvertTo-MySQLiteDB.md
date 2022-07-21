---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3cuuBoq
schema: 2.0.0
---

# ConvertTo-MySQLiteDB

## SYNOPSIS

Convert or dump PowerShell objects into a SQLite database.

## SYNTAX

```yaml
ConvertTo-MySQLiteDB -Inputobject <Object[]> [-Path] <String> -TableName <String> [-TypeName <String>] [-Append] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command is designed to make it easy to take the results of a PowerShell expression, or a collection of objects, and dump them into a SQLite database file. You will need to specify a table name for the data. By default, the command will create a corresponding property map table so that it will be easier to get the data back out with ConvertFrom-MySQLiteDB. This command will use the detected typename or you can specify a typename.

This command was designed with the assumption that you would create a single database and table per command. The Append parameter allows you to include additional tables in the same database file. It does NOT append data to an existing table. If you need to do that, create an Insert query with Invoke-MySQLiteQuery.

Nested objects or more complex properties will be converted to cliXML and stored in the database as byte array or blob.

This command will not overwrite an existing file unless you use -Force.

## EXAMPLES

### Example 1

```powershell
PS C:\> $data = Get-CimInstance win32_operatingsystem -ComputerName $computers | Select-Object @{Name="Computername";Expression={$_.CSName}},@{Name="OS";Expression = {$_.caption}},InstallDate,Version,@{Name="IsServer";Expression={ If ($_.caption -match "server") {$True} else {$False}}}
PS C:\> $data | ConvertTo-MySQLiteDB -Path c:\work\Inventory.db -TableName OS -TypeName myOS -force
```

Convert the results of a PowerShell expression into a SQLite database file using a table called OS and a custom type name of myOS. This process will also create a table called propertymap_myOS with mappings for property names and the original type.

The first property name will be used as the first table column and the primary index so the values from your command need to be unique.

The database can be queried using Invoke-MYSQLiteQuery or dumped out using ConvertFrom-MySQLiteDB.

## PARAMETERS

### -InputObject

What object do you want to create? Typically this will be the result of a PowerShell expression or command. It is recommended that you be selective.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path

Enter the path to the SQLite database file.

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

### -Append

Append a new table to an existing SQLite database file. This does NOT append data to an existing table.

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

### -Force

Overwrite the existing file.

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

### -TypeName

Enter a typename for your converted objects. If you don't specify one, it will be auto-detected. This name will also be used to construct the property map table.

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

### System.Object[]

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[ConvertFrom-MySQLiteDB](ConvertFrom-MySQLiteDB.md)
