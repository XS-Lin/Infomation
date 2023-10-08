# NOARCHIVELOGモードのDBを増分更新バックアップより復元 #

## 目標 ##

NOARCHIVEモードで運用しているデータベースがあります。事故で電源が落ちてしまい、データファイルを格納しているハードディスクが壊れました。
高速リカバリ領域は別ディスクで格納したので、増分更新バックアップは利用可能です。
既存のバックアップ計画は条件に示しています。
DBをリカバリしようとしています。

## 条件 ##

1. 既存バックアップ計画

   毎日増分更新バックアップを取得します。

## 検証環境構成 ##

[oracle_12c_検証環境]

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
export ORACLE_SID=orcl
sqlplus / as sysdba
# データベースが停止した場合: startup;
SQL> select name,open_mode from v$pdbs;
# orcl_pdbがMOUNTEDの場合：alter pluggable database orcl_pdb open;
SQL> alter session set container = orcl_pdb; # cdbに戻る場合: alter session set container = cdb$root;
SQL> CREATE USER test_usr IDENTIFIED BY "test_usr" DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
SQL> GRANT CONNECT,PUBLIC,SELECT ANY TABLE,CREATE TABLE,UNLIMITED TABLESPACE TO test_usr;
SQL> exit
lsnrctl start
# 1回目
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# データ変更
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> CREATE TABLE backup_test ( id NUMBER(6), name VARCHAR2(60), description VARCHAR(4000));
SQL> exit
# 2回目
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# データ変更
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
(略)
SQL> INSERT INTO backup_test VALUES ( 1, 'TEST DATA', 'INCREMENTAL RECOVER 1');
(略)
SQL> exit
# 3回目
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# データ変更
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> UPDATE backup_test SET name = 'UPDATED' WHERE id = 1;
1 row updated.
SQL> INSERT INTO backup_test VALUES ( 2, 'TEST DATA', 'INCREMENTAL RECOVER 2');
1 row created.
SQL> exit
# 4回目
rman TARGET /
(略)
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> RUN
2> {
3>   RECOVER COPY OF DATABASE WITH TAG 'insr_update';
4>   BACKUP INCREMENTAL LEVEL 1 FOR RECOVER OF COPY WITH TAG 'insr_update' DATABASE;
5> }
(略)
RMAN> shutdown
(略)
RMAN> exit
# データベースファイル削除(データファイル,制御ファイル,オンラインREDOログ・ファイル)
rm -r /u01/app/oracle/oradata/ORCL
# エラー状態確認
sqlplus / as sysdba
(略)
Connected to an idle instance.
SQL> startup # ORA-00205 error in identifying control file.
SQL> SELECT STATUS FROM v$instance;
STATUS
-----------
STARTED
SQL> shudown
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイル,制御ファイル,オンラインREDOログ・ファイルがすべて無くしたので、データベースをOpenできません。
制御ファイル等をリスドアして、リカバリ可能です。

## リカバリ手順 ##

~~~bash
# oracleユーザ
sqlplus / as sysdba
SQL> startup nomount;
SQL> show parameter control_files
(略)
# /u01/app/oracle/oradata/ORCL/controlfile/o1_mf_gc0cx9od_.ctl
# /u01/app/oracle/fast_recovery_area/orcl/ORCL/controlfile/o1_mf_gc0cx9qw_.ctl
SQL> exit
# 制御ファイルをコピー
mkdir /u01/app/oracle/oradata/ORCL
mkdir /u01/app/oracle/oradata/ORCL/controlfile
cp /u01/app/oracle/fast_recovery_area/orcl/ORCL/controlfile/o1_mf_gc0cx9qw_.ctl /u01/app/oracle/oradata/ORCL/controlfile/o1_mf_gc0cx9od_.ctl
rman TARGET /
RMAN> startup nomount
RMAN> alter database mount;
RMAN> restore database;
RMAN> recover database;
RMAN> alter database open resetlogs;
RMAN> alter pluggable database orcl_pdb open;
RMAN> exit

sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> select * from backup_test;
  ID NAME           DISCRIPTION
---- -------------- -----------
   2 TEST DATA      INCREMENTAL RECOVER 2
   1 UPDATED        INCREMENTAL RECOVER 1
SQL> exit
~~~

## 補足 ##

リスナー正常起動後、アクセスできるまでおよそ一分間かかります。
alter system register;ですく接続できるようになります。