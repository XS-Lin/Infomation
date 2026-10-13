# AgentPlatform #

## Document ##

[Agent Platform のモデルの概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models?hl=ja)
[AI と ML に関するリソース](https://docs.cloud.google.com/architecture/ai-ml?hl=ja)
[エージェント AI アーキテクチャ ガイド](https://docs.cloud.google.com/architecture/agentic-ai-overview?hl=ja)
[ML アプリケーションとオペレーションのアーキテクチャ ガイド](https://docs.cloud.google.com/architecture/ai-ml/ml-application-operations-architecture-guides?hl=ja)
[Google Cloud で AI / ML ワークロードのストレージを設計する](https://docs.cloud.google.com/architecture/ai-ml/storage-for-ai-ml?hl=ja)
[Gemini Enterprise Agent Platform での ML の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning?hl=ja)
[Gemini Enterprise Agent Platform での VPC Service Controls](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/general/vpc-service-controls?hl=ja)

## Pipelines ##

[Concepts](https://www.kubeflow.org/docs/components/pipelines/concepts/)

- [Component](https://www.kubeflow.org/docs/components/pipelines/concepts/component/)
  - [Lightweight Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/lightweight-python-components/)
  - [Containerized Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/containerized-python-components/)
  - [Container Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/container-components/)
  - [Notebook Python Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/notebook-component/)
  - [Load and Share Components](https://www.kubeflow.org/docs/components/pipelines/user-guides/components/load-and-share-components/)
- [Output HTML と Output Markdown](https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/pipelines/output-html-md?hl=ja)
  - HTML
  - Markdown
- [KFP Output](https://kubeflow-pipelines.readthedocs.io/en/stable/source/dsl.html#kfp.dsl.OutputPath)
  - OutputPath
  - Artifact
  - ClassificationMetrics
  - Dataset
  - HTML
  - Markdown
  - Metrics
  - Model
  - SlicedClassificationMetrics

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

- 調査
  - Pipelinesで、Model等に設定したmetadataはMetadataStoreに記録されるか
  - Pipelinesで、Experimentsにハイパーパラメータを記録
  - Pipelinesで、Modelの関連情報をModelRegisteryに保存
  - モニタリングの結果をBigQueryに保存
  - 試験で、ハイパーパラメータとデータバージョンを記録

## Agent ##

- [Agent Platform で ADK と Agents CLI を使用してエージェントを構築する](https://docs.cloud.google.com/gemini-enterprise-agent-platform/agents/quickstart-adk?hl=ja)
  - [概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/runtime/create-an-agent?hl=ja)
  - [Agent Runtime でエージェントを開発してデプロイする](https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/runtime/quickstart?hl=ja)
  - [RAG Engine の概要](https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/rag-engine/rag-overview?hl=ja)
- [Playwright](https://playwright.dev/)
  - [Playwright python](https://playwright.dev/python/docs/intro)
- [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
  - workflow

## BQ ##

- [Navigation functions](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/navigation_functions)
  - LAG
  - LEAD
- [QUALIFY](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#qualify_clause)
- [オブジェクト テーブルの概要](https://docs.cloud.google.com/bigquery/docs/object-table-introduction?hl=ja)
- [BigQuery DataFrames Python API](https://docs.cloud.google.com/bigquery/docs/reference/bigquery-dataframes?hl=ja)

## 用語の注意 ##

レスポンスタイムはリクエスト処理時間に加えて、ネットワークの待ち時間や待ち行列に入る時間を含める。レイテンシはリクエストが処理される待ち時間。
ここでは、機械学習コミュニティに合わせて、レイテンシはリクエスト送信からレスポンス受信時間とする（レスポンスタイムの意味で利用する）。
※アルゴリズム取引のHFT（High-Frequency Trading：高頻度取引、ミリ秒やマイクロ秒という極めて短い時間で株や為替の売買を大量に繰り返す取引手法）では、区別する必要はある。

## データセット ##

[Nemotron-Personas-Japan](https://huggingface.co/datasets/nvidia/Nemotron-Personas-Japan)

## その他 ##

### Workbech Instance ###

Workbech Instanceでipynbファイル作成の時に、デフォルトの metadata/kernelspec/name は`micromamba-base-py`になるが、デフォルトでインストールしたkernelspecのnameは`python3`である。そのため、デフォルトのままでjupyter executeを実行すると`micromamba-base-py`は見つからないエラーが発生。

~~~bash
ipython kernel install --user --name=micromamba-base-py --display-name="Python (micromamba)"
~~~
