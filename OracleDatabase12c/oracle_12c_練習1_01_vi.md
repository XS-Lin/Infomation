# ARCHIVELOGモードのDBを増分バックアップより復元 #

## 目標 ##

ARCHIVEモードで運用しているデータベースがあります。事故で電源が落ちてしまい、データファイルを格納しているハードディスクが壊れました。
別の場所のリモートストレージで、増分のバックアップがあります。
既存のバックアップ計画は条件に示しています。
サーバー構成およびDBソフトインストールが完了前提で、DBをリカバリしようとしています。

## 条件 ##

1. 既存バックアップ計画

   毎日増分更新バックアップを取得します。

## 検証環境構成 ##

[oracle_12c_検証環境 非CDB]

指定条件の検証環境を構築します。
増分更新バックアップは変更分をバックアップファイルに適用するため、以下の動作になります。
1回目はデータベースのコピーを作成のみ
2回目はLEVEL1増分バックアップ作成のみ
3回目は前回LEVEL1増分バックアップをイメージコピーに適用し、さらにLEVEL1増分バックアップを作成
4回目以後は3回目の繰り返し
よって、4回目実行完了以後、データベースファイルを削除する必要があります。

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
(略)
SQL> exit
# データベース起動
rman TARGET /
# バックアップ実施
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> exit
# 空テーブル作成
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
SQL> CREATE TABLE backup_test ( id NUMBER(6), name VARCHAR2(60), description VARCHAR(4000));
SQL> exit
# 1回目 LEVEL 1 差分増分バックアップ
rman TARGET /
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> exit
# データINSERT
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
(略)
SQL> INSERT INTO backup_test VALUES ( 1, 'TEST DATA', '2 LEVEL 1');
(略)
SQL> exit
# 2回目 LEVEL 1 差分増分バックアップ
rman TARGET /
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> exit
# データ更新と新規
sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> UPDATE backup_test SET name = 'UPDATED' WHERE id = 1;
(略)
SQL> INSERT INTO backup_test VALUES ( 2, 'TEST DATA', '3 LEVEL 1');
(略)
SQL> exit
# 3回目 LEVEL 1 差分増分バックアップ
rman TARGET /
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> exit
# データベースファイル削除(データファイル,制御ファイル,オンラインREDOログ・ファイル)
rm -r /u01/app/oracle/oradata/orcl_noncdb
# エラー状態確認
sqlplus / as sysdba
SQL> select * from dba_objects; # ORA-01116,ORA-01110,ORA-27041 データファイル見つかりません。
SQL> shutdown abort
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイル,制御ファイル,オンラインREDOログ・ファイルがすべて無くしたので、データベースをOpenできません。
制御ファイルをRMANでバックアップからリスドアし、最後のアーカイブREDOログまでリカバリします。

## リカバリ手順 ##

~~~bash
# oracleユーザ
rman TARGET /
RMAN> startup nonmount
RMAN> restore controlfile from autobackup;
RMAN> alter database mount;
RMAN> select * from v$log;
GROUP# THREAD# SEQUENCE#      BYTES BLOCKSIZE MEMBERS ARC STATUS   FIRST_CHANGE# FIRST_TI NEXT_CHANGE# NEXT_TIM CONID
------ ------- --------- ---------- --------- ------- --- -------- ------------- -------- ------------ -------- -----
     1       1         1  209715200       512       1 NO  CURRENT        1595859 19-05-06 184467440737              0
     3       1         3  209715200       512       1 YES UNUSED               0                                    0
     2       1         2  209715200       512       1 YES UNUSED               0                                    0
RMAN> run {
2> set until sequence 1;
3> restore database;
4> recover database;
5>}
RMAN> alter database open resetlogs;
RMAN> exit

sqlplus test_usr/test_usr@localhost:1522/orcl_pdb
SQL> select * from backup_test;
  ID NAME           DISCRIPTION
---- -------------- -----------
   2 TEST DATA      INCREMENTAL RECOVER 2
   1 UPDATED        INCREMENTAL RECOVER 1
SQL> exit
~~~