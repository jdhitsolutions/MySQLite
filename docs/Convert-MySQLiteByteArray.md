---
external help file: mySQLite-help.xml
Module Name: mySQLite
online version: https://bit.ly/3xoAZ8g
schema: 2.0.0
---

# Convert-MySQLiteByteArray

## SYNOPSIS

Convert a MySQLite property blob

## SYNTAX

```yaml
Convert-MySQLiteByteArray [-BlobProperty] <Byte[]> [<CommonParameters>]
```

## DESCRIPTION

Nested object properties are stored as blobs. When you specify such a property using ConvertTo-MySQLiteDB, it is exported using Export-Clixml. The content of the resulting text file is converted to a byte array which is stored in the database table. ConvertFrom-MySQLiteDB should automatically convert it back to a deserialized version of the original object. You can use this stand-alone function to handle the conversion yourself.

## EXAMPLES

### Example 1

```shell
PS C:\> Invoke-MySQLiteQuery -path D:\temp\myproc.db -Query "Select name,id,ws,totalprocessortime from process where id=6624" | Select-Object name,id,ws,@{Name="TotalCPU";Expression = {Convert-MySQLiteByteArray $_.totalprocessortime}}

Name       ID        WS TotalCPU
----       --        -- --------
sqlservr 6624 778153984 00:00:58.0468750
```

The TotalProcessTime property will be returned as a byte array. Convert-MySQLiteByteArray restores it to its original form.

## PARAMETERS

### -BlobProperty

Specify the byte array from the blob property.

```yaml
Type: Byte[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[ConvertFrom-MySQLiteDB](ConvertFrom-MySQLiteDB.md)
