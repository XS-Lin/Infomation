# Postgresql 12 Tips #

## Postgresql 12 Source Code ##

[source code](https://github.com/postgres/postgres)

## docker postgresql env ##

~~~bash
# default db cluster path
/var/lib/postgresql/data
# default postgresql installed path
/usr/lib/postgresql/12/bin
export PATH=/usr/lib/postgresql/12/bin:$PATH
~~~

## 実行プラン確認 ##

~~~sql
--jsonで指定すると、paAdmin4で可視化で見られる。
explain (FORMAT json) select * from test_tb format;
~~~

## 接続ユーザ確認 ##

~~~sql
select datname,usename,application_name,client_addr,client_port from pg_stat_activity;
~~~

## テーブルファイル名を特定 ##

~~~bash
oid2name -d test -i
~~~

## その他 ##

pgsql_tmpディレクトリには、work_memが不足した場合に一時ファイルが作成される

SELECT xmin, xmax, * FROM t1;　で各トランザクションの変化を確認できる
SELECT pg_stat_reset();　統計情報はデータベース単位でリセットできる
xact_start、query_startなどから長時間実行したまま応答のないSQLの特定が可能
temp_files、temp_bytesにてwork_memの不足状況を確認

## ユーザテーブル取得(パテーションの物理テーブルと継承関係の子テーブルを除外) ##

~~~sql
select relname
from pg_class
where relkind in ('r','p')
and not exists (
    select 'x'
    from pg_inherits
    where pg_inherits.inhrelid = pg_class.oid
)
and exists (
    select 'x'
    from pg_namespace
    where pg_namespace.oid = pg_class.relnamespace
    and pg_namespace.nspname in ('public')
)
~~~

## ユーザテーブル取得(パテーション関係がないテーブル) ##

~~~sql
SELECT relname
FROM pg_class
WHERE relkind = 'r'
AND NOT EXISTS (SELECT 'x' FROM pg_inherits WHERE pg_inherits.inhrelid = pg_class.oid)
~~~

## ユーザテーブル取得(パテーション関係があるテーブル) ##

~~~sql
--partition_table_name,table_name
SELECT
  (SELECT relname FROM pg_class WHERE pg_class.oid = p.oid) partition_table_name,
  (SELECT relname FROM pg_class WHERE pg_class.oid = p.poid) table_name
FROM (
  SELECT oid,level1.inhrelid as poid,level2.inhrelid as ppoid
  FROM pg_class
  INNER JOIN pg_inherits level1
  ON pg_class.oid = level1.inhparent
  AND pg_class.relkind = 'p'
  WHERE NOT EXISTS (SELECT 'x' FROM pg_inherits level2 WHERE level1.inhrelid = level2.inhparent)
) p
;
--partition_table_name,sub_partition_table_name,table_name
SELECT
  (SELECT relname FROM pg_class WHERE pg_class.oid = p.oid) partition_table_name,
  (SELECT relname FROM pg_class WHERE pg_class.oid = p.poid) sub_partition_table_name,
  (SELECT relname FROM pg_class WHERE pg_class.oid = p.ppoid) table_name
FROM (
  SELECT oid,level1.inhrelid as poid,level2.inhrelid as ppoid
  FROM pg_class
  INNER JOIN pg_inherits level1
  ON pg_class.oid = level1.inhparent
  AND pg_class.relkind = 'p'
  INNER JOIN pg_inherits level2
  ON level1.inhrelid = level2.inhparent
  WHERE NOT EXISTS (SELECT 'x' FROM pg_inherits level3 WHERE level2.inhrelid = level3.inhparent)
) p
;

~~~

## テーブルの列一覧取得(システム列除外) ##

~~~sql
select
  pg_attribute.attname,
  pg_type.typename,
  pg_attribute.attlen,
  pg_attribute.atttypemod,
  pg_attribute.attnotnull,
  pg_attribute.attndims,
  pg_attribute.attnum
from pg_attribute
join pg_type
on pg_attribute.atttyped = pg_type.oid
where pg_attribute.attrelid = (select oid from pg_class where relname='testtable')
and pg_attribute.attnum > 0
order by pg_attribute.attnum
~~~

## テーブルのインデックス一覧取得 ##

~~~sql
select
  pg_class.relname as table_name,
  (select pg_class.relname from pg_class where pg_class.oid = pg_index.indexrelid) as index_name,
  array(
    select pg_get_indexdef(pg_index.indexrelid,k+1,true)
    from generate_subscripts(pg_index.indkey,1) as k
    order by k
  ) as index_cols,
  pg_get_expr(pg_index.indexors,pg_class.oid) as expr
from pg_index
join pg_class
on pg_index.indrelid = pg_class.oid
where pg_class.relname = 'tb_name'
;
~~~

## Free Space Map ##

~~~sql
CREATE EXTENSION pg_freespacemap;
SELECT * FROM pg_freespacemap('table_name');
~~~

## Page Detail ##

~~~sql
CREATE EXTENSION pageinspect;
CREATE TABLE tbl (data text);
INSERT INTO tbl VALUES('A');
SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('tbl', 0));
~~~

