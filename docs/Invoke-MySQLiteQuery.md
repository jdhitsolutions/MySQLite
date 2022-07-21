---
external help file: MySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3B6YcOW
schema: 2.0.0
---

# Invoke-MySQLiteQuery

## SYNOPSIS

Invoke a query on a SQLite database

## SYNTAX

### file (Default)

```yaml
Invoke-MySQLiteQuery [-Path] <String> [-Query] <String> [-As <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### connection

```yaml
Invoke-MySQLiteQuery [[-Connection] <SQLiteConnection>] [-Query] <String> [-KeepAlive] [-As <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Use this command to run a SQL query against a SQLite database. You can use this command to get data from a table,insert data into a table or modify data. If you are running a SELECT query, which normally returns something, you have an option as to how you would like the results to be formatted.

You will normally use the Path parameter. In scripts, you are more likely to use an existing connection.

See https://sqlite.org/lang.html and http://www.sqlitetutorial.net/ for additional help.

## EXAMPLES

### Example 1

```powershell
PS C:\> $data = Get-Process | Select-object ID,Name,Workingset,VirtualMemorySize,@{Name="Date";Expression={Get-Date}}
PS C:\> $data | foreach-object -begin { $cx = Open-MySQLiteDB c:\work\test.db} -process { Invoke-MySQLiteQuery -connection $cx -keepalive -query "Insert into proc Values ('$($_.ID)','$($_.Name)','$($_.Workingset)','$($_.VirtualMemorySize)','$($_.Date)') "} -end { Close-MySQLiteDB $cx}
PS C:\> Invoke-MySQLiteQuery -Path c:\work\test.db -Query "Select * from proc Order by Workingset Desc Limit 5" | format
-table

   ID Name               Workingset VirtualMemorySize Date
   -- ----               ---------- ----------------- ----
 3112 Memory Compression 1340776448        1484521472 03/13/2022 14:52:14
 5684 powershell         1198268416       -2013696000 03/13/2022 14:52:14
12232 firefox             370966528       -1868365824 03/13/2022 14:52:14
15536 thunderbird         347189248        1131708416 03/13/2022 14:52:14
15788 Code                323653632        1997750272 03/13/2022 14:52:14
```

The first command creates a data set. The second command inserts into a table in the SQLite database file. The last command queries for data in the proc table sorting on the WorkingSet property in descending order. Note that you could have retrieved all data from the table and piped to Where-Object to perform the filtering, but that would not be as efficient.

### Example 2

```powershell
PS C:\> Invoke-MySQLiteQuery c:\work\vm2.db -Query "update metadata set Comment = 'for Hyper-V monitoring'"
PS C:\> Invoke-MySQLiteQuery c:\work\vm2.db -Query "select * from Metadata"

Author         Created             Computername Comment
------         -------             ------------ -------
BOVINE320\Jeff 3/8/2022 2:59:05 PM BOVINE320    for Hyper-V monitoring
```

Update a table column and then query the results

## PARAMETERS

### -As

Write the results of a Select query in the specified format. The default is as an object, but you can get the results as a DataTable or HashTable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Object, Datatable, Hashtable

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

Specify an existing open database connection.

```yaml
Type: SQLiteConnection
Parameter Sets: connection
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -KeepAlive

Keep the connection alive.

```yaml
Type: SwitchParameter
Parameter Sets: connection
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
Parameter Sets: file
Aliases: fullname, database

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Query

Enter a SQL query string. See http://www.sqlitetutorial.net/ for some guidance.

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

### PSCustomObject

### System.Data.Datatable

### Hashtable

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS
