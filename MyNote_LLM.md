# LLM #

## 概要 ##

- Open AI
- Gemini
- Claude
- Grok

[youtube LLM](https://www.youtube.com/andrejkarpathy)

### 基本 ###

[大規模言語モデル](https://ja.wikipedia.org/wiki/%E5%A4%A7%E8%A6%8F%E6%A8%A1%E8%A8%80%E8%AA%9E%E3%83%A2%E3%83%87%E3%83%AB)

ChatGPT、Geminiなどを触ったことがあると思います。質問の回答や文章の要約などイメージがあるでしょう。
明確な定義はまだないですが、わかりやすくいうと、確率に基づいてテキストを生成するシステムです。

ChatGPT,Gemini,Claude,Gork のようなサービスはAPIで利用可能ですが、ここではまずローカルでモデルをホストする方法を簡単に紹介してから、PythonでLLMを利用する方法を説明します。ローカルでLLMを利用することはモデルをダウンロードし、サービスとして起動することです。
余談ですが、セキュリティ問題はローカルでホストできること＝GCEのVMでホストできることなので、アクセス制限することで解決できます。

ここではvllmとllama_cppでハギングフェイスのモデルを利用します（他にollama, Docker Model Runnerなども使えます）。方法は2種類：Pythonに組み込みとウェブサービス。ウェブサービスにすると、Gemini等のAPI利用と同じになります（REST APIかクライアントかで利用できます）。

以下はPythonで直接使用する例です。

~~~python
# vllm
from vllm import LLM, SamplingParams

# Sample prompts.
prompts = [
    "Hello, my name is",
    "The president of the United States is",
    "The capital of France is",
    "The future of AI is",
]
# Create a sampling params object.
sampling_params = SamplingParams(temperature=0.8, top_p=0.95)

def main():
    # Create an LLM.
    llm = LLM(model="facebook/opt-125m")
    # Generate texts from the prompts.
    # The output is a list of RequestOutput objects
    # that contain the prompt, generated text, and other information.
    outputs = llm.generate(prompts, sampling_params)
    # Print the outputs.
    print("\nGenerated Outputs:\n" + "-" * 60)
    for output in outputs:
        prompt = output.prompt
        generated_text = output.outputs[0].text
        print(f"Prompt:    {prompt!r}")
        print(f"Output:    {generated_text!r}")
        print("-" * 60)

if __name__ == "__main__":
    main()

# llama.cpp
from llama_cpp import Llama

def main():
    llm = Llama(
      model_path="./models/deepsex-34b.Q4_K_M.gguf",  # Download the model file first
      n_ctx=4096,  # The max sequence length to use - note that longer sequence lengths require much more resources
      n_threads=16,            # The number of CPU threads to use, tailor to your system and the resulting performance
      n_gpu_layers=100         # The number of layers to offload to GPU, if you have GPU acceleration available
    )
    prompt="open the door keep"
    output = llm(
      f"Below is an instruction that describes a task. Write a response that appropriately completes the request.\n\n### Instruction:\n{prompt}\n\n### Response:", # Prompt
      max_tokens=512,  # Generate up to 512 tokens
      stop=["</s>"],   # Example stop token - not necessarily correct for this specific model! Please check before using.
      echo=True        # Whether to echo the prompt
    )
    print(output)

if __name__ == "__main__":
    main()
~~~

以下ではサービスの例です。

~~~bash
# ウェブサービスとして起動
vllm serve Qwen/Qwen2.5-1.5B-Instruct

# curlでアクセス
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-1.5B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }'

# ウェブサービスとして起動
python -m llama_cpp.server --model ./models/Phi-3-mini-4k-instruct-fp16.gguf

# curlでアクセス
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-1.5B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }'
~~~

LLMの推論能力を利用することには複数回呼び出し、複数種類のLLMを組み合わせるなどが考えられます。
以下はLLMを組み合わせて使う方法です。

~~~python
# LangChain
from langchain_community.llms.llamacpp import LlamaCpp
from langchain_core.prompts import PromptTemplate
from langchain.chains.llm import LLMChain
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

