# Changelog for MySQLite

## 0.7.0

+ Moved public functions to individual files.
+ Updated verbose output in private functions.
+ Updated commands to better handle null property values. [Issue #3](https://github.com/jdhitsolutions/MySQLite/issues/3)
+ Added online help links.
+ Updated module manifest.
+ Updated `README.md`.

## v0.6.0

+ Fixed `ConvertTo-DB` alias.
+ Updated `README.md`.
+ Updated help documentation.
+ Published to the PowerShell Gallery

## v0.5.0

+ Fixed assembly loading problems thanks to insights from @TobiasPSP.
+ Modified functions to accept database connection from the pipeline by value.
+ Fixed Verbose message strings.
+ Help updates.
+ Updated `README.md`

## v0.4.0

+ Renamed `Convert-MySQLiteDB` to `ConvertFrom-MySQLiteDB` (Issue #2)
+ Modified `ConvertTo-MySQLiteDB` to create property maps for each type (Issue #5)
+ Added `-PropertyMap` parameter to `ConvertFrom-MySQLiteDB` (Issue #6)
+ Modified `Get-MySQLiteDBTable` to include table details (Issue #7)
+ Modified `ConvertTo-MySQLiteDB` to let user specify a typename (Issue #8)
+ Added `Get-MySQLiteDB` and its alias `Get-DB`
+ Modified `Invoke-MySQLiteQuery` to better support `PRAGMA` queries
+ Modified `Get-MySQLiteDBTable` to include database source
+ Added `mySQLiteTableDetail.format.ps1xml` formatting file
+ Added `mySQLiteDB.format.ps1xml` formatting file
+ Modified `New-MySQLiteDBTable` to use existing connection and keep alive
+ Modified `ConvertTo-MySQLiteDB` to use existing connection
+ Changed alias `Export-DB` to `ConvertFrom-DB`
+ Added `Open-MySQLiteDB` and `Close-MySQLiteDB` (Issue #10)
+ added help documentation (Issue #4)

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
