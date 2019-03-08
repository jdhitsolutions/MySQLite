# Changelog for MySQLite

## v0.2.0

+ corrected warning messages for bad file names
+ Added better error handling in `New--mySQLiteDB` when specifying an invalid location
+ Added aliases `ndb`, `ndbt`,`Export-DB`,`Get-DB`
+ Fixed bug in `New-MySQLiteDatabaseTable` that wasn't creating the table
+ Modified `New-MySQLiteDatabaseTable` to use parameter sets. Now you can create a table with just the names or with types
+ Modified `Invoke-mySQLiteQuery` to have options of writing Select query results as a PSCustomeobject or Datatable
+ Added `Export-mySQLiteDatabase`
+ Added `Get-MySQLiteTable`
+ restructured module layout

## v0.1.1

+ added parameter aliases

## v0.1.0

+ initial files