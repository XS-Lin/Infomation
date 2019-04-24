# NOARCHIVELOGモードのDBを全体バックアップより復元 #

## 目標 ##

NOARCHIVEモードで運用しているデータベースがあります。データファイルを格納しているハードディスクが壊れました。
別の場所のリモートストレージで、全体のバックアップがあります。
既存のバックアップ計画は条件に示しています。
サーバー構成およびDBソフトインストールが完了前提で、DBをリカバリしようとしています。

## 条件 ##

1. 既定のバックアップ計画

   毎日DBの全体バックアップを取ります。

   ~~~sql
   rman TARGET /
   (略)
   RMAN> SHUTDOWN IMMEDIATE;
   (略)
   RMAN> STARTUP MOUNT;
   (略)
   RMAN> BACKUP DATABASE;
   (略)
   backupが完了しました。(略)

   ※無関係の出力情報は「(略)」で表記
   ~~~

## 検証環境構成 ##

[oracle_12c_検証環境]

~~~bash
# oracleユーザ
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=orcl
# データベース起動
rman TARGET /
RMAN> startup mount
# バックアップ実施
RMAN> backup database;
RMAN> exit
# データファイル削除
rm -r /u01/app/oracle/oradata/ORCL/datafile/*
# エラー状態確認
sqlplus / as sysdba
SQL> alter database open; # ORA-01157
SQL> shutdown
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイルがすべて無くしたので、データベースをOpenできません。
RMANでデータファイルをリスドア・リカバリして復元できます。

## リカバリ手順 ##

~~~bash
# oracleユーザ
rman TARGET /
RMAN> startup mount
RMAN> restore database;
RMAN> alter database open;
RMAN> exit
~~~