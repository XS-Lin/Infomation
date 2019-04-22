# NOARCHIVELOGモードのDBを全体バックアップより復元 #

## 目標 ##

NOARCHIVEモードで運用しているデータベースがあります。事故で電源が落ちてしまい、データファイルを格納しているハードディスクが壊れました。
別の場所のリモートストレージで、全体のバックアップがあります。
既存のバックアップ計画は条件に示しています。
サーバー構成およびDBソフトインストールが完了前提で、DBをリカバリしようとしています。

## 条件 ##

1. 既定のバックアップ計画

   毎日DBの全体バックアップを取ります。

   ~~~sql
   rman TARGET /
   (略)
   RMAN> SHUTDOWN TRANSACTIONAL;
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
# データベースファイル削除(データファイル,制御ファイル,オンラインREDOログ・ファイル)
rm -r /u01/app/oracle/oradata/ORCL
# エラー状態確認
sqlplus / as sysdba
SQL> select * from dba_objects; # ORA-01116,ORA-01110,ORA-27041 データファイル見つかりません。
SQL> select * from v$parameter; # 正常
SQL> shutdown abort
SQL> exit
~~~

## 現状 ##

データベースファイルのデータファイル,制御ファイル,オンラインREDOログ・ファイルがすべて無くしたので、データベースをOpenできません。
SPFILEが残るため、NOMOUNTでインスタンスの起動は可能なので、Sqlplusで接続し、パラメータcontrol_filesでバックアップした制御ファイルの位置がわかります。
正常状態の制御ファイルを指定位置にコピーしてから、RMANでリスドア・リカバリして復元できます。

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
mkdir /u01/app/oracle/fast_recovery_area/orcl/ORCL
mkdir /u01/app/oracle/fast_recovery_area/orcl/ORCL/controlfile
cp /u01/app/oracle/fast_recovery_area/orcl/ORCL/controlfile/o1_mf_gc0cx9qw_.ctl /u01/app/oracle/oradata/ORCL/controlfile/o1_mf_gc0cx9od_.ctl

rman TARGET /
RMAN> startup nomount
RMAN> alter database mount;
RMAN> restore database;
RMAN> select * from v$database;
RMAN> recover database;
RMAN> alter database open resetlogs;
RMAN> exit

sqlplus / as sysdba
SQL> select * from dba_objects;
(略)
SQL> exit
~~~

## 補足 ##

制御ファイルがない場合、alter database mountの時にORA-00205が発生します。詳細情報は/u01/app/oracle/diag/rdbms/orcl/orcl/alert/log.xmlにあります。