# Changelog for MySQLite

## v0.3.0

+ Modified `Get-MySqliteDBTable` to accept pipeline input by property name
+ Modified commands to use a database file or an existing database connection
+ Renamed `Export-mySQLiteDatabase` to `ConvertTo-MySQLiteDatabase` which better reflects the command's purpose
+ Added `Convert-MySQLiteDB` to export a database table to PowerShell objects
+ Modified `Invoke-MySQLiteQuery` to write Select query results as an object, hashtable or DataTable
+ Revised private helper functions

## v0.2.0

+ corrected warning messages for bad file names
+ Added better error handling in `New--mySQLiteDB` when specifying an invalid location
+ Added aliases `ndb`, `ndbt`,`Export-DB`,`Get-DB`
+ Fixed bug in `New-MySQLiteDatabaseTable` that wasn't creating the table
+ Modified `New-MySQLiteDatabaseTable` to use parameter sets. Now you can create a table with column names or with column property types.
+ Modified `Invoke-mySQLiteQuery` to have options of writing Select query results as a PSCustomObject or DataTable
+ Added `Export-mySQLiteDatabase`
+ Added `Get-MySQLiteTable`
+ restructured module layout

## v0.1.1

+ added parameter aliases

## v0.1.0

+ initial files