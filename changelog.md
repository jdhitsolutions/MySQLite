# Changelog for MySQLite

## 0.11.1

This release is identical in files to v0.11.0 published on the PowerShell Gallery. This release corrects a problem pushing the 0.11.0 release to GitHub.

## 0.11.0

### Added

- Added private functions `Convert-ToXml` and `Convert-FromXML` to use `[System.Management.Automation.PSSerializer]` instead of temp files. Thanks to @SeSeKenny for the suggestion and code. [Issue #16](https://github.com/jdhitsolutions/MySQLite/issues/16))
- Added sample databases.

### Changed

- Modified private build query function to use the new private serialization functions.
- Modify parameter validation checks on the database file to include all file name extensions as defined for [SQLite in in Wikipedia](https://en.wikipedia.org/wiki/SQLite). This addresses ([Issue #17](https://github.com/jdhitsolutions/MySQLite/issues/17))

  - .sqlite
  - .sqlite3
  - .db
  - .db3
  - .s3db
  - .sl3

- Upgrade `System.Data.SQLite.dll` to version 1.0.117.0.
- General code clean up.
- Updated `README.md`.
- Help updates.
- 
## 0.10.1

+ Add missing online help links.
+ Help updates.

## 0.10.0

+ Updated `New-MySQLiteDBTable` to allow user to specify which column to use as the index. This also required an update to `ConvertTo-MySQLiteDB`. This should fix [Issue #13](https://github.com/jdhitsolutions/MySQLite/issues/13)
+ Revised private function `buildquery` to enclose property names with dashes inside square brackets. Instead of using `msDS-User-Account-Control-Computed` in a SQL query, it will be entered as `[msDS-User-Account-Control-Computed]`. Dashes are not allowed as column headings. This should fix [Issue #14](https://github.com/jdhitsolutions/MySQLite/issues/14)
+ Also updated queries to escape quotes when property values.
+ Updated `ConvertFrom-MySQLiteDB` to better handle importing serialized data.[Issue #15](https://github.com/jdhitsolutions/MySQLite/issues/15)
+ Added a public function, `Convert-MySQLiteByteArray` to convert blob bytes array back to the original object.
+ Changed `Write-Host` commands to `Write-Verbose` in `Import-MySQLiteDB`.
+ Help updates.

## 0.9.2

+ Fixed typo `Get-MySQLiteDB` that was causing an error getting the database file creation time.

## 0.9.1

+ Updated `Get-MySQLiteDB` get target information when using symbolic links.

## 0.9.0

+ Added missing online help links
+ Updated `Get-MySQLiteDB` to handle symbolic links.

## 0.8.0

+ Updated `README.md`.
+ Added functions `Export-MySQLiteDB` and `Import-MySQLiteDB`.
+ Minor code clean up.

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
