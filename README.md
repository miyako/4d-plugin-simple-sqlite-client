![version](https://img.shields.io/badge/version-19%2B-5682DF)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-simple-sqlite-client)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-simple-sqlite-client/total)

# simple-sqlite-client
Simple SQLite client using libsqlite3.

*macOS library version:
  * `libsqite3-tbd` (system library)

* Windows library version:
  * `sqlite-amalgamation-329000` (vcpkg)

```
status:=PQ EXECUTE (connect;sql{;params{;format}})
```

<div class="grid">
  <div class="syntax-th cell cell--2">Parameter</div>
  <div class="syntax-th cell cell--2">Type</div>
  <div class="syntax-th cell cell--8">Description</div>
  <div class="syntax-td cell cell--2">path</div>
  <div class="syntax-td cell cell--2">TEXT</div>
  <div class="syntax-td cell cell--8">path for sqlite3_open</div>
  <div class="syntax-td cell cell--2">sql</div>
  <div class="syntax-td cell cell--2">TEXT</div>
  <div class="syntax-td cell cell--8">command for sqlite3_prepare_v2</div>   
  <div class="syntax-td cell cell--2">params</div>
  <div class="syntax-td cell cell--2">COLLECTION</div>
  <div class="syntax-td cell cell--8">values for sqlite3_bind_(text|double|int|null)</div>    
  <div class="syntax-td cell cell--2">format</div>
  <div class="syntax-td cell cell--2">LONGINT</div>
  <div class="syntax-td cell cell--8">see below</div>    
  <div class="syntax-td cell cell--2">status</div>
  <div class="syntax-td cell cell--2">OBJECT</div>
  <div class="syntax-td cell cell--8"></div>      
</div>

blob is returned in base64.

### Examples

based on the tutorial from [sqlitetutorial.net](https://www.sqlitetutorial.net/sqlite-select/) 

```4d
$path:=Get 4D folder(Current resources folder)+"chinook.db"
$SQL:="SELECT trackid, name, composer, unitprice FROM tracks;"
$params:=New collection()
$status:=SQLite EXECUTE ($path;$SQL;$params)
```
