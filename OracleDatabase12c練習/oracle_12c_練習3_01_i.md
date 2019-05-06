# フレッシュバックテクノロジ #

## 目標 ##

ユーザの誤操作によって、データが削除されました。フレッシュバックテクノロジを用いて過去の状態に戻すことができます。

## 条件 ##

1. 同一テーブルの同一レコードのデータが2回更新しました。

1. 同一テーブルの同一レコードのデータが2回更新しましたが、1回目のトランザクションだけキャンセルしたい。

## 検証環境構成 ##

[oracle_12c_検証環境:非CDB]

~~~bash
# oracleユーザ
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=orclnoncdb
export NLS_LANG=Japanese_Japan.AL32UTF8
lsnrctl start lsnr_noncdb
sqlplus / as sysdba
SQL> startup
(略)
SQL> alter system register;
SQL> CREATE USER test_usr IDENTIFIED BY "test_usr" DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
SQL> GRANT CONNECT,PUBLIC,SELECT ANY TABLE,CREATE TABLE,UNLIMITED TABLESPACE TO test_usr;
SQL> alter system set undo_retention = 3600 scope=memory;
SQL> alter tablespace undotbs1 guarantee;
(略)
SQL> exit
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
CREATE TABLE backup_test ( id NUMBER(6), name VARCHAR2(60), description VARCHAR(4000));
SQL> INSERT INTO backup_test VALUES ( 0, 'TEST DATA', '');
SQL> INSERT INTO backup_test VALUES ( 1, 'TEST DATA', '');
SQL> INSERT INTO backup_test VALUES ( 2, 'TEST DATA', '');
(略)
SQL> exit

# 以下は誤操作の内容とします。エラーは時刻A～時刻Bの間に発生します。(本例では19:00～19:10となります。)
sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> set autocommit immediate
SQL> UPDATE backup_test SET name = 'UPDATED' WHERE id = 0;
SQL> UPDATE backup_test SET name = 'UPDATED2' WHERE id = 0;
SQL> set autocommit off
SQL> exit

# 復元手順1操作

sqlplus / as sysdba
SQL> alter database add supplemental log data; # flashback_transaction_queryのDML操作表示有効化
SQL> grant select any transaction to test_usr; # flashback_transaction_query参照権限
SQL> alter database add supplemental log data(primary key) columns; # フラッシュバックトランザクション有効化
SQL> grant execute on dbms_flashback to test_usr; # フラッシュバックトランザクション権限
SQL> shutdown immediate
SQL> startup mount
SQL> alter database flashback on;
SQL> alter database open;
SQL> alter table test_usr.backup_test enable row movement; # フラッシュバック表
SQL> exit

# 以下は誤操作の内容とします。エラーは時刻C～時刻Dの間に発生します。(本例では19:50～20:00となります。)
# select systimestamp from dual;
sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> set transaction name 'TRAN1';
SQL> UPDATE backup_test SET name = 'TRAN1',description='XXX' WHERE id = 1;
SQL> UPDATE backup_test SET name = 'TRAN1',description='YYY' WHERE id = 2;
SQL> commit;
SQL> UPDATE backup_test SET name = 'TRAN2' WHERE id = 2;
SQL> exit

# 復元手順2操作

sqlplus / as sysdba
SQL> shutdown immediate
SQL> startup mount
SQL> alter database flashback on; # フラッシュバックデータベース
SQL> alter database open;
SQL> alter table test_usr.backup_test enable row movement; # フラッシュバック表
SQL> exit

# 以下は誤操作の内容とします。エラーは時刻E～時刻Fの間に発生します。(本例では21:50～22:00となります。)
# select systimestamp from dual;
sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> INSERT INTO backup_test VALUES (3, 'TEST DATA', '');
SQL> exit

# 復元手順3操作
~~~

## 現状 ##

backup_testのデータ(id=0)に対して、2回誤った更新を実施し、フラッシュバックテクノロジーを用いて最初の状態を戻しようとします。
backup_testのデータ(id=1,2)に対して、2回誤った更新を実施し、フラッシュバックテクノロジーを用いて、1回目のトランザクションを無効にしたい。
backup_testに何かを誤ってINSERTしました。フラッシュバックテクノロジーを用いて、元に戻したい。

## 復元手順1 フラッシュバックトランザクション ##

