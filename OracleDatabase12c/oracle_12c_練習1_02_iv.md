# ARCHIVELOGモードのDBを全体バックアップより復元 #

## 目標 ##

ARCHIVEモードで運用しているデータベースがあります。事故で電源が落ちてしまい、データファイルを格納しているハードディスクが壊れました。
別の場所のリモートストレージで、全体のバックアップがあります。
既存のバックアップ計画は条件に示しています。
サーバー構成およびDBソフトインストールが完了前提で、DBをリカバリしようとしています。

## 条件 ##

1. 既定のバックアップ計画

   毎日DBの全体バックアップを取ります。

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
(略)
SQL> exit
# データベース起動
rman TARGET /
# バックアップ実施
RMAN> backup database;
(略)
RMAN> exit
# データベースファイル削除(データファイル)
rm -r /u01/app/oracle/oradata/orcl_noncdb/*.dbf
# エラー状態確認
sqlplus / as sysdba
SQL> select * from dba_objects; # ORA-01116,ORA-01110,ORA-27041 データファイル見つかりません。
SQL> shutdown abort
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイルがすべて無くしたので、データベースをOpenできません。
データファイルをバックアップからリスドアし、リカバリします。

## リカバリ手順 ##

~~~bash
rman TARGET /
RMAN> startup mount;
RMAN> restore database;
RMAN> recover database;
RMAN> alter database open;
RMAN> exit

sqlplus / as sysdba
SQL> select * from dba_objects;
(略)
SQL> exit