def main():
    llm = LlamaCpp(
        model_path="./models/Phi-3-mini-4k-instruct-fp16.gguf",
        n_gpu_layers=-1, # try to set all to vram
        max_tokens=500,
        n_ctx=4096,
        seed=42,
        verbose=False
    )
    
    title_prompt = PromptTemplate(
        template="""<|user|>Create a title for a story about {summary}. Only return the title.<|end|><|assistant|>""", 
        input_variables=["summary"]
    )

    character_prompt = PromptTemplate(
        template="""<|user|>Describe the main character of a story about {summary} with the title {title}. Use only two sentences.<|end|><|assistant|>""", 
        input_variables=["summary","title"]
    )

    story_prompt = PromptTemplate(
        template="""<|user|>Create a story about {summary} with the title {title}. The main character is: {character}. Only return the story and it cannot be longer than on paragraph.<|end|><|assistant|>""",
        input_variables=["summary","title", "character"]
    )

    llm_chain = (
        {"summary": RunnablePassthrough()}
        | RunnablePassthrough.assign(title=(title_prompt | llm | StrOutputParser()))
        | RunnablePassthrough.assign(character=(character_prompt | llm | StrOutputParser()))
        | RunnablePassthrough.assign(story=(story_prompt | llm | StrOutputParser()))
    )
    result = llm_chain.invoke({"summary":"a girl that lost her mother"})
    print(result)
    return 
~~~

## AI agent ##

