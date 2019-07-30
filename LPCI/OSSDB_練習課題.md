# Postgre練習課題 #

参考情報:
[Postgresql 11.4 document](https://www.postgresql.jp/document/current/index.html)
[OSS-DB Silver Ver.2.0](https://oss-db.jp/outline/silver)
[OSS-DB Gold Ver.2.0](https://oss-db.jp/outline/gold)

## 一般知識 ##

1. OSS-DBの一般的特徴　【重要度：4】

   1.説明

      PostgreSQLの機能概要、ライセンス、OSSのコミュニティの役割などに関する理解を問う

   1. 主要な知識範囲：
      PostgreSQLの機能全般、OSS-DBおよびOSS一般のライセンス、OSS-DBのコミュニティ、活動内容、参加方法など
      メジャーバージョン / マイナーバージョン
      リリースサイクル / サポートポリシー / バグ報告

1. リレーショナルデータベースに関する一般知識　【重要度：4】

   1. 説明

      リレーショナルデータベースの基本概念、一般的知識を問う
      主要な知識範囲：
      リレーショナルデータモデルの基本概念
      データベース管理システムの役割
      SQL に関する一般知識
      SQLの 分類 (DDL / DML / DCL)
      データベースの設計と正規化

## 開発/SQL ##

1. SQL コマンド 【重要度： 13】

   1. 説明：
      基本的なSQL文およびデータベースの構成要素に関する知識を問う

   1. 主要な知識範囲：
      SELECT 文
      INSERT 文
      UPDATE 文
      DELETE 文
      データ型
      テーブル定義
      インデックス
      ビュー
      マテリアライズドビュー
      ルール
      トリガー
      シーケンス
      スキーマ
      テーブルスペース
      パーティション
      関数定義 / プロシージャ定義
      PL/pgSQL
   1. 重要な用語、コマンド、パラメータなど：
      SELECT/INSERT/UPDATE/DELETE
      FROM
      JOIN
      WHERE
      INTO
      VALUES
      SET
      LIMIT
      OFFSET
      ORDER BY
      DISTINCT
      GROUP BY
      HAVING
      EXISTS
      IN
      NOT
      INTEGER
      SMALLINT
      BIGINT
      NUMERIC
      DECIMAL
      REAL
      DOUBLE PRECISION
      CHAR
      CHARACTER
      VARCHAR
      CHARACTER VARYING
      TEXT
      BOOLEAN
      DATE
      TIME
      TIMESTAMP
      INTERVAL
      SERIAL
      BIGSERIAL
      BYTEA
      NULL
      CREATE/ALTER/DROP TABLE
      PRIMARY KEY
      FOREIGN KEY
      REFERENCES
      UNIQUE
      NOT NULL
      CHECK
      DEFAULT
      CREATE/ALTER/DROP INDEX/VIEW/MATERIALIZED VIEW/RULE/TRIGGER/SCHEMA/SEQUENCE/TABLESPACE/FUNCTION/PROCEDURE
      CREATE TABLE PARTITION BY/OF

      ~~~sql
      --以下は同様
      CREATE ROLE test LOGIN;
      CREATE USER test;

      --特権ユーザ
      CREATE USER test SUPERUSER;
      --一般ユーザ
      CREATE ROLE test CREATEDB; --DB作成権限
      CREATE ROLE test CREATROLE; --ユーザ作成権限
      CREATE ROLE test REPLICATION LOGIN; --ストーミングアプリケーション
      CREATE ROLE test PASSWORD 'test'; --パスワード

      CREATE ROLE group_role;
      GRANT group_role TO role1;
      REVOKE group_role FROM role1;

      SET ROLE group_role; --role1でログインして以後のsqlをgroup_roleとして実行
      SET ROLE role1; --role1に戻る
      SET ROLE NONE; --role1に戻る
      RESET ROLE; --role1に戻る

      DROP ROLE group_role;

      --before drop role
      REASSING OWNED BY role1 TO other_role;
      DROP OWNED BY role1;
      DROP doomed_role;
      ~~~

      ~~~sql
      CREAET TABLE x (col1 char(2));
      CREATE TABLE y (col2 char(2)) INHERITS(x);
      SELECT * FROM y;
      SELECT * FROM ONLY y;
      ~~~

      ~~~sql
      ILIKE,IMILAR
      ISNULL,NOTNULL
      $number --位置パラメータ
      expression[subscript] --添え字
      aggregate_name (expression [ , ... ] [ order_by_clause ] ) [ FILTER ( WHERE filter_clause ) ]
      aggregate_name (ALL expression [ , ... ] [ order_by_clause ] ) [ FILTER ( WHERE filter_clause ) ]
      aggregate_name (DISTINCT expression [ , ... ] [ order_by_clause ] ) [ FILTER ( WHERE filter_clause) ]
      aggregate_name ( * ) [ FILTER ( WHERE filter_clause ) ]
      aggregate_name ( [ expression [ , ... ] ] ) WITHIN GROUP ( order_by_clause ) [ FILTER( WHERE filter_clause ) ]
      --window function
      function_name ([expression [, expression ... ]]) [ FILTER ( WHERE filter_clause ) ] OVER window_name
      function_name ([expression [, expression ... ]]) [ FILTER ( WHERE filter_clause ) ] OVER( window_definition )
      function_name ( * ) [ FILTER ( WHERE filter_clause ) ] OVER window_name
      function_name ( * ) [ FILTER ( WHERE filter_clause ) ] OVER ( window_definition )
      ~~~

      ~~~sql
      --window_definition
      [ existing_window_name ]
      [ PARTITION BY expression [, ...] ]
      [ ORDER BY expression [ ASC | DESC | USING operator ] [ NULLS { FIRST | LAST } ] [, ...] ]
      [ frame_clause ]
      --frame_clause
      { RANGE | ROWS | GROUPS } frame_start [ frame_exclusion ]
      { RANGE | ROWS | GROUPS } BETWEEN frame_start AND frame_end [ frame_exclusion ]
      --frame_start,frame_end
      UNBOUNDED PRECEDING
      offset PRECEDING
      CURRENT ROW
      offset FOLLOWING
      UNBOUNDED FOLLOWING
      --frame_exclusion
      EXCLUDE CURRENT ROW
      EXCLUDE GROUP
      EXCLUDE TIES
      EXCLUDE NO OTHERS
      ~~~

      ~~~sql
      CAST ( expression AS type )
      expression::type
      typename ( expression )
      ~~~

      ~~~sql
      POLICY
      ~~~

      ALTER TABLE ATTACH/DETACH PARTITION

      注意:
      oracle の場合
        CREATE USER 文で同名のスキーマを自動作成
        CREATE SCHEMA 文で指定名前のユーザを作成
      postgresqlの場合
        CREATE USER は CREATE ROLE の別名[参照](https://www.postgresql.jp/document/9.4/html/sql-createuser.html)
        CREATE SCHEMA は スキーマ作成


1. 組み込み関数 【重要度：2】

   1. 説明：
      データベースで標準的に利用できる関数および演算子に関する知識を問う
   1. 主要な知識範囲：
      集約関数
      算術関数
      演算子 + - * / < > = ~ ! @ # % ^ & | ` ?
      文字列関数
      文字列演算子 ~ ! @ # % ^ & | ` ? / 述語
      時間関数
   1. 重要な用語、コマンド、パラメータなど：
      count
      sum
      avg
      max
      min
      char(character)_length
      lower
      upper
      substring
      replace
      trim
      ||
      ~
      LIKE
      SIMILAR TO
      age
      now
      current_date
      current_timestamp / statement_timestamp / clock_timestamp
      current_time
      extract
      to_char

1. トランザクションの概念 【重要度：1】

   1. 説明：
      トランザクション機能に関する知識を問う
   1. 主要な知識範囲：
      トランザクションの構文
      トランザクション分離レベル(リードコミッティド、リピータブルリード、シリアライザブル)
      LOCK 文
      行ロックとテーブルロック
      デッドロック
   1. 重要な用語、コマンド、パラメータなど：
      BEGIN
      COMMIT
      ROLLBACK
      SAVEPOINT
      SET TRANSACTION
      LOCK TABLE
      SELECT FOR UPDATE / SHARE

## 運用管理 ##

1. インストール方法　【重要度：2】

   1. 説明：
      PostgreSQLのインストール方法、データベースクラスタの作成方法などに関する理解を問う
   1. 主要な知識範囲：
      initdbコマンドの使い方
      データベースクラスタの概念と構造
      テンプレートデータベース
   1. 重要な用語、コマンド、パラメータなど：
      initdb
      pg_ctl initdb
      PGDATA
      template0
      template1

1. 標準付属ツールの使い方 【重要度：5】

   1. 説明：
      OSのコマンドプロンプトから実行できる管理用ツールの使い方を問う
   1. 主要な知識範囲：
      データベース管理用コマンドの使い方
   1. 重要な用語、コマンド、パラメータなど：
      pg_ctl
      createuser
      dropuser
      createdb

      ~~~sh
      createdb mydb # createdb: could not connect to database ...
      systemctl start postgresql-11
      ~~~

      dropdb
      psql
      メタコマンド

1. 設定ファイル 【重要度：5】

   1. 説明：
      設定ファイルの使い方、基本的な設定パラメータに関する知識を問う
   1. 主要な知識範囲：
      postgresql.confに関する以下の4項目
      　- 記述方法
      　- 接続と認証
      　- クライアント接続デフォルト
      　- エラー報告とログ取得
      pg_hba.confの設定方法
      SET/SHOWの使い方
   1. 重要な用語、コマンド、パラメータなど：
      postgresql.conf
      pg_hba.conf
      pg_ctl reload/restart
      pg_settings

1. バックアップ方法 【重要度：7】

   1. 説明：
      PostgreSQLのバックアップ方法に関する理解を問う
   1. 主要な知識範囲：
      各種バックアップコマンドの使い方
      ファイルシステムレベルのバックアップとリストア
      ポイントインタイムリカバリ(PITR)の概念と手順
      トランザクションログ(WAL)とWALアーカイブ
      pg_start_backup() / pg_stop_backup()
      COPY文(SQL)、¥copyコマンド(psql)の使い方
   1. 重要な用語、コマンド、パラメータなど：
      pg_dump
      pg_dumpall
      pg_restore
      psql
      pg_basebackup
      PITR
      recovery.conf
      COPY

      ~~~sql
      COPY weather FROM '/home/user/weather.txt';
      ~~~

      ¥copy

1. 基本的な運用管理作業 【重要度：7】

   1. 説明：
      データベース管理者として実行する基本的な運用管理コマンドに関する知識を問う
   1. 主要な知識範囲：
      PostgreSQLの起動・停止方法
      データベースロール / ユーザの概念
      データベースロール / ユーザの追加・削除・変更方法
      VACUUM、ANALYZEの目的と使い方
      自動バキュームの概念と動作
      システム情報関数
      情報スキーマとシステムカタログ
      テーブル単位の権限（GRANT/REVOKE）
   1. 重要な用語、コマンド、パラメータなど：
      pg_ctl start / stop
      CREATE/ALTER/DROP ROLE/USER
      VACUUM
      ANALYZE
      vacuumdb
      autovacuum
      current_user
      version
      information_schema
      GRANT
      REVOKE

1. データベースサーバ構築 【重要度：2】

   1. 説明：
      サーバ構築における容量見積もり、およびデータベースセキュリティに関する知識を問う
   1. 主要な知識範囲：
      テーブル・インデックス容量見積もり
      セキュリティ
      - 通信経路暗号化（SSL)
      - データ暗号化
      - クライアント認証
      - 監査ログ
      データ型のサイズ
      ユーザ・データベース単位のパラメータ設定
   1. 重要な用語、コマンド、パラメータなど：
      チェックサム
      pg_xact
      pg_multixact
      pg_notify
      pg_serial
      pg_snapshots
      pg_stat_tmp
      pg_subtrans
      pg_tblspc
      pg_twophase
      ssl
      pg_stat_ssl
      pgcrypto
      ALTER ROLE
      ALTER DATABASE
      initdb -data-checksums (-k)
      log_statement
      track_functions
      track_activities

1. データベースの構造 【重要度：2】

   1. 説明：
      データベースの物理的な構造に関する知識を問う
   1. 主要な知識範囲：
      データベースクラスタの構造
      プロセス構造
      データの格納方法

      ~~~sql
      -- 階層: サーバ -> データベース -> スキーマ -> テーブルや関数等オブジェクト
      ~~~

   1. 重要な用語、コマンド、パラメータなど：
      autovacuum
      TOAST
      FILLFACTOR
      アーカイブログ
      ページヘッダ
      タプルヘッダ
      postmasterプロセス
      postgresプロセス
      バックグラウンドプロセス
      SQL実行のキャンセル
      シグナル(TERM/INT/HUP)によるサーバプロセスへの影響

1. ホット・スタンバイ運用 【重要度：1】

   1. 説明：
      レプリケーション構成を組むための設定や構築手順、およびレプリケーションの仕組み(プロセスやフロー)、状態の監視などに関する知識を問う
   1. 主要な知識範囲：
      ストリーミングレプリケーション機能とロジカルレプリケーション機能の概要
      同期レプリケーションと非同期レプリケーション
      postgresql.conf、recovery.confの設定
      パブリケーションとサブスクリプションの定義
   1. 重要な用語、コマンド、パラメータなど：
      wal_level
      max_wal_senders
      wal_sender_timeout
      wal_receiver_timeout
      synchronous_standby_names
      synchronous_commit
      max_logical_replication_workers
      CREATE/ALTER/DROP PUBLICATION/SUBSCRIPTION
      pg_stat_replication
      pg_stat_wal_receiver
      recovery_min_apply_delay
      スタンバイでの問い合わせのコンフリクト(衝突)
      hot_standby_feedback
      max_standby_streaming_delay
      pg_wal_replay_pause()
      pg_wal_replay_resume()
      walsenderプロセス
      walreceiverプロセス
      pg_receivewal
      トランザクションログ(WAL)
      スタンバイへ伝搬される処理とされない処理
      スタンバイで実行可能な問い合わせ
      ロジカルレプリケーションのサブスクライバ―へ伝搬される処理とされない処理

## 性能監視 ##

1. アクセス統計情報 【重要度：3】

   1. 説明：
      データベースの利用状況を示す稼働統計情報の内容や見方、収集方法に関する知識を問う
   1. 主要な知識範囲：
      pg_locks
      pg_stat_activity、pg_stat_database
      pg_stat_all_tables 等、行レベル統計情報
      pg_statio_all_tables 等、ブロックレベル統計情報
   1. 重要な用語、コマンド、パラメータなど：
      pg_stat_archiver
      pg_stat_bgwriter
      待機イベント(pg_stat_activity.wait_event)
      pg_stat_progress_vacuum

1. テーブル / カラム統計情報 【重要度：2】

   1. 説明：
      プランナが利用するテーブル・カラムの統計情報についての理解を問う
   1. 主要な知識範囲：
      - pg_class
      - pg_stats
      - テーブル・インデックスの実ファイルとパス
      - 実行計画時に利用される統計情報やパラメータ
   1. 重要な用語、コマンド、パラメータなど：
      pg_statistic
      pg_stats
      null_frac
      n_distinct
      most_common_freqs
      histogram_bounds
      correlation
      default_statistics_target
      effective_cache_size

1. クエリ実行計画 【重要度：3】

   1. 説明：
      EXPLAINが出力する実行計画を読み取り、チューニングを行う。
   1. 主要な知識範囲：
      EXPLAIN / EXPLAIN ANALYZE 出力
      計画型
      EXPLAINからのチューニング
      結合の種類(Nested Loop、Hash、Merge)と性能特性
      SQL構文(JOIN/GROUP BY/ORDER BY/LIMIT)に対応する実行計画
      集約関数(sum/count)を伴うSQLに対応する実行計画
      パーティションに対するSQLの実行計画
      パラレルクエリに対応する実行計画
      ウィンドウ関数(row_number/rankなど)のSQLに対応する実行計画
   1. 重要な用語、コマンド、パラメータなど：
      EXPLAIN / EXPLAIN ANALYZE

1. その他の性能監視 【重要度：1】

   1. 説明：
      性能監視に関するその他の手法
   1. 主要な知識範囲：
      スロークエリの検出
      付属ツールによる解析
      性能劣化要因(リソース枯渇、ロック競合)
   1. 重要な用語、コマンド、パラメータなど：
      shared_preload_libraries
      auto_explain
      auto_explain.*
      log_min_duration_statement
      pg_stat_statements
      log_autovacuum_min_duration
      log_lock_waits
      log_checkpoints
      log_temp_files

## パフォーマンスチューニング ##

1. 性能に関係するパラメータ 【重要度：4】
   1. 説明：
      データベースの設定パラメータで、特にパフォーマンスに影響を与えるもの、パフォーマンスチューニングの参考になるものに関する理解を問う
   1. 主要な知識範囲：
      資源の消費 (RESOURCE USAGE)
      ログ先行書き込み (WRITE AHEAD LOG)
      問い合わせ計画 (QUERY TUNING)
      実行時統計情報 (RUNTIME STATISTICS)
      ロック管理 (LOCK MANAGEMENT)
      軽量ロックと重量ロック
   1. 重要な用語、コマンド、パラメータなど：
      shared_buffers
      huge_pages
      effective_cache_size
      work_mem
      maintenance_work_mem
      autovacuum_work_mem
      wal_level
      fsync
      synchronous_commit
      checkpoint_timeout
      checkpoint_completion_target
      deadlock_timeout

1. チューニングの実施 【重要度：2】

   1. 説明：
      データベース、およびSQLのチューニングに関する理解を問う
   1. 主要な知識範囲：
      パラメータのチューニング
      実行計画のチューニング
      SQL のチューニング
      テーブル構成のチューニング
      ディスクI/Oの分散
      パラメータの反映方法(パラメータ有効化のために必要なアクション)
      インデックスがSQLの性能に与える影響
      Index Only Scan とVisibility Map
   1. 重要な用語、コマンド、パラメータなど：
      Index Only Scan

## 障害対応 ##

1. 起こりうる障害のパターン 【重要度：3】
   1. 説明：
      データベースでのSQL実行タイムアウトやサーバダウン、動作不良、データ消失、OSリソース枯渇などの故障が発生した場合について、エラーメッセージの内容から原因を特定し、適切な対応ができるかを問う
   1. 主要な知識範囲：
      サーバダウン、動作不良、データ消失への対処
      OS リソース枯渇
      OSのパラメータ
      サーバプロセスの状態(idle、idle in transaction、active)
      シグナル(TERM/INT/HUP)によるサーバプロセスへの影響
      サーバプロセスのクラッシュ(セグメンテーションフォルトなど)と影響範囲
   1. 重要な用語、コマンド、パラメータなど：
      statement_timeout
      lock_timeout
      idle_in_transaction_session_timeout
   1. スタンバイでの問い合わせのコンフリクト(衝突)
      hot_standby_feedback
      vacuum_defer_cleanup_age
      max_standby_archive_delay
      max_standby_streaming_delay
      fsync
      synchronous_commit
      restart_after_crash
      pg_cancel_backend()
      pg_terminate_backend()
      pg_ctl kill
      max_locks_per_transaction
      max_files_per_process

1. 破損クラスタ復旧 【重要度：2】

   1. 説明：
      データファイルやトランザクションログファイルが破損した場合について、エラーメッセージの内容から原因を特定し、適切な対応ができるかを問う
   1. 主要な知識範囲：
      トランザクションログ復旧
      システムテーブルのインデックス復旧
      開発者向けオプション
      テーブル・インデックスの実ファイルとパス
      Relfilenode と OID
      インデックス破損とREINDEXによる復旧
      チェックサムによる破損検知と復旧
      トランザクションIDの周回エラー
   1. 重要な用語、コマンド、パラメータなど：
      PITR
      pg_resetwal
      ignore_system_indexes
      ignore_checksum_failure
      コミットログ(pg_xact)
      シングルユーザモード
      VACUUM FREEZE

1. ホット・スタンバイ復旧 【重要度：1】

   1. 説明：
      レプリケーション構成でプライマリ側やスタンバイ側のPostgreSQLが停止・故障した場合について、適切な対応ができるかを問う
   1. 主要な知識範囲：
      ストリーミングレプリケーションとロジカルレプリケーション
      ログファイル内のエラーメッセージ
      スタンバイへ伝搬される処理とされない処理
      プライマリ側PostgreSQLの停止・故障と再開(再起動)の方法
      スタンバイ側PostgreSQLの停止・故障と再開(再起動)の方法
      ロジカルレプリケーションのサブスクライバ―へ伝搬される処理とされない処理
      ロジカルレプリケーションのサブスクライバ―でのコンフリクト
      重要な用語、コマンド、パラメータなど：
      pg_ctl promote
      pg_receivewal
      pg_rewind

## その他 ##

1. 引用符"について

  Postgreでは引用符"がなければ小文字として認識する。「"foo"」と「FOO」は同様。

  参照資料[識別子とキーワード](https://www.postgresql.jp/document/11/html/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS)

1. C形式エスケープでの文字列定数

  ~~~sql
  select E'a\tb'; --eでもいい
  ~~~

  参照資料[C形式エスケープでの文字列定数](https://www.postgresql.jp/document/11/html/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS)

1. ドル記号で引用符付けされた文字列定数

  ~~~sql
  select $$Dianne's horse$$;
  ~~~

1. データベース作成

   (デフォルト)実はtemplate1をコピー
   template0には、標準オブジェクトのみ存在、カスタマイズ不可
   初期のtemplate1はtemplate0と同様、カスタマイズ可能
   注意：この方法で実にクラスター内の任意DB複製可能だが、複製中接続不可(副作用が少ないCOPY DATABASE推奨)

   ~~~sql
   CREATE DATABASE dbname OWNER rolename;
   CREATE DATABASE dbname TEMPLATE template0;
   DROP DATABASE dbname;
   CREATE TABLESPACE fastspace LOCATION '/ssd1/postgresql/data'; --スーパーユーザ必須
   
   CREATE TABLE foo(i int) TABLESPACE space1;

   SET default_tablespace = space1;
   CREATE TABLE foo(i int);

   SELECT spcname FROM pg_tablespace;
   ~~~

   ~~~sh
   createdb -O rolename dbname
   createdb -T template0 dbname
   dropdb dbname
   ~~~

1. 個人的な感想(未検証)

   1. postgresqlには、オラクルのようなオプティマイザーはないが、指定できるインデックスの種類が多いため、同等レベルの実装ができる。

   1. postgresqlのロールはoracleのユーザとロール両方に相当  

   1. postgresqlのロールは同一クラスター内共用

   1. postgresqlのcreate schemaは？ oracleのcreate schemaは一連のテーブルやビューとGRANTを一トランザクションで処理するだけで、ユーザとほぼ同意。
