# Dockerでホットスタンバイでマスタとスタンバイの切り替え #

## 構成(WALは手動コピー) ##

1. コンテナ作成

   ~~~bash
   docker run -d --name postgres-test1 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5432:5432 postgres
   docker run -d --name postgres-test2 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5433:5432 postgres
   docker network inspect bridge
   ~~~

1. DDL投入(postgres-test1,postgres-test2)

   ~~~bash
   su - postgres
   psql postgres
   ~~~

   ~~~sql
   CREATE ROLE repl_user LOGIN REPLICATION PASSWORD 'password';
   CREATE DATABASE replication_test;
   \q
   ~~~

   ~~~bash
   psql -U repl_user replication_test;
   ~~~

   ~~~sql
   CREATE TABLE test_tb(id int,msg text);
   \q
   ~~~

1.　postgres.conf編集

   ~~~bash
   docker cp postgres-test1:/var/lib/postgresql/data/postgresql.conf postgresql1.conf
   docker cp postgres-test2:/var/lib/postgresql/data/postgresql.conf postgresql2.conf
   ~~~

* postgres-test1
  * wal_level = replica (default)
  * synchronous_commit = on (default)
  * listen_addresses = '*'
  * synchronous_standby_names = ''(default)
  * hot_standby = on (default)
  * primary_conninfo = 'host=172.17.0.3 port=5432 user=repl_user password=password application_name=testdb1'
* postgres-test2
  * wal_level = replica (default)
  * synchronous_commit = on (default)
  * listen_addresses = '*'
  * synchronous_standby_names = ''(default)
  * hot_standby = on (default)
  * primary_conninfo = 'host=172.17.0.2 port=5432 user=repl_user password=password application_name=testdb2'

   ~~~bash
   docker cp postgresql1.conf postgres-test1:/var/lib/postgresql/data/postgresql.conf
   docker cp postgresql2.conf postgres-test2:/var/lib/postgresql/data/postgresql.conf
   ~~~

1.　pg_hba.conf編集

   ~~~bash
   docker cp postgres-test1:/var/lib/postgresql/data/pg_hba.conf pg_hba.conf
   # Add row: host    replication     repl_user       0.0.0.0/0               md5
   docker cp pg_hba.conf postgres-test1:/var/lib/postgresql/data/pg_hba.conf
   docker cp pg_hba.conf postgres-test2:/var/lib/postgresql/data/pg_hba.conf
   ~~~

1. マスタに投入(postgres-test1)

   ~~~sql
   INSERT INTO test_tb(id,msg) VALUES (1,'before replaction!');
   ~~~

1. スタンバイサーバ起動(postgres-test2)

   ~~~bash
   docker exec -d postgres-test2 touch /var/lib/postgresql/data/standby.signal
   docker container restart postgres-test2
   ~~~

1. マスタに投入

   ~~~sql
   INSERT INTO test_tb(id,msg) VALUES (2,'test replaction!');
   ~~~

1. スタンバイサーバをマスタに変更

   ~~~bash
   docker exec -d postgres-test2 rm /var/lib/postgresql/data/standby.signal
   docker container restart postgres-test2
   ~~~

1. マスタに投入

   ~~~sql
   INSERT INTO test_tb(id,msg) VALUES (3,'test replaction!');
   ~~~

## トラブルシューティング ##

1. 公式確認
docker run --name postgresql-master -e POSTGRESQL_REPLICATION_MODE=master -e POSTGRESQL_USERNAME=my_user -e POSTGRESQL_PASSWORD=password123 -e POSTGRESQL_DATABASE=my_database -e POSTGRESQL_REPLICATION_USER=my_repl_user -e POSTGRESQL_REPLICATION_PASSWORD=my_repl_password bitnami/postgresql:latest

docker run --name postgresql-slave --link postgresql-master:master -e POSTGRESQL_REPLICATION_MODE=slave -e POSTGRESQL_USERNAME=my_user -e POSTGRESQL_PASSWORD=password123 -e POSTGRESQL_MASTER_HOST=master -e POSTGRESQL_MASTER_PORT_NUMBER=5432 -e POSTGRESQL_REPLICATION_USER=my_repl_user -e POSTGRESQL_REPLICATION_PASSWORD=my_repl_password bitnami/postgresql:latest

