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

## テスト ##

~~~bash
docker run --name test-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres

su - postgres
psql
psql -U testuser -d testdb
~~~

~~~sql
CREATE ROLE testuser LOGIN PASSWORD 'testuser1';

CREATE DATABASE testdb WITH OWNER=testuser ENCODING=UTF8 LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;

CREATE TEMPORARY TABLE hash_map_t (
  id int PRIMARY KEY,
  origin text,
  sha_1st_origin text,
  sha_1st text,
  sha_1st_conflict_id int,
  sha_2st_origin text,
  sha_2st text,
  sha_2st_conflict_id int,
  conflict text,
  result text
);

INSERT INTO hash_map_t
WITH temp_t AS (
  SELECT
    s.a AS id,
    to_char(s.a,'FM0000000') AS origin,
    sha224('TEST' || to_char(s.a,'FM0000000')::bytea) sha_data
  FROM
    generate_series(0,9999999) AS s(a)
)
SELECT
  temp_t.id,
  temp_t.origin,
  temp_t.sha_data,
  to_char(
    (
      get_byte(sha_data,0) * 256 * 256 * (256 / 4) +
      get_byte(sha_data,1) * 256 * (256 / 4) +
      get_byte(sha_data,2) * (256 / 4) +
      get_byte(set_bit(set_bit(substring(sha_data from 4 for 1),0,0),1,0),0) / 4
    ) % 10000000,'FM0000000'
  )
FROM
  temp_t
;

UPDATE
  hash_map_t
SET
  result = conflict_list.sha_1st
FROM (
  SELECT
    min(id) AS no_conflict_id,
    sha_1st
  FROM
    hash_map_t
  GROUP BY
    sha_1st
) conflict_list
WHERE
  hash_map_t.id = conflict_list.no_conflict_id
;

WITH temp_t2 AS (
  SELECT
    min(id) AS no_conflict_id,
    sha_1st conflict_txt,
    encode(sha_1st::bytea,'hex') conflict_txt_sha_origin,
    sha224(sha_1st::bytea) conflict_txt_sha_data
  FROM
    hash_map_t
  GROUP BY
    sha_1st
  HAVING count(*) > 1
)
UPDATE
  hash_map_t
SET
  sha_1st_conflict_id = temp_t2.no_conflict_id,
  sha_2st_origin = temp_t2.conflict_txt_sha_origin,
  sha_2st = to_char((get_byte(temp_t2.conflict_txt_sha_data,0) * 256 * 256 * (256 / 4) + 
                     get_byte(temp_t2.conflict_txt_sha_data,1) * 256 * (256 / 4) +
                     get_byte(temp_t2.conflict_txt_sha_data,2) * (256 / 4) +
                     get_byte(set_bit(set_bit(substring(temp_t2.conflict_txt_sha_data from 4 for 1),0,0),1,0),0) / 4 
                     ) % 10000000,'FM0000000')                    
FROM
  temp_t2
WHERE
  hash_map_t.sha_1st = temp_t2.conflict_txt
AND
  hash_map_t.id <> temp_t2.no_conflict_id
;

UPDATE
  hash_map_t
SET
  result = conflict_list.sha_2st
FROM (
  SELECT
    min(id) AS no_conflict_id,
    sha_2st
  FROM
    hash_map_t t1
  WHERE NOT EXISTS (
    SELECT 'x' FROM hash_map_t t2 WHERE t2.result = t1.sha_2st
  )
  GROUP BY
    sha_2st
) conflict_list
WHERE
  hash_map_t.id = conflict_list.no_conflict_id
;

WITH empty_result AS (
  SELECT
    row_number() OVER (ORDER BY s.a) AS rownum,
    to_char(s.a,'FM0000000') AS no
  FROM
    generate_series(0,9999999) AS s(a)
  WHERE NOT EXISTS (
    SELECT 'x' FROM hash_map_t WHERE to_char(s.a,'FM0000000') = hash_map_t.result
  )
  ORDER BY 1
), unallocated_id AS (
  SELECT
    row_number() OVER (ORDER BY hash_map_t.id) AS rownum,
    hash_map_t.id
  FROM
    hash_map_t
  WHERE
    hash_map_t.result IS NULL
)
UPDATE
  hash_map_t
SET
  result = empty_result.no
FROM
  empty_result
JOIN
  unallocated_id
ON empty_result.rownum = unallocated_id.rownum
WHERE
  hash_map_t.id = unallocated_id.id
;

SELECT count(*) FROM (
  SELECT
    min(id),
    result,
    count(*)
  FROM
    hash_map_t
  GROUP BY result
  HAVING count(*) > 1
) test;
SELECT * FROM hash_map_t WHERE origin = result;
~~~
