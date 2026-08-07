![deprecated](https://img.shields.io/badge/-deprecated-inactive)

use [miyako/4d-plugin-soci](https://github.com/miyako/4d-plugin-soci)

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-simple-sqlite-client)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-simple-sqlite-client/total)

# simple-sqlite-client

Simple SQLite Client lets 4D code run arbitrary SQL against a local SQLite database file. It drives the SQLite C library (`sqlite3.h`) directly — open the file, prepare and execute one statement, and return every result row as plain 4D objects/collections, with no intermediate ODBC or 4D-native SQL layer involved.

| Command | Returns | Purpose |
|---|---|---|
| [`SQLite EXECUTE`](#sqlite-execute) | `Object` | Run one SQL statement (optionally parameterized) against a SQLite file and get the rows back as an object collection. |

**Platforms:** macOS, Windows

---

## Requirements & platform notes

- No special OS permission is required — this opens an ordinary local file through the SQLite library, not a system-protected resource.
- `manifest.json` marks the command `threadSafe: true`. Each call opens and closes its own private SQLite connection and statement, with no shared/global state between calls, so this holds up under concurrent calls.
- The database file at `path` is created automatically if it doesn't already exist (SQLite's own default behavior for `sqlite3_open()` — it opens with create+read/write permissions). If you need "must already exist" semantics, check for the file yourself before calling the command.
- A long-running query yields periodically rather than blocking 4D's interface for its whole duration — you don't need to run it On Server or in a worker process just to avoid freezing the UI, though very large result sets still cost the memory/time to build the return collection.
- **Unsupported bound parameter types are silently skipped, not converted or reported as an error.** If an element in the `params` collection isn't one of the supported kinds (see below), its `?` placeholder is left unbound and SQLite will treat it as `NULL` or raise its own binding error — check your parameter values' types if a query behaves unexpectedly.
- This doc describes the corrected source (a use-after-free in text-parameter binding, a partial-result error path, and a connection leak on open failure were fixed during review). If you're running an older compiled build, a query using text parameters may behave unpredictably, and a query that fails partway through may silently return a truncated row set with no `error` key — rebuild from the corrected source to get the behavior described below.

---

## SQLite EXECUTE

### Syntax

```4d
SQLite EXECUTE ( path ; sql ; params ; integerFormat ) → Object
```

| Parameter | Type | Description |
|---|---|---|
| `path` | Text | Full path to the SQLite database file. Created automatically if it doesn't exist. Mandatory. |
| `sql` | Text | The SQL statement to run. Use `?` placeholders for parameters bound from `params`. Mandatory. |
| `params` | Collection | Values bound in order to each `?` placeholder in `sql`. Pass an empty collection if the query has no placeholders. |
| `integerFormat` | Longint | `0` (simple) or `1` (complex) — see below. Optional; omitting it behaves as `0`. |
| Result | Object | `{values : Collection}` on success, `{error : Longint}` on failure — see Description. |

### Description

**`params` and supported bind types.** Each element of `params` is bound positionally to the SQL statement's `?` placeholders (element 0 → first `?`, and so on). Supported 4D value kinds and how they're bound:

- Text → bound as SQL `TEXT` (UTF-8).
- Real (number) → bound as SQL `REAL`.
- Longint → bound as SQL `INTEGER`.
- Boolean → bound as SQL `INTEGER` (`0`/`1`).
- Null → bound as SQL `NULL`.
- Time → bound as a plain SQL `INTEGER` using 4D's internal time encoding. This hasn't been verified against a known value in this review — confirm it matches what you expect before relying on it for date/time comparisons.

Any other kind of collection element (Date, Picture, Blob, another Collection/Object, etc.) is left unbound for that placeholder — see the caveat above.

**`integerFormat` and how INTEGER columns are returned.** This controls how a SQLite `INTEGER` column value comes back:

- `0` (simple, the default): the column is returned as a plain number, using SQLite's 32-bit `int` accessor. Values outside the 32-bit range lose precision.
- `1` (complex): the column is returned as an object with two fields — `intValue` (the same 32-bit number as above) and `int64Value` (the full 64-bit value, as **Text**, since 4D numbers can't losslessly represent the full 64-bit integer range). Use `int64Value` — not `intValue` — for a column that might legitimately hold a value outside 32-bit range (row IDs, counters, etc.).

**How other column types come back**, regardless of `integerFormat`:

- `REAL` → a number.
- `TEXT` → text.
- `BLOB` → an object `{data : Text}`, where `data` is the blob's bytes, Base64-encoded.
- `NULL` → the field is present with a null value.

**Result shape.**

- On a successful query: `{values : Collection}`, where `values` is a collection of one object per row, each keyed by column name using the type mapping above. A query that matches zero rows still returns `values` as an empty collection, not an absent field.
- If the file can't be opened, or the SQL fails to prepare (bad syntax, missing table, etc.): `{error : Longint}` — a raw SQLite result code — with no `values` field at all.
- If the statement prepares and starts returning rows, but then fails partway through execution: `{values : Collection, error : Longint}` — whatever rows were fetched before the failure, plus the SQLite error code that ended it. Treat `values` as a possibly-truncated result in that case, not a confirmed-complete one.

### Example

From the plugin's own test method (`TEST.4dm`):

```4d
//%attributes = {}
$path:=Get 4D folder:C485(Current resources folder:K5:16)+"chinook.db"

$SQL:="SELECT\n    trackid,\n    name,\n    composer,\n    unitprice\nFROM\n    tracks;"

$params:=New collection:C1472()

$status:=SQLite EXECUTE($path; $SQL; $params)

SET TEXT TO PASTEBOARD:C523(JSON Stringify:C1217($status; *))
```

Note that this call only passes 3 arguments — `integerFormat` is omitted and defaults to simple (`0`).

A parameterized query, binding two values to `?` placeholders:

```4d
$path:=Get 4D folder:C485(Current resources folder:K5:16)+"chinook.db"
$SQL:="SELECT trackid, name, unitprice FROM tracks WHERE composer=? AND unitprice<?;"

$params:=New collection:C1472("AC/DC"; 1.5)

$status:=SQLite EXECUTE($path; $SQL; $params)

If ($status.error=Null)
	For each ($row; $status.values)
		ALERT($row.name+" — "+String:C10($row.unitprice))
	End for each
Else
	ALERT("Query failed, SQLite error code: "+String:C10($status.error))
End if
```

Reading a large integer column safely with `integerFormat`:

```4d
$path:=Get 4D folder:C485(Current resources folder:K5:16)+"chinook.db"
$SQL:="SELECT rowid FROM big_table;"
$params:=New collection:C1472()

 // 1 = complex: get both the 32-bit value and the full 64-bit value as text
$status:=SQLite EXECUTE($path; $SQL; $params; 1)

For each ($row; $status.values)
	$bigId:=$row.rowid.int64Value  //Text — use this, not $row.rowid.intValue, for values outside 32-bit range
End for each
```

---

## Error handling & troubleshooting

- **`error` present, `values` absent → the file couldn't be opened or the SQL didn't prepare.** Check `error` against SQLite's own result-code table (e.g. `SQLITE_CANTOPEN`, `SQLITE_ERROR` for a syntax mistake, `SQLITE_MISUSE`); the path or SQL text is the first thing to check.
- **`error` present *alongside* `values` → the query started returning rows, then failed mid-stream.** Treat `values` as a partial result, not a confirmed-complete one. Common causes: another process holding a conflicting lock on the file (`SQLITE_BUSY`), or a constraint/type error surfacing only when a later row is evaluated.
- **A bound parameter appears to have no effect.** Confirm its 4D value is one of the supported kinds (Text, Real, Longint, Boolean, Null, Time) — anything else is silently left unbound rather than erroring, per the caveat above.
- **A large integer column looks wrong or truncated.** You're almost certainly reading `intValue` (32-bit) instead of `int64Value` (full precision, as Text) — pass `1` for `integerFormat` and read the `int64Value` field.
- **A `Time`-bound parameter doesn't match against a column you expect it to.** The exact integer encoding used for `Time` values wasn't independently confirmed in this review — verify it against a known value before depending on it for date/time filtering.
- **Concurrent calls from multiple processes/threads against the *same* database file** can still hit ordinary SQLite-level file locking (`SQLITE_BUSY`) even though the command itself is thread-safe — that's a property of the SQLite file, not a bug in the plugin.

---

## Quick reference

```4d
 // no parameters
$status:=SQLite EXECUTE($path; "SELECT * FROM t;"; New collection:C1472())

 // with bound parameters
$status:=SQLite EXECUTE($path; "SELECT * FROM t WHERE k=?;"; New collection:C1472($key))

 // full 64-bit integer precision
$status:=SQLite EXECUTE($path; "SELECT id FROM t;"; New collection:C1472(); 1)

 // check result
If ($status.error=Null)
	// use $status.values
Else
	// handle $status.error
End if
```
