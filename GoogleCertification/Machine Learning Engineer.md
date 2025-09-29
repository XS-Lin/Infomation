# Professional Machine Learning Engineer #

## Professional Machine Learning Engineer 認定試験ガイド ##

### セクション 1: ローコード AI ソリューションの構築（試験内容の 13%） ###

1.1 BigQuery ML を使用した ML モデルの開発。考慮事項:

- ビジネス上の問題に基づく適切な BigQuery ML モデル（線形分類、バイナリ分類、回帰、時系列、行列分解、ブーストツリー、オートエンコーダなど）の構築
- BigQuery ML を使用した特徴量エンジニアリングや特徴選択
- BigQuery ML による予測の生成

1.2 ML API または基盤モデルを使用した AI ソリューションの構築。考慮事項:

- Model Garden の ML API を使用したアプリケーションの構築
- 業界固有の API を使用したアプリケーションの構築（Document AI API、Retail API など）
- Vertex AI Agent Builder を使用した検索拡張生成（RAG）アプリケーションの実装

1.3 AutoML を使用したモデルのトレーニング。考慮事項:

- AutoML 用のデータの準備（特徴選択、データラベル付け、AutoML での表形式ワークフローなど）
- 利用可能なデータ（表形式、テキスト、音声、画像、動画など）を使用したカスタムモデルを使用
- 表形式データに AutoML を使用
- AutoML を使用した予測モデルの作成
- トレーニング済みモデルの構成とデバッグ

### セクション 2: チーム内およびチーム間の連携によるデータとモデルの管理（試験内容の 14%以下） ###

2.1 組織全体のデータの探索と前処理（Cloud Storage、BigQuery、Spanner、Cloud SQL、Apache
Spark、Apache Hadoop など）。考慮事項:

- 異なるタイプのデータ（表形式、テキスト、音声、画像、動画など）の効率的なトレーニングを目的とする整理
- Vertex AI でのデータセットの管理
- データの前処理（Dataow、TensorFlow Extended [TFX]、BigQuery など）
- Vertex AI Feature Store での特徴の作成と統合
- データの使用や収集に関するプライバシーの影響（個人情報（PII）や保護対象保健情報（PHI）といった機密データの処理など）
- 推論のための Vertex AI へのさまざまなデータソース（テキスト ドキュメントなど）の取り込み

2.2 Jupyter ノートブックを使用したモデルのプロトタイピング。考慮事項:

- Google Cloud 上での適切な Jupyter バックエンドの選択（Vertex AI Workbench、ColabEnterprise、Dataproc 上のノートブックなど）
- Vertex AI Workbench におけるセキュリティに関するベスト プラクティスの適用
- Spark カーネルの使用
- コードソース リポジトリの統合
- Vertex AI Workbench で一般的なフレームワーク（TensorFlow、PyTorch、sklearn、Spark、JAX など）を使用した Vertex AI Workbench でのモデル開発
- Model Garden のさまざまな基盤モデルとオープンソース モデルの活用

2.3 ML テストのトラッキングと実行。考慮事項:

- 開発とテストに適した Google Cloud 環境（Vertex AI Experiments、Kubeow Pipelines、TensorFlow と PyTorch を使用した Vertex AI TensorBoard など）をフレームワークに応じて選択
- 生成 AI ソリューションの評価

### セクション 3: プロトタイプの ML モデルへのスケーリング（試験内容の 18%） ###

3.1 モデルの構築。考慮事項:

- ML フレームワークとモデル アーキテクチャの選択
- 解釈可能性要件のあるモデル手法

3.2 モデルのトレーニング。考慮事項:

- Google Cloud（Cloud Storage、BigQuery など）上のトレーニング データ（表形式、テキスト、音声、画像、動画など）を整理する
- さまざまな種類のファイル（CSV、JSON、画像、Hadoop、データベースなど）をトレーニングに取り込む
- さまざまな SDK を使用したモデルのトレーニング（Vertex AI カスタム トレーニング、Google Kubernetes Engine 上の Kubeow、AutoML、表形式のワークフローなど）
- 分散トレーニングによる信頼性の高いパイプラインの組織化
- ハイパーパラメータ調整
- ML モデルのトレーニング失敗のトラブルシューティング
- 基盤モデル（Vertex AI Model Garden など）のファイン チューニング

3.3 トレーニングに適したハードウェアの選択。考慮事項:

- コンピューティング オプションとアクセラレータ オプションの評価（CPU、GPU、TPU、エッジデバイスなど）
- TPU と GPU を使用した分散トレーニング（Vertex AI 上の Reduction Server、Horovod など）

