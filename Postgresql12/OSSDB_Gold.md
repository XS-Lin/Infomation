# OSSDB Gold メモ #

参照:
[出題範囲(公式)](https://oss-db.jp/outline/gold)
[サンプルDB](https://www.postgresqltutorial.com/postgresql-sample-database/)
[サンプル問題／例題解説](https://oss-db.jp/measures/sample)
[The Internals of PostgreSQL](http://www.interdb.jp/pg/index.html)
[Overview of Postgres Utility Processes](https://www.slideshare.net/EnterpriseDB/overviewutilityprocesses-finalaug222013)
[PostgreSQL 9.0 Architecture](http://raghavt.blogspot.com/2011/04/postgresql-90-architecture.html)

## 練習環境 ##

### 1 VM ###

1. OS

   [CentOS 8](https://www.centos.org/download/)

1. 構築(Hyper-V)

   1. OS インストール / パスワード: PostgresTest1

   1. ネットワーク /  ブリッジでホストローカル接続

   1. 構築

      ~~~bash
      dnf update
      localectl set-keymap us # US 配列のキーボード使用する場合
      dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
      dnf -qy module disable postgresql
      dnf install postgresql12-server
      /usr/pgsql-12/bin/postgresql-12-setup initdb
      systemctl enable postgresql-12
      systemctl start postgresql-12
      firewall-cmd --add-port=5432/tcp --zone=public --permanent
      firewall-cmd --reload
      su - postgresql
      ip -a address # 192.168.3.9
      vi $PGDATA/postgresql.conf # listen_address="*" port=5432
      /usr/pgsql-12/bin/pg_ctl restart
      vi $PGDATA/hba.conf # ADD: host all all 0.0.0.0/0 md5
      /usr/pgsql-12/bin/pg_ctl reload
      psql
      ~~~

      ~~~sql
      CREATE ROLE ad WITH SUPERUSER PASSWORD 'ad';
      ~~~

      **Tips！ viでctrl+sキーボードロック、ctrl+qで解除**

### 2 Docker ###

1. Dockerインストール

1. Docker用Postgresqlイメージダウンロード、コンテナ起動

   ~~~bash
   docker pull postgres:latest
   #起動
   docker run -d --rm --name postgres-test1 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5432:5432 postgres
   #停止
   docker container stop postgres-test1
   ~~~

1. Docker用Postgresql管理ツールpgadmin

   ~~~bash
   docker pull dpage/pgadmin4
   docker run --name pgadmin -p 5050:80 -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" -e "PGADMIN_DEFAULT_PASSWORD=SuperSecret" -d dpage/pgadmin4
   ~~~

## 運用管理（30％） ##

### データベースサーバ構築 【重要度：2】 ###

1. 説明

   サーバ構築における容量見積もり、およびデータベースセキュリティに関する知識を問う

1. 主要な知識範囲

   * テーブル・インデックス容量見積もり
   * セキュリティ
     * 通信経路暗号化（SSL)
     * データ暗号化
     * クライアント認証
     * 監査ログ
   * データ型のサイズ
   * ユーザ・データベース単位のパラメータ設定

1. 重要な用語、コマンド、パラメータなど

   * チェックサム
      * I/Oシステムによる破損検知を補助するために、データページにおいてチェックサムを使用、チェックサムの失敗はすべてpg_stat_databaseビューで報告、 デフォルトではデータページはチェックサム計算はされない
   * pg_xact
      * [68.1. データベースファイルのレイアウト] トランザクションのコミット状態のデータを保有するサブディレクトリ
   * pg_multixact
      * [68.1. データベースファイルのレイアウト] マルチトランザクションの状態のデータを保有するサブディレクトリ（共有行ロックで使用されます）
   * pg_notify
      * [68.1. データベースファイルのレイアウト] LISTEN/NOTIFY状態データを保有するサブディレクトリ
   * pg_serial
      * [68.1. データベースファイルのレイアウト] コミットされたシリアライザブルトランザクションに関する情報を保有するサブディレクトリ
   * pg_snapshots
      * [68.1. データベースファイルのレイアウト] エクスポートされたスナップショットを保有するサブディレクトリ
   * pg_stat_tmp
      * [68.1. データベースファイルのレイアウト] 統計サブシステム用の一時ファイルを保有するサブディレクトリ
   * pg_subtrans
      * [68.1. データベースファイルのレイアウト] サブトランザクションの状態のデータを保有するサブディレクトリ
   * pg_tblspc
      * [68.1. データベースファイルのレイアウト] テーブル空間へのシンボリックリンクを保有するサブディレクトリ
   * pg_twophase
      * [68.1. データベースファイルのレイアウト] プリペアドトランザクション用の状態ファイルを保有するサブディレクトリ
   * ssl
      * [18.9. SSLによる安全なTCP/IP接続] OpenSSLがクライアントとサーバシステムの両方にインストールされ、構築時にPostgreSQLにおけるそのサポートが有効になっている必要がある
   * pg_stat_ssl
      * [27.2.2. 統計情報の表示]  接続（通常およびレプリケーション）あたり1行の形式で、接続に使
われるSSLの情報を表示します。
   * pgcrypto
      * [F.25. pgcrypto]
        * 汎用ハッシュ関数
          * digest バイナリハッシュを計算
          * hmac ハッシュ化MACを計算
        * パスワードハッシュ化関数
          * crypt
          * gen_salt
   * ALTER ROLE
   * ALTER DATABASE
   * initdb -data-checksums (-k)
   * log_statement
       * [19.8.3. 何をログに] どのSQL文をログに記録するかを制御します。 有効な値は、 none（off）、 ddl、 mod、 およびall（全てのメッセージ） 注記
   * track_functions
       * [19.9.1. 問い合わせおよびインデックスに関する統計情報コレクタ] 関数の呼び出し数と費やされた時間の追跡を有効にします。 手続き言語関数のみを追跡するためにはplと指定してください。 SQL関数、 C言語関数も追跡するためにはallと指定してください。 デフォルトは、 統計情報追跡機能を無効にするnoneです。 スーパーユーザのみがこの設定を変更できます。
   * track_activities
       * [19.9.1. 問い合わせおよびインデックスに関する統計情報コレクタ] 各セッションで実行中のコマンドに関する情報とそのコマンドの実行開始時刻の収集を有効にします。 このパラメータはデフォルトで有効です。

1. 勉強法

### 運用管理用コマンド全般 【重要度：4】 ###

1. 説明

   データベースの運用管理に関する高度な知識を問う

1. 主要な知識範囲

   * バックアップ、PITR
   * VACUUM、ANALYZE、REINDEX
   * 自動バキューム
   * チェックポイント
   * サーバログ管理
   * ディスク容量監視
   * 自動VACUUMと手動VACUUM/ANALYZEの違い

1. 重要な用語、コマンド、パラメータなど

   * ALTER SYSTEM
       * ALTER SYSTEM SET configuration_parameter { TO | = } { value | 'value' | DEFAULT }
       * ALTER SYSTEM RESET configuration_parameter
       * ALTER SYSTEM RESET ALL
       * 変更分は postgresql.auto.conf に保存、DB起動時postgresql.conf -> postgresql.auto.conf順でパラメータ設定
   * ANALYZE
       * ANALYZE [ ( option [, ...] ) ] [ table_and_columns [, ...] ]
       * ANALYZE [ VERBOSE ] [ table_and_columns [, ...] ]
       * option
           * VERBOSE [ boolean ]
           * SKIP_LOCKED [ boolean ]
       * table_and_columns
           * table_name [ ( column_name [, ...] ) ]
       * 統計情報を収集し、その結果をpg_statisticシステムカタログに保存

   * CLUSTER
       * CLUSTER [VERBOSE] table_name [ USING index_name ]
       * CLUSTER [VERBOSE]
       * index_nameで指定されたインデックスに基づき、table_nameで指定されたテーブルをインデックス情報に基づいて物理的に並べ直される。クラスタ化後にテーブルが更新されても、その変更はクラスタ化されまない。テーブルのfillfactor格納パラメータを100%より小さく設定することで、更新処理中のクラスタ順序付けを保護するのに役に立つ。クラスター途中はACCESS EXCLUSIVEロック。 
   * REINDEX
       * REINDEX [ ( VERBOSE ) ] { INDEX | TABLE | SCHEMA | DATABASE | SYSTEM } [ CONCURRENTLY ] name
       * 使用される状況
           * インデックスが破損してしまい、有効なデータがなくなった
           * インデックスが「膨張状態」、つまり、多くの空、もしくは、ほとんど空のページを持つ状態になっている
           * インデックスの格納パラメータ（フィルファクタなど）を変更し、この変更を確実に有効にしたい
           * CONCURRENTLYオプションをつけたインデックス作成が失敗すると、このインデックスは「無効」として残され、有効化にする
   * VACUUM
       * 
   * CHECKPOINT
   * PITR
   * WAL
   * pg_dump
   * pg_dumpall
   * pg_basebackup
   * pg_start_backup()
   * pg_stop_backup()
   * postgresql.conf
   * recovery.conf
   * vacuumdb
   * pgstattuple
   * pg_cancel_backend()
   * pg_terminate_backend()
   * pg_isready
   * log_connections
   * log_disconnections
   * log_duration

### データベースの構造 【重要度：2】 ###

1. 説明

   データベースの物理的な構造に関する知識を問う
   * メモリ
     * 共有:shared_buffers,walbuffers
     * プロセス毎:work_mem,autovacuum_work_mem,maintenance_work_mem,temp_buffers
   * プロセス
      * postmaster(必須): PostgreSQLの親プロセス。接続を待ち受けるプロセス
      * postgres(必須): 個々のクライアントの要求を処理するプロセス（max_connections = 100）
      * logger: PostgreSQLのログをファイルに書き出すプロセス（logging_collector =on）
      * checkpointer(必須): チェックポイント処理を行うプロセス
      * background writer(必須): 共有バッファ変更内容をディスクに書き出すプロセス
      * walwriter(必須): WAL（Write-Ahead Log）の書き込みを行うプロセス
      * autovacuum launcher: データの更新を監視し、autovacuum workerプロセスを起動するプロセス（autovacuum = on）
      * autovacuum worker: 自動バキュームを実行するプロセス（autovacuum_max_workers = 3）
      * achiver: WALをアーカイブするプロセス（archive_mode = on）
      * stats collector(必須): 統計情報を収集するプロセス
      * background worker: 任意の処理を実行するユーザ定義のプロセス (max_worker_processes = 8)
      * logical replication launcher: logical replication workerを起動するプロセス
      * logical replication worder: WALを論理レプリケーションでパブリッシャから受信し、適用するプロセス(max_logical_replication_workers = 4)
      * walsender: WALをストリーミングレプリケーションのスタンバイサーバ、論理レプリケーションのサブスクライバへ転送するプロセス (max_wal_senders = 10)
      * startup (スタンバイ側): ストリーミングレプリケーションのスタンバイでWALを適用するプロセス
      * walreciever (スタンバイ側): WALをストリーミングレプリケーションでプライマリから受信するプロセス
   * ストレージ
      * データベースクラスター:データベース、WAL、ログ、一時ファイル、その他
      * バックアップ:ベースバックアップ、アーカイブログ、ダンプ

1. 主要な知識範囲

   * データベースクラスタの構造
      * PG_VERSION
      * base
      * global
      * pg_xacts
      * pg_dynshmem
      * pg_hba.conf
      * (省略)
      * pg_twophase
      * pg_wal
      * postgresql.auto.conf
      * postgresql.conf
      * postmaster.opts
      * postmaster.pid
   * プロセス構造
   * データの格納方法
      * テーブルファイル上のブロックは共有バッファを介して読み込み,複数のプロセスで共有する
      * ページはブロックをメモリ上にコピーしたもの
      * 読取イメージ: クライアント <- 共有バッファのページ <- ブロック

         ~~~txt
         データファイルのブロックはすでに共有バッファに存在の場合ディスクI/Oは発生しない
         ~~~

      * データ変更はWALバッファと共有バッファに行う
      * コミット時にWALファイルに書き込み
      * 更新イメージ: 更新 -> 共有バッファのページ **&** 更新 -> WALバッファ -> WALログ)

         ~~~txt
         共有バッファのページと対応するブロックは不一致になるが、クラッシュの場合はWALログより回復
         ~~~

      * 共有バッファの変更内容をディスクに反映(チェックポイント,キャッシュ追い出し,writerプロセスがバックグラウンドで同期処理を行う)
      * ディスク反映済みのWALファイルは不要になる
      * 反映イメージ: 共有バッファのページ -> ブロック

         ~~~txt
         共有バッファのページと対応するブロックを一致にする
         ~~~

      * トランザクションIDを用いてバージョン管理
      * 追記型の書き込み

         | STEP | テーブルt1内容※ | トランザクション内容 |
         | ---: | --- | --- |
         | 1 |                                 | Tran(ID=12304): SELECT * FROM t1 |
         | 2 | xmin=12302 xmax=0 value='S'     |                                  |
         | 3 |                                 | Tran(ID=12306): UPDATE t1 SET value = 'G'                    |
         | 4 | xmin=12302 xmax=12306 value='S' | |
         | 5 | xmin=12306 xmax=0 value='G'     | |
         | 6 |                                 | Tran(ID=12308): DELETE FROM t1   |
         | 7 | xmin=12302 xmax=12306 value='S' | |
         | 8 | xmin=12306 xmax=12308 value='G' | |
      * ※各トランザクション内で次にテーブル参照したとき、整合性が保たれる。SELECT xmin, xmax, * FROM t1;
      * xmin この行バージョンの挿入トランザクションの識別情報（トランザクションID）です。 （行バージョンとは、 行の個別の状態です。 行が更新される度に、 同一の論理的な行に対する新しい行バージョンが作成されます。）
      * xmax 削除トランザクションの識別情報（トランザクションID）です。 削除されていない行バージョンではゼロです。 可視の行バージョンでこの列が非ゼロの場合があります。 これは通常、 削除トランザクションがまだコミットされていないこと、 または、 削除の試行がロールバックされたことを意味しています。

1. 重要な用語、コマンド、パラメータなど

   * autovacuum
      * [19.10. 自動Vacuum作業]
   * TOAST
      * [68.2. TOAST] pg_class.reltoastrelid
   * FILLFACTOR
      * [格納パラメータ] テーブルのフィルファクタ(fillfactor)は10から100までの間の割合（パーセント）です。 100（すべて使用）がデフォルトです。
   * アーカイブログ
      * [25.3.6.2. 圧縮アーカイブログ]
   * ページヘッダ
      * [68.6. データベースページのレイアウト]
         * ページのレイアウト: PageHeaderData(24B),ItemIdData(4B*n),空き領域,アイテム,特別な空間
         * PageHeaderData: pd_lsn(8B，LSN: このページへの最終変更に対応するWALレコードの最後のバイトの次のバイト),pd_checksum(2B),pd_flags(2B),pd_lower(2B),pd_upper(2B),pd_special(2B),pd_pagesize_version(2B),pd_prune_xid(4B)
         * HeapTupleHeaderDataのレイアウト: t_xmin,t_xmax,t_cid,t_xvac,t_ctid（この行または最新バージョンの行の現在のTID）,t_infomask2,t_infomask,t_hoff
   * タプルヘッダ
      * [24.1.5.1. マルチトランザクションと周回]
   * postmasterプロセス
   * postgresプロセス
   * バックグラウンドプロセス
   * SQL実行のキャンセル
   * シグナル(TERM/INT/HUP)によるサーバプロセスへの影響

### ホット・スタンバイ運用 【重要度：1】 ###

1. 説明

   レプリケーション構成を組むための設定や構築手順、およびレプリケーションの仕組み(プロセスやフロー)、状態の監視などに関する知識を問う

1. 主要な知識範囲

   * ストリーミングレプリケーション機能とロジカルレプリケーション機能の概要
   * 同期レプリケーションと非同期レプリケーション
   * postgresql.conf、recovery.confの設定

1. 重要な用語、コマンド、パラメータなど

   * wal_level
      * wal_levelはどれだけの情報がWALに書かれるかを決定します。replica(default,WALアーカイビングおよびレプリケーションをサポートするために十分なデータを書き出し、 これにはスタンバイサーバで読み取り専用の問い合わせを実行することも含む),minimal(クラッシュまたは即時停止から回復するのに必要な情報を除き、 すべてのログを削除),logical(更にロジカルデコーディングをサポートするのに必要な情報を追加)
   * max_wal_senders
      * 複数のスタンバイサーバあるいは、 ストリーミングを使ったベースバックアップクライアントからの同時接続を受ける接続最大値を設定,デフォルトは10
   * wal_sender_timeout
   * wal_receiver_timeout
   * synchronous_standby_names
   * synchronous_commit
   * max_logical_replication_workers
   * CREATE/ALTER/DROP PUBLICATION/SUBSCRIPTION
   * pg_stat_replication
   * pg_stat_wal_receiver
   * recovery_min_apply_delay
   * スタンバイでの問い合わせのコンフリクト(衝突)
   * hot_standby_feedback
   * max_standby_streaming_delay
   * pg_wal_replay_pause()
   * pg_wal_replay_resume()
   * walsenderプロセス
   * walreceiverプロセス
   * pg_receivewal
   * トランザクションログ(WAL)
   * スタンバイへ伝搬される処理とされない処理
   * スタンバイで実行可能な問い合わせ
   * ロジカルレプリケーションのサブスクライバ―へ伝搬される処理とされない処理

1. 勉強法

   1. ストリーミングレプリケーション

      ~~~bash
      # 通信ネットワーク定義
      docker network create --driver bridge postgres_net
      docker network inspect postgres_net
      # 読み書き、マスター、プライマリ
      docker run -d --name postgres-test1 --net=postgres_net -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5432:5432 postgres
      # スタンバイ、セカンダリ
      docker run -d --name postgres-test2 --net=postgres_net -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5433:5432 postgres
      # スタンバイ、セカンダリ(もう一つ)
      docker run -d --name postgres-test3 --net=postgres_net -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5434:5432 postgres
      ~~~

      ~~~sql
      --レプリケーション動作の研究のため、ユーザ名を別々にする
      --サーバpostgres-test1
      CREAETE ROLE repuser1 WITH LOGIN REPLICATION PASSWORD 'repuser1';
      --サーバpostgres-test2
      CREAETE ROLE repuser2 WITH LOGIN REPLICATION PASSWORD 'repuser2';
      --サーバpostgres-test3
      CREAETE ROLE repuser3 WITH LOGIN REPLICATION PASSWORD 'repuser3';
      ~~~

      ~~~bash
      # サーバpostgres-test1 $PGDATA/pg_hba.conf
      host    repdb     repuser1       0.0.0.0/0            md5
      # サーバpostgres-test2 $PGDATA/pg_hba.conf
      host    repdb     repuser2       0.0.0.0/0            md5
      # サーバpostgres-test1 $PGDATA/pg_hba.conf
      host    repdb     repuser3       0.0.0.0/0            md5
      ~~~

      ~~~bash
      # サーバpostgres-test1 $PGDATA/postgresql.conf
      listen_addresses = '*'
      wal_level = replica
      max_wal_senders = 2
      archive_mode = off
      wal_keep_segments = 8
      # サーバpostgres-test2 $PGDATA/postgresql.conf
      hot_standby = on
      # サーバpostgres-test3 $PGDATA/postgresql.conf
      hot_standby = on
      ~~~

      ~~~bash
      # 全てのコンテナ開始
      docker start postgres-test1
      docker start postgres-test2
      docker start postgres-test3
      ~~~

      ~~~bash
      # ネットワーク削除
      docker network rm postgres_net
      # 全てのコンテナ停止
      docker stop postgres-test1
      docker stop postgres-test2
      docker stop postgres-test3
      # 全てのコンテナ削除
      docker rm postgres-test1
      docker rm postgres-test2
      docker rm postgres-test3
      ~~~

   2. ロジカルレプリケーション

## 性能監視（30％） ##

### アクセス統計情報 【重要度：3】 ###

1. 説明

   データベースの利用状況を示す稼働統計情報の内容や見方、収集方法に関する知識を問う
   * 性能チューニングを実施するために現状を分析し、性能低下の最大の要因を特定
   * OSのシステム監視ツール
      * メモリの利用状況
      * CPUの利用率
      * ディスクI/O
   * PostgreSQLの機能
      * ログから調査
      * 実行時統計情報の確認
         * 統計情報コレクタ（stats collectorプロセス）によって収集されるデータベースの動作状況に関する情報
         * 統計情報の収集はデフォルトで有効(track_counts = on,track_activities = on )
         * 統計情報はデータベース単位でリセットできる(SELECT pg_stat_reset();)
         * 実行中のSQLに関する情報をプロセスごとに表示(pg_stat_activity)
            * psコマンドなどと組み合わせてプロセスの特定が可能
            * xact_start、query_startなどから長時間実行したまま応答のないSQLの特定が可能
            * waiting列でロック待ちの確認
         * データベースに関する統計情報ビュー(pg_stat_database)
            * numbackends以外の項目は最後にリセットされてからの累積値を表示
               * 設定変更時はカウンタをリセットする
            * blks_read、blks_hitにてデータベースごとのキャッシュヒット率を確認
               * blks_hit / (blks_hit + blks_read)
               * ただしblks_hitにはOS側のキャッシュヒットは含まれていない
            * temp_files、temp_bytesにてwork_memの不足状況を確認
         * ユーザが作成したテーブルに関する行単位の統計情報ビュー(pg_stat_user_tables)
            * n_live_tup、n_dead_tupにて有効行、無効行を確認
            * last_autovacuum、last_autoanalyzeにて自動VACUUMの実行状況を確認
            * pg_stat_sys_tables：システムテーブルについて
            * pg_stat_all_tables：すべてのテーブルについて
            * pg_statio_user_tablesでは、ブロック単位の統計情報が確認できる
         * ユーザが作成したインデックスに関する行単位の統計情報ビュー(pg_stat_user_indexes)
            * idx_scanにてインデックスの利用状況を確認
            * pg_stat_sys_indexes：システムインデックスについて
            * pg_stat_all_indexes：すべてのインデックスについて

1. 主要な知識範囲

   * pg_locks
   * pg_stat_activity、pg_stat_database
      * pg_stat_activity
      * pg_stat_database
   * pg_stat_all_tables 等、行レベル統計情報
      * 
   * pg_statio_all_tables 等、ブロックレベル統計情報

1. 重要な用語、コマンド、パラメータなど

   * pg_stat_archiver
   * pg_stat_bgwriter
   * 待機イベント(pg_stat_activity.wait_event)
   * pg_stat_progress_vacuum

### テーブル / カラム統計情報 【重要度：2】 ###

1. 説明

   プランナが利用するテーブル・カラムの統計情報についての理解を問う

1. 主要な知識範囲

   * pg_class
   * pg_stats
   * テーブル・インデックスの実ファイルとパス
   * 実行計画時に利用される統計情報やパラメータ

1. 重要な用語、コマンド、パラメータなど

   * pg_statistic
   * pg_stats
   * null_frac
   * n_distinct
   * most_common_freqs
   * histogram_bounds
   * correlation
   * default_statistics_target
   * effective_cache_size

### クエリ実行計画 【重要度：3】 ###

1. 説明

   EXPLAINが出力する実行計画を読み取り、チューニングを行う。
   * SQL実行にあたり、内部的にどのような処理方式を組み合わせて実行するかを事前に見積もる
      * 選択できるすべての実行計画を検証
   * 実行計画の確認
      * EXPLAIN：実行計画を表示
      * EXPLAIN ANALYZE：実行計画と実行結果に基づく情報
   * 計画タイプ [例：Hash Join (cost=1.61..74.17 rows=1106 width=457)]
      * 内部的な処理の方式
      * 同じ処理であっても異なる方式が存在する
   * コスト（例：cost=1.61..74.17）
      * シーケンシャルアクセスでディスクから1ページ読み取るコストを1とした相対的な数値を表示
      * 「最初の行を取得するまでの指定コスト」と「すべての行を取得するまでの推定コスト」（≠実行時間）
      * 下位の計画ノードにおける推定コストが含まれる
   * 行数（例：rows=1106）
      * 取得される推定行数
   * 行の平均サイズ（例：width=457）
      * 取得される行の平均サイズ（バイト）
   * 実行時間（例： actual time=0.058..3.221）
      * 最初の行を取得するまでの実行時間とすべての行を取得するまでの実行時間（ミリ秒）
      * 下位の計画ノードにおける実行時間を含む
   * 行数（例：rows=999）
      * 実際に取得された行数
   * ループ回数（例：loops=1）
      * 繰り返して実行された回数
      * 実行時間と行数にはループ回数を乗じる
   * 計画作成時間（例：Planning time: 0.624 ms）
   * 実行時間（例：Execution time: 4.080 ms）

1. 主要な知識範囲

   * EXPLAIN / EXPLAIN ANALYZE 出力
   * 計画型
   * EXPLAINからのチューニング
   * 結合の種類(Nested Loop、Hash、Merge)と性能特性
   * SQL構文(JOIN/GROUP BY/ORDER BY/LIMIT)に対応する実行計画
   * 集約関数(sum/count)を伴うSQLに対応する実行計画
   * パーティションに対するSQLの実行計画
   * パラレルクエリに対応する実行計画
   * ウィンドウ関数(row_number/rankなど)のSQLに対応する実行計画

1. 重要な用語、コマンド、パラメータなど

   * EXPLAIN / EXPLAIN ANALYZE

### その他の性能監視 【重要度：1】 ###

1. 説明

   性能監視に関するその他の手法

1. 主要な知識範囲

   * スロークエリの検出
   * 付属ツールによる解析
   * 性能劣化要因(リソース枯渇、ロック競合)

1. 重要な用語、コマンド、パラメータなど

   * shared_preload_libraries
   * auto_explain
   * auto_explain.*
   * log_min_duration_statement
   * pg_stat_statements
   * log_autovacuum_min_duration
   * log_lock_waits
   * log_checkpoints
   * log_temp_files

## パフォーマンスチューニング（20％） ##

### 性能に関係するパラメータ 【重要度：4】 ###

1. 説明

   データベースの設定パラメータで、特にパフォーマンスに影響を与えるもの、パフォーマンスチューニングの参考になるものに関する理解を問う
   * 共有バッファの設定
      * 共有バッファ（データの読み取り時に使用されるバッファ）を増やして読み取り性能を向上させる
         * デフォルト値（128MB以下）は少なすぎる
         * 物理メモリが1GB以上の場合は共有バッファに4分の1を割り当てる
      * 共有バッファを大きくしすぎるとメモリ領域を圧迫して逆に性能が低下
         * Linuxでは余ったメモリ領域をディスクI/Oのバッファキャッシュとして使用してくれる
   * 共有バッファのページ割り当て
      * pg_stat_bgwriter
         * バックグランドライタと共有メモリに関する情報
         * すべてのデータベースに共通
   * データベース単位のキャッシュヒット(pg_stat_database,キャッシュヒット率=blks_hit/(blks_read + blks_hit))
   * テーブル単位のキャッシュヒット(pg_stat_user_tables)
   * SQL単位のキャッシュヒット(EXPLAIN (ANALYZE, BUFFERS) SQL)
      * shared hit =ヒットしたページ数
      * read＝読み込んだブロック数
      * written=書き込んだブロック数
   * ワークメモリの設定
      * ワークメモリ（ソートやハッシュ作成時などに使用されるメモリ）を増やしてSQLの実行時間を短くする
         * ワークメモリが少ないと、ソート時に一時ファイルの作成が必要になったり、ハッシュ作成に十分なメモリを確保できない
         * 共有メモリとは別にバックエンドごとに確保される(work_mem × max_connections)
         * log_temp_filesを利用して調査
         * 大きなメモリを設定する場合には、セッション・トランザクションごとに設定
      * 大きな値を設定すると物理メモリ不足になる可能性がある
   * 一時ファイルの利用状況の確認
      * work_memが十分でないとソート処理やハッシュ作成処理などで一時ファイルが利用される
      * 大量の一時ファイルを使うSQLを調査
         * 指定サイズ以上の一時ファイルを利用するSQLを特定(log_temp_files = 1MB ,すべての場合0指定)
      * EXPLAIN ANALYZEでも確認できる
         * Sort Method: external merge Disk: 11912kB
         * Sort Method: quicksort Memory: 25kB
      * 一時ファイルが多用されている場合にはwork_memのチューニングの余地あり
   * メンテナンスワークメモリの設定
      * メンテナンスワークメモリを増やし、バキュームを効率的に実行して短時間に完了させる
      * メンテナンスワークメモリ
         * VACUUMやREINDEX、CREATE INDEXなどの実行時に使用されるメモリの閾値
         * 共有メモリとは別に確保(maintenance_work_mem = 64MB)
         * VACUUMなどは一般的に同時に実行しないため、基本的に大きな値を設定しても問題ない
            * 自動バキュームでは、複数のプロセスがVACUUMを同時に実行するため（デフォルトでは3プロセス）、値を大きくしすぎないように注意
   * 自動バキュームの活動調査
      * 自動バキュームの活動状況をログに記述
      * テーブル単位で自動バキュームの実行時間の特定
      * 確認
         * 実行回数/1日 … 各テーブルがどれほどの頻度で実行されるか
         * 実行時間帯 … アクセスが多い時間帯に実行される頻度
         * 実行時間
   * WALバッファの設定
      * WALバッファ（WALファイルの書き込み時に使用されるバッファ）を増やして書き込み性能を向上させる
         * デフォルトでは-1=shared_buffers÷32 (shared_buffers = 512MBで16MB)
         * 更新が多い場合には増やす（最大16MB）
         * サーバ起動時に共有メモリバッファ（shared_buffers）とは別に指定された容量のメモリが確保される(wal_buffers = -1)
         * WALバッファが少なすぎると、コミット時以外にも書き込みが発生してしまう
   * チェックポイントの設定
      * チェックポイント処理の頻度を減らしてディスクI/Oの総量を減少させる
         * 更新が少ない場合にはcheckpoint_timeoutを長く、更新が多い場合にはcheckpoint_segmentsを多く設定
         * チェックポイント処理時の書き込み量が増えるため、一時的なディスクI/Oへの負荷は増加
            * max_wal_size = 1GB チェックポイント処理を実行するまでの完了済みWAサイズ
            * checkpoint_timeout = 5 min チェックポイント処理を実行するまでの間隔
            * checkpoint_completion_target = 0.5 チェックポイント処理を完了するまでの時間（間隔に対する割合）

   * チェックポイントの実行頻度と負荷状況
      * チェックポイントの実行をログに記録し、vmstatなどで取った負荷状況と見比べる
         * チェックポイントが頻発していないか
         * チェックポイント時の負荷が高すぎないか
   * プランナコスト定数の設定
      * プラットフォームの特性に合わせてプランナコスト定数を調整し、より適切な実行計画が作成されるようにする
         * プランナはプランナコスト定数をもとにコストを推定
           * seq_page_cost = 1.0 シーケンシャルアクセスでディスクから1ブロック読み取るコスト
           * random_page_cost = 4.0 ランダムアクセスでディスクから1ブロック読み取るコスト
           * effective_cache_size = 4GB プランナが想定するキャッシュサイズ(実際にメモリは確保されない)
         * インデックススキャンが選択されやすくするには
            * random_page_costを減らしてeffective_cache_sizeを増やす
            * effective_cache_sizeは共有メモリバッファの2倍（物理メモリの50%）くらいが適切

1. 主要な知識範囲

   * 資源の消費 (RESOURCE USAGE)
   * ログ先行書き込み (WRITE AHEAD LOG)
   * 問い合わせ計画 (QUERY TUNING)
   * 実行時統計情報 (RUNTIME STATISTICS)
   * ロック管理 (LOCK MANAGEMENT)
   * 軽量ロックと重量ロック

1. 重要な用語、コマンド、パラメータなど

   * shared_buffers
   * huge_pages
   * effective_cache_size
   * work_mem
   * maintenance_work_mem
   * autovacuum_work_mem
   * wal_level
   * fsync
   * synchronous_commit
   * checkpoint_timeout
   * checkpoint_completion_target
   * deadlock_timeout

### チューニングの実施 【重要度：2】 ###

1. 説明

   データベース、およびSQLのチューニングに関する理解を問う

1. 主要な知識範囲

   * パラメータのチューニング
   * 実行計画のチューニング
   * SQL のチューニング
   * テーブル構成のチューニング
   * ディスクI/Oの分散
   * パラメータの反映方法(パラメータ有効化のために必要なアクション)
   * インデックスがSQLの性能に与える影響
   * Index Only Scan とVisibility Map

1. 重要な用語、コマンド、パラメータなど

   * Index Only Scan

## 障害対応（20％） ##

### 起こりうる障害のパターン 【重要度：3】 ###

1. 説明

   データベースでのSQL実行タイムアウトやサーバダウン、動作不良、データ消失、OSリソース枯渇などの故障が発生した場合について、エラーメッセージの内容から原因を特定し、適切な対応ができるかを問う

1. 主要な知識範囲

   * サーバダウン、動作不良、データ消失への対処
   * OS リソース枯渇
   * OSのパラメータ
   * サーバプロセスの状態(idle、idle in transaction、active)
   * シグナル(TERM/INT/HUP)によるサーバプロセスへの影響
   * サーバプロセスのクラッシュ(セグメンテーションフォルトなど)と影響範囲

1. 重要な用語、コマンド、パラメータなど

   * statement_timeout
   * lock_timeout
   * idle_in_transaction_session_timeout
   * スタンバイでの問い合わせのコンフリクト(衝突)
   * hot_standby_feedback
   * vacuum_defer_cleanup_age
   * max_standby_archive_delay
   * max_standby_streaming_delay
   * fsync
   * synchronous_commit
   * restart_after_crash
   * pg_cancel_backend()
   * pg_terminate_backend()
   * pg_ctl kill
   * max_locks_per_transaction
   * max_files_per_process

### 破損クラスタ復旧 【重要度：2】 ###

1. 説明

   データファイルやトランザクションログファイルが破損した場合について、エラーメッセージの内容から原因を特定し、適切な対応ができるかを問う

1. 主要な知識範囲

   * トランザクションログ復旧
   * システムテーブルのインデックス復旧
   * 開発者向けオプション
   * テーブル・インデックスの実ファイルとパス
   * Relfilenode と OID
   * インデックス破損とREINDEXによる復旧
   * チェックサムによる破損検知と復旧
   * トランザクションIDの周回エラー

1. 重要な用語、コマンド、パラメータなど

   * PITR
   * pg_resetwal
   * ignore_system_indexes
   * ignore_checksum_failure
   * コミットログ(pg_xact)
   * シングルユーザモード
   * VACUUM FREEZE

### ホット・スタンバイ復旧 【重要度：1】 ###

1. 説明

   レプリケーション構成でプライマリ側やスタンバイ側のPostgreSQLが停止・故障した場合について、適切な対応ができるかを問う

1. 主要な知識範囲

   * ストリーミングレプリケーションとロジカルレプリケーション
   * ログファイル内のエラーメッセージ
   * スタンバイへ伝搬される処理とされない処理
   * プライマリ側PostgreSQLの停止・故障と再開(再起動)の方法
   * スタンバイ側PostgreSQLの停止・故障と再開(再起動)の方法
   * ロジカルレプリケーションのサブスクライバ―へ伝搬される処理とされない処理

1. 重要な用語、コマンド、パラメータなど

   * pg_ctl promote
   * pg_receivewal
   * pg_rewind

## 公式マニュアルのメモ ##

* [4.1.2.4. ドル記号で引用符付けされた文字列定数]$$を使用でエスケープ回避
* [4.2.14. 式の評価規則]AND,OR など、副式の評価順は定義されていない
* [5.11. テーブルのパーティショニング]重要なことはテーブルのサイズがデータベースサーバの物理メモリより大きいこと,大抵最適な選択はクエリのWHERE句に最もよく現れる列または列の組み合わせ
* [7.8.1. WITH内のSELECT]再帰的問い合わせの評価 WITH RECURSIVE
* [8.1.2. 任意の精度を持つ数]numeric型は0から離れるように丸め、realやdoubleprecision型ではその値に最も近い偶数に丸め
* [8.3. 文字型]character(n)はcharacter varying(n),textより遅い(一部OSでCHARは速いが、postgresqlはその特性を使用していない)
* [8.5. 日付/時刻データ型]timestamp(p)、pは秒以下の小数0-6
* [8.5.1.3. タイムスタンプ]1999-01-08 04:05:06 -8:00 ISO8601
* [8.8. 幾何データ型]点、直線、多辺形、円など
* [8.14.4. jsonb インデックス] GINインデックス
* [8.19. オブジェクト識別子データ型] 'mytable'::regclass   oid,xid,cid,tid
* [8.20. pg_lsn 型] はWALの位置を示す
* [9.25. システム情報関数]
* [9.26.3. バックアップ制御関数]
* [9.26.4. リカバリ制御関数]
* [9.26.6. レプリケーション関数]
* [9.26.7. データベースオブジェクト管理関数] pg_database_size(name) pg_indexes_size(regclass) pg_relation_size(relation regclass, fork text) pg_table_size(regclass)  pg_total_relation_size(regclass) pg_size_pretty
* [9.26.9. 汎用ファイルアクセス関数] pg_ls_waldir()  pg_ls_archive_statusdir() pg_stat_file(filename text[, missing
_ok boolean])
* [9.26.10. 勧告的ロック用関数]
* [第11章 インデックス]

## サンプル問題勉強 ##

### 運用管理 ###

1. Q1.20 レプリケーション構成において、フェールオーバを実施する方法として正しいものは次のうちどれか。

    * A. スレーブ側でrecovery.confのtrigger_fileパラメータで設定したトリガファイルを作成する
    * B. マスタ側でrecovery.confのtrigger_fileパラメータで設定したトリガファイルを作成する
    * C. postgresql.confで自動フェールオーバの設定をする
    * D. pg_ctl promoteコマンドを実行する
    * E. pg_hba.confの第2列目に、下記のようにレプリケーションの設定をする [host    replication    postgres    192.168.1.2/32    trust]

1. Q1.19 ログローテート時に同じ名前のログファイルが存在する場合に、追記、上書きを設定する設定は次のうちどれか。

    * A. log_min_error_statement
    * B. log_rotation_age
    * C. log_directory
    * D. log_truncate_on_rotation
    * E. log_connections

1. Q1.18 継続的アーカイブによるバックアップからの復旧を行う時に使用する設定ファイルについて、正しいものをひとつ選択してください。

    * A. postgresql.conf
    * B. pg_hba.conf
    * C. pg_recovery.conf
    * D. recovery.conf
    * E. restore.conf

1. Q1.16 バックアップに関して正しいものをすべて選択しなさい。

    * A. 通常はフルバックアップを取得するよりも、pg_basebackupによって更新差分を取得する方が処理時間は短い。
    * B. recovery_target_timelineをデフォルト値で使用すると、ベースバックアップが取得された際のタイムラインへ回復する。
    * C. pg_dumpコマンドによってpsqlコマンドでリストア可能な形式 として出力したバックアップファイルには、データベースを作成する SQLコマンドが含まれる場合がある。
    * D. pg_dumpコマンドも、pg_restoreコマンドも並列実行することが可能であり、複数のデータベースのバックアップ・リストア処理を行う際は高速化が図れる。
    * E. pg_restoreコマンドで--encodingオプションを使用すると、sjisで作成したダンプファイルをUTF8でリストアすることができる。

1. Q1.15 CLUSTERコマンドに関する説明として、適切ではないものを1つ選びなさい。

    * A. CLUSTERコマンドによりテーブルデータが物理的に再編成され、読み込み性能が向上する可能性がある
    * B. CLUSTERコマンドが実行されているテーブルに対する読み込みは待機される
    * C. PRIMARY KEYが存在しないテーブルに対するCLUSTERコマンドは実行できない
    * D. maintenance_work_memの値を大きくするとCLUSTERコマンドの性能が向上する可能性がある
    * E. CLUSTERコマンドによりテーブルおよびインデックスサイズを削減できる可能性がある

1. Q1.11 pg_basebackupコマンドに関する説明として、適切でないものを2つ選びなさい。

    * A. 別サーバで動作しているPostgreSQLデータベースクラスタのベースバックアップを取得できる
    * B. pg_basebackupコマンドの実行前にpg_start_backupコマンドを実行する必要がある
    * C. fetch方式の場合、max_wal_sendersパラメータを少なくとも1以上に設定する必要がある
    * D. オプションを明示的に指定しないで実行した場合に、WALはバックアップに含まれる
    * E. テーブル空間が追加で作成されている場合は、テーブル空間内のデータはバックアップに含まれない

1. Q1.10 VACUUMに関して正しいものを全て選択しなさい。

    * A. FULLオプションを付加すると、データベース全体の不要領域が回収される。
    * B. VERBOSEオプションを付加すると、VACUUM処理の詳細な情報を取得することができる。
    * C. AUTOオプションを付加すると、autovacuumの設定を用いてVACUUMが行われる。
    * D. ANALYZEオプションを付加すると、統計情報の更新も行われる。
    * E. 一つのVACUUMコマンドに複数のテーブルを指定して実行することができる。

1. Q1.09 ロングトランザクションによる弊害についての説明として、適切なものを２つ選びなさい。

    * A. オンラインバックアップの取得ができなくなる
    * B. VACUUMによる不要領域の回収ができなくなる。
    * C. DBへの接続ができなくなる
    * D. 新たなトランザクションが開始できなくなる
    * E. テーブルが長時間ロックされ、そのテーブルに対するDDLが完了しなくなる

1. Q1.08 VACUUMに関して正しいものを全て選択しなさい。

    * A. VACUUMを実行するユーザが対象テーブルに対するVACUUMの実行権限を持っていない場合はエラーとなる。
    * B. トランザクションブロック内でVACUUMを実施すれば、ROLLBACKによって処理を取り消すことができる。
    * C. オプションが指定されていない通常のVACUUMでも、不要領域をOSに返還することがある。
    * D. 多数の行を追加または削除した場合は、VACUUM ANALYZEを実施すべきである。

1. Q1.07 ANALYZEに関して正しいものを全て選択しなさい。

    * A. 整列されたデータを昇順にロードした場合、ANALYZEを実施しなくとも最適なプランが作成される。
    * B. 自動バキュームデーモンがANALYZEを実施する場合がある。
    * C. default_statistics_targetの値を大きくすると、ANALYZEの所要時間は短くなるがプランナの予測の品質は低下する。
    * D. 対象とするテーブルへのSHARE UPDATE EXCLUSIVEロックが取得される。
    * E. PostgreSQLのANALYZE文は、標準SQLに準拠している。

1. Q1.06 2台のサーバ(プライマリサーバ、スタンバイサーバ)でストリーミングレプリケーションを行い、スタンバイサーバをホットスタンバイとして運用する。この環境を構築する際に各サーバで設定するパラメータとして誤っているものを1つ選びなさい。

    * A. プライマリサーバのpg_hba.confに、データベースフィールドを"replication"と指定した項目を設定する
    * B. プライマリサーバのpostgresql.confに、"wal_level = hot_standby"を設定する
    * C. スタンバイサーバのpostgresql.confに、"hot_standby = on"を設定する
    * D. スタンバイサーバのpostgresql.confに、"standby_mode = 'on'"を設定する
    * E. スタンバイサーバのrecovery.confの"primary_conninfo"に、プライマリサーバへの接続情報(libpq接続文字列)を設定する

1. Q1.05 データベースクラスタ配下の各サブディレクトリに保有されるデータの説明として、適切ではないものを1つ選びなさい。

    * A. globalディレクトリにはデータベースクラスタ全体で共有するテーブルが保有される。
    * B. pg_tblspcディレクトリにはテーブル空間により管理されるテーブルが保有される。
    * C. pg_xactディレクトリにはトランザクションのコミット状態のデータが保有される。
    * D. pg_walディレクトリにはWALファイルが保有される。
    * E. pg_stat_tmpディレクトリには統計情報コレクタがバックエンドプロセスと必要な情報をやり取りするための一時ファイルが格納される。

1. Q1.04 以下のSQL文でインデックスを定義し、100万行を挿入する。[CREATE INDEX member_index ON member_table (team_id, birthday);]ここで、team_idのデータ型はINTEGER、birthdayのデータ型はDATE、いずれもNOT NULL制約が付いているものとする。インデックスのファイルサイズ見積りとして最も適切なものを1つ選びなさい。なお、1ブロックは8192バイトとし、FILLFACTORは90%とする。

    * A. 9メガバイト
    * B. 13メガバイト
    * C. 19メガバイト
    * D. 23メガバイト
    * E. 29メガバイト

1. Q1.02 PostgreSQL のプロセス構造について、適切なものをすべて選びなさい。

    * A. データベースに接続するクライアント一つ一つについて、別々のサーバプロセスが起動する。
    * B. データベースクラスタ内のそれぞれのデータベースについて、別々のサーバプロセスが起動する。
    * C. WAL ライタ、自動バキュームランチャ、統計情報コレクタなどいくつかのプロセスが動作しているが、いずれも postgres という同一の実行ファイルから作られるプロセスである。
    * D. クライアントが接続していないときは、通常は postmaster というプロセスだけが動作している。
    * E. データベースクラスタ1つに対して、postmaster というプロセスが1つ動作している。

1. Q1.01 以下のSQL分でテーブルを定義し、50万行を挿入する。

    ~~~sql
    CREATE TABLE registration (
      id BIGINT PRIMARY KEY,
      reg_event INTEGER NOT NULL,
      reg_client INTEGER NOT NULL,
      reg_date TIMESTAMP NOT NULL
    );
    ~~~

    テーブルのファイルサイズ見積りとして最も適切なものを1つ選びなさい。1ブロックは8192バイトとし、インデックスのファイルサイズは含めないものとする。

    * A. 5メガバイト
    * B. 15メガバイト
    * C. 25メガバイト
    * D. 40メガバイト
    * E. 60メガバイト

1. Q1.22 crypt関数の意味として、正しいものは次のうちどれか。

    * A. 対称鍵を指定して、データを暗号化する
    * B. データのバイナリハッシュを計算する
    * C. パスワードのハッシュ処理を行う
    * D. データのハッシュ化MACを計算する
    * E. パスワードハッシュ時に使用するランダムなソルト文字列を新規に作成する

1. Q1.21「mydb」テーブルのみに対して、更新/削除された行の切り詰めを行いたい。VACUUMコマンドの使い方として正しいものは次のうちどれか。

    * A. VACUUM mydb;
    * B. VACUUM FULL mydb;
    * C. VACUUM VERBOSE mydb;
    * D. VACUUM;
    * E. VACUUM -f mydb;

### 性能監視 ###

1. Q2.16 下記のEXPLAINの実行結果について、正しい記述を３つ選んでください。

    ~~~sql
    postgres=# EXPLAIN SELECT relname,nspname FROM pg_class left join pg_namespace ON (pg_class.relnamespace = pg_namespace.oid);
                                   QUERY PLAN
    -------------------------------------------------------------------------
     Hash Left Join  (cost=1.14..15.97 rows=288 width=128)
       Hash Cond: (pg_class.relnamespace = pg_namespace.oid)
       ->  Seq Scan on pg_class  (cost=0.00..10.88 rows=288 width=68)
       ->  Hash  (cost=1.06..1.06 rows=6 width=68)
             ->  Seq Scan on pg_namespace  (cost=0.00..1.06 rows=6 width=68)
    (5 行)
    ~~~

    * A. このEXPLAINコマンドを実行すると、引数に指定したSQL文が実際に実行される
    * B. 計画ノードの「Hash Left Join」、「Seq Scan on pg_class」、「Seq Scan on pg_namespace」の記述
    * C. 「cost=〜」の部分は、処理にかかる実際の時間を示している
    * D. 「rows=〜」の部分は、それぞれの計画ノードを実行した際の推定の処理行数を示している
    * E. 「width=〜」の部分は、統計情報をもとに推測される1行あたりの平均のバイトサイズを示している

1. Q2.15 pg_stat_statementsの説明として正しいものは次のうちどれか。

    * A. SQL文の実行に指定した時間以上かかった場合、それぞれのSQL文の実行に要した時間を記録する
    * B. ロック待ちとなっているトランザクションや対象のテーブルを確認する
    * C. 実行された全てのSQL文の実行時の統計情報を記録する
    * D. データベースあたり1行の形式でデータベース全体の情報を表示する
    * E. 現在のデータベースの各テーブルごとに1行の形で、テーブルへのアクセス統計情報を表示する

1. Q2.14 pg_classに関する記述の中で、正しいものを2つ選びなさい。

    * A. relpages列にはテーブル内の行数が格納されている
    * B. pg_classはテーブルの情報のみを格納している
    * C. pg_class内には常に最新の情報が格納されている
    * D. relpages列の値は推測値である
    * E. pg_classに格納されている統計情報は一部のDDLコマンドで更新される

1. Q2.13 テーブルへのアクセスの統計情報を表示する方法として、正しいSQL文を選択してください。

    * A. SELECT * FROM pg_stat_activity;
    * B. SELECT * FROM pg_stat_database;
    * C. SELECT * FROM pg_stat_bgwriter;
    * D. SELECT * FROM pg_stat_all_tables;
    * E. SELECT * FROM pg_stat_all_indexes;

1. Q2.12 pg_locksビューによって確認することが可能なロックの対象となるオブジェクトを全て選択しなさい。

    * A. データベース
    * B. リレーション
    * C. タプル
    * D. カラム
    * E. パラメータ

1. Q2.11

   ~~~sql
   EXPLAIN ANALYZE SELECT * FROM pgbench_accounts a
    JOIN pgbench_branches b ON (a.bid = b.bid) WHERE a.aid = 10000;

    上記問い合わせの実行計画(EXPLAIN ANALYZE)を確認したところ、下記の出力であった。
    QUERY PLAN
    -----------------------------------------------------------------------------------------------------------------------------------
    Nested Loop (cost=0.00..2891.02 rows=1 width=461) (actual time=4.589..64.393 rows=1 loops=1)
       Join Filter: (a.bid = b.bid)
       -> Seq Scan on pgbench_accounts a (cost=0.00..2890.00 rows=1 width=97) (actual time=4.555..64.356 rows=1 loops=1)
             Filter: (aid = 10000)
             Rows Removed by Filter: 99999
       -> Seq Scan on pgbench_branches b (cost=0.00..1.01 rows=1 width=364) (actual time=0.007..0.008 rows=1 loops=1)
    Total runtime: 64.557 ms
    (7 rows)
    ~~~

    上記問い合わせをより高速にするために行うこととして最も適切なものをひとつ選びなさい。
    なお、各テーブルの構成は下記のようになっている。

    Table "public.pgbench_accounts"
    | Column | Type | Modifiers |
    |----------|---------------|-----------|
    | aid | integer | not null
    | bid | integer |  |
    | abalance | integer | |
    | filler | character(84)| |

    Table "public.pgbench_branches"
    | Column | Type | Modifiers |
    |----------|---------------|-----------|
    | bid | integer | not null  |
    | bbalance | integer |  |
    | filler | character(88) |  |
    Indexes:
        "pgbench_branches_pkey" PRIMARY KEY, btree (bid)

    * A. pgbench_accountsのabalance列にインデックスを作成する
    * B. pgbench_branchesのbid列にインデックスを作成する
    * C. pgbench_accountsを対象にANALYZEを実行する
    * D. pgbench_accountsのaid列にインデックスを作成する
    * E. pgbench_branchesを対象にANALYZEを実行する

1. Q2.10 EXPLAINコマンドで指定可能な出力形式のうち誤っているものを全て選択しなさい。

    * A. JSON
    * B. HTML
    * C. CSV
    * D. YAML
    * E. XML

1. Q2.09 EXPLAINコマンドを使用することで、問い合わせ文の実行計画を表示することができる。EXPLAINコマンドの対象となるSQLコマンドとして正しいものを全て選択しなさい。

    * A. DELETE
    * B. DROP TABLE
    * C. REINDEX
    * D. PREPARE
    * E. EXECUTE

1. Q2.08 標準統計情報ビューに関して正しいものを全て選択しなさい。

    * A. pg_stat_all_tablesから、TOASTテーブルから読み取られたディスクブロック数を取得することができる。
    * B. pg_stat_activityから、現在の問い合わせの実行開始時刻を取得することができる。
    * C. pg_stat_databaseから、対象データベースのエラー発生数を取得することができる。
    * D. pg_statio_all_tablesから、対象テーブルのバッファヒット数を取得することができる。

1. Q2.07 pg_stat_databaseに関する記述で誤っているものを全て選択しなさい。

    * A. データベースクラスタ全体の稼働統計情報が1行だけ格納される。
    * B. blks_hitはバッファキャッシュにヒットしたブロック数が格納される。
    * C. blks_readはディスクから読み込んだブロック数とバッファキャッシュから読み込んだブロック数の合計である。
    * D. デフォルトではtrack_countsパラメータがoffであるため、稼働統計情報が収集されない。
    * E. tup_fetchedはインデックススキャンを使用して読み取った行数が格納される。

1. Q2.06 ロングトランザクションを発見するのに有効なシステムカタログについての解説で、適切なものを選びなさい。

    * A. pg_stat_activityのwaitingを監視する
    * B. pg_stat_activityのquery_startを監視する
    * C. pg_stat_activityのxact_startを監視する
    * D. ロングトランザクションを発見するのに有効なシステムカタログは無い

1. Q2.05 oid2nameの使い方として誤っているものを1つ選びなさい。

    * A. データベースのOID一覧を取得するため以下のコマンドを実行した

      ~~~bash
      oid2name
      ~~~

    * B. 別ホストsrv上の5432ポートで動作するPostgreSQLのデータベースのOID一覧を取得するため以下のコマンドを実行した

      ~~~bash
      oid2name -h srv -p 5432
      ~~~

    * C. データベースtestdbに含まれるテーブルのファイルノード番号一覧を取得するため以下のコマンドを実行した

      ~~~bash
      oid2name -d testdb
      ~~~

    * D. テーブル空間のOID一覧を取得するため以下のコマンドを実行した

      ~~~bash
      oid2name -s
      ~~~

    * E. データベースtestdbに含まれるテーブル/インデックス/シーケンスのファイルノード一覧を取得するため以下のコマンドを実行した

      ~~~bash
      oid2name -i -d testdb
      ~~~

1. Q2.03 テーブル/カラム統計情報に関する記述の中で、正しいものを2つ選びなさい

    * A. pg_classでは、テーブルのほか、ビューやインデックスの情報も扱う。
    * B. pg_classには、常に最新の情報が格納されている。
    * C. pg_class内の列であるreltuplesにはテーブル内の行数が格納されるが、この値は推測値である。
    * D. pg_statsは、カラム統計情報を扱うテーブルである。
    * E. pg_statsで参照できる情報の中には実データの一部が格納されるため、一般のユーザは参照できない。

1. Q2.02 EXPLAINコマンドを用いて問い合わせを実行させ、結果が出力された。

    ~~~sql
    EXPLAIN ANALYZE SELECT *
    FROM table1 t1, table2 t2
    WHERE t1.unique1 < 100 AND t1.unique2 = t2.unique2;

    QUERY PLAN
    -----------------------------------------------------------------------------------------------------------------------------------
    Nested Loop (cost=0.00..352.17 rows=97 width=16) (actual time=0.033..1.875 rows=100 loops=1)
       -> Index Scan using table1_i1 on table1 t1 (cost=0.00..24.05 rows=97 width=8) (actual time=0.016..0.218 rows=100 loops=1)
             Index Cond: (unique1 < 100)
       -> Index Scan using table2_i2 on table2 t2 (cost=0.00..3.27 rows=1 width=8) (actual time=0.004..0.006 rows=1 loops=100)
             Index Cond: (t2.unique2 = t1.unique2)
    Total runtime: 2.065 ms
    ~~~

    この結果言えることとして、誤っているものを2つ選択せよ。

    * A. この問い合わせにより出力される行数は97行であった。
    * B. Total runtime には、結果行を操作するための時間の他に、エクゼキュータの起動、停止時間も含まれている。
    * C. table2_i2 という名前のインデックスを用いて検索をしている。
    * D. Nested Loop の cost と actual time の値が大きく異なっているので、統計情報の再収集が必要である。
    * E. table1 が外側、table2 が内側になるネステッドループで結合をしている。

1. Q2.01 pg_stat_database, pg_stat_all_tables などのアクセス統計情報(稼働統計情報)のビューに関する説明として、適切なものを2つ選びなさい。

    * A. ANALYZE コマンドを実行したときにデータが収集される。
    * B. stats collector プロセスによって定期的にデータが収集される。
    * C. テーブルの行数、最大値・最小値、データの分布など、テーブル内のデータの状態が収集される。
    * D. プランナが SQL の最適な実行計画を作成するために利用される。
    * E. システム全体のスループットの調査、パフォーマンス問題の発見などに使われる。

### パフォーマンスチューニング ###

1. Q3.15 PostgreSQLサーバをレプリケーション構成で稼働させる場合、synchronous_commit パラメータによってプライマリ機とスタンバイ機の同期レベルをチューニングすることが可能である。以下の選択肢は、プライマリ機でトランザクションのコミットを実行した際の、synchronous_commit パラメータの設定値毎の動作の説明をしたものである。誤っているものを1つ選びなさい。

    * A. on にすると、WALがスタンバイ機のディスクに正常に書き出されたタイミングでコミット成功とする
    * B. off にすると、WALがプライマリ機にもスタンバイ機にもまだ書き出されていない状況でもコミット成功とする
    * C. local にすると、WALがスタンバイ機のディスクに書き出される前の、バッファに書き出されたタイミングでコミット成功とする
    * D. remote_apply にすると、スタンバイ機でのWALのディスク書き込みだけでなく、WALの記述内容がデータベースに適用されたタイミングでコミット成功とする

1. Q3.14 buffers_backendに関する説明として適切なものをすべて選びなさい。

    * A. pg_stat_bgwriterビューによ�����て表示���れる
    * B. チェックポイントによる書き出しの際に値が増加する
    * C. buffers_backendの値がbuffers_allocに対して大きい場合は、shared_buffersの値のチューニングを検討する必要がある
    * D. バックグラウンドライタによる書き出しの際に値が増加する
    * E. バックエンドプロセスによる書き出しの際に値が増加する

1. Q3.13 問い合わせ計画に関する以下の内容のうち、正しいものを全て選択しなさい。

    * A. enable_indexscanを無効に設定すると、インデックススキャンは完全に行われなくなる。
    * B. enable_seqscanを無効に設定すると、シーケンシャルスキャンは完全に行われなくなる。
    * C. random_page_costをseq_page_costと比較して小さく設定すると、よりインデックススキャンが使用されるようになる。
    * D. random_page_costをseq_page_costと比較して大きく設定すると、よりインデックススキャンが使用されるようになる。
    * E. default_statistics_targetをより小さく設定すると、より細かく統計情報を収集するようになるため、プランナの予測の品質が向上する。 

1. Q3.12 work_memをチューニングすることによって、性能が向上すると考えられる処理を全て選択しなさい。

    * A. ORDER BY
    * B. CREATE INDEX
    * C. マージ結合
    * D. VACUUM
    * E. 自動VACUUM

1. Q3.11 インデックスの作成に関する説明として、適切なものを2つ選びなさい。

    * A. FILLFACTORの指定が省略された場合、デフォルト値として対象テーブルのFILLFACTORと同じ値が設定される
    * B. UNLOGGEDパラメータが指定された場合、インデックスの更新時にWALログが取られなくなり、更新処理が高速化する
    * C. PARALLELパラメータが指定された場合、複数のプロセスによりインデックスが作成され、作成時間が短縮する
    * D. CONCURRENTLYパラメータが指定された場合、対象テーブルに対する書き込みをロックせずにインデックスを作成するが、通常の方式より作成時間が長くなる
    * E. インデックスの定義で使用される関数と演算子は、immutableでなければならない

1. Q3.10 GUCパラメータのenable_seqscanをonからoffに変更する前後で、同一のクエリに対してEXPLAIN ANALYZE文で実行計画を取得する。実行計画の変化の説明として、最も適切ではないものを１つ選びなさい。この時、enable_seqscan以外の条件はすべて同一とする。

    * A. Total runtimeの値が大きくなる可能性がある
    * B. Total runtimeの値が小さくなる可能性がある
    * C. 最上位ノードの全体推定コストが大きくなる可能性がある
    * D. 最上位ノードの全体推定コストが小さくなる可能性がある
    * E. 全く同一の実行計画が選択される可能性がある

1. Q3.09 インデックスの再作成について正しい記述を2つ選びなさい。

    * A. インデックスの再作成はサービスを停止して行う必要がある。
    * B. REINDEXはインデックスの元となるテーブルの読み込みをロックしないため、サービス稼働中に実行しても参照処理への影響はない。
    * C. CREATE INDEX CONCURRENTLYは、同時挿入、更新、削除と競合するロックを獲得せずにインデックスを作成できる。
    * D. CREATE INDEX CONCURRENTLYでは、プライマリキーの作成も可能である。
    * E. 定期的にインデックスの再作成を行うことで、インデックスの肥大化を抑止できる。

1. Q3.08 PostgreSQLの処理全般が定期的に遅くなる現象が発生した。この場合のチューニングで効果が期待できる対策を2つ選びなさい。

    * A. 遅くなったSQLを見直し、負荷の原因となっている記述を修正する。
    * B. checkpoint_completion_targetを調整して、チェックポイントの負荷分散を図る。
    * C. autovacuum_vacuum_cost_limitまたはvacuum_cost_limit値を小さくし、VACUUM処理の負荷低減を図る。
    * D. ストリーミングレプリケーション構成に変更し負荷分散を図る。
    * E. PostgreSQLの特性であり対策はない。

1. Q3.07 full_page_writesパラメータをOFFに設定した場合に関する説明として、適切でないものを2つ選びなさい。

    * A. データ更新時の応答性能が向上する可能性がある
    * B. データ更新時のWALの書き込み量が低減する可能性がある
    * C. wal_levelパラメータがminimalの場合は、応答性能は変化しない
    * D. システムクラッシュ時に、回復不可能なデータ破損が発生する可能性がある
    * E. ポイントインタイムリカバリの運用はできなくなる

1. Q3.06 性能低下の原因に関して正しいものをすべて選択しなさい。

    * A. shared_buffersの値を大きく設定しすぎたことによって、チェックポイント中の問い合わせの性能が低下した。
    * B. maintenance_work_memをwork_memよりも大きく設定したことによって、VACUUM処理の性能が低下した。
    * C. 複数のセッションが多量のINSERTを発行したことによって、WALファイルへの書き込みで競合が発生し、INSERTの性能が低下した。
    * D. pgstattupleを用いて定期的にタプルレベルの統計情報を取得しなかったため、PostgreSQLが最適な実行計画を作成できずに問い合わせの性能が低下した。

1. Q3.03 データベースに大量データを投入する際の性能を向上させるために、一時的に講じることとして、適切とは言えないものを2つ選びなさい。

    * A. 自動コミットをオフにする
    * B. インデックスや外部キー制約を削除する
    * C. maintenance_work_memを増やす
    * D. checkpoint_segmentsを減らす
    * E. checkpoint_timeoutを増やす

1. Q3.02 デッドロックに関する GUC パラメータ deadlock_timeout の説明として、正しいものをすべて選びなさい。

    * A. deadlock_timeout で指定された時間を経過してもロックが獲得できなければ、デッドロックが発生していると判断される。
    * B. deadlock_timeout の値を調整することで、デッドロックの発生を回避できる。
    * C. deadlock_timeout の値を小さくすると、ロック待ちのプロセスが減るので、結果的にCPU負荷を小さくすることができると考えられる。
    * D. デッドロックはアプリケーションの作り方を工夫することで回避すべきであり、deadlock_timeout の値はなるべく大きくすることが望ましい。
    * E. deadlock_timeout のデフォルトの設定では、デッドロックの検出は自動的には実行されない。

1. Q3.01 GUCパラメータの説明として、誤っているものを1つ選びなさい。

    * A. shared_bufferは、PostgreSQLサーバが使用する共有メモリバッファのサイズ を設定する。
    * B. max_connectionsは、PostgresSQLサーバに接続できる最大クライアント数を 設定する。
    * C. work_memは、VACUUM、CREATE INDEXなどの保守作業で使用されるメモリの最 大容量を設定する。
    * D. sslをonに設定することでSSL接続を有効にする。
    * E. wal_levelは、WALに書き込まれる情報を制御するパラメータである。

### 障害対応 ###

1. Q4.08 共有メモリが不足して、サーバがダウンしてしまった時の対策として正しいものは次のうちどれか。

    * A. maintenance_work_memで適切なメモリ領域を設定する
    * B. shared_buffersで適切なメモリ領域を設定する
    * C. autovacuum_work_memで適切なメモリ領域を設定する
    * D. pg_resetwalを用いてWALファイルを整合性のある状態に復旧し、PostgreSQLを起動する
    * E. work_memで適切なメモリ領域を設定する

1. Q4.07 操作ミスによってリレーションが消失することを想定した対策または復旧を行う際に、実施すべき内容として正しいものを全て選択しなさい。

    * A. ミラーリングによって、ディスクの複製を作成しておく。
    * B. pg_basebackupによって、定期的に論理バックアップを取得しておく。
    * C. PITRによって、操作ミス直前の時間まで巻き戻しを行う。
    * D. pg_dumpallによって、操作ミス直前の時間まで巻き戻しを行う。
    * E. wal_levelをminimalからhot_standbyに変更しておく。

1. Q4.06 以下のサーバログに関する説明として、適切なものを1つ選びなさい。

    ~~~txt
    LOG: server process (PID 21334) was terminated by signal 11: Segmentation fault
    DETAIL: Failed process was running: SELECT user_func();
    ~~~

    * A. ユーザ要求によりクエリがキャンセルされた
    * B. プロセスに対してpg_cancel_backend関数が発行された
    * C. プロセスに対してpg_terminate_backend関数が発行された
    * D. OOM KillerによりSIGKILLが発生した
    * E. user_funcユーザ定義関数によりSIGSEGVが発生した

1. Q4.05 2台のサーバでレプリケーションを行い、スタンバイサーバをホットスタンバイとして稼動させる。サーバ間の通信が一時的に遮断し、その後に復旧した場合の説明として、適切ではないものを2つ選びなさい。   

    * A. レプリケーションの方式が同期か非同期かにかかわらず、通信が遮断中でも、マスタサーバでの参照系クエリは実行可能である
    * B. レプリケーションの方式が同期か非同期かにかかわらず、通信が遮断中でも、スタンバイサーバでの参照系クエリは実行可能である
    * C. 同期レプリケーションの場合は、通信が遮断中は、マスタサーバでの更新系クエリは待機させられる
    * D. 通信復旧後のデータの再同期処理には、アーカイブWALが必須となる
    * E. 通信復旧後のデータの再同期処理に、アーカイブWALが利用される際は、マスタサーバのGUCパラメータrestore_commandが実行され、スタンバイサーバにアーカイブWALが転送される

1. Q4.04 PostgreSQLへの接続に関して、スーパーユーザでPostgreSQLに接続した際、以下のメッセージが出力された。

    ~~~txt
    FATAL: sorry, too many clients already
    ~~~

    このエラーメッセージが出力される原因として適切なものを1つ選びなさい。

    * A. 同時接続数がmax_connectionsに設定した値を超えた。
    * B. 同時接続数がsuperuser_reserved_connectionsに設定した値を超えた。
    * C. 同時接続数がdb_connectionsに設定した値を超えた。
    * D. 同時接続数が（max_connections - superuser_reserved_connections）の値を超えた。
    * E. 同時接続数が（db_connections - superuser_reserved_connections）を超過した。

1. Q4.03 あるユーザテーブルの参照時に、以下のエラーメッセージが出力された。

    ~~~txt
    ERROR: invalid page header in block 0 of relation base/16408/16421
    ~~~

    この時の対処として最も適切なものを1つ選びなさい。

    * A. データベース全体に対してVACUUMを実行する
    * B. 該当のテーブルファイルを削除し、PostgreSQLを再起動する
    * C. zero_damaged_pages を on に設定して再度テーブルを参照する
    * D. 該当のシステムテーブルに対してCLUSTERを実行する
    * E. PostgreSQLをシングルユーザ状態で起動し、該当のテーブルに定義されたインデックスに対してREINDEX INDEXを実行する

1. Q4.02 PostgreSQLのWALファイルが破損した場合の復旧方法として正しいものを2つ選びなさい。

    * A. pg_xact領域のファイルをすべて削除し、PostgreSQLを再起動する
    * B. PostgreSQLを起動したまま、環境変数PGDATAにデータベースクラスタ領域を指定してpg_resetwalを実行する
    * C. PostgreSQLを停止し、コマンドラインでデータベースクラスタ領域を指定してpg_resetwalを実行後にPostgreSQLを起動する
    * D. pg_controldataファイルを削除し、PostgreSQLを再起動する
    * E. pg_resetwalの-xオプションで次のトランザクションIDを指定する場合は、pg_xactディレクトリ内のファイル名で最も大きな数字に1を加えて、1048576で乗算した値を用いる

1. Q4.01 システムカタログのインデックスに関する説明として、適切ではないものを1つ選びなさい。

    * A. 共有システムカタログのインデックスは$PGDATA/global内に作成される。
    * B. システムカタログのインデックスが破損している場合、サーバプロセスが起動時に強制終了する可能性がある。
    * C. システムカタログの読み込み時にシステムインデックスを無視するにはGUCパラメータのignore_system_indexesを利用する。
    * D. インデックスの破損範囲が不明な場合に、データベースの全てのシステムインデックスを再構成するためのSQLコマンドはREINDEX SYSTEMである。
    * E. 共有システムカタログのいずれかのインデックスが破損した可能性がある場合は、必ずスタンドアロンサーバを使用して修復しなければいけない。

### 解答 ###

1. Q1.20 レプリケーション構成において、フェールオーバを実施する方法として正しいものは次のうちどれか。
    * 正解 AD
    * 補足: Postgresql 12 では recovery.conf が廃止され、選択肢Aの promote_trigger_file は postgresql.conf に統合される。

1. Q1.19 ログローテート時に同じ名前のログファイルが存在する場合に、追記、上書きを設定する設定は次のうちどれか。
    * 正解 D
    * 補足: log_min_error_statement エラーSQL文をログに出力するレベルの設定 log_rotation_age 指定した時間でログファイルをローテート log_directory ログファイルを格納するディレクトリ log_connections サーバへの接続情報出力

1. Q1.18 継続的アーカイブによるバックアップからの復旧を行う時に使用する設定ファイルについて、正しいものをひとつ選択してください。
    * 正解 D
    * 補足: 継続的アーカイブによるバックアップを行う場合、下記の手順を実施します。
      1. データベースに接続し、SELECT pg_start_backup('label'); を実行します。
      1. データベースクラスタのデータディレクトリをtarやcpio等を使用してバックアップします。
      1. データベースに接続し、SELECT pg_stop_backup(); を実行します。
    * 補足: 継続的アーカイブによるバックアップからの復旧を行う場合、下記の手順を実施します。
      1. PostgreSQLサーバを停止します。
      1. データベースクラスタのディレクトリを一時コピーします。
      1. データベースクラスタのディレクトリ以下のすべてのファイルとディレクトリを削除します。
      1. 上記バックアップ手順2で取得したバックアップからデータベースファイルをリストアします。
      1. リストアしたファイルのうち、pg_wal内のファイルをすべて削除します。 => postmaster.pid があれば削除
      1. クラスタデータディレクトリに復旧コマンドの設定ファイル recovery.conf を作成します。=>12 では 復旧コマンドをpostgresql.confに設定し、recovery.signalを作成
      1. PostgreSQLサーバを起動します。

1. Q1.16 バックアップに関して正しいものをすべて選択しなさい。
    * 正解 BCD
    * 補足: pg_basebackup はクラスター全体バックアップ(pg_start_backupとpg_stop_backupは内部で自動実行)、recovery_target_timeline

1. Q1.15 CLUSTERコマンドに関する説明として、適切ではないものを1つ選びなさい。
    * 正解 C

1. Q1.11 pg_basebackupコマンドに関する説明として、適切でないものを2つ選びなさい。
    * 正解 BE
    * 補足:max_wal_sendersはfetch方式最低1,stream方式最低2,Postgresql 12 のデフォルトは10

1. Q1.10 VACUUMに関して正しいものを全て選択しなさい。
    * 正解 BD
    * 補足: VACUUM [(options)] [table_and_column]
      * FULL 排他ロック必要、データをコピー、終了まで古いコピーは解放しない
      * FREEZE ?
      * VERBOSE 詳細を出力
      * ANALYZE 統計情報更新
      * DISABLE_PAGE_SKIPPING 通常は可視性マップもとにスキップ、このオプションでデフォルトを無効できる。
      * SKIP_LOCKED パテーションのロックがあると全パテーションスキップ
      * INDEX_CLEANUP
      * TRUNCATE
      * 列リストの場合、ANALYZE必須

1. Q1.09 ロングトランザクションによる弊害についての説明として、適切なものを２つ選びなさい。
    * 正解 BE

1. Q1.08 VACUUMに関して正しいものを全て選択しなさい。
    * 正解 CD

1. Q1.07 ANALYZEに関して正しいものを全て選択しなさい。
    * 正解 BD
    * 補足:ANALYZE [(options)] [table_and_column]
      * VERBOSE
      * SKIP_LOCKED
      * 読み取りロック
      * default_statistics_target デフォルトの統計対象設定、デフォルト値100。大きくするとANALYZE時間が増えるが、プランナの予測精度向上

1. Q1.06 2台のサーバ(プライマリサーバ、スタンバイサーバ)でストリーミングレプリケーションを行い、スタンバイサーバをホットスタンバイとして運用する。この環境を構築する際に各サーバで設定するパラメータとして誤っているものを1つ選びなさい。
    * 正解 D
    * 補足1: wal_level (default:replica,minimal,logical,9.6以前のarchiveとhot_standbyはreplicaにマップ)
    * 補足2: Postgresql 12では standby_mode,primary_conninfo,restore_command の設定はpostgresql.conf、recovery.conf はサポートしなくなっている。

1. Q1.05 データベースクラスタ配下の各サブディレクトリに保有されるデータの説明として、適切ではないものを1つ選びなさい。
    * 正解 B

1. Q1.04 以下のSQL文でインデックスを定義し、100万行を挿入する。[CREATE INDEX member_index ON member_table (team_id, birthday);]ここで、team_idのデータ型はINTEGER、birthdayのデータ型はDATE、いずれもNOT NULL制約が付いているものとする。インデックスのファイルサイズ見積りとして最も適切なものを1つ選びなさい。なお、1ブロックは8192バイトとし、FILLFACTORは90%とする。
    * 正解 D
    * 補足:B-treeインデックスの場合、1.リーフページに格納できる行数算出=>2.必要なリーフページ数算出=>3.ルートおよびインターナルページの必要数算出
      1. リーフページに格納できる行数算出
        * 1ブロックは8192バイト,FILLFACTOR90% => 8192×0.9≒7372バイト
        * リーフページの固定的に必要な領域ページヘッダ（24バイト）とスペシャルデータ（16バイト,Postgresql 12 のソースコードより20）と行ごとにアイテムポインタ（4バイト）とインデックスタプル（8バイト＋インデックスキーサイズ）
        * （7372－24－16）÷（4＋8＋8）≒366
      1. ひとつのリーフページに格納できる行数が366行ですので、必要なリーフページ数は、1000000÷366≒2732ページ
      1. リーフページが2732ページあり、ルートページから直接リーフページをポイント可能なページ数（366ページ）を超えているため、中間にインターナルページが必要な「多段インデックス」の構造
        * 必要なインターナルページ数は、2732÷366≒8ページ
          1. 1行のサイズは28+8+4+4+8=52バイト
          1. ファイルサイズは8192*3185=26091520バイト
      1. 1ページあたり行数 = (PageSize - PageHeaderData - 特別な空間)*FILLFACTOR / (ItemIdData + (行ヘッダ + 行データ) ) = (8192 - 24 - 20)*0.9 / (4 + 8 + 4 + 4) = 366 (切り捨て)
      1. リーフページ数 = 総行数 / 1ページあたり行数 = 1000000 / 366 = 2733 (切り上げ)
      1. 階層数(ルートを0層とする) = リーフページ数 に対して 1ページあたり行数 を底とする対数 = [math]::log(2733,366) = 2 (切り上げ)
      1. 総ページ数 = 各階層ページ数の和 = リーフページ数/1ページあたり行数 + リーフページ数/1ページあたり行数/1ページあたり行数 + 1 = 2733 + 8 + 1 = 2742 ※ページ数計算時切り上げ
      1. インデックスサイズ = 総ページ数 * PageSize = 21.5 MB
    * [B木](https://ja.wikipedia.org/wiki/B%E6%9C%A8)

1. Q1.02 PostgreSQL のプロセス構造について、適切なものをすべて選びなさい。
    * 正解 ACE

1. Q1.01 以下のSQL分でテーブルを定義し、50万行を挿入する。
    * 正解 C
    * 補足:PageHeaderData24バイト,ItemIdData 1アイテムにつき4バイト,空き領域,アイテム,特別な空間(通常のテーブルでは空)
      1. [68.6. データベースページのレイアウト](https://www.postgresql.jp/document/12/html/storage-page-layout.html)
      1. 1ページあたり行数 = (PageSize - PageHeaderData) / (ItemIdData + (行ヘッダ + 行データ) ) = ( 8192 - 24 ) / (4 + 23 + 8 + 4 + 4 + 8) = 160 (切り捨て)
      1. 総ページ数 = 総行数 / 1ページあたり行数 = 500000 / 291 = 3125 (切り上げ)
      1. テーブルサイズ = 総ページ数 * PageSize = 24.4 MB

1. Q1.22 crypt関数の意味として、正しいものは次のうちどれか。
    * 正解 C
    * 補足:
      * pgp_sym_encrypt 対称鍵を指定して、データを暗号化する
      * digest データのバイナリハッシュを計算する
      * hmac データのハッシュ化MACを計算する
      * gen_salt パスワードハッシュ時に使用するランダムなソルト文字列を新規に作成する。

1. Q1.21「mydb」テーブルのみに対して、更新/削除された行の切り詰めを行いたい。VACUUMコマンドの使い方として正しいものは次のうちどれか。
    * 正解 B

1. Q2.16 下記のEXPLAINの実行結果について、正しい記述を３つ選んでください。
    * 正解 BDE
    * 補足: <計画ノード>  (cost=<初期推定コスト>..<全体推定コスト> rows=<行数> width=<行の平均サイズ1>)

1. Q2.15 pg_stat_statementsの説明として正しいものは次のうちどれか。
    * 正解 C
    * 補足:
      * log_min_duration_statement:SQL文の実行に指定した時間以上かかった場合、それぞれのSQL文の実行に要した時間を記録する (0:全てログに出力,-1:出力しない。デフォルト:-1)
      * pg_locks:ロック待ちとなっているトランザクションや対象のテーブルを確認する
      * pg_stat_statements:実行された全てのSQL文の実行時の統計情報を記録する
      * pg_stat_database:データベースあたり1行の形式でデータベース全体の情報を表示する
      * pg_stat_all_tables:現在のデータベースの各テーブルごとに1行の形で、テーブルへのアクセス統計情報を表示する

1. Q2.14 pg_classに関する記述の中で、正しいものを2つ選びなさい。
    * 正解 DE

1. Q2.13 テーブルへのアクセスの統計情報を表示する方法として、正しいSQL文を選択してください。
    * 正解 D

1. Q2.12 pg_locksビューによって確認することが可能なロックの対象となるオブジェクトを全て選択しなさい。
    * 正解 BD
    * 補足: locktype -> relation、 extend、 page、 tuple、 transactionid、 virtualxid、 object、userlock、 advisory

1. Q2.11
    * 正解 D

1. Q2.10 EXPLAINコマンドで指定可能な出力形式のうち誤っているものを全て選択しなさい。
    * 正解 BC
    * 補足: TEXT、XML、JSON、YAML

1. Q2.09 EXPLAINコマンドを使用することで、問い合わせ文の実行計画を表示することができる。EXPLAINコマンドの対象となるSQLコマンドとして正しいものを全て選択しなさい。
    * 正解 AE
    * 補足: SELECT、INSERT、UPDATE、DELETE、VALUES、EXECUTE、DECLARE、CREATE TABLE AS、CREATE MATERIALIZED VIEW AS

1. Q2.08 標準統計情報ビューに関して正しいものを全て選択しなさい。
    * 正解 BD
    * 補足:
      * pg_stat_all_tables : 現在のデータベース内のテーブル（TOASTテーブルを含む）毎に１行の形式で、 特定のテーブルへのアクセスに関する統計情報を表示
      * pg_stat_activity : サーバプロセス毎に、 そのプロセスの現在の活動に関連する情報を表示する１行を持つ
      * pg_stat_database : クラスタ内のデータベース毎に1行と加えて共有オブジェクトのための1行が含まれ、 データベース全体の統計情報を示す
      * pg_statio_all_tables : は現在のデータベース内のテーブル（TOASTテーブルを含む）ごとに、 特定のテーブルのI/Oに関する統計情報を示す１行を保持

1. Q2.07 pg_stat_databaseに関する記述で誤っているものを全て選択しなさい。
    * 正解 ACDE
    * 補足:
      * blks_hit : バッファキャッシュに既にあることが分かっているために読み取りが不要だったディスクブロック数 (PostgreSQLのバッファキャッシュにおけるヒットのみ,オペレーティングシステムのファイルシステムキャッシュは含まれない)
      * blks_read : ディスクブロック数
      * tup_fetched  : 問い合わせで取り出された行数
      * track_countsパラメータがon (デフォルト)
      * pg_stat_(all|sys|user)_tables の idx_tup_fetch : インデックススキャンで読み取られた行数

1. Q2.06 ロングトランザクションを発見するのに有効なシステムカタログについての解説で、適切なものを選びなさい。
    * 正解 C

1. Q2.05 oid2nameの使い方として誤っているものを1つ選びなさい。
    * 正解 B
    * 補足: Postgresql 12 の場合、全てが正しい使い方である。ホスト指定オプション「-H」は12以後廃止予定、「-h」は使用できるようになっている。
      * oid2name [option...]
      * -f filenode
      * -i
      * -o oid
      * -q
      * -s
      * -S
      * -t tablename_pattern
      * -V
      * -x
      * -d database
      * -h host
      * -p port
      * -U username

1. Q2.03 テーブル/カラム統計情報に関する記述の中で、正しいものを2つ選びなさい。
    * 正解 AC
    * 補足:
      * pg_statistic : データベースの内容に関する統計データを保存
      * pg_stats : 一般のユーザが読み取り可能なpg_statisticに対するビュー

1. Q2.02 EXPLAINコマンドを用いて問い合わせを実行させ、結果が出力された。
    * 正解 AD
    * 補足:
      * Total runtime には、結果行を操作するための時間の他に、エクゼキュータの起動、停止時間も含まれています。
      * ネステッドループによる結合は、上に書かれているほうが外側、下に書かれているほうが内側のループになります。

1. Q2.01 pg_stat_database, pg_stat_all_tables などのアクセス統計情報(稼働統計情報)のビューに関する説明として、適切なものを2つ選びなさい。
    * 正解 BE
    * 補足:
      * アクセス統計情報(稼働統計情報)は、stats collector(統計情報コレクタ)プロセスによって、デフォルトでは500ミリ秒ごとに収集され、統計情報ビューなどによって参照できる
      * プランナが SQL の最適な実行計画を作成するときに使われる統計情報は具体的にはテーブルの行数、最大値・最小値、データの分布、などといった静的な情報が、ANALYZE コマンドを実行した時などに収集され、pg_class, pg_statistic などのシステムカタログに格納る。

1. Q3.15 PostgreSQLサーバをレプリケーション構成で稼働させる場合、synchronous_commit パラメータによってプライマリ機とスタンバイ機の同期レベルをチューニングすることが可能である。以下の選択肢は、プライマリ機でトランザクションのコミットを実行した際の、synchronous_commit パラメータの設定値毎の動作の説明をしたものである。誤っているものを1つ選びなさい。
    * 正解 C
    * 補足: on [1234578]、 remote_apply [12345678]、 remote_write [123478]、 local [1238]、 off [18]
      * 1.ユーザがプライマリ機でコミット
      * 2.プライマリ機がWALをプライマリ機のディスクに保存
      * 3.プライマリ機が、WALをスタンバイ機に送信し、スタンバイ機がWALを受取る
      * 4.スタンバイ機が、WALをオペレーションシステムのバッファキャッシュに保存する
      * 5.スタンバイ機が、バッファキャッシュに保存されたWALをディスクに保存する
      * 6.スタンバイ機が、WALの記述内容に従って、データベースを更新する
      * 7.プライマリ機が、スタンバイ機からの報告を受取る
      * 8.プライマリ機が、コミットを成功と判定する

1. Q3.14 buffers_backendに関する説明として適切なものをすべて選びなさい。
    * 正解 ACE
    * 補足: TODO:background process 調査
      * pg_stat_bgwriter : クラスタのグローバルデータに関する１つの行、バックグラウンドライタプロセスの活動状況に関する統計情報を１行のみで表示
      * buffers_backend : バックエンドにより直接書き出されたバッファ数
      * buffers_clean : バックグラウンドライタにより書き出されたバッファ数
      * buffers_checkpoint : チェックポイント期間に書き出されたバッファ数
      * buffers_alloc : 割当られたバッファ数

1. Q3.13 問い合わせ計画に関する以下の内容のうち、正しいものを全て選択しなさい。
    * 正解 AC
    * 補足:
      * enable_indexscan : 問い合わせプランナがインデックス走査計画型を選択することを有効もしくは無効にします。デフォルトはonです。
      * seq_page_cost : シーケンシャルな一連の取り出しの一部となる、 ディスクページ取り出しに関する、 プランナの推定コストを設定します。 デフォルトは1.0です。
      * random_page_cost : 非シーケンシャル的に取り出されるディスクページのコストに対するプランナの推測を設定します。 デフォルトは4です。
      * default_statistics_target : ALTER TABLE SET STATISTICSで列特定の目的セットの無いテーブル列に対し、 デフォルトの統計対象を設定します。 より大きい値はANALYZEに必要な時間を増加させますが、 プランナの予測の品質を向上させ
ます。 デフォルトは100です。

1. Q3.12 work_memをチューニングすることによって、性能が向上すると考えられる処理を全て選択しなさい。
    * 正解 AC
    * 補足:
      * work_mem : ソート（内部並べ替え）処理やハッシュ処理で使用するメモリ
      * maintenance_work_mem : 「VACUUM」や「CREATE INDEX」で使用するメモリ

1. Q3.11 インデックスの作成に関する説明として、適切なものを2つ選びなさい。
    * 正解 DE
    * 補足:
      * FILLFACTOR : インデックスの作成時デフォルト値は90、テーブル作成時デフォルト値は100
      * UNLOGGED : テーブル指定可、インデックス指定不可。テーブルとそのインデックスは更新時WALログが取られなくなる。
      * CONCURRENTLY : 対象テーブルに対する同時挿入、 更新、 削除を防止するようなロックを獲得せずにインデックスを作成します。 通常のインデックス作成処理では、 完了するまで対象テーブルへの書き込みはできません（読み取りは可能です）。 
      * CREATE FUNCTION
        * IMMUTABLE :  関数がデータベースに対する変更を行わないこと、 および、 その関数に同じ引数値を与えた場合に常に同じ結果を返すこと
        * STABLE : 関数がデータベースに対する変更を行わないこと、 および、 その関数に同じ引数値を与えた場合、 常に同じ結果を返すが、 SQL文が異なると結果が変わってしまう可能性があること。例:データベース検索や（現在の時間帯のような）パラメータ変数などに結果が依存する関
        * VOLATILE :  1つのテーブルスキャン内でも関数の値が変化する可能性があるため、 最適化できないこと。random()、 currval()、 timeofday()などは変動的な関数。 例えばsetval()などの副作用がある関数は、 その結果を完全に予測できるとしても、 呼び出しを最適化しないよう、 VOLATILE（変動的）に分類する必要があることに注意してください。

1. Q3.10　GUCパラメータのenable_seqscanをonからoffに変更する前後で、同一のクエリに対してEXPLAIN ANALYZE文で実行計画を取得する。実行計画の変化の説明として、最も適切ではないものを１つ選びなさい。この時、enable_seqscan以外の条件はすべて同一とする。
    * 正解 D

1. Q3.09 インデックスの再作成について正しい記述を2つ選びなさい。
    * 正解 CE
    * 補足:
      * REINDEX : 元となるテーブルの読み込みはロックしない、対象のインデックスについては排他ロックを取得する
      * CREATE INDEX CONCURRENTLY : プライマリキーの作成できない

1. Q3.08 PostgreSQLの処理全般が定期的に遅くなる現象が発生した。この場合のチューニングで効果が期待できる対策を2つ選びなさい。
    * 正解 BC
    * 補足:VACUUM処理による可能性がある

1. Q3.07 full_page_writesパラメータをOFFに設定した場合に関する説明として、適切でないものを2つ選びなさい。
    * 正解 CE
    * 補足:
      * full_page_writes : 有効の場合、チェックポイントの後にそのページが最初に変更された過程で、 ディスクページの全ての内容をWALに書き込みます。このパラメータを無効にすると、 通常の操作速度が上がりますが、 システム障害後に、 回復不能なデータ破損、 あるいは警告なしのデータ損壊をもたらすかもしれません。このパラメータを無効にしてもポイントインタイムリカバリ（PITR）用のWALアーカイブの使用に影響ありません。デフォルトはon。pg_start_backupを実行してからpg_stop_backupを実行するまでの間は、一時的にfull_page_writes=on相当の挙動をとる。

1. Q3.06 性能低下の原因に関して正しいものをすべて選択しなさい。
    * 正解 AC
    * 補足:
      * pgstattuple : タプルレベルの統計情報を入手するための各種関数を提供

1. Q3.03 データベースに大量データを投入する際の性能を向上させるために、一時的に講じることとして、適切とは言えないものを2つ選びなさい。
    * 正解 DE
    * 補足:
      * 自動コミットをオフ
      * インデックスや外部キー制約を削除
      * maintenance_work_memを増やす
      * checkpoint_segmentsを増やす

1. Q3.02 デッドロックに関する GUC パラメータ deadlock_timeout の説明として、正しいものをすべて選びなさい。
    * 正解 D
    * 補足:
      * deadlock_timeout : デッドロック状態があるかどうかを調べる前にロックを待つ時間をミリ秒で計算したもの。デフォルト1秒。デッドロックの検出はそれ自体が CPU 負荷の高い処理

1. Q3.01 GUCパラメータの説明として、誤っているものを1つ選びなさい。
    * 正解 C

1. Q4.08 共有メモリが不足して、サーバがダウンしてしまった時の対策として正しいものは次のうちどれか。
    * 正解 D
    * 補足: pg_resetwal トランザクションログファイル(WALファイル)が破損/消失した場合の復旧方法

1. Q4.07 操作ミスによってリレーションが消失することを想定した対策または復旧を行う際に、実施すべき内容として正しいものを全て選択しなさい。
    * 正解 CE

1. Q4.06 以下のサーバログに関する説明として、適切なものを1つ選びなさい。
    * 正解 E
    * 補足:
      * ユーザ要求によりクエリがキャンセルされた or プロセスに対してpg_cancel_backend関数が発行された

         ~~~txt
         ERROR: canceling statement due to user request
         STATEMENT: SELECT user_func();
         ~~~

      * プロセスに対してpg_terminate_backend関数が発行された

         ~~~txt
         ERROR: canceling statement due to user request
         STATEMENT: SELECT user_func();
         ~~~

      * OOM KillerによりSIGKILLが発生した

         ~~~txt
         LOG: server process (PID 21334) was terminated by signal 9: Killed
         DETAIL: Failed process was running: SELECT user_func();
         ~~~

1. Q4.05 2台のサーバでレプリケーションを行い、スタンバイサーバをホットスタンバイとして稼動させる。サーバ間の通信が一時的に遮断し、その後に復旧した場合の説明として、適切ではないものを2つ選びなさい。
    * 正解 E
    * 補足: TODO

1. Q4.04 PostgreSQLへの接続に関して、スーパーユーザでPostgreSQLに接続した際、以下のメッセージが出力された。
    * 正解 A
    * 補足:
      * max_connections - superuser_reserved_connections : 非スーパーユーザで接続可能な最大接続数,超える場合エラーメッセージ

         ~~~txt
         FATAL: remaining connection slots are reserved for non-replication superuser connections
         ~~~

1. Q4.03 あるユーザテーブルの参照時に、以下のエラーメッセージが出力された。
    * 正解 C
    * 補足: TODO
      * zero_damaged_pages

1. Q4.02 PostgreSQLのWALファイルが破損した場合の復旧方法として正しいものを2つ選びなさい。
    * 正解 CE
    * 補足: TODO

1. Q4.01 システムカタログのインデックスに関する説明として、適切ではないものを1つ選びなさい。
    * 正解 CE
    * 補足: TODO

## プロセス アーキテクチャ ##

[The Internals of PostgreSQL](http://www.interdb.jp/pg/index.html)

1. Postgres Server Process
   * a parent of all processes related to a database cluster
1. Backend Processes
   * Each backend process handles all queries and statements issued by a connected client
1. Background Processes
   * background writer
   * checkpointer
   * autovacuum launcher
   * WAL writer
   * statistics collector
   * logging collector (logger)
   * archiver

1. buffer
   * [buffer](https://github.com/postgres/postgres/blob/master/src/backend/storage/buffer/README)
     * buffer table
       * A hash table. Stores relation of buffer_tag and buffer_id. A buffer table can be logically divided into three parts: a hash function, hash bucket slots, and data entries.
     * buffer descriptor    #shared descriptor/state data for a single shared buffer.
       * [BufferDesc](https://github.com/postgres/postgres/blob/master/src/include/storage/buf_internals.h)
         * BufferTag tag    #ID of page contained in buffer,physical relation identifier
           * typedef struct buftag
             * RelFileNode rnode
               * typedef struct RelFileNode
                 * oid spcNode    #tablespace
                 * oid dbNode    #database
                 * oid relNode     #relation
                   * [Oid](https://github.com/postgres/postgres/blob/master/src/include/postgres_ext.h)
                   * typedef unsigned int Oid
             * ForkNumber forkNum    #the fork number of the relation to which its page belongs
               * [ForkNumber](https://github.com/postgres/postgres/blob/7559d8ebfa11d98728e816f6b655582ce41150f3/src/include/common/relpath.h)
               * typedef enum ForkNumber {InvalidForkNumber = -1,MAIN_FORKNUM = 0,FSM_FORKNUM,VISIBILITYMAP_FORKNUM,INIT_FORKNUM}
             * BlockNumber blockNum    #the block number of its page
               * [BlockNumber](https://github.com/postgres/postgres/blob/master/src/include/storage/block.h)
               * typedef uint32 BlockNumber
               * each data file (heap or index) is divided into postgres disk blocks(which may be thought of as the unit of i/o -- a postgres buffer contains exactly one disk block). the blocks are numbered sequentially, 0 to 0xFFFFFFFE.
         * int buf_id    #buffer's index number
         * pg_atomic_uint32 state    #state of the tag, containing flags, refcount and usagecount
           * [pg_atomic_uint32](postgres/src/include/port/atomics/generic-msvc.h)
           * typedef struct pg_atomic_uint32
             * volatile uint32 value    #コンパイラに変更しない指示。
             * Buffer state
               * 18 bits refcount    #pin count,accessing count of the page. when 0, the page is unpined,other wise is pined.  
               * 4 bits usage count    #accessed count of the page. used in the page replacement algorithm.
               * 10 bits of flags    #
                 * dirty bit    #the stored page is dirty
                 * valid bit    #the stored page can be read or written. If invalid, buffer manager holds no metadata or the page is replacing.
                 * io_in_progress bit    #the buffer manager is reading or writting the stored page. means a single progress holds the io_in_progress_lock of this descriptor.
         * int wait_backend_pid    #backend PID of pin-count waiter
         * int freeNext    #link in freelist chain
         * LWLock content_lock    #to lock access to buffer contents
           * [LWLock](https://github.com/postgres/postgres/blob/master/src/include/storage/lwlock.h)
           * typedef struct LWLock
             * uint16 tranche    #tranche ID
             * pg_atomic_uint32 state    #state of exclusive/nonexclusive lockers
             * proclist_head waiters    #list of waiting PGPROCs
               * [proclist_head](https://github.com/postgres/postgres/blob/master/src/include/storage/proclist_types.h)
               * int head    #pgprocno of the head PGPROC
               * int tail    #pgprocno of the tail PGPROC
     * buffer pool
       * A simple arrary. Index name is buffer_id. Slot stores data file page. Slot size 8 KB.

1. buffer manager
   * [buffer manager header](https://github.com/postgres/postgres/blob/master/src/include/storage/bufmgr.h)
   * [buffer manager](https://github.com/postgres/postgres/blob/master/src/backend/storage/buffer/bufmgr.c)
     * ReadBufferExtended
       * Params
         * Relation reln
         * ForkNumber forkNum
         * BlockNumber blockNum
         * ReadBufferMode mode
         * BufferAccessStrategy strategy
       * Returns Buffer
         * [Buffer](https://github.com/postgres/postgres/blob/master/src/include/storage/buf.h)
         * typedef int Buffer;

1. page definition
   * [PageHeaderData](https://github.com/postgres/postgres/blob/master/src/include/storage/bufpage.h)
   * typedef struct PageHeaderData
     * PageXLogRecPtr pd_lsn
       * uint32 xlogid
       * uint32 xrecoff
     * uint16 pd_checksum
     * uint16 pd_flags
     * LocationIndex pd_lower
     * LocationIndex pd_upper
     * LocationIndex pd_special
       * typedef uint16 LocationIndex
     * uint16 pd_pagesize_version
     * TransactionId pd_prune_xid
     * ItemIdData pd_linp[FLEXIBLE_ARRAY_MEMBER]
       * [ItemIdData](https://github.com/postgres/postgres/blob/master/src/include/storage/itemid.h)
       * unsigned lp_off:15,lp_flags:2,lp_len:15;

   * [PageInit](https://github.com/postgres/postgres/blob/master/src/backend/storage/page/bufpage.c)
   * [_bt_pageinit](https://github.com/postgres/postgres/blob/master/src/backend/access/nbtree/nbtpage.c)
   * [BTPageOpaqueData](https://github.com/postgres/postgres/blob/master/src/include/access/nbtree.h)
     * typedef struct BTPageOpaqueData
       * BlockNumber btpo_prev
       * BlockNumber btpo_next
         * [BlockNumber](https://github.com/postgres/postgres/blob/master/src/include/storage/block.h)
         * typedef uint32 BlockNumber;
       * union { uint32 level; TransactionId xact;} btpo
         * [TransactionId](https://github.com/postgres/postgres/blob/master/src/include/c.h)
         * typedef uint32 TransactionId;
       * uint16 btpo_flags
       * BTCycleId btpo_cycleid
         * [BTCycleId](https://github.com/postgres/postgres/blob/master/src/include/access/nbtree.h)
         * typedef uint16 BTCycleId
       * 4 + 4 + 4 + 4 + 2 + 2 = 20 Byte

1. Tuple Structure
   * [HeapTupleHeaderData](https://github.com/postgres/postgres/blob/master/src/include/access/htup_details.h)
   * struct HeapTupleHeaderData    #t_xmin 4B,t_xmax 4B,t_cid 4B,t_ctid 6B,t_infomask2 2B,t_infomask 2B,t_hoff 1B
     * union {HeapTupleFields t_heap; DatumTupleFields t_datum;} t_choice
       * typedef struct HeapTupleFields
         * TransactionId t_xmin    # insert transaction id
         * TransactionId t_xmax    # update or delete transaction id. If this tuple has not been updated or deleted, set to 0.
         * union {CommandId t_cid; TransactionId t_xvac;} t_field3    #t_cid holds the command means how many sql commands executed before this comamnd.
           * [CommandId](https://github.com/postgres/postgres/blob/master/src/include/c.h)
           * typedef uint32 CommandId
       * typedef struct DatumTupleFields
         * int32 datum_len_
         * int32 datum_typmod
         * Oid datum_typeid
     * ItemPointerData t_ctid     #current TID of this or newer tuple (or a speculative insertion token). When this tuple is updated, point to the new tuple, otherwise point to itself.
       * [ItemPointerData](https://github.com/postgres/postgres/blob/master/src/include/storage/itemptr.h)
       * typedef struct ItemPointerData
         * BlockIdData ip_blkid
           * [BlockIdData](https://github.com/postgres/postgres/blob/master/src/include/storage/block.h)
           * typedef struct BlockIdData
             * uint16 bi_hi
             * uint16 bi_lo
         * OffsetNumber ip_posid
           * [OffsetNumber](https://github.com/postgres/postgres/blob/master/src/include/storage/off.h)
           * typedef uint16 OffsetNumber
     * uint16 t_infomask2    #number of attributes + various flags
     * uint16 t_infomask    #various flag bits, see below
     * uint8 t_hoff    #sizeof header incl. bitmap, padding
     * bits8 t_bits[FLEXIBLE_ARRAY_MEMBER]    #bitmap of NULLs
       * [FLEXIBLE_ARRAY_MEMBER](https://github.com/postgres/postgres/blob/master/src/include/c.h)
       * define FLEXIBLE_ARRAY_MEMBER #empty
   * (4 + 4 + 4 + 4) + (2 + 2 + 2) + 2 + 2 + 1 = 23 Byte
   * [heap_fill_tuple](https://github.com/postgres/postgres/blob/master/src/backend/access/common/heaptuple.c)

1. PostgreSQL Limits
   * [Appendix K. PostgreSQL Limits](https://www.postgresql.org/docs/12/limits.html)

1. [Free Space Map](https://www.postgresql.jp/document/12/html/storage-vm.html)

1. Concurrency
   * transaction id
     * select txid_current(); #begin がなければトランザクション自動終了になる。
     * special txid
       * 0 Invalid
       * 1 Bootstrap
       * 2 Frozen
   * Commit Log (clog)
     * pg_xact
       * Max file size 256 KB
   * transaction status
     * IN_PROGRESS,COMMITTED,ABORTED,SUB_COMMITTED
   * Visibility Check Rules
     * Rule 1: If Status(t_xmin) = ABORTED ⇒ Invisible
     * Rule 2: If Status(t_xmin) = IN_PROGRESS ∧ t_xmin = current_txid ∧ t_xmax = INVAILD ⇒ Visible
     * Rule 3: If Status(t_xmin) = IN_PROGRESS ∧ t_xmin = current_txid ∧ t_xmax ≠ INVAILD ⇒ Invisible
     * Rule 4: If Status(t_xmin) = IN_PROGRESS ∧ t_xmin ≠ current_txid ⇒ Invisible
     * Rule 5: If Status(t_xmin) = COMMITTED ∧ Snapshot(t_xmin) = active ⇒ Invisible
     * Rule 6: If Status(t_xmin) = COMMITTED ∧ (t_xmax = INVALID ∨ Status(t_xmax) = ABORTED) ⇒ Visible
     * Rule 7: If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = IN_PROGRESS ∧ t_xmax = current_txid ⇒ Invisible
     * Rule 8: If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = IN_PROGRESS ∧ t_xmax ≠ current_txid ⇒ Visible
     * Rule 9: If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = COMMITTED ∧ Snapshot(t_xmax) = active ⇒ Visible
     * Rule10: If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = COMMITTED ∧ Snapshot(t_xmax) ≠ active ⇒ Invisible
   * Transaction snapshots
     * READ COMMITTED : the transaction obtains a snapshot whenever an SQL command is executed
     * REPEATABLE READ or SERIALIZABLE : the transaction only gets a snapshot when the first SQL command is executed
   * Visibility Check
     * T1: Start transaction (txid 200)
     * T2: Start transaction (txid 201)
     * T3: Execute SELECT commands of txid 200 and 201
     * T4: Execute UPDATE command of txid 200
     * T5: Execute SELECT commands of txid 200 and 201
     * T6: Commit txid 200
     * T7: Execute SELECT command of txid 201
   * [HTUP_DETAILS_H](https://github.com/postgres/postgres/blob/master/src/include/access/htup_details.h)
     * define HEAP_XMIN_COMMITTED 0x0100    #t_xmin committed
     * define HEAP_XMIN_INVALID 0x0200    #t_xmin invalid/aborted
     * define HEAP_XMIN_FROZEN (HEAP_XMIN_COMMITTED|HEAP_XMIN_INVALID)
     * define HEAP_XMAX_COMMITTED 0x0400    #t_xmax committed
     * define HEAP_XMAX_INVALID 0x0800    #t_xmax invalid/aborted
     * define HEAP_XMAX_IS_MULTI 0x1000    #t_xmax is a MultiXactId

1. VACUUM
   * Removing dead tuples
     * Remove dead tuples and defragment live tuples for each page.
     * Remove index tuples that point to dead tuples.
   * Freezing old txids
     * Freeze old txids of tuples if necessary.
     * Update frozen txid related system catalogs (pg_database and pg_class).
     * Remove unnecessary parts of the clog if possible.
   * Others
     * Update the FSM and VM of processed tables.
     * Update several statistics (pg_stat_all_tables, etc).
   * VACUUM Process
     * ( 1) Get each table from the specified tables.
     * ( 2) Acquire ShareUpdateExclusiveLock lock for the table. This lock allows reading from other transactions.
     * ( 3) Scan all pages to get all dead tuples, and freeze old tuples if necessary.
       * maintenance_work_mem
     * ( 4) Remove the index tuples that point to the respective dead tuples if exists.
       * vacuum_cleanup_index_scale_factor
     * ( 5) Do the following tasks, step ( 6) and ( 7), for each page of the table.
     * ( 6) Remove the dead tuples and Reallocate the live tuples in the page.
       * Note that unnecessary line pointers are not removed and they will be reused in future. Because, if line pointers are removed, all index tuples of the associated indexes must be updated.
     * ( 7) Update both the respective FSM and VM of the target table.
     * ( 8) Clean up the indexes by the index_vacuum_cleanup()@indexam.c function.
     * ( 9) Truncate the last page if the last one does not have any tuple.
     * (10) Update both the statistics and the system catalogs related to vacuum processing for the target table.
     * (11) Update both the statistics and the system catalogs related to vacuum processing.
     * (12) Remove both unnecessary files and pages of the clog if possible.
   * Visibility Map
     * shows page visibility and information about whether tuples are frozen or not in each page
     * Sample
       * ls $PGDATA/base/16384/18751*  ->  18751, 18751_fsm, 18751_vm
   * Freeze Processing
     * freezeLimit_txid = (OldestXmin − vacuum_freeze_min_age)
     * pg_database.datfrozenxid < (OldestXmin − vacuum_freeze_table_age)
     * After freezing each table, the pg_class.relfrozenxid of the target table is updated.
     * pg_database.datfrozenxid
     * pg_class.relfrozenxid
   * Autovacuum Daemon
     * autovacuum_worker
     * autovacuum_naptime
     * autovacuum_max_works
   * Full VACUUM
     * Process
       * When the VACUUM FULL command is executed for a table, PostgreSQL first acquires the AccessExclusiveLock lock for the table and creates a new table file whose size is 8 KB.
       * PostgreSQL copies only live tuples within the old table file to the new table.
       * After copying all live tuples, PostgreSQL removes the old file, rebuilds all associated table indexes, updates both the FSM and VM of this table, and updates associated statistics and system catalogs.
     * Note
       * Nobody can access(read/write) the table when Full VACUUM is processing.
       * At most twice the disk space of the table is used temporarily; therefore, it is necessary to check the remaining disk capacity when a huge table is processed.

## メモリ アーキテクチャ ##

1. Local Memory Area
   * work_mem
     * Executor uses this area for sorting tuples by ORDER BY and DISTINCT operations, and for joining tables by merge-join and hash-join operations.
   * maintenance_work_mem
     * Some kinds of maintenance operations (e.g., VACUUM, REINDEX) use this area.
   * temp_buffers
     * Executor uses this area for storing temporary tables.

1. Shared Memory Area
   * shared buffer pool
     * PostgreSQL loads pages within tables and indexes from a persistent storage to here, and operates them directly.
   * WAL buffer
     * To ensure that no data has been lost by server failures, PostgreSQL supports the WAL mechanism. WAL data (also referred to as XLOG records) are transaction log in PostgreSQL; and WAL buffer is a buffering area of the WAL data before writing to a persistent storage.
   * commit log
     * Commit Log(CLOG) keeps the states of all transactions (e.g., in_progress,committed,aborted) for Concurrency Control (CC) mechanism.

## WAL-PITR-Replication ##

1. Write Ahead Logging
   * [WAL](http://www.interdb.jp/pg/pgsql09.html#_9.1.)
   * Transaction Log and WAL Segment Files
     * WAL segment file name (hexadecimal 24bit): 000000010000000100000000 = 00000001 + 00000001 + 00000000 = (uint4)timelineId + (uint32)((LSN-1)/16M*256) + (uint32)(((LSN-1)/16M)%256)
     * next of 0000000100000001000000FF is 000000010000000200000000
   * WAL Segment
     * WAL File 16MB (XLogPage + XLogPage + XLogPage + ...)
       * XLogPage 8KB (XLogLongPageHeaderData + XLogRecord + XLogRecord+ XLogRecord + ...)
         * [XLogLongPageHeaderData](https://github.com/postgres/postgres/blob/master/src/include/access/xlog_internal.h)
            * uint16 xlp_magic    #magic value for correctness checks
            * uint16 xlp_info    #flag bits
            * TimeLineID xlp_tli    #TimeLineID of first record on page
              * [TimeLineID](https://github.com/postgres/postgres/blob/master/src/include/access/xlogdefs.h)
              * typedef uint32 TimeLineID;
            * XLogRecPtr xlp_pageaddr    #XLOG address of this page
              * [XLogRecPtr](https://github.com/postgres/postgres/blob/master/src/include/access/xlogdefs.h)
              * typedef uint64 XLogRecPtr;
            * uint32 xlp_rem_len    #total len of remaining data for record
         * [XLOG record format](http://www.interdb.jp/pg/pgsql09.html#_9.1.)
         * [XLOG record format](https://github.com/postgres/postgres/blob/master/src/include/access/xlogrecord.h)
           * Fixed-size header (XLogRecord struct)
             * [XLogRecord](https://github.com/postgres/postgres/blob/master/src/include/access/xlogrecord.h)
               * uint32 xl_tot_len    #total len of entire record
               * TransactionId xl_xid    #xact id
               * XLogRecPtr xl_prev    #ptr to previous record in log
               * uint8 xl_info    #flag bits
                 * [Resource manager](https://github.com/postgres/postgres/blob/master/src/backend/access/transam/rmgr.c)
                 * [xact_redo_commit](https://github.com/postgres/postgres/blob/master/src/backend/access/transam/xact.c)
                 * [heap_xlog_insert,heap_xlog_update](https://github.com/postgres/postgres/blob/master/src/backend/access/heap/heapam.c)
               * RmgrId xl_rmid    #resource manager for this record
                 * [RmgrId](https://github.com/postgres/postgres/blob/master/src/include/access/rmgr.h)
                 * typedef uint8 RmgrId
               * #2 bytes of padding here, initialize to zero
               * pg_crc32c xl_crc    #CRC for this record
                 * [pg_crc32c](https://github.com/postgres/postgres/blob/master/src/include/port/pg_crc32c.h)
                 * typedef uint32 pg_crc32c;
           * XLogRecordBlockHeader struct
             * [XLogRecordBlockHeader](https://github.com/postgres/postgres/blob/master/src/include/access/xlogrecord.h)
             * typedef struct XLogRecordBlockHeader
               * uint8 id
               * uint8 fork_flags
               * uint16 data_length
           * XLogRecordBlockHeader struct
           * ...
           * XLogRecordDataHeader[Short|Long] struct
             * typedef struct XLogRecordDataHeaderShort
               * uint8 id     #XLR_BLOCK_ID_DATA_SHORT
               * uint8 data_length
             * typedef struct XLogRecordDataHeaderLong
               * uint8 id     #XLR_BLOCK_ID_DATA_LONG
               * #followed by uint32 data_length, unaligned
           * block data
           * block data
           * ...
           * main data
             * [xl_heap_insert](https://github.com/postgres/postgres/blob/master/src/include/access/heapam_xlog.h)
             * [xl_heap_update](https://github.com/postgres/postgres/blob/master/src/include/access/heapam_xlog.h)
             * [xl_heap_lock](https://github.com/postgres/postgres/blob/master/src/include/access/heapam_xlog.h)
             * [CheckPoint](https://github.com/postgres/postgres/blob/master/src/include/catalog/pg_control.h)
         * [PG_RMGR](https://github.com/postgres/postgres/blob/master/src/include/access/rmgrlist.h)
   * [exec_simple_query](https://github.com/postgres/postgres/blob/master/src/backend/tcop/postgres.c)
   * [pg_controldata](https://www.postgresql.jp/document/12/html/app-pgcontroldata.html)

1. Base buckup and Point-In-Time Recovery

   * Base Backup
     * [pg_start_backup](https://github.com/postgres/postgres/blob/master/src/backend/access/transam/xlogfuncs.c)
       * 1.Force into the full-page wirte mode.
       * 2.Switch to the current WAL segment file (version 8.4 or later).
       * 3.Do checkpoint.
       * 4.Create a backup_label file
         * backup lable file
         * CHECKPOINT LOCATION
         * START WAL LOCATION
         * BACKUP METHOD
         * BACKUP FROM
         * START TIME
         * LABEL
         * START TIMELINE
     * [pg_end_backup](https://github.com/postgres/postgres/blob/master/src/backend/access/transam/xlogfuncs.c)
       * 1.Reset to non-full-page writes mode if it has been forcibly changed by the pg_start_backup.
       * 2.Write a XLOG record of backup end.
       * 3.Switch the WAL segment file.
       * 4.Create a backup history file
         * backup history file
         * {WAL segment}.{offset value at the time the base backup was started}.backup
       * 5.Delete the backup_label file
     * [pg_basebackup](https://www.postgresql.jp/document/12/html/app-pgbasebackup.html)
   * PITR
     * 1.reads the value of ‘CHECKPOINT LOCATION’ from the backup_label file
     * 2.reads values of parameters from the recovery.conf (version 11 or earlier) or the postgresql.conf (version 12 or later)
     * 3.starts replaying WAL data from the REDO point ‘CHECKPOINT LOCATION’ to recovery_target_time or the end.
     * 4.create a timeline history file, such as ‘00000002.history’, in pg_wal
   * timeline
     * timelineId
       * uint4,start at 1
       * increased by 1 when recovery
     * timeline history file
       * "8-digit new timelineId".history
       * timelineId,LSN,reason

1. Streaming Replication
   * [Streaming Replication sequence](http://www.interdb.jp/pg/pgsql11.html#_11.1.)
   * [pg_stat_replication](https://www.postgresql.jp/document/12/html/monitoring-stats.html#MONITORING-STATS-VIEWS)

1. データタイプ定義
   * [c.h](https://github.com/postgres/postgres/blob/master/src/include/c.h)
     * struct varlena {char vl_len_[4];char vl_dat[FLEXIBLE_ARRAY_MEMBER];};
       * typedef struct varlena bytea;
       * typedef struct varlena text;
       * typedef struct varlena BpChar;    #char(n)
       * typedef struct varlena VarChar;    #varchar(n)
   * [postgres.h](https://github.com/postgres/postgres/blob/master/src/include/postgres.h)
     * typedef uintptr_t Datum;
   * [varchar.c](https://github.com/postgres/postgres/blob/master/src/backend/utils/adt/varchar.c)
     * "The difference between these types and 'text' is that we truncate and possibly blank-pad the string at insertion time." these types=CHAR,VARCHAR

## メモ ##

1. UNLOGGED

CREATE TABLE の時にログ取らないテーブル作成、速いがクラッシュ時に安全ではない。スタンバイサーバに送信しない。このテーブルのインデックスもWALがない。

1. immutable

インデックスの定義で使用される全ての関数と演算子は、「不変」（immutable）でなければなりません。

1. default_statistics_target

列特定の目的セットの無いテーブル列に対し、デフォルトの統計対象を設定。
より大きい値はANALYZEに必要な時間を増加させますが、プランナの予測の品質を向上させます。デフォルトは100です。

1. work_mem

一時ディスクファイルに書き込むようになる前に、クエリ操作（たとえば並べ替えとハッシュテーブル操作）が使用する最大のメモリ容量

1. maintenance_work_mem

VACUUM、CREATE INDEX、およびALTER TABLE ADD FOREIGN KEYの様な保守操作で使用されるメモリの最大容量

1. VACUUM

1. AUTOVACUUM

1. レプリケーションフェールオーバー、通信遮断

1. CLUSTER

CLUSTERは、index_nameで指定されたインデックスに基づき、table_nameで指定されたテーブルをクラスタ化するように、PostgreSQLに指示

1. [pg_basebackup](https://www.postgresql.jp/document/12/html/app-pgbasebackup.html)

1. recovery_target_timeline

1. [pg_stat_statements](https://www.postgresql.jp/document/12/html/pgstatstatements.html)

1. [pg_stat_database](https://www.postgresql.jp/document/12/html/monitoring-stats.html#MONITORING-STATS-VIEWS)

1. pg_stat_all_tables

1. pg_stat_bgwriter

1. [pg_locks](https://www.postgresql.jp/document/12/html/view-pg-locks.html)

1. EXPLAIN

1. [enable_seqscan](https://www.postgresql.jp/document/12/html/runtime-config-query.html)

## 2回目 ##

1. 間違った質問
   * 1.16 BCD
   * 1.11 BE
   * 1.07 BC
   * 1.06 C
   * 2.15 C
   * 2.13 D
   * 2.12 BC
   * 2.11 D
   * 2.09 BC
   * 2.08 ABD
   * 2.07 AD
   * 2.02 AD
   * 2.01 AE
   * 3.14 AC
   * 3.13 ACE
   * 3.12 AC
   * 3.11 DE
   * 3.10 D
   * 3.09 CE
   * 3.07 CD
   * 3.03 CD
   * 4.07 C

## 3回目 ##

1. 間違った質問
   * 1.07
   * 1.06
   * 2.09
   * 2.08
   * 2.07
   * 2.01
   * 3.14
   * 3.13
   * 3.07
   * 3.03
   * 4.07