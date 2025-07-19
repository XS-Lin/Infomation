# ローカル試験環境 #

## Main ##

### 参考資料 ###

[powershell about_Operators](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.3)
[OpenCV](https://opencv.org/)

### 開発環境 ###

### 環境変数 ###

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
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\tools\jdk\corretto_aws\jdk17.0.8_8', 'User')
[Environment]::SetEnvironmentVariable('GRADLE_HOME', 'C:\tools\gradle\gradle-8.13', 'User')
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\tools\jdk\oracle\jdk-23.0.2', 'User')
~~~

* [VisualVM](https://visualvm.github.io/download.html)
  * [getting start](https://visualvm.github.io/gettingstarted.html)

~~~powershell
C:\tools\visualvm\visualvm_2110\bin\visualvm.exe --jdkhome "$Env:JAVA_HOME" --userdir "C:\Temp\visualvm_userdir"
~~~

#### Go lang ####

~~~powershell
# バージョン確認
go version # go1.24.2 windows/amd64

# 環境変数確認
go env
~~~

#### Python ####

* Python 3.12
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python312`
* Python 3.13
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python313`

~~~powershell
# バージョン確認
py -V
py --list
py -3.11 -V 

# pipサンプル
pip --python=<env> install <package>
pip config set global.require-virtualenv true

# ----- 2025/03/14 ----------------
py -3.11 -V # Python 3.11.9

# ----- 2025/04/19 ----------------
py -3.12 -V # Python 3.12.10
# common
py -3.12 -m pip install numpy scipy scikit-learn pandas matplotlib seaborn keras
py -3.12 -m pip install tensorflow tensorflow_datasets tf_keras
py -3.12 -m pip install google-cloud-bigquery google-cloud-spanner google-cloud-core google-cloud-kms google-cloud-logging
py -3.12 -m pip install pydot tqdm 
py -3.12 -m pip install kfp docker # kubeflow, not work in Windows 
py -3.12 -m pip avro graphviz 
py -3.12 -m venv venv

# ----- 2025/04/19 ----------------
py -V # Python 3.13.3
# common 
py -m pip install google-cloud-bigquery google-cloud-spanner google-cloud-core google-cloud-kms google-cloud-logging google-cloud-dataflow-client
py -m pip install numpy scipy pandas matplotlib seaborn scikit-learn
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

* Docker Desktop 4.40.0 (187762)

~~~powershell
# 開発環境共有ネット
docker network create --driver=bridge application_net
~~~

~~~powershell
# docker pull jupyter/datascience-notebook:2022-12-15
# docker pull quay.io/jupyter/datascience-notebook:2024-06-10
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
#### 2025-03-22
docker pull gitlab/gitlab-ce:17.10.0-ce.0

~~~

~~~powershell
#### 2025-03-22
docker pull postgres:17.4-bookworm

~~~

~~~powershell
#### 2025-03-22
docker pull mysql:8.0.41-bookworm

#### 2024-06 DELETED ####
# docker pull mysql:8.0.31
docker pull mysql:8.0.37-debian
# コンテナ作成
docker run --network application_net --name mysql_instance_1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Password0 -d mysql:8.0.37-debian
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
docker run -it --network application_net --rm mysql:8.0.37-debian mysql -h mysql_instance_1 -u admin -p

~~~

[Nvdia TensorFlow](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow)
[NGC Catalog User Guide](https://docs.nvidia.com/ngc/gpu-cloud/ngc-catalog-user-guide/index.html)

~~~powershell

~~~

#### IDE ####

* VS Code
* Visual Studio Community 2022
* IntelliJ

### 開発環境 WSL2 ###

~~~powershell
wsl -l -v # インストール済み
#  NAME              STATE           VERSION
#* Ubuntu            Running         2
#  docker-desktop    Running         2
wsl -l -o # オンラインで利用可能なものを確認
# AlmaLinux-Kitten-10
# Debian
# SUSE-Linux-Enterprise-15-SP6
# Ubuntu-24.04
# openSUSE-Leap-15.6
# OracleLinux_9_1
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
sudo apt update
sudo apt install software-properties-common
sudo apt install python3.11-full
sudo apt install bpfcc-tools

python3.11 -m venv venv
cd venv
. ./bin/activate
pip install bcc
pip install numba
python test.py
~~~

~~~bash
# 2024/12/07
# CUDA 更新後、Tensorflow-gpu認識確認
nvidia-smi # NVIDIA-SMI 565.51.01              Driver Version: 566.36         CUDA Version: 12.7
cd /mnt/e/tool/python_for_wsl2
. python311_venv/bin/activate 
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))" # [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
deactivate
~~~

#### 環境設定 LLM ####

* vllm

~~~bash
# 2025/07/15
sudo apt update
# https://launchpad.net/~deadsnakes
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.12-full
sudo apt install python3.12-dev # Python.h: No such file or directory エラー対応
pip install --upgrade pip

cd /mnt/e/tool/python_for_wsl2_vllm
python3.12 -m venv venv
. ./venv/bin/activate
pip install vllm --extra-index-url https://download.pytorch.org/whl/cu128 # vllm-0.9.2
# pip install vllm --torch-backend=auto
pip install 'apache-beam[gcp]' # apache-beam-2.66.0
pip install pytest pytest-cov # pytest-8.4.1 pytest-cov-6.2.1
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
~~~

* uv
  * [uv](https://docs.astral.sh/uv/guides/)

~~~bash
# 2025/07/16
# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
~~~

* streamlit
  * [streamlit](https://docs.streamlit.io/)
    * Cloud Shell で直接起動の時に --server.enableCORS=false オプションをつけると画面が表示できる

~~~bash

~~~

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
~~~

#### 環境設定 for Google Cloud ####

[Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

~~~bash
# 2025/07/17
terraform --version # Terraform v1.12.2
~~~

### 開発環境 Docker ###

#### Docker Desktop ####

* [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
  * [2025/07/17] Docker Desktop 4.43.1 (198352)

#### 環境設定 ####

[Docker Model Runner](https://docs.docker.com/ai/model-runner/)
[Docker MCP Catalog and Toolkit](https://docs.docker.com/ai/mcp-catalog-and-toolkit/)

* vLLM
  * [Using Docker](https://docs.vllm.ai/en/latest/deployment/docker.html#use-vllms-official-docker-image)
  * [chat_templates](https://github.com/chujiezheng/chat_templates/tree/main/chat_templates)

~~~powershell
# 
docker pull vllm/vllm-openai:v0.9.2
$HUGGING_FACE_HUB_TOKEN=$(Get-Content E:\project\docker_volume\vllm-storage\huggingface\token.txt)
# 再利用しない場合は --rm
docker run -it --name=vllm-worker-mistralai-Mistral-7B --runtime=nvidia --gpus=all -p 8001:8000 --ipc=host --mount type=bind,src=E:\project\docker_volume\vllm-storage\huggingface,dst=/root/.cache/huggingface --env "HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN" vllm/vllm-openai:v0.9.2 --model mistralai/Mistral-7B-v0.1

# chat_template が正しくない
$postText = @{
  messages=@(@{role="user"; content="Who is the Prime Minister of Japan?"})
  chat_template="
{% if messages[0]['role'] == 'system' %}
    {% set system_message = messages[0]['content'] | trim + '<|end_of_turn|>' %}
    {% set messages = messages[1:] %}
{% else %}
    {% set system_message = '' %}
{% endif %}

{{ bos_token + system_message }}
{% for message in messages %}
    {% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}
        {{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}
    {% endif %}

    {{ 'GPT4 Correct ' + message['role'] | capitalize + ': ' + message['content'] + '<|end_of_turn|>' }}
{% endfor %}

{% if add_generation_prompt %}
    {{ 'GPT4 Correct Assistant:' }}
{% endif %}
"  
} | ConvertTo-Json -Compress
$postBody = [Text.Encoding]::UTF8.GetBytes($postText)
$postUri = "http://localhost:8001/v1/chat/completions"
Invoke-RestMethod -Method POST -Uri $postUri -Body $postBody -ContentType application/json
~~~

* datascience
  * [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
  * [Selecting an Image](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)

~~~powershell
# 
docker pull quay.io/jupyter/datascience-notebook:2025-07-14
# 再利用しない場合は --rm
docker run -it -p 8888:8888 -v E:\project\datascience\train\LearnPython\data_science\datascience-notebook:/home/jovyan/work quay.io/jupyter/datascience-notebook:2025-07-14
# Tokenは毎回起動の時に変わため、コンソールから確認
# http://127.0.0.1:10000/lab?token=2cfea28b8c1c367c8244c652e1d2676b181e53273f84524e
~~~

* tensorflow
  * [Selecting an Image](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html)

~~~powershell
# 
docker pull quay.io/jupyter/tensorflow-notebook:cuda-2025-07-14
# 再利用しない場合は --rm
docker run -it --runtime=nvidia --gpus=all --name=tensorflow-worker -p 8888:8888 --mount type=bind,src=E:\project\docker_volume\tensorflow-notebook-storage,dst=/home/jovyan/work quay.io/jupyter/tensorflow-notebook:cuda-2025-07-14
# Tokenは毎回起動の時に変わため、コンソールから確認
# http://127.0.0.1:8888/lab?token=2c7cb5210a5580f80d5637fb0e68e068ca99ebf332869106
~~~

## other main tools ##

* [Blender](https://www.blender.org/download/)
  * [2025/07/16]  4.5.0
* Unreal Engine
  * 5.4.2
* [Wireshark](https://www.wireshark.org/download.html)
  * [2025/07/16]  4.4.7 x64
* [owasp zap](https://www.zaproxy.org/download/)
  * [2025/07/16] ZAP 2.16.1
* [DBeaver](https://dbeaver.io/download/)
  * [2025/07/16] 25.1.2
* [Graphviz](https://graphviz.org/)
  * [2025/07/16] Graphviz-13.1.0-win64
* [gcloud CLI](https://cloud.google.com/sdk/docs/install?hl=ja)
  * [2025/07/16] Google Cloud SDK 530.0.0
* GitHub Desktop
  * [2025/07/16] Version 3.5.1 (x64)
* [CMake](https://cmake.org/download/)
  * [2025/07/16] 4.1.0-rc1
* [OpenCV](https://docs.opencv.org/4.x/d3/d52/tutorial_windows_install.html)
  * [2025/07/16] 4.12.0
  * [2025/07/16] 3.4.16
* [CUDA Toolkit 12.9](https://developer.nvidia.com/cuda-downloads)
  * [2025/07/17] 12.9

~~~powershell
# PATHに追加
# '%CUDA_PATH%;%JAVA_HOME%\bin;%GRADLE_HOME%\bin;%GRAPHVIZ_HOME%\bin;%USERPROFILE%\go\bin'

# ツール格納先
# C:\tools

# Graphviz
[Environment]::SetEnvironmentVariable('GRAPHVIZ_HOME', 'C:\tools\graphviz\Graphviz-13.1.0-win64', 'User')

# gcloud CLI
gcloud components update

# git
git update-git-for-windows # curl: (43) A libcurl function was given a bad argument
~~~

~~~powershell
# 2025/07/17
# Nvidia
nvidia-smi # NVIDIA-SMI 576.88 Driver Version: 576.88 CUDA Version: 12.9
nvcc -V # Cuda compilation tools, release 12.9, V12.9.86
~~~

## 設定問題のメモ ##

[cuda_version問題](https://stackoverflow.com/questions/75614728/cuda-12-tf-nightly-2-12-could-not-find-cuda-drivers-on-your-machine-gpu-will)
tensorflowがcuda12.2,cudnn8.9対応待ち。