### セクション 4: モデルのサービングとスケーリング（試験内容の 20%） ###

4.1 モデルのサービング。考慮事項:

- バッチ推論とオンライン推論（Vertex AI、Dataow、BigQuery ML、Dataproc など）
- さまざまなフレームワーク（PyTorch、XGBoost など）を使用したモデルのサービング
- Model Registry でのモデルの整理
- 1 つのモデルの異なるバージョンを使用した A/B テスト

4.2 オンライン モデル サービングのスケーリング。考慮事項:

- Vertex AI Feature Store を使用した特徴の管理とサービング
- パブリック エンドポイントとプライベート エンドポイントへのモデルのデプロイ
- 適切なハードウェアの選択（CPU、GPU、TPU、エッジなど）
- スループットに基づいたサービング バックエンドのスケーリング（Vertex AI Prediction、コンテナ化されたサービングなど）
- 本番環境でのトレーニングとサービングのための ML モデルの調整（簡素化手法、パフォーマンス、レイテンシ、メモリ、スループット向上のための ML ソリューションの最適化など）

### セクション 5: ML パイプラインの自動化とオーケストレーション（試験内容の 22%） ###

5.1 エンドツーエンドの ML パイプラインの開発。考慮事項:

- データとモデルの検証
- トレーニングとサービングの間で一貫したデータ前処理の保証
- Google Cloud でのサードパーティ パイプラインのホスティング（MLow など）
- コンポーネント、パラメータ、トリガー、コンピューティングのニーズの特定（Cloud Build、Cloud Run など）
- オーケストレーション フレームワーク（Kubeow Pipelines、Vertex AI Pipelines、Cloud Composer など）
- ハイブリッド戦略またはマルチクラウド戦略
- TFX コンポーネントまたは Kubeow DSL を使用したシステムの設計（Dataow など）

5.2 モデルの再トレーニングの自動化。考慮事項:

- 適切な再トレーニング ポリシーの決定
- 継続的インテグレーションと継続的デリバリー（CI / CD）パイプライン（Cloud Build、Jenkinsなど）を使用したモデルのデプロイ

5.3 メタデータのトラッキングと監査。考慮事項:

- モデルのアーティファクトとバージョンの追跡と比較（Vertex AI Experiments、Vertex ML Metadata など）
- モデルおよびデータセットのバージョンの指定
- モデルとデータ系列

### セクション 6: AI ソリューションのモニタリング（試験内容の 13%） ###

6.1 AI ソリューションに対するリスクの特定。考慮事項:

- データやモデルの意図しない搾取（ハッキングなど）からの保護による、安全な AI システムの構築
- Google の責任ある AI への取り組みとのすり合わせ（バイアスのモニタリングなど）
- AI ソリューションの準備状況の評価（公平性、バイアスなど）
- Vertex AI でのモデルの説明可能性（Vertex AI Prediction など）

6.2 AI ソリューションのモニタリング、テスト、トラブルシューティング。考慮事項:

- 継続的な評価指標の確立（Vertex AI Model Monitoring、Explainable AI など）
- トレーニング / サービング スキューのモニタリング
- 特徴アトリビューションのドリフトのモニタリング
- ベースライン、シンプルなモデル、時間枠に対するモデルのパフォーマンスのモニタリング
- 一般的なトレーニング エラーやサービング エラーのモニタリング

## Professional Machine Learning Engineer Study Guide ##

### 1 Framing ML Problems ###






https://www.credly.com/badges/208d618e-c3d8-4449-9ce7-57e45f324865/public_url

### 未分類 ###

- loss
  - Loss is a number indicating how bad the model's predication was on a single example. If the model's predication is perfect, the loss is zero; otherwise, the loss is greater.
  - Loss is nothing but a predication error of neural net.
  - The method to calculate the loss is called loss function.
  - Loss is used to calculate the gradients. And the gradients are used to update the weight of neural net.
  - The goal of training a model is to find a set of weights and biases that have low loss, on average, accross all examples.

