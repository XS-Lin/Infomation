# ARCHIVELOGモードのDBを増分バックアップより復元 #

## 目標 ##

ARCHIVEモードで運用しているデータベースがあります。事故で電源が落ちてしまい、データファイルを格納しているハードディスクが壊れました。
別の場所のリモートストレージで、増分のバックアップがあります。
既存のバックアップ計画は条件に示しています。
サーバー構成およびDBソフトインストールが完了前提で、DBをリカバリしようとしています。

※増分バックアップは差分増分と累積増分2種類があるが、差分増分を例とします。累積増分との区別はバックアップコマンドを以下に変更のみです。

~~~sql
BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;
~~~

## 条件 ##

1. 既定のバックアップ計画

   毎週日曜日にレベル0増分バックアップを取得し、月から土曜日はレベル1の差分増分バックアップを取得します。

1. 障害のタイミング

   木曜日の電源切断により、データベースファイルを格納するハードディスクが故障しました。

## 検証環境構成 ##

[oracle_12c_検証環境 非CDB]

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
RMAN> backup incremental level 0 database;
(略)
RMAN> exit
# 空テーブル作成
sqlplus test_usr/test_usr@localhost:1522/orcl_noncdb
SQL> CREATE TABLE backup_test ( id NUMBER(6), name VARCHAR2(60), description VARCHAR(4000));
SQL> exit
# 1回目 LEVEL 1 差分増分バックアップ
rman TARGET /
(略)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
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
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
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
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;
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
SPFILEが残るため、NOMOUNTでインスタンスの起動は可能なので、Sqlplusで接続し、パラメータcontrol_filesでバックアップした制御ファイルの位置がわかります。
正常状態の制御ファイルを指定位置にコピーしてからRMANでリスドアできますが、REDOログがないためリカバリは失敗します。
アーカイブしていないREDOログのデータが消えるので、最後のアーカイブREDOログまでリカバリします。

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
     1       1         1  209715200       512       1 YES INACTIVE       1437261 19-05-02      1542076              0
     3       1         3  209715200       512       1 NO  CURRENT        1595858          184467440737              0
     2       1         2  209715200       512       1 YES INACTIVE       1542076 19-05-02      1595858              0
RMAN> run {
2> set until sequence 3;
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