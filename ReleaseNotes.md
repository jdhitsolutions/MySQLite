# Release Notes

## mySQLite 0.14.0

### Changed

- Updated `Import-MySqliteDB` to use an existing database. The new parameter is called `UseExisting` with an alias of `Append`. _This may be a breaking change_.
- Updated functions with additional verbose output to capture PowerShell version and culture.
- Help updates
- Updated `README.md`

### Fixed

- Modified helper functions to store DateTime values as `yyyy-MM-dd HH:mm:ss` which should better handle culture-related problems. [Issue #23](https://github.com/jdhitsolutions/mySQLite/issues/23) _This may be a breaking change_.

[0.14.0]: https://github.com/jdhitsolutions/MySQLite/compare/v0.13.0..v0.14.0
