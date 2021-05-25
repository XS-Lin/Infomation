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

## アクセス権限 ##

df+ = pg_proc.proacl
dt+ = pg_class.relacl

## フォルダ内すべてのsqlファイル実行 ##

~~~bash
ls | awk '{printf "\\i %s\n",$1}' | psql db_name -o db.log 2>error.log
~~~

## 関数性能テスト ##

~~~sql
DECLARE
  start_t timestamp;
  end_t timestamp;
  iter int;
BEGIN
  SELECT clock_timestamp INTO start_t;
  FOR iter IN 0..100000 LOOP
    PERFORM func_test();
  END LOOP;
  SELECT clock_timestamp INTO end_t;
  RAISE INFO '%',end_t-start_t;
END;
~~~

## pass cmd param to file in psql ##

~~~bash
psql -f gen_data.sql -v data_count=100 -At
~~~

~~~sql
--gen_data.sql
SELECT format('INSERT INTO table_name VALUES (%s,null,'''','''')') FROM generate_series(1,:data_count) AS s(a);
~~~

## アーカイブ失敗や長期スタンバイダウンなど原因で $PGDATA/pg_walにファイルが大量にたまる対策 ##

事象:アーカイブ失敗の原因でPGDATA/pg_walにファイルが大量に溜まり、ハードディスク容量不足でDBが落ちて再起動失敗
一時対策:不要な一時ファイルを削除し、ハードディスク容量がすごしある状態でDB再起動成功したが、ハードディスク容量が少ないまま
対策：以下のようにWALをクリアし、アーカイブ方法再検討

~~~bash
# チェックポイントを含むwalファイル名取得
pg_controldata -D $PGDATA | grep REDO
# ファイル一覧取得(必要であればファイル保存)
pg_archivecleanup -d -n $PGDATA/pg_wal <WAL>
# 不要になったWALを削除
pg_archivecleanup -d $PGDATA/pg_wal <WAL>
~~~
