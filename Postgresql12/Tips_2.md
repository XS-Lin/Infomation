# postgresql tips #

## テーブル所有者変更 ##

ALTRE TABLE ... OWNER TO ... でテーブル所有者変更の場合、テーブルとインデックスの所有者が変更される。
パテーションは変更されないが、以下のコマンドですべてのテーブル、インデックスを変更できる。

~~~sql
SELECT 'ALTRE TABLE ' || schemaname || '.' || tablename || ' OWNER TO newowner;'
FROM pg_tables
WHERE tableowner = 'oldowner';
~~~

## オブジェクト所有者確認 ##

~~~sql
SELECT a.rolname as owner,c.relname as objname,c.relkind as objkind
FROM pg_class c
JOIN pg_authid a
ON c.relowner = a.oid
UNION ALL
SELECT a.rolname,p.proname,p.prokind
FROM pg_proc
JOIN pg_authid a
ON p.proowner = a.oid
~~~

## オブジェクト所有者変更 ##

~~~sql
--シーケンス
SELECT 'ALTER SEQUENCE ' || n.nspname || '.' || c.relname || ' OWNER TO newowner;'
FROM pg_class c
JOIN pg_authid a ON c.relowner = a.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'S' AND a.rolname = 'oldowner';
-- VIEW
SELECT 'ALTER VIEW ' || n.nspname || '.' || c.relname || ' OWNER TO newowner;'
FROM pg_class c
JOIN pg_authid a ON c.relowner = a.oid
JOIN pg_namespace ON c.relnamespace = n.oid
WHERE c.relkind = 'v'
AND a.rolname = 'wdb01ope1';
-- 関数
SELECT 'ALTER FUNCTION ' || n.nspname || '.' || p.proname || '(' || oidvectortypes(p.proargtypes) || ')' || ' OWNER TO newowner;'
FROM pg_proc p
JOIN pg_authid a ON p.proowner = a.oid
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.prokind = 'f' AND a.rolname = 'oldowner';
~~~

## 内部機能 ##

[describe.c](https://github.com/postgres/postgres/blob/master/src/bin/psql/describe.c)

## フォルダ内すべてのsqlファイル実行 ##

~~~bash
ls | awk '{printf "\\i %s\n",$1}' | psql db_name -o db.log 2>error.log
~~~
