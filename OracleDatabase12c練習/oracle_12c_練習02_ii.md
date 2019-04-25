# NOARCHIVELOGモードのDBを増分バックアップより復元 #

## 目標 ##

NOARCHIVEモードで運用しているデータベースがあります。データファイルを格納しているハードディスクが壊れました。
高速リカバリ領域は別ディスクで格納したので、増分バックアップは利用可能です。
既存のバックアップ計画は条件に示しています。
DBをリカバリしようとしています。

※増分バックアップは差分増分と累積増分2種類があるが、差分増分を例とします。累積増分との区別はバックアップコマンドを以下に変更のみです。

~~~sql
BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;
~~~

## 条件 ##

1. 既存バックアップ計画

   毎週日曜日にレベル0増分バックアップを取得し、月から土曜日はレベル1の差分増分バックアップを取得します。

1. 障害のタイミング

   木曜日の電源切断により、データベースファイルを格納するハードディスクが故障しました。

## 検証環境構成 ##

[oracle_12c_検証環境]

指定条件の検証環境を構築します。
レベル0増分とレベル1差分増分3回分が必要です。
そして、3回分の差分増分が全部適用の確認のため、データ変更が必要です。
1回目:空テーブル作成
2回目:テーブルにデータINSERT
3回目:前回のデータを変更し、新しいデータをINSERT

各段階のバックアップ取得後、データファイル全部削除します。

~~~bash
# oracleユーザ
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=orcl
sqlplus / as sysdba
SQL> select name,open_mode from v$pdbs;
# orcl_pdbがREAD WRITE以外の場合：alter pluggable database orcl_pdb open;
SQL> alter session set container = orcl_pdb;
SQL> CREATE USER test_usr IDENTIFIED BY "test_usr" DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
SQL> GRANT CONNECT,PUBLIC,SELECT ANY TABLE,CREATE TABLE,UNLIMITED TABLESPACE TO test_usr;
SQL> exit
lsnrctl start
# LEVEL 0 増分バックアップ
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# 空テーブル作成
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> CREATE TABLE backup_test (id NUMBER(6), name VARCHAR2(60), description VARCHAR(4000));
SQL> exit
# 1回目 LEVEL 1 差分増分バックアップ
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# データINSERT
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
(略)
SQL> INSERT INTO backup_test VALUES ( 1, 'TEST DATA', '2 LEVEL 1');
1 row created.
SQL> exit
# 2回目 LEVEL 1 差分増分バックアップ
rman TARGET /
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
(略)
RMAN> alter database open;
(略)
RMAN> alter pluggable database orcl_pdb open;
(略)
RMAN> exit
# データ更新と新規
sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> UPDATE backup_test SET name = 'UPDATED' WHERE id = 1;
1 row updated.
SQL> INSERT INTO backup_test VALUES ( 2, 'TEST DATA', '3 LEVEL 1');
1 row created.
SQL> exit
# 3回目 LEVEL 1 差分増分バックアップ
rman TARGET /
(略)
RMAN> shutdown immediate
(略)
RMAN> startup mount
(略)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
(略)
RMAN> shutdown
(略)
RMAN> exit
# データファイル削除
rm -r /u01/app/oracle/oradata/ORCL/datafile/*
# エラー状態確認
sqlplus / as sysdba
(略)
Connected to an idle instance.
SQL> startup # ORA-01157
SQL> shudown
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイルがすべて無くしたので、データベースをOpenできません。

## リカバリ手順 ##

~~~bash
# oracleユーザ
rman TARGET /
RMAN> startup mount
RMAN> restore database;
RMAN> recover database;# REDOログが使用できない場合は、NOREDOオプションが必須
RMAN> alter database open resetlogs;
RMAN> alter pluggable database orcl_pdb open;
RMAN> exit

sqlplus test_usr/test_usr@localhost:1521/orcl_pdb
SQL> select * from backup_test;
  ID NAME           DISCRIPTION
---- -------------- -----------
   2 TEST DATA      3 LEVEL 1
   1 UPDATED        2 LEVEL 1
SQL> exit
~~~