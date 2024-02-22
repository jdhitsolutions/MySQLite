---
external help file: mySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3cuuBoq
schema: 2.0.0
---

# ConvertTo-MySQLiteDB

## SYNOPSIS

Convert or dump PowerShell objects into a SQLite database.

## SYNTAX

```yaml
ConvertTo-MySQLiteDB -InputObject <Object[]> [-Path] <String> -TableName <String> [-Primary <String>] [-TypeName <String>] [-Append] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command is designed to make it easy to take the results of a PowerShell expression, or a collection of objects, and dump them into a SQLite database file. You will need to specify a table name for the data. By default, the command will create a corresponding property map table so that it will be easier to get the data back out with ConvertFrom-MySQLiteDB. This command will use the detected typename or you can specify a typename.

This command was designed with the assumption that you would create a single database and table per command. The Append parameter allows you to include additional tables in the same database file. It does NOT append data to an existing table. If you need to do that, create an Insert query with Invoke-MySQLiteQuery.

Nested objects or more complex properties will be converted to cliXML and stored in the database as byte array or blob.

This command will not overwrite an existing file unless you use -Force.

For best results, you should select only the properties you need as some properties may not serialize very well.

## EXAMPLES

### Example 1

```shell
PS C:\> $data = Get-CimInstance win32_OperatingSystem -ComputerName $computers | Select-Object @{Name="Computername";Expression={$_.CSName}},@{Name="OS";Expression = {$_.caption}},InstallDate,Version,@{Name="IsServer";Expression={ If ($_.caption -match "server") {$True} else {$False}}}
PS C:\> $data | ConvertTo-MySQLiteDB -Path c:\work\Inventory.db -TableName OS -TypeName myOS -force
```

Convert the results of a PowerShell expression into a SQLite database file using a table called OS and a custom type name of myOS. This process will also create a table called propertymap_myOS with mappings for property names and the original type.

The first property name will be used as the first table column and the primary index so the values from your command need to be unique.

The database can be queried using Invoke-MySQLiteQuery or dumped out using ConvertFrom-MySQLiteDB.

NOTE: Storing objects in a database requires serializing nested objects. This is accomplished by converting objects to cliXML and storing that information as an array of bytes in the database. To convert back, the data must be converted to the original clixml string, saved to a temporary file, and then re-imported with `Import-Clixml`. This process is not guaranteed to be 100% error free. The converted object property should be the deserialized version of the original property.

### Example 2

```shell
PS C:\> Get-Process  | Where-Object {$_.name --NotMatch "^(system|idle)$"} | Select-Object * | ConvertTo-MySQLiteDB -Path d:\temp\allproc.db -TableName Process -TypeName myProcess -Primary ID
```

Create a database from local process information. This example is specifying the primary key. You need to have one unique property to use as the primary key for the database. If you see a constraint error, you most likely need to set a primary key.

## PARAMETERS

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

### -Primary

Specify the column name to use as the primary key or index. Otherwise, the first detected property will be used.

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
