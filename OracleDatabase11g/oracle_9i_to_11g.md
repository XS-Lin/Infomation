# Oracle9i から 11g へ移行メモ #

## 対象 ##

移行元:Oracle 9i

* host os : solaris 10
* database version : Oracle Database 9i (9.2.0.5.0)

移行先:Oracle 11gR2

* host os : Redhat Linux 7.5
* database version : Oracle 11gR2 (11.2.0.4.0)

## 方式 ##

オリジナルのエクスポート/インポート・ユーティリティ(exp/imp)使用

* 理由
   1. Oracleのバージョン差によって、直接アップグレードできません。
   1. OS変更があります。

   ※詳細は各バージョンの「Database Upgrade Guide」参照
   [Oracle 11.2 upgrade path](https://docs.oracle.com/cd/E11882_01/server.112/e23633/preup.htm#UPGRD002)

## 手順 ##

1. Oracle Databaseをアップグレードするための準備

   1. 現行DB情報収集 [info_all.sql](https://github.com/XS-Lin/Infomation/blob/master/OracleDatabase11g/oracle_9i_to_11g_tool/get_info/info_all_9i_for_linux.sql)

         ~~~sql
         sqlplus system/ora@orcl01 @info_all.sql <path> <sid>
         ~~~

   1. 新データベース計画(容量、配置先等)

      1. DBの移行は一般的に性能劣化はいけないので、CPU/メモリハードディスクなどは現行本番機の同等以上を選択します。

      1. DBの移行はフォルダ構成が変わる場合はありますが、ここでは現行本番機と同等配置を前提とします。

   1. エクスポート実施 (Oracle 9iサーバのコンソール)

      1. 外部接続を切断のため、リスナー停止してデータベース再起動

         **実行前にユーザセッションや実行中のトランザクションの有無確認**

         ~~~sh
         lsnrctl stop <listener_name>
         export ORACLE_SID=<sid>
         sqlplus / as sysdba
         shutdown immediate
         start up
         ~~~

      1. 定義情報取得

         ~~~sh
         exp system/ora%@orcl01 full=y DIRECT=y FILE=full_rows_N.dmp LOG=full_rows_N.log rows=N
         ~~~

      1. ユーザ単位でデータ取得

         ~~~sh
         exp USERID=system/ora@orcl01 DIRECT=y FILE=<sid>_<user_name>.dmp OWNER=<user_name> LOG=exp_<sid>_<user_name>.log
         ~~~

   1. よくあるエラーについて

      1. ORA-01455: 列の変換により整数データ型がオーバーフローしました。

      原因は不明です。エラーはマテビューから出たなので、古きSNAPSHOTの文法によると推測します。マテビューは作り直しますので、対処は不要です。

1. Oracle Databaseのアップグレード処理のテスト

   1. 試験環境構築

      1. ソフトウェアのみインストール

         ~~~bash
         # 例:インストール先は以下とする。
         /u01/app/oracle
         ~~~

      1. dbcaでデータベース作成

         ~~~bash
         # dbcaの汎用データベーステンプレートを利用するために
         #   controlfile_<sid>.csvより制御ファイルの配置先を取得し、DBCAに設定
         #   dba_data_files_<sid>.csvよりSYSTEMファイル、TEMPファイル、UNDOログファイルの配置先を取得し、DBCAに設定
         #   設定対象:controlfile,SYSTEM・SYSAUX・TEMP・UNDOTBS1テーブルスペースのデータファイル
         # ここはデータファイル配置先は以下とする。
         /u01/app/oracle/oradata/<sid>/
         # スクリプトを保存して、再作成の場合は使用する。デフォルト保存先：
         /u01/app/oracle/admin/<sid>/scripts
         ~~~

      1. インポートためのテーブルスペースおよびユーザ作成 (CreateTablespaceAndUser.py)

         ~~~sql
         --dba_data_files_<sid>.csvとdba_temp_files_SID.csv より各テーブルスペース作成、フォルダがない場合は作成必要
         CREATE TABLESPACE <tablespace_name> DATAFILE '<path>' SIZE <size> AUTOEXTEND ON NEXT 16384 MAXSIZE UNLIMITED;
         --user_<sid>.csvより、ユーザ情報を取得し、ユーザ作成
         CREATE USER <user_name> IDENTIFIED BY <user_password> DEFAULT TABLESPACE <tablespace> TEMPORARY TABLESPACE <temp_tablespace>;
         --注意点
         --  1.同一テーブルスペースに複数データファイル含む場合があります。
         --  2.9iと11gの一時表領域の管理方法が違うため、
         --    9i のdba_data_files_<sid>.csvの「CONTENTS」が「TEMPORARY」の場合、
         --    11g で一時表領域として作成必要
         --  3. 9iと11g のCONNECTロールの権限が違うため、対処が必要
         --    例：11gのCONNECTロールに9iと同等な権限を付与する
         --       GRANT ALTER SESSION,CREATE SESSION,CREATE CLUSTER,CREATE SYNONYM,CREATE DATABASE LINK,CREATE TABLE,CREATE SEQUENCE,CREATE VIEW TO CONNECT;
         ~~~

   1. 試験環境にimp実施

         ~~~bash
         imp system/ora@orcl01 FILE=<sid>_CCOM.dmp FROMUSER=CCOM TOUSER=CCOM COMMIT=Y LOG=imp_<sid>_CCOM.log
         ~~~

   1. impエラー等処置

      1. エクスポートのログファイルに「EXP-00000」がある場合、どこかで不完全の可能性が高い。移行前後のオブジェクト比較、データ件数比較によって特定できます。

1. アップグレードしたテスト用Oracle Databaseのテスト

   1. 情報取得し、現行と比較

   1. 現行アプリケーションテストDBに接続し、正常実行できる確認

   1. 問題処置し、本番用手順作成

1. 新しい本番Oracle Databaseのチューニングおよび調整

   1. 本番環境構築

   1. 本番環境にデータ投入

   1. チューニング

## NOTE ##

9i の exp ツールでエクスポートしたdmpファイルに「CREATE USER "TEST" IDENTIFIED BY VALUES 'B054199D796F24A0'」(パス: database)について、
11g で 「CREATE USER "TEST" IDENTIFIED BY database;」を実行すると、「SYS.USER$」テーブルのパスワード列が「'9F529D35EF01DE2F'」となる。

試験:
11gで以下のSQLを実行すると、どちらの場合でもSYS.USE$のパスワード列が「'9F529D35EF01DE2F'」になる。

~~~sql
CREATE USER "TEST" IDENTIFIED BY "database";
CREATE USER "TEST" IDENTIFIED BY "databasE";
CREATE USER "TEST" IDENTIFIED BY "DATABASE";
~~~

sec_case_sensitive_logonが「TURE」なので、大文字小文字が一致しない場合はログインできない。
また、以下のようにTESTユーザを作成すると、

~~~sql
--SYSで
CREATE USER "TEST" IDENTIFIED BY "TEST";
ALTER USER IDENTIFIED BY VALUES '9F529D35EF01DE2F';
GRANT CREATE SESSION TO TEST;
show parameter sec_case_sensitive_logon --TRUE
~~~

sec_case_sensitive_logonが「TURE」でも、以下いずれもログイン可能になる。

~~~sh
sqlplus test/database
sqlplus test/DATAbase
sqlplus test/databasE
sqlplus test/DATABASE
~~~

## その他補足 ##

1. sqlplusでshutdown immediateの実行途中でctrl+cで強制中止し、sqlplusで再接続してshutdown immediateすると、エラーが発生します。

   **ORA-24324： サービス・ハンドルが初期化されていません。**

   対応方法:shutdown abortでインスタンスを強制終了してstartup

1. 一時ファイルのサイズは本番機と同様に設定しましたが、インデックス作成の時に一時領域不足エラーが発生しました。(発生しない場合が多い)

   **ORA-01652: 一時セグメントを拡張できません**

   対応方法:一時表領域拡張し、インデックスを再作成
