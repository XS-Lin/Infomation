# Professional Machine Learning Engineer #

## Skill Boost ##

### BigQuery ML ###

- [BigQuery の AI と ML の概要](https://cloud.google.com/bigquery/docs/bqml-introduction?hl=ja)
- [The CREATE MODEL statement](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create)
  - BigQuery ML で利用可能なモデル種類
- 注意
  - BigQuery ML will automatically treat any integer as a numerical value rather than a categorical value


### Natural Language API ###

- [Natural Language API Basics](https://cloud.google.com/natural-language/docs/basics)

~~~bash
curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json
~~~

## VertexAI ##

- [image](https://console.cloud.google.com/artifacts/docker/deeplearning-platform-release/us/gcr.io/workbench-container?invt=Abz0xg&inv=1) 
  - gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0

~~~dockerfile
FROM gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0
ENV TEST_ENV=test_env_x

RUN echo 'root:Docker!' | chpasswd 
# or 
# RUN echo 'Docker!' | passwd --stdin root 

RUN chown <username>:<groupname> <file_or_directory>
# or
# RUN chmod <mode> <file_or_directory>

COPY --chown=<username>:<groupname> <src> <dest>

# Dockerfile_v0.txt
FROM gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0
ENV TEST_ENV=test_env_x
# Dockerfile_v1.txt
FROM gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0
ENV TEST_ENV=test_env_x
ENV APP_PATH=/app
RUN mkdir $APP_PATH
# Dockerfile_v2.txt
FROM gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0
ENV TEST_ENV=test_env_x
ENV APP_PATH=/app
RUN mkdir $APP_PATH
RUN chown jupyter:jupyter /app
# Dockerfile_v3.txt
FROM gcr.io/deeplearning-platform-release/workbench-container:20250609-2200-rc0
ENV TEST_ENV=test_env_x
ENV APP_PATH=/app
RUN mkdir $APP_PATH
RUN chown jupyter:jupyter /app
RUN echo 'root:Docker!' | chpasswd
~~~

~~~powershell
Get-Content Dockerfile_v0.txt | docker build -t customized-workbench-container:v0 -
Get-Content Dockerfile_v1.txt | docker build -t customized-workbench-container:v1 -
Get-Content Dockerfile_v2.txt | docker build -t customized-workbench-container:v2 -
Get-Content Dockerfile_v3.txt | docker build -t customized-workbench-container:v3 -

docker run -it --rm customized-workbench-container:v0 /bin/bash
# root@90691109fe3b:/# ls -l /home
# total 4
# drwxr-x--- 11 jupyter jupyter 4096 Jun 11 11:15 jupyter

docker run -it --rm customized-workbench-container:v1 /bin/bash
# root@fd531dd42c00:/# ls -l
# drwxr-xr-x   2 root root  4096 Jun 11 11:29 app

docker run -it --rm customized-workbench-container:v2 /bin/bash
# root@89be177a895e:/# ls -l
# drwxr-xr-x   1 jupyter jupyter  4096 Jun 11 11:29 app

docker run -it --rm --user=jupyter:jupyter customized-workbench-container:v3 /bin/bash
# jupyter@b77455309bbc:/$
# jupyter@b77455309bbc:/$ su
# Password:
# root@b77455309bbc:/#
# root@b77455309bbc:/# exit
# exit
# jupyter@b77455309bbc:/$
~~~

## Jupyter Notebook ###

- Magic Tips:
  - must be the first line
  - %%bash - Use bash
  - %%bigquery - Use SQL access BigQuery

## その他 ##

### developers google ###

https://developers.google.com/machine-learning/crash-course/linear-regression/gradient-descent?hl=ja
https://developers.google.com/machine-learning/crash-course/numerical-data?hl=ja

### DataProc ###

~~~bash
PROJECT_ID=$(gcloud config get-value project) && \
gcloud config set project $PROJECT_ID

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

# Enable/disable access to Google Cloud APIs from this subnet for instances without a public ip address.
gcloud compute networks subnets update default --region=us-east4  --enable-private-ip-google-access 
gcloud dataproc clusters create example-cluster --worker-boot-disk-size 500 --worker-machine-type=e2-standard-4 --master-machine-type=e2-standard-4
gcloud dataproc jobs submit spark --cluster example-cluster \
  --class org.apache.spark.examples.SparkPi \
  --jars file:///usr/lib/spark/examples/jars/spark-examples.jar -- 1000
gcloud dataproc clusters update example-cluster --num-workers 4
gcloud dataproc clusters update example-cluster --num-workers 2
~~~

~~~bash
# hdfs 操作
hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt
hdfs dfs -ls /
~~~

### Cloud Natural Language API ###

~~~bash
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)
gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-natlang-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

# IN SSH
gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
~~~

### Speech-to-Text API ###

~~~bash
export API_KEY=<YOUR_API_KEY>
touch request.json
nano request.json
# Edit request.json
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}"
~~~

~~~json
// request.json
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
  }
}
~~~

### Video Intelligence ###

[Video Intelligence: Qwik Start](https://www.cloudskillsboost.google/paths/17/course_templates/631/labs/526870)

~~~bash
gcloud iam service-accounts create quickstart
gcloud iam service-accounts keys create key.json --iam-account quickstart@qwiklabs-gcp-02-15fe717123fc.iam.gserviceaccount.com
gcloud auth activate-service-account --key-file key.json
gcloud auth print-access-token

cat > request.json <<EOF
{
   "inputUri":"gs://spls/gsp154/video/train.mp4",
   "features": [
       "LABEL_DETECTION"
   ]
}
EOF

curl -s -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer '$(gcloud auth print-access-token)'' \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json

curl -s -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer '$(gcloud auth print-access-token)'' \
    'https://videointelligence.googleapis.com/v1/projects/1031248412615/locations/asia-east1/operations/3256661309120195010'
~~~

### 基本スキル ###

1. データ可視化
1. 統計
1. データ集計
1. 資料作り

### 分析の型 ###

1. リピート分析、RFM分析、デシル分析、ファネル分析、退会分析など
