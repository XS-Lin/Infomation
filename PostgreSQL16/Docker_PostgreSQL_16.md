# Docker PostgreSQL 16 #

## 設定 ##

[postgresql 16 document](https://www.postgresql.org/docs/current/index.html)

**以下の設定でhostから接続の時に、localhostではなく、127.0.0.1を利用すること。**

~~~powershell
# Docker Desktop 4.24.1 (123237)
docker -v # Docker version 24.0.6, build ed223bc
docker pull postgres:16.0-bookworm

# Optional: add -d for background exec
docker run -v E:\tool\postgresql_dir\for_docker_postgresql16\pgdata:/var/lib/postgresql/data --name local-postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test -p 127.0.0.1:5432:5432 postgres:16.0-bookworm

docker container stop local-postgres
docker container start local-postgres

docker container exec -it local-postgres bash
su - postgres

~~~

~~~bash
echo $PGDATA # /var/lib/postgresql/data
bash --version # GNU bash, version 5.2.15(1)-release (x86_64-pc-linux-gnu)
uname -a # Linux 832727f18b02 5.15.90.1-microsoft-standard-WSL2 #1 SMP Fri Jan 27 02:56:13 UTC 2023 x86_64 GNU/Linux
cat /etc/debian_version # 12.1
psql --version # psql (PostgreSQL) 16.0 (Debian 16.0-1.pgdg120+1)

su - postgres
pwd # /var/lib/postgresql
ls # data
psql postgres
~~~

~~~sql
-- list database
\list
SELECT version(); --PostgreSQL 16.0 (Debian 16.0-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit

-- help
\h

-- check exist roles
SELECT rolname FROM pg_roles;
SELECT rolname FROM pg_roles WHERE rolcanlogin;

CREATE ROLE test WITH LOGIN PASSWORD 'testp';
CREATE DATABASE testdb OWNER test;

-- quit
\q
~~~

~~~sql
-- psql -d testdb -U test
CREATE TABLE test_table (
  id varchar(36),
  full_name varchar(100),
  age int,
  update_datetime timestamp
);
~~~
