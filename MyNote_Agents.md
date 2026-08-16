# Agents #

## Scale Agents ##

- [CrewAI、LangGraph、A2A、ADK を使用してエージェントをスケーリングする](https://codelabs.developers.google.com/next26/scale-agents?hl=ja#0)
  - [CrewAI のドキュメント](https://docs.crewai.com/)
    - [Skills](https://crewai.mintlify.app/v1.12.2/en/concepts/skills)
    - 基本の流れ
      - LLM
        - 各種主要LLM利用可
      - Tool
      - Agent
      - Task
      - Process
      - RUN
  - [LangGraph のドキュメント](https://langchain-ai.github.io/langgraph/)
    - [Gemini と LangGraph を使用して ReAct エージェントをゼロから作成する](https://ai.google.dev/gemini-api/docs/langgraph-example?hl=ja)
    - 基本の流れ
      - State
      - Nodes
      - Edges
  - [Vertex AI のドキュメント](https://cloud.google.com/vertex-ai/docs?hl=ja)
  - [A2A プロトコル](https://github.com/google/a2a-python)
  - [ADK ドキュメント](https://google.github.io/adk-docs/)
- [MCP、ADK、A2A を使ってみる](https://codelabs.developers.google.com/codelabs/currency-agent?hl=ja#0)

- [Gemma 4](https://huggingface.co/collections/google/gemma-4)

## Skills ##

- [CrewAI Skills](https://github.com/crewAIInc/skills)
- [Google Cloud Agent Skills](https://github.com/google/skills)
- [Anthropics Agent Skills](https://github.com/anthropics/skills)
- [汎用 Code Skill - 非公式](https://github.com/alirezarezvani/claude-skills)

## 権限管理 ##

- 考え方
  - Planner、Orchestrator はホスト環境にデプロイ、完全な情報を把握する
  - Executor はDocker等、限定的な環境で動作する。

## Claude Code ##

- [Claude Code CLI リファレンス](https://code.claude.com/docs/ja/cli-reference)
  - [Claude Cowork](https://support.claude.com/ja/articles/10065433-claude-desktop%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)
  - [claude -p 料金](https://support.claude.com/ja/articles/15036540-claude-%E3%83%97%E3%83%A9%E3%83%B3%E3%81%A7-claude-agent-sdk-%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%99%E3%82%8B)

## Local LLM 環境 ##

- フォーマット
  - gguf: docker model runner
  - Safetensors: vllm

- [Docker model runner](https://docs.docker.com/ai/model-runner/inference-engines/#platform-support)
  - docker.io/ai/gemma4:latest
    - 7.52B
    - MOSTLY_Q4_K_M
    - gguf
  - [api-reference](https://docs.docker.com/ai/model-runner/api-reference/)

~~~powershell
docker model status # BACKEND llama.cpp - gguf 実行用
docker model list # gemma4
# 起動後 http://localhost:12434/ から利用可能 # api-reference 参照 
#   http://localhost:12434/models
docker model run hf.co/TrevorJS/gemma-4-E4B-it-uncensored-GGUF:Q4_K_M # run model from huggingface
~~~

- [Chroma Introduction](https://docs.trychroma.com/docs/overview/introduction)
  - [Client-Server Mode](https://docs.trychroma.com/docs/run-chroma/client-server)
- [AlloyDB for PostgreSQL](https://docs.cloud.google.com/alloydb/docs?hl=ja)
  - [AlloyDB Omni](https://docs.cloud.google.com/alloydb/omni/docs?hl=ja)
- Gemini API
  - [Gemini と LangGraph を使用して ReAct エージェントをゼロから作成する](https://ai.google.dev/gemini-api/docs/langgraph-example?hl=ja)
  - [Gemini と CrewAI を使用したカスタマー サポートの分析](https://ai.google.dev/gemini-api/docs/crewai-example?hl=ja)

~~~powershell
py -3.13 -m venv .venv
. .venv\Scripts\activate
pip install uv
uv init # オプション --no-workspace --no-readme 
uv add httpx uvicorn 'crewai[google-genai]>=1.14.7,<1.15.0' 'langgraph>=1.2.6,<1.3.0' langchain-google-genai
uv add pytest pytest-cov mypy pydantic
# google-adk と crewai に参照する opentelemetry にコンフリクト発生、そのため別々のプロジェクトで管理
#   2026/06/20時点最新  
#     crewai == 1.14.7 
#     google-adk==2.3.0
#   crewai==1.14.7 depends on opentelemetry-api>=1.34.0,<1.35.dev0
#   google-adk==2.0.0 depends on opentelemetry-api>=1.36,<=1.41.1

$env:GEMINI_API_KEY=$(Get-Content -Path "..\GeminiAPIKey.txt" -Raw)

~~~

~~~powershell
py -3.13 -m venv .venv
.venv\Scripts\activate
pip install uv
uv init
uv add 'a2a-sdk>=1.1.0,<1.2.0' 'google-adk>=2.3.0,<2.4.0'
uv add pytest pytest-cov mypy pydantic
# バージョンアップの場合、pyproject.toml に必要なバージョンを記載し
# uv sync -U --dry-run


~~~

### WSL2 ###

- [huggingface google/gemma-4-26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it)
  - Safetensors
  - BF16のBaseモデルの場合、RTX4090では動けない。AIから58GB以上VRAMが必要の回答
  - [huggingface google/gemma-4-26B-A4B-it-qat-q4_0-unquantized](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized)
    - baseはメモリ不足
  - [huggingface HauhauCS/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced](https://huggingface.co/HauhauCS/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced/Gemma-4-E4B-Uncensored-HauhauCS-Aggressive)
- [huggingface google/gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it)
  - Safetensors
  - RTX4090 のすべての 24GB を使う（モデル+予測）。複雑な仕事は厳しい。
  - [huggingface TrevorJS/gemma-4-E4B-it-uncensored-GGUF](https://huggingface.co/TrevorJS/gemma-4-E4B-it-uncensored-GGUF)
  - [huggingface huihui-ai/Huihui-gemma-4-E4B-it-abliterated](https://huggingface.co/huihui-ai/Huihui-gemma-4-E4B-it-abliterated)
- [vllm](https://docs.vllm.ai/en/stable/)
  - [GPU](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/)
  - [Supported Models](https://docs.vllm.ai/en/stable/models/supported_models/#plugins)
  - [vllm serve](https://docs.vllm.ai/en/v0.19.1/cli/serve/)

~~~bash
# vllm

nvidia-smi # NVIDIA-SMI 610.43.02              KMD Version: 610.62        CUDA UMD Version: 13.3

cd '/mnt/e/tool/wsl2_vllm'
python3.12 -m venv .venv
# code . # 任意
. .venv/bin/activate
pip install uv
uv init
uv add vllm
uv run --with vllm vllm --help # 

# default ~/.cache/huggingface/hub/ 
#   HF_HOME, VLLM_CACHE_ROOT で変更可能
vllm serve google/gemma-4-E4B-it  # huggingface からダウンロード

# vllm serve /path/to/your/local/model/directory # to run local
~~~

~~~bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E4B-it",
    "prompt": "San Francisco is a",
    "max_tokens": 7,
    "temperature": 0
  }'

# ブラウザから http://localhost:8000/docs でドキュメント確認可能
~~~

## Remote LLM 環境 ##

[API キー](https://aistudio.google.com/api-keys?hl=ja)

## Workbench Instance ##

~~~powershell


~~~
