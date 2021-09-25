# Associate Cloud Engineer #

## スキル ##

[認定試験ガイド(公式)](https://cloud.google.com/certification/guides/cloud-engineer)

1. クラウド ソリューション環境の設定

    1.1 クラウド プロジェクトとアカウントを設定する。以下のような作業を行います。

    * プロジェクトを作成する
    * プロジェクト内で事前定義された IAM ロールにユーザーを割り当てる
    * Cloud Identity でユーザーを管理する（手動および自動）
    * プロジェクトで API を有効にする
    * Stackdriver ワークスペースをプロビジョニングする

    1.2 課金構成を管理する。以下のような作業を行います。

    * 請求先アカウントを作成する
    * プロジェクトを請求先アカウントにリンクする
    * 課金の予算とアラートを設定する
    * 日 / 月単位の料金見積もりを目的として請求関連のエクスポートを設定する

    1.3 コマンドライン インターフェース（CLI）、具体的には Cloud SDK をインストール、構成する（例: デフォルト プロジェクトの設定）。

2. クラウド ソリューションの計画と構成

    2.1 料金計算ツールを使用して GCP プロダクトの使用量を計画して見積もる

    2.2 コンピューティング リソースを計画、構成する。以下のような点を考察します。

    * ワークロードに適したコンピューティング サービス（例: Compute Engine、Google Kubernetes Engine、App Engine、Cloud Run、Cloud Functions）の選択
    * プリエンプティブル VM とカスタム マシンタイプの適宜使用

    2.3 データ ストレージ オプションを計画、構成する。以下のような点を考察します。

    * プロダクト（例: Cloud SQL、BigQuery、Cloud Spanner、Cloud Bigtable）の選択
    * ストレージ オプション（例: Standard、Nearline、Coldline、Archive）の選択
    2.4 ネットワーク リソースを計画、構成する。以下のようなタスクを行います。

    * 負荷分散オプションの違いを見分ける
    * 可用性を考慮してネットワーク内のリソースのロケーションを決定する
    * Cloud DNS を構成する

3. クラウド ソリューションのデプロイと実装

    3.1 Compute Engine リソースをデプロイ、実装する。以下のようなタスクを行います。

    * Cloud Console と Cloud SDK（gcloud）を使用してコンピューティング インスタンスを起動する（例: ディスク、可用性ポリシー、SSH 認証鍵の割り当て）
    * インスタンス テンプレートを使用して、自動スケーリングされるマネージド インスタンス グループを作成する
    * インスタンス用のカスタム SSH 認証鍵を生成、アップロードする
    * VM で Stackdriver Monitoring と Stackdriver Logging の構成を行う
    * コンピューティングの割り当てを評価し、割り当ての引き上げをリクエストする
    * モニタリングとロギング用に Stackdriver Agent をインストールする

    3.2 Google Kubernetes Engine リソースをデプロイ、実装する。以下のようなタスクを行います。

    * Google Kubernetes Engine クラスタをデプロイする
    * Pod を使用して Google Kubernetes Engine にコンテナ アプリケーションをデプロイする
    * Google Kubernetes Engine アプリケーションのモニタリングとロギングを構成する

    3.3 App Engine リソース、Cloud Run リソース、Cloud Functions リソースをデプロイ、実装する。以下のようなタスクを行います（該当する場合）。

    * アプリケーションをデプロイし、スケーリング構成、バージョン、トラフィック分割を更新する
    * Google Cloud イベント（例: Cloud Pub/Sub イベント、Cloud Storage オブジェクト変更通知イベント）を受け取るアプリケーションをデプロイする

    3.4 データ ソリューションをデプロイ、実装する。以下のようなタスクを行います。

    * プロダクト（例: Cloud SQL、Cloud Datastore、BigQuery、Cloud Spanner、Cloud Pub/Sub、Cloud Bigtable、Cloud Dataproc、Cloud Dataflow、Cloud Storage）を使用してデータシステムを初期化する
    * データを読み込む（例: コマンドラインによるアップロード、API による転送、インポート / エクスポート、Cloud Storage からのデータの読み込み、Cloud Pub/Sub へのデータのストリーミング）

    3.5 ネットワーキング リソースをデプロイ、実装する。以下のようなタスクを行います。

    * サブネットを持つ VPC（例: カスタムモード VPC、共有 VPC）を作成する
    * カスタム ネットワーク構成（例: 内部専用 IP アドレス、限定公開の Google アクセス、静的外部 IP アドレスとプライベート IP アドレス、ネットワーク タグ）を持つ Compute Engine インスタンスを起動する
    * VPC 用の上り（内向き）および下り（外向き）ファイアウォール ルール（例: IP サブネット、タグ、サービス アカウント）を作成する
    * Cloud VPN を使用して Google VPC と外部ネットワークとの間の VPN を作成する
    * アプリケーションへのネットワーク トラフィックを分散するロードバランサ（例: グローバル HTTP(S) ロードバランサ、グローバル SSL プロキシ ロードバランサ、グローバル TCP プロキシ ロードバランサ、リージョン ネットワーク ロードバランサ、リージョン内部ロードバランサ）を作成する

    3.6 Cloud Marketplace を使用してソリューションをデプロイする。以下のようなタスクを行います。

    * Cloud Marketplace カタログを閲覧し、ソリューションの詳細を見る
    * Cloud Marketplace ソリューションをデプロイする

    3.7 Cloud Deployment Manager を使用してアプリケーション インフラストラクチャをデプロイする。以下のようなタスクを行います。

    * Deployment Manager テンプレートを開発する
    * Deployment Manager テンプレートを起動する

4. クラウド ソリューションの正常なオペレーションの確保

    4.1 Compute Engine リソースを管理する。以下のようなタスクを行います。

    * 単一の VM インスタンス（例: 起動、停止、構成の編集、インスタンスの削除）を管理する
    * インスタンスに SSH / RDP で接続する
    * GPU を新しいインスタンスに接続し、CUDA ライブラリをインストールする
    * 現在実行されている VM のインベントリ（インスタンス ID、詳細）を見る
    * スナップショットを操作する（例: VM からのスナップショットの作成、スナップショットの表示、スナップショットの削除）
    * イメージを操作する（例: VM またはスナップショットからのイメージの作成、イメージの表示、イメージの削除）
    * インスタンス グループを操作する（例: 自動スケーリング パラメータの設定、インスタンス テンプレートの割り当てや作成、インスタンス グループの削除）
    * 管理インターフェース（例: Cloud Console、Cloud Shell、GCloud SDK）を操作する

    4.2 Google Kubernetes Engine リソースを管理する。以下のようなタスクを行います。

    * 現在実行されているクラスタのインベントリ（ノード、Pod、サービス）を見る
    * コンテナ イメージ リポジトリを閲覧し、コンテナ イメージの詳細を見る
    * ノードプールを操作する（例: ノードプールの追加、編集、削除）
    * Pod を操作する（例: Pod の追加、編集、削除）
    * サービスを操作する（例: サービスの追加、編集、削除）
    * ステートフル アプリケーション（例: 永続ボリューム、ステートフル セット）を操作する
    * 管理インターフェース（例: Cloud Console、Cloud Shell、Cloud SDK）を操作する

    4.3 App Engine リソースと Cloud Run リソースをデプロイする。以下のようなタスクを行います。

    * アプリケーションのトラフィック分割パラメータを調整する
    * 自動スケーリング インスタンスのスケーリング パラメータを設定する
    * 管理インターフェース（例: Cloud Console、Cloud Shell、Cloud SDK）を操作する

    4.4 ストレージとデータベースのソリューションを管理する。以下のようなタスクを行います。

    * Cloud Storage バケット間でオブジェクトを移動する
    * ストレージ クラス間で Cloud Storage バケットを変換する
    * Cloud Storage バケットのオブジェクト ライフサイクル管理ポリシーを設定する
    * データ インスタンス（例: Cloud SQL、BigQuery、Cloud Spanner、Cloud Datastore、Cloud Bigtable）からデータを取得するクエリを実行する
    * BigQuery クエリのコストを見積もる
    * データ インスタンス（例: Cloud SQL、Cloud Datastore）のバックアップと復元を行う
    * Cloud Dataproc、Cloud Dataflow、BigQuery のジョブ ステータスを確認する
    * 管理インターフェース（例: Cloud Console、Cloud Shell、Cloud SDK）を操作する

    4.5 ネットワーキング リソースを管理する。以下のようなタスクを行います。

    * 既存の VPC にサブネットを追加する
    * サブネットを拡張して IP アドレスを増やす
    * 静的外部または内部 IP アドレスを予約する
    * 管理インターフェース（例: Cloud Console、Cloud Shell、Cloud SDK）を操作する

    4.6 モニタリングとロギングを行う。以下のようなタスクを行います。

    * リソース指標に基づいて Stackdriver アラートを作成する
    * Stackdriver カスタム指標を作成する
    * ログが外部システム（例: オンプレミスまたは BigQuery）にエクスポートされるようにログシンクを構成する
    * Stackdriver のログを表示、フィルタリングする
    * Stackdriver のログメッセージの詳細を見る
    * Cloud Diagnostics を使用してアプリケーションの問題を調査する（例: Cloud Trace データの確認、Cloud Debug を使用したアプリケーションのポイントインタイムの確認）
    * Google Cloud Platform のステータスを見る
    * 管理インターフェース（例: Cloud Console、Cloud Shell、Cloud SDK）を操作する

5. アクセスとセキュリティの構成

    * 5.1 Identity and Access Management（IAM）を管理する。以下のようなタスクを行います。

    * IAM ロールの割り当てを見る
    * IAM ロールをアカウントまたは Google グループに割り当てる
    * カスタム IAM ロールを定義する

    5.2 サービス アカウントを管理する。以下のようなタスクを行います。

    * 特権が制限されているサービス アカウントを管理する
    * サービス アカウントを VM インスタンスに割り当てる
    * 別のプロジェクトのサービス アカウントにアクセス権を付与する

    5.3 プロジェクトとマネージド サービスの監査ログを見る。

## 試験対策 ##

### Cloud SDK ###

~~~powershell
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
gcloud components install beta
gcloud auth configure-docker
~~~

### IAM ###

~~~powershell

~~~

### CI/CD ###

~~~powershell
# Cloud Build

# Artifact Registry 

# Source Repositories

~~~

### コンピューティング ###

~~~powershell
# 作成
gcloud beta compute --project=fluent-anagram-326107 instances create instance-1 --zone=us-central1-a --machine-type=e2-micro --subnet=default --network-tier=PREMIUM --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --service-account=192288398012-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=centos-8-v20210916 --image-project=centos-cloud --boot-disk-size=20GB --boot-disk-type=pd-balanced --boot-disk-device-name=instance-1 --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any --labels=test=acs

gcloud compute --project=fluent-anagram-326107 firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud compute --project=fluent-anagram-326107 firewall-rules create default-allow-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server

# 接続
gcloud beta compute ssh --zone "us-central1-a" "instance-1"  --project "fluent-anagram-326107"
# 初回接続の時に認証鍵が未登録の場合は自動生成される。デフォルトパス ~/.ssh/google_compute_engine
#   https://cloud.google.com/sdk/gcloud/reference/beta/compute/ssh
# TeraTerm で上記認証鍵を利用することが可能で、必要な情報は外部IP、ユーザ、鍵ファイル
gcloud compute instances list --filter="name~'inst*'" # EXTERNAL_IP
# Compute Engine > 設定 > メタデータ > SSH認証鍵

# 削除
gcloud compute instances delete "instance-1"
~~~

### サーバーレス ###

~~~powershell
# App Engine

# Cloud RUN

# Cloud Function

~~~

### ストレージ ###

~~~powershell
# Object Storage (Cloud Storage)

# Persistent Storage (used by GKE)

# Memory Cache (Redis)

~~~

### データベース ###

~~~powershell
# Cloud SQL (Postgresql13)

# NoSql (FireStore ネイティブ モード)

~~~

### ネットワーキング ###

~~~powershell
# VPC

# VPN

# Cloud Load Balancing

~~~

### ビッグデータ ###

~~~powershell
# Pub/Sub

# DataProc

# DataFlow

~~~
