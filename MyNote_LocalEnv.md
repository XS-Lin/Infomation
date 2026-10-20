# ローカル試験環境 #

## Main ##

### 参考資料 ###

[powershell about_Operators](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.3)

### 開発環境 ###

#### 環境変数 ####

* PATHに以下を追加

~~~powershell
%CUDA_PATH%
%JAVA_HOME%\bin
%GRADLE_HOME%\bin
%GRAPHVIZ_HOME%\bin
%USERPROFILE%\go\bin
~~~

#### JAVA ####

~~~powershell
# バージョン確認
java --version

# 環境変数確認
$Env:JAVA_HOME
$Env:GRADLE_HOME
# PATHに追加 %JAVA_HOME%\bin;%GRADLE_HOME%\bin;
#[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\tools\jdk\corretto_aws\jdk17.0.8_8', 'User')
[Environment]::SetEnvironmentVariable('GRADLE_HOME', 'C:\tools\gradle\gradle-9.8.1', 'User')
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\tools\jdk\oracle\jdk-27', 'User')
~~~

* [VisualVM](https://visualvm.github.io/download.html)
  * [getting start](https://visualvm.github.io/gettingstarted.html)

~~~powershell
C:\tools\visualvm\visualvm_22\bin\visualvm.exe --jdkhome "$Env:JAVA_HOME" --userdir "C:\Temp\visualvm_userdir"
~~~

#### Go lang ####

~~~powershell
# 環境変数確認
go env

# ----- 2026/10/17 ----------------
# バージョン確認
go version # go version go1.27.2 windows/amd64
~~~

#### Python ####

* Python 3.12
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python312`
* Python 3.13
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python313`
* Python 3.14
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python314`

~~~powershell
# pipサンプル
pip --python=<env> install <package>
pip config set global.require-virtualenv true

# ----- 2026/10/17 ----------------
py --list # 3.12 ~ 3.15
py -V # Python 3.15.0
py -3.14 -V # Python 3.14.8
py -3.13 -V # Python 3.13.16
py -3.12 -V # Python 3.12.10
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
[github pgvector](https://github.com/pgvector/pgvector?tab=readme-ov-file#docker)
[hub pgvector](https://hub.docker.com/r/pgvector/pgvector/tags)
[Nvdia TensorFlow](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow)
[NGC Catalog User Guide](https://docs.nvidia.com/ngc/gpu-cloud/ngc-catalog-user-guide/index.html)

~~~powershell
# ----- 2026/10/17 ----------------
* Docker Desktop 4.95.0
~~~

~~~powershell
# 開発環境共有ネット
docker network create --driver=bridge application_net
~~~

~~~powershell
docker pull quay.io/jupyter/datascience-notebook:2024-11-19
$work_folder="E:\project\datascience\train\LearnPython\data_science\datascience-notebook"
docker run -it --network application_net --name my_data_science_notebook_v20241119 -p 8888:8888 -v ${work_folder}:/home/jovyan/work quay.io/jupyter/datascience-notebook:2024-11-19

# コンテナ停止・起動
docker stop my_data_science_notebook_v20241119
docker start my_data_science_notebook_v20241119

# コンテナ接続とライブラリインストール（イメージ変更しない前提、docker停止の時には消える）
docker exec -it my_data_science_notebook_v20241119 /bin/bash # default user: jovyan
docker exec -it --user root my_data_science_notebook_v20241119 /bin/bash # default user: root
apt update
apt install graphviz
~~~

~~~powershell
# https://hub.docker.com/r/gitlab/gitlab-ce/docker pull gitlab/gitlab-ce:18.7.5-ce.0
# ----- 2026/10/17 ----------------
docker pull gitlab/gitlab-ce:19.5.0-ce.0
~~~

~~~powershell
# https://hub.docker.com/r/pgvector/pgvector
# ----- 2026/10/17 ----------------
docker pull pgvector/pgvector:0.8.7-pg18-trixie
docker run -it --network application_net -e POSTGRES_USER=test_u -e POSTGRES_PASSWORD=test_p -e POSTGRES_DB=test_db --name test_pgvector_db -p 5432:5432 --mount type=bind,source=E:\tool\postgresql_dir\for_docker_postgresql16_pgvector,target=/var/lib/postgresql/ pgvector/pgvector:0.8.7-pg18-trixie
~~~

~~~sql
CREATE EXTENSION vector;
CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3));
INSERT INTO items (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
SELECT * FROM items ORDER BY embedding <-> '[3,1,2]' LIMIT 5;
~~~

#### IDE ####

* Antigravity
* VS Code
* Visual Studio Community 2026

### 開発環境 WSL2 ###

~~~powershell
# ----- 2025/10/12 ----------------
wsl -l -v # インストール済み
#  NAME              STATE           VERSION
#* Ubuntu            Running         2
#  docker-desktop    Running         2
wsl -l -o # オンラインで利用可能なものを確認
# AlmaLinux-Kitten-10
# Debian
# Ubuntu-24.04
wsl.exe --install -d <Distribution Name>
wsl --status
# 既定のディストリビューション: Ubuntu
# 既定のバージョン: 2
wsl --version
wsl --help
wsl --user <Username>
<DistributionName> config --default-user <Username>

wsl --set-default <Distribution Name>
wsl ~ # ディレクトリをホームに変更する
cd ~

wsl --update
~~~

~~~powershell
# ----- 2025/10/12 ----------------
wsl --uninstall Ubuntu-22.04
wsl --unregister Ubuntu-22.04
wsl --install Ubuntu-24.04
# Ubuntu-24.04 linxs/local
wsl -l -v
#   NAME              STATE           VERSION
# * Ubuntu-24.04      Stopped         2
#   Ubuntu            Stopped         2
#   docker-desktop    Stopped         2
~~~

#### 環境設定 TensorFlow ####

* TensorFlow
  1. Windows11 WSL2
  2. NVIDIA GPU driver
  3. CUDA Toolkit
  4. cuDNN SDK
  5. (Optional) TensorRT

~~~bash
# 2023/10/08
# linxs/local
sudo apt-get update
sudo apt update
sudo apt list --upgradable

apt-get upgrade # 現在システムにインストールされている全パッケージ(/etc/apt/sources.list)の最新バージョンに更新※削除はしない、追加インストールしない
apt-get dist-upgrade # upgradeに加えて、依存関係も変更※削除、追加あり
apt upgrade # sources.list(5)からシステムに現在インストール済みのすべてのパッケージで利用可能なアップグレードをインストール※追加あり、削除しない
apt full-upgrade # upgradeに加えて、システム全体をアップグレードする※削除あり

uname -a #Linux PC-LIN-MAIN 5.15.90.1-microsoft-standard-WSL2 #1 SMP Fri Jan 27 02:56:13 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
lsb_release -d # Description:    Ubuntu 22.04.3 LTS

# tool set for source code install
sudo apt-get install build-essential

# https://www.tensorflow.org/install/pip
# https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_network
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda

/usr/local/cuda/extras/demo_suite/deviceQuery # deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 12.2, CUDA Runtime Version = 12.2, NumDevs = 1, Device0 = NVIDIA GeForce RTX 4090

nvidia-smi # Segmentation fault , success after reboot

# WSL2 再起動
wsl --shutdown # すべて影響
wsl --terminate Ubuntu # 指定したディストリビューションを終了
nvidia-smi # 再起動後正常表示 NVIDIA-SMI 535.112                Driver Version: 537.42       CUDA Version: 12.2

# cuDNN
#   https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html
#     https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html
#     1. GPU, CUDA Toolkit, and CUDA Driver Requirements
#       CUDA Toolkit Version: 12.2=12.2 OK
#       Driver Version:       537.42>=527.41 OK
#     2. CPU Architecture and OS Requirements
#       Architecture: x86_64=x86_64 OK
#       OS:           Ubuntu 22.04.3=22.04 OK
#       Kernel:       5.15.90>=5.15.0 OK
#       GCC:          11.2.0 != 11.4.0 NG
#       Glibc:        2.35=2.35 OK
gcc --version # gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
ldd --version # ldd (Ubuntu GLIBC 2.35-0ubuntu3.4) 2.35

# 1.1.3. Installing Zlib 
apt list --installed | grep zlib1g # すでにインストール済み
# sudo apt-get install zlib1g

# 1.3.2. Debian Local Installation
sudo dpkg -i /mnt/e/tool/cuDNN/cudnn-local-repo-ubuntu2204-8.9.5.29_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-*/cudnn-local-*-keyring.gpg /usr/share/keyrings/
sudo apt update
sudo apt-get install libcudnn8=8.9.5.29-1+cuda12.2 
sudo apt-get install libcudnn8-dev=8.9.5.29-1+cuda12.2
sudo apt-get install libcudnn8-samples=8.9.5.29-1+cuda12.2
# check avilable if not found
apt-cache search libcudnn8 # libcudnn8 - cuDNN runtime libraries ...
apt list -a libcudnn8 # libcudnn8/unknown 8.9.5.29-1+cuda12.2 amd64
# test

cd /tmp
cp -r /usr/src/cudnn_samples_v8/ .
make clean && make # test.c:1:10: fatal error: FreeImage.h: No such file or directory  1 | #include "FreeImage.h"
sudo apt -y install libfreeimage3 libfreeimage-dev
make
./mnistCUDNN # Test passed

# apt-cache
#   gencaches : パッケージ情報を収集、更新する
#   show <package_name> : パッケージ情報を表示する
#   showpkg <package_name> : パッケージの依存関係などを表示する
#   search <key_word> : キーワードを元にパッケージを検索する
sudo apt-cache gencaches
apt-cache search python3.11
sudo apt-get install python3.11 python3.11-venv

cd /mnt/e/tool/python_for_wsl2
/bin/python3.11 -m venv python311_venv
cd python311_venv
. bin/activate
pip install pandas matplotlib seaborn notebook
pip install tensorflow
# Verify the CPU setup
python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))" # tf.Tensor(1643.4073, shape=(), dtype=float32)
# Verify the GPU setup
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
deactivate
~~~

~~~bash
# Ubuntu-24.04
sudo apt update
sudo apt upgrade

uname -a
# Linux PC-LIN-MAIN 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
lsb_release -d
# Ubuntu 24.04.4 LTS

# ---- WSL2 NVIDIA GPU Setting
# ---- https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_local
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda-repo-wsl-ubuntu-13-2-local_13.2.1-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-13-2-local_13.2.1-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-13-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-13-2

gcc --version # gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0
ldd --version # ldd (Ubuntu GLIBC 2.39-0ubuntu8.7) 2.39

# WSL再起動 wsl --terminate Ubuntu-24.04
sudo apt install -y python3.12 python3.12-venv python3.12-dev

mkdir tensorflow_test
cd tensorflow_test
python3.12 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install tensorflow[and-cuda]

python3 -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

# uv https://docs.astral.sh/uv/guides/
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv self update
uv python list # 
uv python install 3.12 3.13 3.14 3.15 
python3.12 -V # Python 3.12.15
python3.13 -V # Python 3.13.16
python3.14 -V # Python 3.14.8
python3.15 -V # Python 3.15.0
uv venv --python 3.12
~~~

#### 環境設定 LLM ####

* vllm

~~~bash
# ----- 2025/07/15 ----------------
sudo apt update
# https://launchpad.net/~deadsnakes
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.12-full
sudo apt install python3.12-dev # Python.h: No such file or directory エラー対応

cd /mnt/e/tool/python_for_wsl2_vllm
python3.12 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install --upgrade uv
# pip install vllm --extra-index-url https://download.pytorch.org/whl/cu128 # vllm-0.9.0.1
uv pip install vllm --torch-backend=cu128
uv add 'apache-beam[gcp]' # apache-beam-2.66.0
uv add pytest pytest-cov # pytest-8.4.1 pytest-cov-6.2.1
# pip freeze > requirements.txt
vllm --help

# vLLM Sample 1
#   terminal 1
vllm serve Qwen/Qwen2.5-1.5B-Instruct
#   terminal 2
curl http://localhost:8000/v1/models
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-1.5B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }'

# vLLM Sample 2: https://github.com/vllm-project/vllm/blob/main/examples/offline_inference/basic/basic.py

# transformers
python -c "from transformers import pipeline; print(pipeline('sentiment-analysis')('we love you'))"

deactivate
~~~

* llama
  * [Required] WSL2 CUDA Toolkit
    * [2025/07/18] [WSL2 CUDA Toolkit Ubuntu](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_local)

~~~bash
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda-repo-wsl-ubuntu-12-9-local_12.9.1-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-12-9-local_12.9.1-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-12-9-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-9
# cat /var/lib/apt/lists/*cuda*Packages | grep "Package:" | grep cudart

# 2025/07/18
python3.12 -m venv .venv
uv init
. .venv/bin/activate
#CMAKE_ARGS='-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="89"' uv add llama-cpp-python
#-- Unable to find cudart library.
#-- Could NOT find CUDAToolkit (missing: CUDA_CUDART) (found version "12.9.86")
CUDACXX=/usr/local/cuda-12.9/bin/nvcc CMAKE_ARGS='-DGGML_CUDA=ON -DCUDA_PATH=/usr/local/cuda-12.9 -DCUDAToolkit_ROOT=/usr/local/cuda-12.9' uv add llama-cpp-python
uv add langchain
uv add langchain-community
~~~

* streamlit
  * [streamlit](https://docs.streamlit.io/)
    * Cloud Shell で直接起動の時に --server.enableCORS=false オプションをつけると画面が表示できる
* fastapi
  * [fastapi](https://github.com/fastapi/fastapi)

#### 環境設定 Kubeflow piplines (local docker runner) ####

~~~bash
# 2024/12/07
cd /mnt/e/tool/python_for_wsl2
. python311_venv/bin/activate 
pip install kfp docker # kubeflow
pip install google-cloud-aiplatform
pip install mysql-connector-python # mysql-connector-python-9.1.0
pip install pytest pytest-cov pytest-xdist pytest-httpserver
deactivate

gcloud auth application-default login --no-launch-browser # 認証情報作成

# ----- 2025/10/12 ----------------

~~~

#### 環境設定 for Google Cloud ####

[Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

~~~bash
# ----- 2026/10/17 ----------------
# https://developer.hashicorp.com/terraform/install
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform --version # Terraform v1.16.6
~~~

### 開発環境 Docker ###

#### Docker Desktop ####

* [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

#### 環境設定 ####

[Docker Model Runner](https://docs.docker.com/ai/model-runner/)
[Docker MCP Catalog and Toolkit](https://docs.docker.com/ai/mcp-catalog-and-toolkit/)

* vLLM
  * [Using Docker](https://docs.vllm.ai/en/latest/deployment/docker.html#use-vllms-official-docker-image)
  * [Docker Hub](https://hub.docker.com/r/vllm/vllm-openai/tags)

~~~powershell
# https://hub.docker.com/r/vllm/vllm-openai/tags
docker pull vllm/vllm-openai:cu134-nightly
$HUGGING_FACE_HUB_TOKEN=$(Get-Content E:\project\docker_volume\vllm-storage\huggingface\token.txt)
# 再利用しない場合は --rm
docker run -it --name=vllm-worker-mistralai-Mistral-7B --runtime=nvidia --gpus=all -p 8001:8000 --ipc=host --mount type=bind,src=E:\project\docker_volume\vllm-storage\huggingface,dst=/root/.cache/huggingface --env "HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN" vllm/vllm-openai:cu134-nightly --model mistralai/Mistral-7B-v0.1
~~~

* datascience
  * [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
  * [Selecting an Image](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)
    * [Image Repo list](https://quay.io/organization/jupyter)

~~~powershell
docker pull quay.io/jupyter/datascience-notebook:2026-10-12
docker run -it -p 8888:8888 --mount type=bind,src=E:\project\datascience\train\LearnPython\data_science\datascience-notebook,dst=/home/jovyan/work quay.io/jupyter/datascience-notebook:2026-10-12
~~~

* tensorflow
  * [Selecting an Image](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)
    * [Image Repo list](https://quay.io/organization/jupyter)

~~~powershell
docker pull quay.io/jupyter/tensorflow-notebook:cuda-2026-10-12
docker run -it --runtime=nvidia --gpus=all --name=tensorflow-worker -p 8888:8888 --mount type=bind,src=E:\project\docker_volume\tensorflow-notebook-storage,dst=/home/jovyan/work quay.io/jupyter/tensorflow-notebook:cuda-2026-10-12
~~~

## other main tools ##

* Unreal Engine
* [Blender](https://www.blender.org/download/)
  * [2025/12/01]  5.0.0
  * [2026/10/17]  5.2.2
* [Wireshark](https://www.wireshark.org/download.html)
  * [2025/12/01]  4.6.1 x64
  * [2026/03/07]  4.6.4 x64
  * [2026/03/07]  4.6.9 x64
* [owasp zap](https://www.zaproxy.org/download/)
  * [2025/10/12] ZAP 2.16.1
* [DBeaver](https://dbeaver.io/download/)
  * [2025/10/12] 25.2.2
  * [2026/03/07] 26.0.0
  * [2026/10/17] 26.2.2
* [Graphviz](https://graphviz.org/)
  * [2026/03/07] Graphviz-14.1.3-win64
  * [2026/10/17] Graphviz-16.1.0-win64
* [gcloud CLI](https://cloud.google.com/sdk/docs/install?hl=ja)
  * [2026/10/17] Google Cloud SDK 589.0.0
* GitHub Desktop
  * [2026/10/17] Version 3.6.7 (x64)
* [CMake](https://cmake.org/download/)
  * [2026/10/17] 4.5.0-rc1-windows-x86_64
* [OpenCV](https://docs.opencv.org/4.x/d3/d52/tutorial_windows_install.html)
  * [2025/07/16] 3.4.16
  * [2026/01/02] 4.13.0
  * [2026/10/17] 5.0.0
* [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads)
  * [2025/07/17] 12.9
  * [2026/10/17] 13.4.3
* [Drawio](https://www.drawio.com/)[download](https://github.com/jgraph/drawio-desktop/releases)
  * [2026/10/17] 32.4.1
* [Comfy Desktop](https://docs.comfy.org/ja/installation/desktop/windows)
  * [2026/10/17] v1.1.7

~~~powershell
# PATHに追加
# '%CUDA_PATH%;%JAVA_HOME%\bin;%GRADLE_HOME%\bin;%GRAPHVIZ_HOME%\bin;%USERPROFILE%\go\bin'

# Nvidia
nvidia-smi # NVIDIA-SMI 610.57.01              KMD Version: 610.88        CUDA UMD Version: 13.3
nvcc -V # Cuda compilation tools, release 12.0, V12.0.140 

# Graphviz
[Environment]::SetEnvironmentVariable('GRAPHVIZ_HOME', 'C:\tools\graphviz\Graphviz-16.1.0-win64', 'User')

# gcloud CLI
gcloud components update

# git
git update-git-for-windows # curl: (43) A libcurl function was given a bad argument
~~~