[AI エージェント](https://cloud.google.com/discover/what-are-ai-agents?hl=ja)

AI を使用してユーザーの代わりに目標を追求し、タスクを完了させるソフトウェア システムです。
わかりやすくいうと、自然言語でタスクおよびタスクを実行するための各ツールのインターフェースをLLM提示し、LLMがツールを選んでタスクを実行します。

~~~python
# main.py
from pydantic_ai.models.gemini import GeminiModel
from pydantic_ai import Agent

from dotenv import load_dotenv
import tools

load_dotenv()
model = GeminiModel("gemini-2.5-flash")

agent = Agent(model,
              system_prompt="You are an experienced programmer",
              tools=[tools.read_file, tools.list_files, tools.rename_file])

def main():
    history = []
    while True:
        user_input = input("Input: ")
        resp = agent.run_sync(user_input,
                              message_history=history)
        history = list(resp.all_messages())
        print(resp.output)

if __name__ == "__main__":
    main()

# tools.py
from pathlib import Path
import os

base_dir = Path("./test")

def read_file(name: str) -> str:
    """Return file content. If not exist, return error message.
    """
    print(f"(read_file {name})")
    try:
        with open(base_dir / name, "r") as f:
            content = f.read()
        return content
    except Exception as e:
        return f"An error occurred: {e}"

def list_files() -> list[str]:
    print("(list_file)")
    file_list = []
    for item in base_dir.rglob("*"):
        if item.is_file():
            file_list.append(str(item.relative_to(base_dir)))
    return file_list

def rename_file(name: str, new_name: str) -> str:
    print(f"(rename_file {name} -> {new_name})")
    try:
        new_path = base_dir / new_name
        if not str(new_path).startswith(str(base_dir)):
            return "Error: new_name is outside base_dir."

        os.makedirs(new_path.parent, exist_ok=True)
        os.rename(base_dir / name, new_path)
        return f"File '{name}' successfully renamed to '{new_name}'."
    except Exception as e:
        return f"An error occurred: {e}"
~~~

[Agent Development Kit エージェントを開発する](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/develop/adk?hl=ja)
[Agent Development Kit](https://google.github.io/adk-docs/)
[Agent Development Kit: Using Open & Local Models via LiteLLM](https://google.github.io/adk-docs/agents/models/#using-open-local-models-via-litellm)
[Agent Development Kit: LLM Agent](https://google.github.io/adk-docs/agents/llm-agents/)
[Agent Development Kit: MCP](https://google.github.io/adk-docs/mcp/)

~~~python


~~~

## MCP ##

[Model Context Protocol](https://nshipster.com/model-context-protocol/)
[MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture)
[context7](https://github.com/upstash/context7)
[データベース向け MCP ツールボックス](https://cloud.google.com/blog/ja/products/ai-machine-learning/mcp-toolbox-for-databases-now-supports-model-context-protocol)
[wiki Model Context Protocol](https://ja.wikipedia.org/wiki/Model_Context_Protocol#cite_note-TheVerge20241125-2)
[zenn Model Context Protocol（MCP）とは？生成 AI の可能性を広げる新しい標準](https://zenn.dev/cloud_ace/articles/model-context-protocol)
[note AIエージェント時代を変える「MCP」とは？その可能性と活用法](https://note.com/gabc/n/n9d3b8e852d34)

AIアシスタントなどの生成AIがデータの存在するシステムに対して接続可能にするためのプロトコルであり、データを保有するシステムの開発者はMCPに対応することによって、MCPに対応する生成AIへそのデータへのアクセスを提供することが可能になります。
わかりやすいように、AIエージェントと密結合しているツールを分離してサービスとして提供します。これによって、AIエージェントの縛りがなくなり、複数エージェントの併用などは可能になります。余談ですが、MCP自体とAIはほぼ関係がないです。

~~~python
from mcp.server.fastmcp import FastMCP
import tools

mcp = FastMCP("host info mcp")
#mcp.add_tool(tools.get_host_info)

@mcp.tool()
def get_host_info() -> str:
    import platform
    import psutil
    import subprocess
    import json
    """get host information
    Returns:
        str: the host information in JSON string
    """
    info: dict[str, str] = {
        "system": platform.system(),
        "release": platform.release(),
        "machine": platform.machine(),
        "processor": platform.processor(),
        "memory_gb": str(round(psutil.virtual_memory().total / (1024**3), 2)),
    }

    cpu_count = psutil.cpu_count(logical=True)
    if cpu_count is None:
        info["cpu_count"] = "-1"
    else:
        info["cpu_count"] = str(cpu_count)
    
    try:
        cpu_model = subprocess.check_output(
            ["sysctl", "-n", "machdep.cpu.brand_string"]
        ).decode().strip()
        info["cpu_model"] = cpu_model
    except Exception:
        info["cpu_model"] = "Unknown"

    return json.dumps(info, indent=4)

def main():
    mcp.run("stdio") # sse

if __name__ == "__main__":
    main()
~~~

## Docker ##

[model-runner](https://docs.docker.com/ai/model-runner/)

### Docker model runner ###

~~~powershell
.\.venv\Scripts\activate
pip install -U uv
uv init
uv add langchain
uv add langchain_openai 
uv add "langchain[google-genai]" 

~~~

## Hugging Face ##

[deepsex](https://huggingface.co/TheBloke/deepsex-34b-GGUF?not-for-all-audiences=true)
[open_clip](https://huggingface.co/docs/hub/open_clip)
[sentence-transformers](https://huggingface.co/sentence-transformers)
[Vision Transformer](https://huggingface.co/docs/transformers/model_doc/vit)
[SuperClaude v3](https://github.com/SuperClaude-Org/SuperClaude_Framework)

## Vector Database ##

[pgvector](https://github.com/pgvector/pgvector)
[chromadb](https://github.com/chroma-core/chroma)

## GUI ##

[Streamlit vs Gradio in 2025: AIアプリフレームワークとしての比較](https://www.squadbase.dev/ja/blog/streamlit-vs-gradio-in-2025-a-framework-comparison-for-ai-apps)
[Streamlit vs Gradio：PythonでWebアプリ開発に最適なフレームワークの比較](https://eusi.jp/streamlit-vs-gradio%EF%BC%9Apython%E3%81%A7web%E3%82%A2%E3%83%97%E3%83%AA%E9%96%8B%E7%99%BA%E3%81%AB%E6%9C%80%E9%81%A9%E3%81%AA%E3%83%95%E3%83%AC%E3%83%BC%E3%83%A0%E3%83%AF%E3%83%BC%E3%82%AF%E3%81%AE/)

## Supported Models ##

- [vllm](https://docs.vllm.ai/en/latest/models/supported_models.html#text-generation)
- [llama.cpp](https://github.com/ggml-org/llama.cpp/discussions/5141)
- [litellm](https://docs.litellm.ai/docs/providers)
  - [LiteLLM supports all models on VLLM](https://docs.litellm.ai/docs/providers/vllm)
- [langchain](https://python.langchain.com/docs/integrations/llms/)
  - [langchain-litellm](https://python.langchain.com/docs/integrations/providers/litellm/)
  - [langchain-vllm](https://docs.vllm.ai/en/v0.9.1/serving/integrations/langchain.html)
  - [langchain-llamacpp](https://python.langchain.com/docs/integrations/llms/llamacpp/)
