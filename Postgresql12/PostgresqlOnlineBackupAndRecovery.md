# Postgresql 12 バックアップとリカバリー #

[PostgreSQL 12.3文書 第25章 バックアップとリストア](https://www.postgresql.jp/document/12/html/backup.html)
[PostgreSQL 12.3文書 25.3. 継続的アーカイブとポイントインタイムリカバリ（PITR）](https://www.postgresql.jp/document/12/html/continuous-archiving.html#BACKUP-ARCHIVING-WAL)

## 継続的アーカイブによるバックアップ手順 ##

1. データベースに接続し、SELECT pg_start_backup('bk1'); を実行します。
1. データベースクラスタのデータディレクトリをtarやcpio等を使用してバックアップします。
1. データベースに接続し、SELECT pg_stop_backup(); を実行します。

## 継続的アーカイブによるバックアップからの復旧手順 ##

1. PostgreSQLサーバを停止します。
1. データベースクラスタのディレクトリを一時コピーします。
1. データベースクラスタのディレクトリ以下のすべてのファイルとディレクトリを削除します。
1. 上記バックアップ手順2で取得したバックアップからデータベースファイルをリストアします。
1. リストアしたファイルのうち、pg_wal内のファイルをすべて削除します。(postmaster.pidも削除)
1. クラスタデータディレクトリに復旧コマンドをpostgresql.confに設定し、recovery.signalを作成します。
1. PostgreSQLサーバを起動します。

## シミュレーション ##

1. コンテナ「postgres1」でtestdb作成し、コンテナ「postgres2」で復元

1. Docker Postgresql 12

    ~~~bash
    docker run -d --name postgres1 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5440:5432 postgres
    docker exec -it postgres1 bash
    su - postgres
    mkdir archive
    psql
    CREATE ROLE test_user LOGIN PASSWORD 'password';
    CREATE DATABASE testdb WITH OWNER=test_user TEMPLATE=template0 ENCODING=UTF8 LC_COLLATE='C' LC_CTYPE='C';
    \q
    psql -U test_user -d testdb
    CREATE TABLE test_tb(id int,msg text);
    INSERT INTO test_tb(id,msg) VALUES (1,'insert');
    \q
    psql
    SELECT pg_start_backup('bk1');
    # 外部で docker cp 実行
    SELECT pg_stop_backup();
    \q
    exit
    exit
    ~~~

    ~~~powershell
    docker cp postgres1:/var/lib/postgresql/data/postgresql.conf postgresql_x.conf
    # archive_mode=on
    # archive_command='test ! -f /var/lib/postgresql/archive/%f && cp %p /var/lib/postgresql/archive/%f'
    # restore_command = 'cp /var/lib/postgresql/archive/%f %p'
    docker cp postgresql_x.conf postgres1:/var/lib/postgresql/data/postgresql.conf

    docker cp postgres1:/var/lib/postgresql/data dbdata
    docker cp postgres1:/var/lib/postgresql/archive dbarchive
    # /var/lib/postgresql/data/pg_wal 以下を別フォルダ移動
    # /var/lib/postgresql/data/postmaster.pid 削除
    # /var/lib/postgresql/data/recovery.signal 空ファイル作成

    docker run -d --name postgres2 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5441:5432 -p 5442:5433 postgres
    docker cp dbdata postgres2:/var/lib/postgresql/data1
    docker cp dbarchive postgres2:/var/lib/postgresql/archive
    docker exec -it postgres2 bash
    chown -R postgres:postgres /var/lib/postgresql/data1
    chown -R postgres:postgres /var/lib/postgresql/archive
    chmod 750 /var/lib/postgresql/data1
    su - postgres
    export PATH=/usr/lib/postgresql/12/bin:$PATH
    pg_ctl start -D /var/lib/postgresql/data1
    psql -p 5433
    psql -p 5433 -U test_user -d testdb
    SELECT * FROM test_tb;
    # 上記作成したtestdbのtest_tbのデータが表示されます。
    ~~~
