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
RMAN> startup nomount
RMAN> restore controlfile from autobackup;
RMAN> alter database mount;
RMAN> select * from v$log;
GROUP# THREAD# SEQUENCE#      BYTES BLOCKSIZE MEMBERS ARC STATUS  FIRST_CHANGE# FIRST_TI NEXT_CHANGE# NEXT_TIM CONID
------ ------- --------- ---------- --------- ------- --- ------- ------------- -------- ------------ -------- -----
     1       1         1  209715200       512       1 NO  CURRENT       1408558 19-04-22 184467440737              0
     3       1         0  209715200       512       1 YES UNUSED              0                     0              0
     2       1         0  209715200       512       1 YES UNUSED              0                     0              0
RMAN> run {
2> set until sequence 1;
3> restore database;
4> recover database;
5>}
RMAN> alter database open resetlogs;
RMAN> exit

sqlplus / as sysdba
SQL> select * from dba_objects;
(略)
SQL> exit


## 試行錯誤 ##

rman TARGET /
RMAN> alter database mount;
RMAN> restore database;
RMAN> recover database; #エラー発生 ORA-00313,ORA-00312,ORA-27037
RMAN> list failure; # すべてのオンライン・ログ・グループは使用できないことを確認
(略)
障害ID 優先度    ステータス 検出時間 サマリー
------ -------- --------- -------- --------
74     CRITICAL OPEN      19-04-25 オンライン・ログ・グループ3は使用できません
68     CRITICAL OPEN      19-04-25 オンライン・ログ・グループ2は使用できません
62     CRITICAL OPEN      19-04-25 オンライン・ログ・グループ1は使用できません
77     HIGH     OPEN      19-04-25 オンライン・ログ・メモリ/u01/app/oracle/oradata/orcl_noncdb/redo03.logがありません
71     HIGH     OPEN      19-04-25 オンライン・ログ・メモリ/u01/app/oracle/oradata/orcl_noncdb/redo02.logがありません
65     HIGH     OPEN      19-04-25 オンライン・ログ・メモリ/u01/app/oracle/oradata/orcl_noncdb/redo01.logがありません

RMAN> advise failure; # 使用中のオンライン・ログ・グループは自動修復できないことを確認
RMAN> select * from v$log_history; # 情報なし
RMAN> select groups#,status,type,member from v$logfile;
GROUPS# STATUS TYPE MEMBER
------- ------ ------ ---------------------------------------------------
      3        ONLINE /u01/app/oracle/oradata/orcl_noncdb/redo03.log
      2        ONLINE /u01/app/oracle/oradata/orcl_noncdb/redo02.log
      1        ONLINE /u01/app/oracle/oradata/orcl_noncdb/redo01.log
#RMAN> alter database open resetlogs; # ORA-01139
#RMAN> alter database clear logfile group 1; # ORA-01624,ORA-00312
#RMAN> alter database drop logfile member '/u01/app/oracle/oradata/orcl_noncdb/redo01.log'; # ORA-00361
#RMAN> alter database add logfile member '/u01/app/oracle/oradata/orcl_noncdb/redo11.log' to group 1; # ORA-00933
RMAN> repair failure;
(略)
RMAN> list failure;
障害ID 優先度    ステータス 検出時間 サマリー
------ -------- --------- -------- --------
62     CRITICAL OPEN      19-04-25 オンライン・ログ・グループ1は使用できません
65     HIGH     OPEN      19-04-25 オンライン・ログ・メモリ/u01/app/oracle/oradata/orcl_noncdb/redo01.logがありません
~~~