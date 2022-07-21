---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3OBHDxT
schema: 2.0.0
---

# ConvertFrom-MySQLiteDB

## SYNOPSIS

Convert a table from a SQLite database.

## SYNTAX

### table (Default)

```yaml
ConvertFrom-MySQLiteDB [-Path] <String> -TableName <String> -PropertyTable <String> [-TypeName <String>] [<CommonParameters>]
```

### hash

```yaml
ConvertFrom-MySQLiteDB [-Path] <String> -TableName <String> -PropertyMap <Hashtable> [-TypeName <String>] [<CommonParameters>]
```

### raw

```yaml
ConvertFrom-MySQLiteDB [-Path] <String> -TableName <String> [-RawObject] [<CommonParameters>]
```

## DESCRIPTION

This command is intended primarily to dump or convert a table from a SQLite database file into PowerShell. It is assumed you create the table using ConvertTo-MySQLiteDB but this should work for most tables. To get the best results you will want to specify a mapping table of keys and datatypes. If you used ConvertTo-MySQLiteDB, it will create a corresponding property map table that you can use. Otherwise, you can use a hashtable. If you want to let SQLite do its best, you can use the -RawObject parameter.

## EXAMPLES

### Example 1

```powershell
PS C:\> ConvertFrom-MySQLiteDB -Path C:\work\Inventory.db -TableName OS -PropertyTable propertymap_myos


Computername : SRV2
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:32 PM
Version      : 10.0.14393
IsServer     : True

Computername : SRV1
OS           : Microsoft Windows Server 2016 Standard Evaluation
InstallDate  : 10/26/2020 6:56:33 PM
Version      : 10.0.14393
IsServer     : True
...
```

Dump a table created using ConvertTo-MySQLiteDB. The resulting objects will have a type name of myOS which is derived from the property map table name which was also created by ConvertTo-MySQLiteDB. As an alternative, you can specify a different type name.

### Example 2

```powershell
PS C:\> ConvertFrom-MySQLiteDB -Path C:\work\test.db -TableName proc -PropertyMap @{Name="string";Date="datetime";id="int";virtualmemorysize = "int";workingset="int"} | Get-Member



   TypeName: System.Management.Automation.PSCustomObject

Name              MemberType   Definition
----              ----------   ----------
Equals            Method       bool Equals(System.Object obj)
GetHashCode       Method       int GetHashCode()
GetType           Method       type GetType()
ToString          Method       string ToString()
Date              NoteProperty datetime Date=3/13/2020 2:52:14 PM
id                NoteProperty int id=17276
Name              NoteProperty string Name=ApplicationFrameHost
virtualmemorysize NoteProperty int virtualmemorysize=295845888
workingset        NoteProperty int workingset=11640832
```

Convert a table using a hashtable of property assignments.

## PARAMETERS

### -Path

Enter the path to the SQLite database file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: database, fullname

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PropertyMap

Enter an optional hashtable of property names and types.

```yaml
Type: Hashtable
Parameter Sets: hash
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PropertyTable

Enter the name of the property map table that is part of the database.

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawObject

Write raw objects to the pipeline. PowerShell will make its best guess as an appropriate datatype.

```yaml
Type: SwitchParameter
Parameter Sets: raw
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TableName

Enter the name of the table with data to import.

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

```yaml
Type: String
Parameter Sets: table, hash
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

### System.String

## OUTPUTS

### System.Object

### Hashtable

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[ConvertTo-MySQLiteDB](ConvertTo-MySQLiteDB.md)
