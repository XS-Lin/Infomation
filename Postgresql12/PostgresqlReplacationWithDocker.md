# DockerでReplacation構成 #

## Dockerインストール ##

## 概要 ##

   docker で Postgresql 12 レプリケーション の マスター 1 対 スタンバイ 3 を構築する。

## 詳細 ##

   ~~~bash
   docker pull postgres:latest
   #起動
   docker run -d -v /dbdata --name postgres-test1 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5432:5432 postgres
   docker run -d --volumes-from postgres-test1 --name postgres-test2 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5433:5432 postgres
   docker run -d --volumes-from postgres-test1 --name postgres-test3 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5434:5432 postgres
   docker run -d --volumes-from postgres-test1 --name postgres-test4 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5435:5432 postgres
   #停止(コンテナ作成以後用)
   docker container stop postgres-test1
   docker container stop postgres-test2
   docker container stop postgres-test3
   docker container stop postgres-test4
   #開始(コンテナ作成以後用)
   docker container start postgres-test1
   docker container start postgres-test2
   docker container start postgres-test3
   docker container start postgres-test4

   # ネットワークはデフォルト使用(docker network inspect bridge)
   docker rm -v
   docker ps -a
   ~~~

   ~~~powershell
   # ファイル編集方法の例(postgresqlのイメージにviなどツールがないため)
   docker cp postgres-test1:/var/lib/postgresql/data/pg_hba.conf pg_hba.conf
   # pg_hba.conf 編集
   # host replication repl_user 0.0.0.0/0 md5
   docker cp pg_hba.conf postgres-test1:/var/lib/postgresql/data/pg_hba.conf

   docker cp postgres-test1:/var/lib/postgresql/data/postgresql.conf postgresql.conf
   # postgresql.conf 編集
   # listen_addresses = '*'
   # wal_level = replica
   # synchronous_commit = on
   # max_wal_senders = 10 # 参考ファイルが4だが起動できない
   # synchronous_standby_names = 'FIRST 2 (testdb2,testdb3,testdb4)'
   # archive_command = 'cp %p /dbdata/archive/%f'
   # wal_log_hints = on
   docker cp postgresql.conf postgres-test1:/var/lib/postgresql/data/postgresql.conf
   ~~~

   ~~~bash
   # docker attach postgres-test1 (コンテナ内部のシェルが動作中のみ,exitでコンテナ終了、Ctrl + P + Qの場合は終了しない)
   docker exec -it postgres-test1 bash #コンテナのbash起動
   hostname -i # IP確認
   su - postgres
   cd /dbdata
   mkdir backup
   mkdir archive
   # /usr/lib/postgresql/12/bin/pg_ctl restart -D /var/lib/postgresql/data 実行するとコンテナが終了になるため、コンテナ再起動で対応
   psql postgres
   ~~~

   ~~~sql
   --postgres-test1
   CREATE ROLE repl_user LOGIN REPLICATION PASSWORD 'password';
   CREATE DATABASE replication;
   --スタンバイサーバに実行すると、以下のエラーが発生
   --ERROR:  cannot execute INSERT in a read-only transaction
   --select pg_is_in_recovery(); -- t の場合、上記実行は失敗となる。
   --standby.signalを削除し、再起動。(誤ってスタンバイにしたため)
   ~~~

   ~~~powershell
   # ファイル編集方法の例(postgresqlのイメージにviなどツールがないため)
   docker cp postgres-test2:/var/lib/postgresql/data/postgresql.conf postgresql_2.conf

   #postgresql_2.conf変更
   #hot_standby = on
   #restore_command = 'cp /dbdata/archive/%f %p'
   #archive_cleanup_command = 'pg_archivecleanup /dbdata/archive %r'
   #primary_conninfo = 'host=172.17.0.2 port=5432 user=repl_user password=password application_name=testdb2'
   docker cp postgresql_2.conf postgres-test2:/var/lib/postgresql/data/postgresql.conf
   #postgresql_3.conf変更
   #hot_standby = on
   #restore_command = 'cp /dbdata/archive/%f %p'
   #archive_cleanup_command = 'pg_archivecleanup /dbdata/archive %r'
   #primary_conninfo = 'host=172.17.0.2 port=5432 user=repl_user password=password application_name=testdb3'
   docker cp postgresql_3.conf postgres-test3:/var/lib/postgresql/data/postgresql.conf
   #postgresql_4.conf変更
   #hot_standby = on
   #restore_command = 'cp /dbdata/archive/%f %p'
   #archive_cleanup_command = 'pg_archivecleanup /dbdata/archive %r'
   #primary_conninfo = 'host=172.17.0.2 port=5432 user=repl_user password=password application_name=testdb4'
   docker cp postgresql_4.conf postgres-test4:/var/lib/postgresql/data/postgresql.conf

   # 注意:参考記事はrecovery.confがありますが、Postgresql 12はサポートしない。作成した場合、起動失敗になる。
   ~~~

   ~~~sql
   --replaction process
   --postgres-test1
   select datname,usename,application_name,client_addr,wait_event from pg_stat_activity;
   select pid,usename,application_name,client_addr,client_port,state,sync_state,reply_time from pg_stat_replication;
   --postgres-test2,postgres-test3,postgres-test4
   select datname,usename,application_name,client_addr,wait_event from pg_stat_activity;
   select pid,status,sender_host,sender_port from pg_stat_wal_receiver;
   select * from pg_stat_wal_receiver;
   ~~~

   ~~~sql
   --postgres-test1
   --psql -d replication -U repl_user
   CREATE TABLE test_tb(id int,msg text);
   INSERT INTO test_tb(id,msg) VALUES (1,'before replaction!');
   INSERT INTO test_tb(id,msg) VALUES (2,'test replaction!');
   INSERT INTO test_tb(id,msg) VALUES (3,'test replaction!');
   INSERT INTO test_tb(id,msg) VALUES (4,'test replaction!');
   SELECT * FROM test_tb;
   ~~~

   ~~~bash
   # 以下はバックアップからDB作成用
   pg_basebackup -h 172.17.0.2 -U repl_user -p 5432 -D /dbdata/backup -R -P -Xs
   ~~~

   ~~~bash
   docker exec -d postgres-test2 touch /var/lib/postgresql/data/standby.signal
   docker exec -d postgres-test3 touch /var/lib/postgresql/data/standby.signal
   docker exec -d postgres-test4 touch /var/lib/postgresql/data/standby.signal
   docker container restart postgres-test2
   docker container restart postgres-test3
   docker container restart postgres-test4
   ~~~

## 参考 ##

[ストリーミングレプリケーション ～ 仕組み、構成のポイント ～](https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/article-index/streaming-replication1/)
[PostgreSQLの冗長構成の構築(同期ストリーミングレプリケーション)](https://qiita.com/kouyaf77@github/items/e0372783839cec6729ea)
[Streaming Replication Setup in PG12](https://www.highgo.ca/2019/11/07/streaming-replication-setup-in-pg12-how-to-do-it-right/)