# OSSDB Gold メモ #

参照:
[出題範囲(公式)](https://oss-db.jp/outline/gold)
[サンプルDB](https://www.postgresqltutorial.com/postgresql-sample-database/)

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
      * [18.9. SSLによる安全なTCP/IP接続]
   * pg_stat_ssl
      * [27.2.2. 統計情報の表示]  接続（通常およびレプリケーション）あたり1行の形式で、接続に使
われるSSLの情報を表示します。
   * pgcrypto
      * [F.25. pgcrypto]
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
   * ANALYZE
   * CLUSTER
   * REINDEX
   * VACUUM
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
      wal_level = hot_standby
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

