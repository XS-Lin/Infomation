# AgentPlatform #

## Document ##

[Agent Platform のモデルの概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models?hl=ja)
[AI と ML に関するリソース](https://docs.cloud.google.com/architecture/ai-ml?hl=ja)
[エージェント AI アーキテクチャ ガイド](https://docs.cloud.google.com/architecture/agentic-ai-overview?hl=ja)
[ML アプリケーションとオペレーションのアーキテクチャ ガイド](https://docs.cloud.google.com/architecture/ai-ml/ml-application-operations-architecture-guides?hl=ja)
[Google Cloud で AI / ML ワークロードのストレージを設計する](https://docs.cloud.google.com/architecture/ai-ml/storage-for-ai-ml?hl=ja)
[Gemini Enterprise Agent Platform での ML の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning?hl=ja)
[Gemini Enterprise Agent Platform での VPC Service Controls](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/general/vpc-service-controls?hl=ja)

## Workbench ##

## Pipelines ##

[Concepts](https://www.kubeflow.org/docs/components/pipelines/concepts/)

- [Component](https://www.kubeflow.org/docs/components/pipelines/concepts/component/)
  - [Lightweight Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/lightweight-python-components/)
  - [Containerized Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/containerized-python-components/)
  - [Container Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/container-components/)
  - [Notebook Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/notebook-component/)
  - [Load and Share Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/load-and-share-components/)

### Containerized Python Components 調査 ###

- Containerized Python Components
  - components フォルダの内容をビルドする

## MLOps ##

- 注意点: 各製品の通常利用方法とPipelinesとの統合を整理すること。

- [Gemini Enterprise Agent Platform での特徴管理の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/featurestore?hl=ja)
- [Model Registry の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/model-registry/introduction?hl=ja)
- [Agent Platform でのモデル評価](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/evaluation/introduction?hl=ja)
- [Gemini Enterprise Agent Platform Pipelines の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/pipelines/introduction?hl=ja)
- [Gemini Enterprise Agent Platform ML メタデータの概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/ml-metadata/introduction?hl=ja)
- [モデル モニタリングの概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/model-monitoring/overview?hl=ja)
- [Gemini Enterprise Agent Platform の試験運用版の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/experiments/intro-vertex-ai-experiments?hl=ja)
- [パイプラインのビルド](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/pipelines/build-pipeline?hl=ja)
- [パイプライン テンプレートの作成、アップロード、使用](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/pipelines/create-pipeline-template?hl=ja)

## 用語の注意 ##

レスポンスタイムはリクエスト処理時間に加えて、ネットワークの待ち時間や待ち行列に入る時間を含める。レイテンシはリクエストが処理される待ち時間。
ここでは、機械学習コミュニティに合わせて、レイテンシはリクエスト送信からレスポンス受信時間とする（レスポンスタイムの意味で利用する）。
※アルゴリズム取引のHFT（High-Frequency Trading：高頻度取引、ミリ秒やマイクロ秒という極めて短い時間で株や為替の売買を大量に繰り返す取引手法）では、区別する必要はある。

## データセット ##

[Nemotron-Personas-Japan](https://huggingface.co/datasets/nvidia/Nemotron-Personas-Japan)

