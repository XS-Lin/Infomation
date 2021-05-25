# Postgresql 12 Tips #

## Postgresql 12 Source Code ##

[source code](https://github.com/postgres/postgres)

## 各種定義取得 ##

~~~sql
\l+
\df pg_get*def
\dt tablename*
describe tablename1
~~~

## docker postgresql env ##

~~~bash
# default db cluster path
/var/lib/postgresql/data
# default postgresql installed path
/usr/lib/postgresql/12/bin
export PATH=/usr/lib/postgresql/12/bin:$PATH
~~~

## 日本語で結果出力 ##

~~~bash
PGCLIENTENCODING=SJIS psql -d <dbname> -c "SELECT ..." -o <out_filename>
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

## テーブルスペースの確認 ##

~~~sql
select oid,spcname,spcowner,spcacl,spcoptions,pg_tablespace_location(oid) from pg_tablespace;
~~~

## データベースのサイズ ##

~~~cpp
/*
以下のファイルを参照し、psql -l のソースコード確認
/src/bin/psql/describe.c
/src/backend/utils/dbsize.c
linuxで<sys/stat.h>を参照している

linuxのstatコマンドも<sys/stat.h>参照している
http://github.com/rofl0r/gnulib/blob/master/lib/stat.c


--apparent-size ディスク上のサイズ
--block-size    duの出力の単位(default:1024)
du --apparent-size --block-size=1024
*/

// Windows の場合 /src/include/port/win32_port.h でlinuxの <sys/stat.h> を互換する 
include <sys/stat.h>

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

## ユーザテーブル取得(パーティション深さ) ##

~~~sql
WITH RECURSIVE t(rel_oid,child_oid,level,root_oid) AS (
  SELECT
    pg_class.oid AS rel_oid,
    pg_inherits.inhrelid AS child_oid,
    CASE WHEN pg_inherits.inhrelid IS NULL 0 ELSE 1 AS level,
    pg_class.oid AS root_oid
  FROM pg_class
  LEFT JOIN pg_inherits
  ON pg_class.relkind IN ('p','r')
  AND pg_class.relnamespace = 'public':: regnamespace
  AND pg_class.relowner = 'username'::regrole
  UNION ALL
  SELECT
    t.child_oid,
    pg_inherits.inhrelid,
    t.level + 1,
    t.root_oid
  FROM t
  INNER JOIN pg_inherits
  ON t.child_oid = pg_inherits.inhparent
)
SELECT
  root_oid::regclass AS table_name,
  MAX(t.level) AS level
FROM t
WHERE NOT EXISTS (SELECT 'x' FROM pg_inherits WHERE pg_inherits.inhrelid = t.root_oid)
GROUP BY root_oid
ORDER BY table_name
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

## シーケンス一覧取得(serial以外) ##

~~~sql
SELECT c.relname
FROM pg_class c
WHERE c.relkind = 'S'
AND NOT EXISTS (
  SELECT 'x'
  FROM pg_depend
  WHERE pg_depend.obhid = c.oid
  AND pg_depend.deptype = 'a'
)
;
~~~

## シーケンス(serial)と付随するテーブル取得 ##

~~~sql
SELECT
  n1.nspname table_schema,
  c1.relname table_name,
  n2.nspname seq_schema,
  c2.relname seq_name
FROM
  pg_class c1
JOIN
  pg_namespace n1 ON c1.relnamespace = n1.oid
JOIN
  pg_depend d ON d.refobjid = c1.oid
JOIN
  pg_class c2 ON d.objid = c2.oid AND c2.relkind = 'S'
JOIN
  pg_namespace n2 ON c2.relnamespace = n2.oid
; 
~~~

## Free Space Map ##

[pg_freespacemap](https://www.postgresql.jp/document/12/html/pgfreespacemap.html)
[pg_visibility](https://www.postgresql.jp/document/12/html/pgvisibility.html)

~~~sql
CREATE EXTENSION pg_freespacemap;
SELECT * FROM pg_freespacemap('table_name');

SELECT * FROM pg_freespace('foo');
SELECT * FROM pg_freespace('foo', 7);
~~~

## Page 調査 ##

[pageinspect](https://www.postgresql.jp/document/12/html/pageinspect.html)

~~~sql
CREATE EXTENSION pageinspect;
CREATE TABLE tbl (data text);
INSERT INTO tbl VALUES('A');
SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('tbl', 0));
~~~

## 共有バッファキャッシュで何が起きているかをリアルタイムに確認 ##

[pg_buffercache](https://www.postgresql.jp/document/12/html/pgbuffercache.html)

~~~sql

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
   SELECT pid,application_name,state,sent_lsn FROM pg_stat_replication;
   SELECT pg_current_wal_lsn();
   SELECT * FROM pg_replication_slots;
   ~~~

* standby server

   ~~~sql
   SELECT pid,sender_host,status,received_lsn FROM pg_stat_wal_receiver;
   SELECT pg_last_wal_receive_lsn();
   ~~~

* 情報
  * pg_current_wal_lsnとpg_stat_replication.sent_lsn 違いが大きい場合、マスタサーバが高負荷状態であること可能性があり
  * pg_stat_replication.sent_lsnとpg_last_wal_receive_lsn の差異は、ネットワーク遅延、またはスタンバイが高負荷状態であることを示す可能性があり
  * pg_last_wal_replay_lsnとpg_stat_wal_receiver.received_lsnとの違いが大きい場合、WALのリプレイを上回る速さでWALが受信されている

## Streaming Replication 設定 ##

### slotなし ###

* standby server

   ~~~bash
   /var/lib/postgresql/data/postgresql.conf
   synchronous_standby_names = '1 (testdb1)'
   primary_conninfo = 'host=172.17.0.3 port=5432 user=repl_user password=password application_name=testdb1'
   ~~~

### slotあり ###

* primary server

   ~~~sql
   --マスタ(slot作成)
   SELECT * FROM pg_create_physical_replication_slot('testslot2');
   ~~~

* standby server

   ~~~bash
   /var/lib/postgresql/data/postgresql.conf
   synchronous_standby_names = '1 (testdb1)'
   primary_conninfo = 'host=172.17.0.3 port=5432 user=repl_user password=password application_name=testdb1'
   primary_slot_name = 'testslot2'
   ~~~

## LSNからWALファイル名確認 ##

   ~~~sql
   SELECT pg_walfile_name('1/00002D3E');
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

## VACCUM設定 ##

[AUTOVACUUM](https://www.postgresql.jp/document/12/html/routine-vacuuming.html#AUTOVACUUM)
[Chapter 6 Vacuum Processing](se)

* AUTOVACUUM
  * テーブルのrelfrozenxid値(pg_class.relfrozenxid)がautovacuum_freeze_max_age トランザクション年齢よりも古い場合、そのテーブルは常にバキューム実施
  * 以外の場合、不要となったタプル数が「バキューム閾値」を超えると、バキューム実施
    * バキューム閾値 = バキューム基礎閾値 + バキューム規模係数 * タプル数
      * バキューム基礎閾値 autovacuum_vacuum_threshold (default 50)
      * バキューム規模係数 autovacuum_vacuum_scale_factor (default 0.2)
      * タプル数 pg_class.reltuples
    * 解析閾値 = 解析基礎閾値 + 解析規模係数 * タプル数
* VACUUM

* 関連パラメータ
  * vacuum_freeze_min_age               (default=50000000)
  * vacuum_freeze_table_age             (default=150000000,max=0.95 * autovacuum_freeze_max_age)
  * autovacuum_freeze_max_age           (default 200000000)
  * vacuum_multixact_freeze_min_age     (default=5000000)
  * vacuum_multixact_freeze_table_age   (default=150000000)
  * autovacuum_multixact_freeze_max_age (default=400000000)
  * autovacuum_naptime                  (default=1min)
  * autovacuum_max_works                (default=3)

~~~sql
--relfrozenxid 凍結切捨てXID。この切り捨てXIDよりも古いXIDを持つトランザクションにより挿入されたすべての行は凍結状態であることが保証されています
SELECT c.oid::regclass as table_name,
       greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind IN ('r', 'm');

--datfrozenxid データベース内で現れる凍結されていないXIDの下限値
SELECT datname, age(datfrozenxid) FROM pg_database;

mxid_age(pg_class.relminmxid)

--VACUUM FULL実施すべきタイミングは？ベストプラクティスはない。
CREATE EXTENSION pg_freespacemap;
SELECT
  count(*) as "number of pages",
  pg_size_pretty(cast(avg(avail) as bigint)) as "Av. freespace size",
  round(100 * avg(avail)/8192 ,2) as "Av. freespace ratio"
FROM
  FROM pg_freespace('table_name');

--pg_stat_user_tablesのlast_vacuum列、last_autovacuum列で手動VACUUM、自動VACUUMが起動した時刻を確認できる
--同じくpg_stat_user_tablesのn_dead_tup列で不要な行(dead-tuple)が除去されたことを確認できる
~~~

### 内部情報 ###

1. 不要なタプル削除
   * ブロック(page)内の不要なタプルを削除し、有効なタプルを詰める
   * 不要なタプルを参照しているインデックスタプルを削除

2. 古い txid 凍結
   * 必要に応じて古い txid 凍結
     * 凍結処理は基本的にlazy modeで動作するが、特定の条件を満たす場合はeager modeで動作する。
     * Lazy Mode
       * VACUUM対象テーブルの行の t_xmin < freezeLimit_txid は凍結対象になる。freezeLimit_txid = (OldestXmin − vacuum_freeze_min_age)
       * OldestXmin 実行中のトランザクションのtxid。実行中のトランザクションがない場合、VACUUMコマンドのtxid。
     * Eager Mode
       * 条件: pg_database.datfrozenxid < (OldestXmin − vacuum_freeze_table_age) ※VMを参照してブロック(page)にあるタプルがすべて凍結した場合が該当ブロックをスキップ
       * pg_database.datfrozenxid は各テーブルの一番古い凍結したtxidを保持する。
   * 凍結対象 txid に関するシステムカタログ更新(pg_database、pg_class、pg_stat_all_tablesなど)
     * pg_database
       * datfrozenxid ※一部のテーブルがeager modeで凍結処理した場合更新しない。すべてのテーブルがeager modeで凍結処理した場合は更新
     * pg_class
       * relfrozenxid
   * 不要な clog 削除
     * pg_database.datfrozenxid が更新された場合、pg_xact以下の不要なclogファイルを削除する

3. 内部情報更新
   * 処理対象のテーブルのFSMとVMを更新
   * pg_stat_all_tablesなど更新

VACUUM FREEZE (VACUUM FULL)はeager modeで凍結処理実施、freezeLimit=OldestXmin (not「OldestXmin - vacuum_freeze_min_age」)

## pg_control確認 ##

~~~bash
pg_controldata $PGDATA
~~~

## backup_label確認 ##

~~~bash
cat $PGDATA/backup_label
# CHECKPOINT LOCATION
# START WAL LOCATION --スタンバイ初回起動時使用
# START TIMELINE --11以後
cat $PGDATA/backup_label.old #スタンバイリカバリー完了
~~~

## PITR ##

~~~bash
# postgresql.conf
restore_command = 'cp /mnt/server/archived/%f %p'
recover_target_time = "2020-11-6 12:05 GMT"

touch /usr/local/pgsql/data/recovery.signal
~~~

[10.2. How Point-in-Time Recovery Works](http://www.interdb.jp/pg/pgsql10.html)
Where are WAL segments/Archive logs read from?
  Normal recovery mode – from the pg_xlog subdirectory (in version 10 or later, pg_wal subdirectory) under the base directory.
  PITR mode – from an archival directory set in the configuration parameter archive_command.
Where is the checkpoint location read from?
  Normal recovery mode – from a pg_control file.
  PITR mode – from a backup_label file.

## 容量監視 ##

* df 、du –s などで以下の領域監視
  * データファイル
  * ­WALファイル
  * アーカイブ領域
* データベースやオブジェクトサイズは関数で確認
  * pg_database_size(‘database’)
  * pg_relation_size(‘object’)
  * ­pg_total_relation_size(‘table’)

## インデックスの劣化 ##

­pg_classのreltuples、relpagesを参照し、ページが多きい時にREINDEXなど再作成

## tablespace内部調査 ##

~~~sql
drop tablespace space_name; --ERROR: tablespace "space_name" is not empty
select c.relname,t.spcname from pg_class c join pg_tablespace t on c.reltablespace = t.oid where t.spcname = 'space_name';
~~~

## PostgreSQLの物理情報 ##

* page
  * header
    * ページについての一般情報 [PageHeaderDataのレイアウト](https://www.postgresql.jp/document/12/html/storage-page-layout.html)
    * ソースファイル
      * [PageHeaderData](https://github.com/postgres/postgres/blob/master/src/include/storage/bufpage.h)
  * tuple
    * アイテム識別子 [テーブル行のレイアウト](https://www.postgresql.jp/document/12/html/storage-page-layout.html)
    * ソースファイル
      * [ItemIdData](https://github.com/postgres/postgres/blob/master/src/include/storage/itemid.h)

* buffer_tag
  * ディスク上にあるPageのポインター、データの構成:'{(tablespace,database,relation),forkNum,blockNum}'
  * ソースファイル
    * [BufferTag](https://github.com/postgres/postgres/blob/master/src/include/storage/buf_internals.h)
    * [ForkNumber](https://github.com/postgres/postgres/blob/master/src/include/common/relpath.h)
    * [BlockNumber](https://github.com/postgres/postgres/blob/master/src/include/storage/block.h)

* buffer_id
  * メモリ上にあるPageのポインター、データの構成:int
    * 関連ソースファイル
      * [BufferDesc](https://github.com/postgres/postgres/blob/master/src/include/storage/buf_internals.h)
      * [HeapTupleHeaderData](https://github.com/postgres/postgres/blob/master/src/include/access/htup_details.h)

* 内部情報取得
  * [pageinspect](https://www.postgresql.jp/document/12/html/pageinspect.html)
    * get_raw_page
    * page_header
    * fsm_page_contents
      * [freespace README](https://github.com/postgres/postgres/tree/master/src/backend/storage/freespace)
    * heap_page_items
    * tuple_data_split
    * heap_page_item_attrs
    * bt_metap
    * bt_page_stats
    * bt_page_items
  * [pg_buffercache](https://www.postgresql.jp/document/12/html/pgbuffercache.html)
    * pg_buffercache

## PostgreSQLのアーキテクチャ ##

* プロセス
  * Postgres Server Process
  * Backend Processes
  * Background Processes
    * background writer
      * 動作
        * flush dirty pages little by little to reduce the influence of the intensive writing of checkpointing,flushes max bgwriter_lru_maxpages (default: 100)
      * 実行タイミング
        * wakes every bgwriter_delay (default: 200ms)
    * checkpointer
      * 動作
        * writes a XLOG record called checkpoint record to the current WAL segment (contains the location of the latest REDO point)  and flushes dirty pages whenever checkpointing starts
      * 実行タイミング
        * checkpoint_timeout (default: 5min)
        * the total size of the WAL segment files in the pg_wal > max_wal_size (default: 1GB)
        * PostgreSQL server stops in smart or fast mode
        * CHECKPOINT command manually
    * autovacuum launcher
      * 動作
        * invokes autovacuum_max_works workers (default: 3)
      * 実行タイミング
        * wakes every autovacuum_naptime (default: 1min)
    * WAL writer
      * 動作
        * This process writes and flushes periodically the WAL data on the WAL buffer to persistent storage.
      * 実行タイミング
        * WAL segment has been filled up
        * The function pg_switch_xlog has been issued
        * archive_mode is enabled and the time set to archive_timeout has been exceeded
    * statistics collector
    * logging collector
    * archiver
      * 動作
        * archive_command 実行
      * 実行タイミング
        * WAL segment switche

* メモリ
  * Local Memory Area
    * work_mem
    * maintenance_work_mem
    * temp_buffers
  * Shared Memory Area
    * shared buffer pool
    * WAL buffer
    * commit log

* プロセス取得
  * ps -ef | grep postgres # get pid
  * pstree -p pid
