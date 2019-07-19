# Oracle9i から 11g へ移行メモ #

## 対象 ##

移行元:Oracle 9i

* host os = solaris 10
* database version = 9.2.0.5.0
* client version = 9.2.0.1.0

移行先:Oracle 11gR2

* host os = Redhat Linux 7.5
* database version = 11.2.0.1.4
* client version = 12.1.0.2.0

## 方式 ##

オリジナルのエクスポート/インポート・ユーティリティ(exp/imp)使用

* 理由
   1. Oracleのバージョン差によって、直接アップグレード不能
   1. OS変更あり

   ※詳細は各バージョンの「Database Upgrade Guide」参照
   [Oracle 11.2 upgrade path](https://docs.oracle.com/cd/E11882_01/server.112/e23633/preup.htm#UPGRD002)

## 手順 ##

1. Oracle Databaseをアップグレードするための準備

   1. 現行DB情報収集 (info_all.sql)

         ~~~sql
         sqlplus system/ora@orcl01 @info_all.sql <path> <sid>
         ~~~

   1. 新データベース計画(容量、配置先等)

      1. DBの移行は一般的に性能劣化はいけないので、CPU/メモリハードディスクなどは現行本番機の同等以上を選択する。

      1. DBの移行はフォルダ構成が変わる場合はあるが、ここでは現行本番機と同等配置を前提とする。

   1. 試験データ取得のためにexp実施

      1. 定義情報取得

         ~~~dos
         exp system/ora%@orcl01 full=y DIRECT=y FILE=full_rows_N.dmp LOG=full_rows_N.log rows=N
         ~~~

      1. ユーザ単位でデータ取得

         ~~~dos
         exp USERID=system/ora@orcl01 DIRECT=y FILE=<sid>_<user_name>.dmp OWNER=<user_name> LOG=exp_<sid>_<user_name>.log
         ~~~

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
         --  1.同一テーブルスペースに複数データファイル含む場合がある。
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

   1. 個別権限付与

1. アップグレードしたテスト用Oracle Databaseのテスト

   1. 情報取得し、現行と比較

   1. 現行アプリケーションテストDBに接続し、正常実行できる確認

   1. 問題処置し、本番用手順作成

1. 新しい本番Oracle Databaseのチューニングおよび調整

   1. 本番環境構築

   1. 本番環境にデータ投入

   1. チューニング