- [Choosing the right orchestrator in Google Cloud](https://cloud.google.com/blog/topics/developers-practitioners/choosing-right-orchestrator-google-cloud?hl=en)

## crash-course ##

- [Linear regression](https://developers.google.com/machine-learning/crash-course/linear-regression)
- [Linear regression: Loss](https://developers.google.com/machine-learning/crash-course/linear-regression/loss)
  - Loss is a numerical metric that describes how wrong a model's predictions are. Loss measures the distance between the model's predictions and the actual labels. The goal of training a model is to minimize the loss, reducing it to its lowest possible value.
  - Types of loss
    - L1 loss
      - The sum of the absolute values of the difference between the predicted values and the actual values.
      - NOTE: 予測値と実際の値の差の絶対値の和
    - Mean absolute error (MAE)
      - The average of L1 losses across a set of *N* examples.
      - NOTE: N個のサンプルのセットにおける L1 損失の平均。
    - L2 loss
      - The sum of the squared difference between the predicted values and the actual values.
      - NOTE: 予測値と実際の値の差の二乗和
    - Mean squared error (MSE)
      - The average of L2 losses across a set of *N* examples.
      - NOTE: N個のサンプルセット全体の L2 損失の平均。
- [Linear regression: Gradient descent](https://developers.google.com/machine-learning/crash-course/linear-regression/gradient-descent)
  - Gradient descent is a mathematical technique that iteratively finds the weights and bias that produce the model with the lowest loss.
- [Linear regression: Hyperparameters](https://developers.google.com/machine-learning/crash-course/linear-regression/hyperparameters)
  - Hyperparameters are variables that control different aspects of training. Three common hyperparameters are:
    - Learning rate
      - Learning rate is a floating point number you set that influences how quickly the model converges.
      - If the learning rate is too low, the model can take a long time to converge.
      - However, if the learning rate is too high, the model never converges, but instead bounces around the weights and bias that minimize the loss.
      - The goal is to pick a learning rate that's not too high nor too low so that the model converges quickly.
    - Batch size
      - Batch size is a hyperparameter that refers to the number of examples the model processes before updating its weights and bias.
      - You might think that the model should calculate the loss for every example in the dataset before updating the weights and bias. However, when a dataset contains hundreds of thousands or even millions of examples, using the full batch isn't practical.
      - Stochastic gradient descent (SGD) - 確率的勾配降下法
        - 1 of batch size
      - Mini-batch stochastic gradient descent (mini-batch SGD) - ミニバッチ確率的勾配降下法
        - 1 ~ batch size of batch size
      - When training a model, you might think that noise is an undesirable characteristic that should be eliminated. However, a certain amount of noise can be a good thing. In later modules, you'll learn how noise can help a model generalize better and find the optimal weights and bias in a neural network.
    - Epochs
      - During training, an epoch means that the model has processed every example in the training set once. For example, given a training set with 1,000 examples and a mini-batch size of 100 examples, it will take the model 10 iterations to complete one epoch.
- [Logistic regression: Calculating a probability with the sigmoid function](https://developers.google.com/machine-learning/crash-course/logistic-regression/sigmoid-function)
  - Logistic regression is an extremely efficient mechanism for calculating probabilities.
  - Converted to a binary category such as True or False, Spam or Not Spam.
  - Sigmoid function
  - Transforming linear output using the sigmoid function
- [Logistic regression: Loss and regularization](https://developers.google.com/machine-learning/crash-course/logistic-regression/loss-regularization)
  - Log Loss
  - Regularization in logistic regression
- [Thresholds and the confusion matrix](https://developers.google.com/machine-learning/crash-course/classification/thresholding)
  - Confusion matrix
- [Classification: Accuracy, recall, precision, and related metrics](https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall)
  - Accuracy = correct / total = (TP + TN)/(TP + TN + FP + FN)
    - Use as a rough indicator of model training progress/convergence for balanced datasets.
    - For model performance, use only in combination with other metrics.
    - Avoid for imbalanced datasets. Consider using another metric.
  - Recall, or true positive rate = correct classified actual positives / all actual positives = TP/(TP + FN)
    - Use when false negatives are more expensive than false positives.
  - False positive rate = incorrectly classified actual negatives / all actual negatives = FP/(FP + TN)
    - Use when false positives are more expensive than false negatives.
  - Precision = correctly classified actual positives / everything classified actual positives = TP/(TP + FP)
    - Use when it's very important for positive predictions to be accurate.
  - F1 score = 2 x precision x recal/(precision + recal) = 2TP/(2TP+FP+FN)
    - The F1 score is the harmonic mean (a kind of average) of precision and recall.
- [Classification: ROC and AUC](https://developers.google.com/machine-learning/crash-course/classification/roc-and-auc)
  - Receiver-operating characteristic curve (ROC)
    - The ROC curve is a visual representation of model performance across all thresholds.
    - Vertical axis: TPR = TP/(TP + FN) = recall
    - Horizontal axis: FPR = FP/(FP + TN)
  - Area under the curve (AUC)
    - The area under the ROC curve (AUC) represents the probability that the model, if given a randomly chosen positive and negative example, will rank the positive higher than the negative.
- [Numerical data: How a model ingests data using feature vectors](https://developers.google.com/machine-learning/crash-course/numerical-data/feature-vectors)
  - feature engineering - determine the best way to represent raw dataset values as trainable values in the feature vector
    - Normalization: Converting numerical values into a standard range.
    - Binning (also referred to as bucketing): Converting numerical values into buckets of ranges.
- [Numerical data: First steps](https://developers.google.com/machine-learning/crash-course/numerical-data/first-steps)
  - [Working with Missing Data (pandas Documentation)](http://pandas.pydata.org/pandas-docs/stable/missing_data.html)
  - [Visualizations (pandas Documentation)](http://pandas.pydata.org/pandas-docs/stable/visualization.html)
- [Numerical data: Normalization](https://developers.google.com/machine-learning/crash-course/numerical-data/normalization)
  - Linear scaling
  - Z-score scaling
    - A Z-score is the number of standard deviations a value is from the mean
  - Log scaling
  - Clipping
    - Clipping is a technique to minimize the influence of extreme outliers.
  - [Summary of normalization techniques](https://developers.google.com/machine-learning/crash-course/numerical-data/normalization#summary_of_normalization_techniques)
- [Numerical data: Qualities of good numerical features](https://developers.google.com/machine-learning/crash-course/numerical-data/qualities-of-good-numerical-features)
- [過学習: L2 正則化](https://developers.google.com/machine-learning/crash-course/overfitting/regularization?hl=ja)
  - 重みの二乗和、0近い重みは全体の影響に少ない
  - Setting the regularization rate to zero removes regularization completely. In this case, training focuses exclusively on minimizing loss, which poses the highest possible overfitting risk.
  - The ideal regularization rate produces a model that generalizes well to new, previously unseen data. Unfortunately, that ideal value is data-dependent, so you must do some tuning.
  - Early stopping: an alternative to complexity-based regularization
  - Finding equilibrium between learning rate and regularization rate
    - If the regularization rate is high with respect to the learning rate, the weak weights tend to produce a model that makes poor predictions. Conversely, if the learning rate is high with respect to the regularization rate, the strong weights tend to produce an overfit model.
- [過学習: 損失曲線の解釈](https://developers.google.com/machine-learning/crash-course/overfitting/interpreting-loss-curves?hl=ja)
- [ニューラル ネットワーク: ノードと隠れ層](https://developers.google.com/machine-learning/crash-course/neural-networks/nodes-hidden-layers?hl=ja)
- []()
- []()
- []()

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

### Generative AI ###

- [Agent Development Kit](https://google.github.io/adk-docs/)
- [Google Gen AI SDK](https://googleapis.github.io/python-genai/)
- [github GoogleCloudPlatform/generative-ai](https://github.com/GoogleCloudPlatform/generative-ai)
  - [intro_gemini_2_5_flash](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_gemini_2_5_flash.ipynb)
  - [intro_gemini_curl](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_gemini_curl.ipynb)
  - [intro_genai_sdk](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/getting-started/intro_genai_sdk.ipynb)
  - [intro_function_calling](https://github.com/GoogleCloudPlatform/generative-ai/blob/main/gemini/function-calling/intro_function_calling.ipynb)
  - [gemini-streamlit-cloudrun](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/gemini/sample-apps/gemini-streamlit-cloudrun)
  - [setup-env](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)
- [Beginner: Introduction to Generative AI Learning Path](https://www.cloudskillsboost.google/paths/118)
- [Build and Modernize Applications With Generative AI](https://www.cloudskillsboost.google/paths/1282)
- [AI Labs with Gemini on Google Cloud](https://www.cloudskillsboost.google/paths/1873)
- [Deploy and Manage Generative AI Models](https://www.cloudskillsboost.google/paths/1283)

- [Advanced: Generative AI for Developers Learning Path](https://www.cloudskillsboost.google/paths/183?utm_source=cgc&utm_medium=website&utm_campaign=evergreen)
- [Machine Learning Engineer Learning Path](https://www.cloudskillsboost.google/paths/17)

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

docker run --name test -it --rm --user=jupyter:jupyter customized-workbench-container:v3 /bin/bash
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

### Books ###

[直感LLM](https://github.com/HandsOnLLM/Hands-On-Large-Language-Models)

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

### udemy ###

- [udemy GCP Professional ML Engineer Practice Exams 2025](https://www.udemy.com/course/gcp-professional-ml-engineer-practice-exams-2025/?couponCode=CP190825Q3JP)