docker run --name postgres-test2 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 5433:5432 postgres

1. 構築確認

/usr/lib/postgresql/13/bin/pg_ctl reload -D /var/lib/postgresql/data
/usr/lib/postgresql/13/bin/pg_ctl restart -D /var/lib/postgresql/data

docker logs postgres-test2

~~~txt
2020-10-14 03:29:14.243 UTC [94] FATAL:  database system identifier differs between the primary and standby
2020-10-14 03:29:14.243 UTC [94] DETAIL:  The primary's identifier is 6883260886006087717, the standby's identifier is 6883302747092308005.
~~~

docker cp postgres-test1:/var/lib/postgresql/data dbdata
docker exec postgres-test2 rm -rf /var/lib/postgresql/data #実行中しかできない
docker cp dbdata/data postgres-test2:/var/lib/postgresql/data1
chown -R postgres /var/lib/postgresql/data1
chmod -R 700 /var/lib/postgresql/data1/data
/usr/lib/postgresql/13/bin/pg_ctl start -D /var/lib/postgresql/data1/data
docker cp postgresql2.conf postgres-test2:/var/lib/postgresql/data1/data/postgresql.conf
docker exec -d postgres-test2 touch /var/lib/postgresql/data1/data/standby.signal
/usr/lib/postgresql/13/bin/pg_ctl reload -D /var/lib/postgresql/data1/data

## pgpool ##

~~~powershell
docker network create my-network --driver bridge

$ docker run --detach --name pg-0 `
  --network my-network `
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 `
  --env REPMGR_NODE_NAME=pg-0 `
  --env REPMGR_NODE_NETWORK_NAME=pg-0 `
  --env REPMGR_PRIMARY_HOST=pg-0 `
  --env REPMGR_PASSWORD=repmgrpass `
  --env POSTGRESQL_POSTGRES_PASSWORD=adminpassword `
  --env POSTGRESQL_USERNAME=customuser `
  --env POSTGRESQL_PASSWORD=custompassword `
  --env POSTGRESQL_DATABASE=customdatabase `
  bitnami/postgresql-repmgr:latest

$ docker run --detach --name pg-1 `
  --network my-network `
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 `
  --env REPMGR_NODE_NAME=pg-1 `
  --env REPMGR_NODE_NETWORK_NAME=pg-1 `
  --env REPMGR_PRIMARY_HOST=pg-0 `
  --env REPMGR_PASSWORD=repmgrpass `
  --env REPMGR_PASSWORD=repmgrpass `
  --env POSTGRESQL_POSTGRES_PASSWORD=adminpassword `
  --env POSTGRESQL_USERNAME=customuser `
  --env POSTGRESQL_PASSWORD=custompassword `
  --env POSTGRESQL_DATABASE=customdatabase `
  bitnami/postgresql-repmgr:latest

$ docker run --detach --rm --name pgpool `
  --network my-network `
  --env PGPOOL_BACKEND_NODES=0:pg-0:5432,1:pg-1:5432 `
  --env PGPOOL_SR_CHECK_USER=postgres `
  --env PGPOOL_SR_CHECK_PASSWORD=adminpassword `
  --env PGPOOL_ENABLE_LDAP=no `
  --env PGPOOL_USERNAME=customuser `
  --env PGPOOL_PASSWORD=custompassword `
  bitnami/pgpool:latest

docker run --detach --rm --name pgpool -p 9999:9999 `
  --network my-network `
  --env PGPOOL_ADMIN_USERNAME=pgpooluser `
  --env PGPOOL_ADMIN_PASSWORD=pgpooluserpass `
  --env PGPOOL_BACKEND_NODES=0:pg-0:5432,1:pg-1:5432 `
  --env PGPOOL_SR_CHECK_USER=postgres `
  --env PGPOOL_SR_CHECK_PASSWORD=adminpassword `
  --env PGPOOL_ENABLE_LDAP=no `
  --env PGPOOL_POSTGRES_USERNAME=customuser `
  --env PGPOOL_POSTGRES_PASSWORD=custompassword `
  bitnami/pgpool:latest
~~~

~~~powershell
docker network inspect my-network
~~~