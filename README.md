![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-simple-sqlite-client)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-simple-sqlite-client/total)

# simple-sqlite-client
Simple SQLite client using libsqlite3

* macOS library version:
  * `libsqite3-tbd` (system library)

* Windows library version:
  * `sqlite-amalgamation-329000` (vcpkg)

### Syntax

[miyako.github.io](https://miyako.github.io/2024/08/23/4d-plugin-simple-sqlite-client.html)

### Example

```4d
$path:=Get 4D folder(Current resources folder)+"chinook.db"
$SQL:="SELECT trackid, name, composer, unitprice FROM tracks;"
$params:=New collection()
$status:=SQLite EXECUTE ($path;$SQL;$params)
```

```json
{
	"values": [
		{
			"TrackId": 1,
			"Name": "For Those About To Rock (We Salute You)",
			"Composer": "Angus Young, Malcolm Young, Brian Johnson",
			"UnitPrice": 0.99
		},
		{
			"TrackId": 2,
			"Name": "Balls to the Wall",
			"Composer": null,
			"UnitPrice": 0.99
		},
		{
			"TrackId": 3503,
			"Name": "Koyaanisqatsi",
			"Composer": "Philip Glass",
			"UnitPrice": 0.99
		}
	]
}
```
