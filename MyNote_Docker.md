# MyNote_Docker #

## ドキュメント ##

[Docker ドキュメント](http://docs.docker.jp/index.html)
[docker run](http://docs.docker.jp/engine/reference/commandline/run.html)
[Dockerfile Linter](https://hadolint.github.io/hadolint/)
[Dockerfile のベスト・プラクティス](http://docs.docker.jp/develop/develop-images/dockerfile_best-practices.html)
[Dockerfile リファレンス](http://docs.docker.jp/engine/reference/builder.html)

## Cheat sheet ##

~~~bash
# 実行(docker create + start)
docker run

# ホストとコンテナのファイルコピー
docker cp

# コンテナ内コマンド実行
docker exec

# 一時停止と再開
docker pause / docker unpause

# 停止
docker stop

# コンテナ詳細
docker inspect

# ポート確認
docker port

# コンテナID確認
docker ps -aq

# イメージ確認
docker image ls
docker images

# イメージ削除
docker image rm
docker rmi

# 使用されないイメージ削除
docker image prune

# すべてのコンテナ起動
docker-compose up

# すべてのコンテナ再構成
docker-compose build

# すべてのコンテナ停止
docker-compose stop

# すべてのコンテナ削除
docker-compose rm

~~~

## Example ##

1. 停止したコンテナをクリア

   ~~~bash
   docker rm -v $(docker ps -aq -f status=exited)
   ~~~

1. すべてのコンテナをクリア

   ~~~bash
   docker rm $(docker ps -aq)
   ~~~

1. すべてのイメージ階層末端のイメージ削除

   ~~~bash
   docker rmi $(docker images -q -f dangling=true)
   ~~~

1. すべてのコンテナをバックグラウンドで起動

   ~~~bash
   docker-compose up -d
   ~~~

1. Redis

   ~~~bash
   docker pull redis
   docker run --name myredis -d redis
   docker run --rm -it --link myredis:redis redis /bin/bash
   root@943968872cd1:/data# redis-cli -h redis -p 6379
   redis:6379> ping
   PONG
   redis:6379> set "abc" 123
   OK
   redis:6379> get "abc"
   "123"
   redis:6379> exit
   root@943968872cd1:/data# exit
   docker stop myredis
   docker rm -v myredis
   ~~~

1. Postgresql

   ~~~bash
   docker pull postgres:latest
   docker run -d --rm --name postgres-test1 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=test1 -p 5432:5432 postgres
   docker container stop postgres-test1
   ~~~

1. maildev

   ~~~bash
   docker pull maildev/maildev:latest

   ~~~

1. MEAN

   ~~~bash
   docker pull mongo
   docker pull node
   ~~~

1. フォルダコピー

   ~~~bash
   # コンテナに指定ディレクトリがない場合
   docker cp ./bar test:/foo/bar
   # コンテナに指定ディレクトリがある場合
   docker cp ./bar/. test4:/foo/bar
   ~~~

## docker redmine ##

[docker redmine](https://hub.docker.com/_/redmine)

~~~powershell
docker pull redmine

# postgres + redmine
docker network create -d bridge my-bridge-network
docker run --rm -d --name redmine-postgres --network my-bridge-network  -e POSTGRES_PASSWORD=secret -e POSTGRES_USER=redmine postgres
docker run --rm -d --name my-redmine --network my-bridge-network -p 80:3000 -e REDMINE_DB_POSTGRES=redmine-postgres -e REDMINE_DB_USERNAME=redmine -e REDMINE_DB_PASSWORD=secret redmine

docker stop my-redmine 
docker stop redmine-postgres
docker rm my-redmine
docker rm redmine-postgres

# default amdin user: admin/admin
~~~

## docker gitlab ##

[docker gitlab](gitlab/gitlab-ce)
[GitLab Docker images](https://docs.gitlab.com/ee/install/docker.html)

~~~powershell
sudo docker pull gitlab/gitlab-ce:latest

docker run --detach \
--hostname gitlab.example.com \
--publish 443:443 --publish 80:80 --publish 22:22 \
--name gitlab \
--restart always \
--volume $GITLAB_HOME/config:/etc/gitlab \
--volume $GITLAB_HOME/logs:/var/log/gitlab \
--volume $GITLAB_HOME/data:/var/opt/gitlab \
--shm-size 256m \
gitlab/gitlab-ce:latest

~~~

## docker file ##

### test ###
