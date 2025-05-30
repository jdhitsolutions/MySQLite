# Release Notes

## mySQLite 1.0.0

### Added

- Added assembly for ARM64 on Windows.
- Added new sample database `ProcessData.db` to the `samples` folder.

### Changed

- Updated `Import-MySqliteDB` and `Export-MySqliteDB` to better handle importing exported databases. __Breaking changes as the export process creates a different JSON file.__
- Changed `Write-Verbose` commands to 'Write-Debug` in private helper functions.
- Revised the PRAGMA query `Get-MySqliteDB` to get all database information in a single query.
- Updated`Get-MySqliteDB` to display missing database information and extended the custom object to include a few more properties.
- Updated verbose messaging.
- Updated online help links.
- Updated `README.md`.

### Fixed

- Updated error handling in `Invoke-MySqliteQuery` to write errors instead of warnings. __This is a breaking change__. [[Issue #25](https://github.com/jdhitsolutions/mySQLite/issues/25)]
- Updated `Get-MySqliteDB` to handle database files stored in OneDrive. [[Issue #27](https://github.com/jdhitsolutions/mySQLite/issues/27)]

[1.0.0]: https://github.com/jdhitsolutions/MySQLite/compare/v0.14.0..v1.0.0