~~~bash
# oracleユーザ
# データ変更の情報を取得します。
sqlplus / as sysdba
SQL> select versions_startscn,versions_starttime,versions_endscn,versions_endtime,versions_xid,versions_operation,TEST_USR.backup_test.*
2> from TEST_USR.backup_test
3> versions between timestamp
4> to_timestamp('2019/05/06 19:00:00.000000','YYYY/MM/DD HH24:MI:SS.FF6')
5> and
6> to_timestamp('2019/05/06 19:10:00.000000','YYYY/MM/DD HH24:MI:SS.FF6')
7> where id = 0;
VERSIONS_STARTSCN VERSIONS_STARTTIME          VERSIONS_ENDSCN VERSIONS_ENDTIME            VERSIONS_XID     VERSIONS_OPERATION ID NAME      DESCRIPTION
----------------- --------------------------- --------------- --------------------------- ---------------- ------------------ -- --------- -----------
          2214372 19-05-06 19:04:12.000000000                                             05000A0066030000 U                   0 UPDATED2
          2214361 19-05-06 19:03:41.000000000         2214372 19-05-06 19:04:12.000000000 04001C006E020000 U                   0 UPDATED
          2214336 19-05-06 19:02:50.000000000         2214361 19-05-06 19:03:41.000000000 0A0015007A030000 I                   0 TEST DATA
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
SQL> UPDATE backup_test SET name = 'UPDATED2' WHERE id = 0;
(略)
SQL> exit

sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> select xid,start_scn,start_timestamp,commit_scn,commit_timestamp,operation,undo_sql
2> from flashback_transaction_query
3> where table_name = 'BACKUP_TEST'
4> and table_owner = 'TEST_USR'
5> and logon_user = 'TEST_USR'
6> and start_timestamp BETWEEN to_timestamp('19-05-06 19:50:00') and to_timestamp('19-05-06 20:00:00');
XID              START_SCN START_TI COMMIT_SCN COMMIT_TI OPERATION UNDO_SQL
---------------- --------- -------- ---------- --------- --------- --------------------------------------------------------------------------------------------
02001F0066030000   2216584 19-05-06    2216588 19-05-06  UPDATE    update "TEST_USR"."BACKUP_TEST" set "NAME" = 'TRAN1' where ROWID = 'AAAR/cAAHAAAACTAAB';
06001A0050030000   2216393 19-05-06    2216527 19-05-06  UPDATE    update "TEST_USR"."BACKUP_TEST" set "NAME" = 'TEST DATA' where ROWID = 'AAAR/cAAHAAAACTAAB';
06001A0050030000   2216393 19-05-06    2216527 19-05-06  UPDATE    update "TEST_USR"."BACKUP_TEST" set "NAME" = 'TEST DATA' where ROWID = 'AAAR/cAAHAAAACTAAA';
SQL> exit
sqlplus / as sysdba
SQL> begin
2>    dbms_flashback.transaction_backout(
3>    numtxns => 1,
4>    names => txname_array('TRAN1'),
5>    options => dbms_flashback.nocascade_force,
6>    scnhint => 2215974
7>    );
8> end;
9> /
(略)
SQL> select * from test_usr.backup_test where id in (1,2);
  ID NAME           DESCRIPTION
---- -------------- -----------
   1 TEST DATA
   2 TEST DATA
SQL> exit
~~~

## 復元手順2 フラッシュバック表 ##

~~~bash
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
SQL> select * from backup_test where id=3;
  ID NAME           DESCRIPTION
---- -------------- -----------
   3 TEST DATA
SQL> flashback table backup_test to timestamp to_timestamp('2019/05/06 21:50:00','YYYY/MM/DD HH24:MI:SS');
フラッシュバックが完了しました。
SQL> select * from backup_test where id=3;
レコードが選択されませんでした。
SQL> exit
~~~

## 復元手順3 フラッシュバックデータベース ##

~~~bash
rman target /
RMAN> shutdown immediate
RMAN> startup mount
RMAN> flashback database to time "TO_DATE('2019/05/06 21:50:00','YYYY/MM/DD HH24:MI:SS')";
RMAN> alter database open read only;
RMAN> select * from test_usr.backup_test where id = 3;
行が選択されませんでした。
RMAN> shutdown immediate
RMAN> startup mount
RMAN> alter database open resetlogs;
RMAN> exit
~~~

## 補足 ##

制御ファイルがない場合、alter database mountの時にORA-00205が発生します。詳細情報は/u01/app/oracle/diag/rdbms/orcl/orcl/alert/log.xmlにあります。