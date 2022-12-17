# ローカル試験環境 #

## Main ##

### 開発環境 ###

#### Go lang ####

* go 1.19.4

#### Python ####

* Python 3.11.1

~~~powershell
# common
pip install 

# venv は割愛
~~~

#### Docker ####

[hub gitlab ce](https://hub.docker.com/r/gitlab/gitlab-ce/)
[gitlab](https://docs.gitlab.com/ee/install/docker.html#install-gitlab-using-docker-engine)
[hub redmine](https://hub.docker.com/_/redmine)
[hub apache/airflow](https://hub.docker.com/r/apache/airflow)
[jupyter/datascience-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook)
[hub centos](https://hub.docker.com/_/centos/)
[hub ubuntu](https://hub.docker.com/_/ubuntu)
[hub alpine](https://hub.docker.com/_/alpine)
[hub debian](https://hub.docker.com/_/debian)
[hub kaggle/python](https://hub.docker.com/r/kaggle/python)

* Docker Engine v20.10.21
* Kubernetes v1.25.2
* Images
  * jupyter/datascience-notebook:2022-12-15
  * jupyter/tensorflow-notebook:2022-12-15
  * kaggle/python:latest
    * gcr.io/kaggle-private-byod/python:v123
  * apache/airflow:2.5.0-python3.10
  * gitlab/gitlab-ce:15.5.6-ce.0
  * postgres:13.9-alpine3.17
  * mysql:8.0.31
  * self build image
    * base
      * alpine
        * python 3.11.1-alpine3.17
      * ubuntu:23.04
      * debian:11-slim

~~~powershell
# 開発環境共有ネット
docker network create --driver=bridge application_net
~~~

~~~powershell
docker pull jupyter/datascience-notebook:2022-12-15
$work_folder="d:\Site\MyScript\python_test\data_science\datascience-notebook"
docker run -it --network application_net --name my_data_science_notebook -p 8888:8888 -v ${work_folder}:/home/jovyan/work jupyter/datascience-notebook:2022-12-15

# コンテナ停止・起動
docker stop my_data_science_notebook
docker start my_data_science_notebook
~~~

~~~powershell
docker pull jupyter/tensorflow-notebook:2022-12-15
$work_folder="d:\Site\MyScript\python_test\data_science\tensorflow-notebook"
docker run -it --network application_net --name my_tensorflow_notebook -p 8888:8888 -v ${work_folder}:/home/jovyan/work jupyter/tensorflow-notebook:2022-12-15

# コンテナ停止・起動
docker stop my_tensorflow_notebook
docker start my_tensorflow_notebook
~~~

~~~powershell
docker pull kaggle/python:latest
~~~

~~~powershell
docker pull apache/airflow:2.5.0-python3.10
~~~

~~~powershell
docker pull gitlab/gitlab-ce:15.5.6-ce.0


~~~

~~~powershell
docker pull postgres:13.9-alpine3.17
~~~

~~~powershell
docker pull mysql:8.0.31
# コンテナ作成
docker run --network application_net --name mysql_instance_1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Password0 -d mysql:8.0.31
# コンテナ停止・起動
docker stop mysql_instance_1
docker start mysql_instance_1
# 詳細情報
docker inspect mysql_instance_1
# ローカル接続
docker exec -it mysql_instance_1 bash
# mysql -u root -p
# SELECT user AS role_name FROM mysql.user WHERE host = '%' AND NOT LENGTH(authentication_string);
# CREATE USER IF NOT EXISTS admin IDENTIFIED BY 'Admin_Password0';
# GRANT ALL PRIVILEGES ON *.* TO admin;
# リモート接続
docker run -it --network application_net --rm mysql:8.0.31 mysql -h mysql_instance_1 -u admin -p
~~~

~~~bash

~~~

#### IDE ####

* VS Code
* Visual Studio Community 2022
* Unreal Engine 5.1.0
* Blender 3.4

#### other ####

* Wireshark
* owasp zap
* pgAdmin
