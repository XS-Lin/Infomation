# Docker MySQL 8.0.36 #

## 設定 ##

~~~powershell
docker network ls
docker network inspect bridge # "Gateway": "172.17.0.1"

# 実行中のコンテナをネットワークに接続
#   docker network connect multi-host-network container1
# 接続するネットワーク上で使う IP アドレスを指定
#   docker network connect --ip 10.10.36.122 multi-host-network container2
~~~

~~~powershell
docker -v # Docker version 25.0.2, build 29cf629

# イメージ
docker pull mysql:8.0.36-debian

# 起動
docker run --name mysql-8_0-local-server  -v E:\tool\mysql_dir\for_docker_mysql8\mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=local -p 127.0.0.1:3306:3306 -d mysql:8.0.36-debian

# ローカル接続
docker container exec -it mysql-8_0-local-server bash
mysql --help
mysql -u root -p
~~~

~~~sql
-- 初期設定
SELECT VERSION(), CURRENT_DATE;
SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS test_db CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'test_user'@'172.17.0.1' IDENTIFIED BY 'test_user_p';
GRANT ALL ON test_db.* TO 'test_user'@'172.17.0.1';
-- FLUSH PRIVILEGES;
~~~

### 接続エラー対策 ###

- DBeaver「mysql Public Key Retrieval is not allowed」
  - MySQL8.0からデフォルトの認証方式がcaching_sha2_passwordになっている
  - allowPublicKeyRetrieval=true の設定が必要
