# MyNote_Docker #

## ドキュメント ##

[Docker ドキュメント](http://docs.docker.jp/index.html)
[docker run](http://docs.docker.jp/engine/reference/commandline/run.html)

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
docker images

# イメージ削除
docker rmi

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


