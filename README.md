![version](https://img.shields.io/badge/version-19%2B-5682DF)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-simple-sqlite-client)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-simple-sqlite-client)

# simple-sqlite-client
Simple SQLite client using libsqlite3.

### Examples

based on the tutorial from [sqlitetutorial.net](https://www.sqlitetutorial.net/sqlite-select/) 

```
$path:=Get 4D folder(Current resources folder)+"chinook.db"
$SQL:="SELECT trackid, name, composer, unitprice FROM tracks;"
$params:=New collection()
$status:=SQLite EXECUTE ($path;$SQL;$params)
```

### Remarks

* using native ``libsqite3`` on Mac
* using ``vcpkg`` ``sqlite-amalgamation-329000`` on Windows