## Transaction Snapshot ##

Transaction IDがxminより小さいものは使用済み、xmax以上は未使用、xip_listにある分は使用中または未使用

~~~sql
SELECT txid_current_snapshot();
--xmin:xmax:xip_list
--100:104:100,102
~~~

## How to show pg_class.relfrozenxid and pg_database.datfrozenxid ##

~~~sql
VACUUM table_1;

SELECT n.nspname as "Schema", c.relname as "Name", c.relfrozenxid
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','')
AND n.nspname <> 'information_schema' AND n.nspname !~ '^pg_toast'
AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY c.relfrozenxid::text::bigint DESC;

SELECT datname, datfrozenxid FROM pg_database WHERE datname = 'testdb';
~~~

## When should I do VACUUM FULL ? Unfortunately no best practice ##

~~~sql
CREATE EXTENSION pg_freespacemap;
SELECT count(*) as "number of pages",pg_size_pretty(cast(avg(avail) as bigint)) as "Av. freespace size",round(100 * avg(avail)/8192 ,2) as "Av. freespace ratio" FROM pg_freespace('accounts');
--テーブルのページが複数かつほぼ空の場合、VACUUM FULLを実行するとページが減る
~~~

## LSNとwalfileの関係 ##

[バックアップ制御関数](https://www.postgresql.jp/document/12/html/functions-admin.html)

~~~sql
select pg_start_backup('label_goes_here');  --オンラインバックアップの実行準備、戻り値はpg_lsn
select pg_stop_backup();  --排他的オンラインバックアップの実行の終了、戻り値はpg_lsn
SELECT pg_current_wal_flush_lsn();  --先行書き込みログの現在のフラッシュ位置を取得する
SELECT pg_current_wal_insert_lsn();  --現在の先行書き込みログの挿入位置の取得
SELECT pg_current_wal_lsn();  --現在の先行書き込みログの書き込み位置を取得
SELECT pg_walfile_name('1/00002D3E');  --先行書き込みログの位置をファイル名に変換
SELECT pg_walfile_name_offset('1/00002D3E'); --先行書き込みログの位置を、ファイル名とファイル内の10進のバイトオフセットに変換
~~~

## control data 参照 ##

~~~bash
pg_controldata $PGDATA
~~~

## Normal recovery と PITR の違い ##

1. Where are WAL segments/Archive logs read from?
   * Normal recovery mode – from the pg_xlog subdirectory (in version 10 or later, pg_wal subdirectory) under the base directory.
   * PITR mode – from an archival directory set in the configuration parameter archive_command.
1. Where is the checkpoint location read from?
   * Normal recovery mode – from a pg_control file.
   * PITR mode – from a backup_label file.

## Streaming Replication 情報確認 ##

* primary server

   ~~~sql
   SELECT application_name,state FROM pg_stat_replication;
   ~~~

* standby server

   ~~~sql
   SELECT sender_host,status FROM pg_stat_wal_receiver;
   ~~~

## Streaming Replication エラー動作 ##

synchronous_standby_namesに設定した同期対象が接続できない場合、トランザクションコミットできなくなる

~~~bash
# synchronous_standby_names = ''
pg_ctl -D $PGDATA reload
~~~

## Postgresql File ##

~~~sql
SELECT relname,oid,relfilenode FROM pg_class WHERE relname = 'relname';
SELECT pg_relation_filepath('relname');
~~~