# LLM #

## 概要 ##

[youtube LLM](https://www.youtube.com/andrejkarpathy)

### 基本 ###

[大規模言語モデル](https://ja.wikipedia.org/wiki/%E5%A4%A7%E8%A6%8F%E6%A8%A1%E8%A8%80%E8%AA%9E%E3%83%A2%E3%83%87%E3%83%AB)

明確な定義はまだないですが、わかりやすくいうと、確率に基づいてテキストを生成するシステムです。

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

~~~python


~~~

## MCP ##

[Model Context Protocol](https://nshipster.com/model-context-protocol/)
[MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture)
[context7](https://github.com/upstash/context7)
[データベース向け MCP ツールボックス](https://cloud.google.com/blog/ja/products/ai-machine-learning/mcp-toolbox-for-databases-now-supports-model-context-protocol)
[wiki Model Context Protocol](https://ja.wikipedia.org/wiki/Model_Context_Protocol#cite_note-TheVerge20241125-2)
[zenn Model Context Protocol（MCP）とは？生成 AI の可能性を広げる新しい標準](https://zenn.dev/cloud_ace/articles/model-context-protocol)

AIアシスタントなどの生成AIがデータの存在するシステムに対して接続可能にするためのプロトコルであり、データを保有するシステムの開発者はMCPに対応することによって、MCPに対応する生成AIへそのデータへのアクセスを提供することが可能である。

~~~python


~~~

## Docker ##

[model-runner](https://docs.docker.com/ai/model-runner/)

## Hugging Face ##

[deepsex](https://huggingface.co/TheBloke/deepsex-34b-GGUF?not-for-all-audiences=true)
[open_clip](https://huggingface.co/docs/hub/open_clip)
[sentence-transformers](https://huggingface.co/sentence-transformers)
[Vision Transformer](https://huggingface.co/docs/transformers/model_doc/vit)
[SuperClaude v3](https://github.com/SuperClaude-Org/SuperClaude_Framework)

## Vector Database ##

[pgvector](https://github.com/pgvector/pgvector)
[chromadb](https://github.com/chroma-core/chroma)