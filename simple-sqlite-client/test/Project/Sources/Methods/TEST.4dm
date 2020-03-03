//%attributes = {}
$path:=Get 4D folder:C485(Current resources folder:K5:16)+"chinook.db"

$SQL:="SELECT\n    trackid,\n    name,\n    composer,\n    unitprice\nFROM\n    tracks;"

$params:=New collection:C1472()

$status:=SQLite EXECUTE ($path;$SQL;$params)