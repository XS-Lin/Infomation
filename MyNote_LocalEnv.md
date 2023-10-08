# ローカル試験環境 #

## Main ##

### 開発環境 ###

#### JAVA ####

~~~powershell
# 環境変数確認
$Env:USERPROFILE
$Env:JAVA_HOME
$Env:GRADLE_HOME
# PATHに追加 %JAVA_HOME%\bin;%GRADLE_HOME%\bin;
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\tools\jdk\corretto_aws\jdk17.0.8_8', 'User')
[Environment]::SetEnvironmentVariable('GRADLE_HOME', 'C:\tools\gradle\gradle-8.3', 'User')

~~~

* [VisualVM](https://visualvm.github.io/download.html)
  * [getting start](https://visualvm.github.io/gettingstarted.html)

~~~powershell
E:\tool\visualvm_217\bin\visualvm.exe --jdkhome "$Env:JAVA_HOME" --userdir "C:\Temp\visualvm_userdir"
~~~


#### Go lang ####

* go 1.21.2
  * 環境変数PATHに追加 `%USERPROFILE%\go\bin;`


#### Python ####

* Python 3.11
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python311`
* Python 3.12
  * `%USERPROFILE%\AppData\Local\Programs\Python\Python312`

~~~powershell
# common
cd $Env:USERPROFILE\AppData\Local\Programs\Python\Python312\Scripts
.\pip install numpy scipy pandas notebook matplotlib seaborn
.\pip install selenium openpyxl avro graphviz 

# venv
$Env:USERPROFILE\AppData\Local\Programs\Python\Python312\python.exe -m venv venv
pip install google-cloud-bigquery google-cloud-spanner google-cloud-core google-cloud-dataflow google-cloud-kms google-cloud-logging
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

* Docker Engine v20.10.21
* Kubernetes v1.25.2
* Images
  * jupyter/datascience-notebook:2023-08-14
  * apache/airflow:slim-2.7.1-python3.11
  * gitlab/gitlab-ce:16.3.5-ce.0
  * postgres:16.0-bookworm
  * mysql:8.1.0-oracle

~~~powershell
# 開発環境共有ネット
docker network create --driver=bridge application_net
~~~

~~~powershell
docker pull jupyter/datascience-notebook:2022-12-15
$work_folder="d:\Site\MyScript\python_test\data_science\datascience-notebook"
docker run -it --network application_net --name my_data_science_notebook -p 8888:8888 -v ${work_folder}:/home/jovyan/work jupyter/datascience-notebook:2022-12-15

# コンテナ停止・起動
docker stop my_data_science_notebook
docker start my_data_science_notebook
~~~

~~~powershell
docker pull mysql:8.0.31
# コンテナ作成
docker run --network application_net --name mysql_instance_1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Password0 -d mysql:8.0.31
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
docker run -it --network application_net --rm mysql:8.0.31 mysql -h mysql_instance_1 -u admin -p
~~~

[Nvdia TensorFlow](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow)
[NGC Catalog User Guide](https://docs.nvidia.com/ngc/gpu-cloud/ngc-catalog-user-guide/index.html)


~~~powershell

~~~

#### IDE ####

* VS Code
* Visual Studio Community 2022

#### other ####

* Blender
  * 3.6.4
* Unreal Engine
  * 5.3
* [Wireshark](https://www.wireshark.org/download.html)
  * 4.0.10
* [owasp zap](https://www.zaproxy.org/download/)
  * 2.13.0
* [pgAdmin](https://www.pgadmin.org/download/pgadmin-4-windows/)
  * 7.4
* [Graphviz](https://graphviz.org/)
  * 9.0.0
    * $Env:GRAPHVIZ_HOME="E:\tool\graphviz\windows_10_msbuild_Release_graphviz-9.0.0-win32\Graphviz"

### 開発環境 WSL2 ###

#### 環境設定 ####

* TensorFlow
  1. Windows11 WSL2
  2. NVIDIA GPU driver
  3. CUDA Toolkit
  4. cuDNN SDK
  5. (Optional) TensorRT

~~~bash
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

## 更新履歴 ##

----
2023/10/08

~~~python
>>> import tensorflow as tf
#2023-10-08 12:55:26.729293: I tensorflow/core/util/port.cc:111] oneDNN custom operations are on. You may see slightly different numerical results due to #floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
#2023-10-08 12:55:26.924816: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
#2023-10-08 12:55:27.824508: E tensorflow/compiler/xla/stream_executor/cuda/cuda_dnn.cc:9342] Unable to register cuDNN factory: Attempting to register factory for #plugin cuDNN when one has already been registered
#2023-10-08 12:55:27.824547: E tensorflow/compiler/xla/stream_executor/cuda/cuda_fft.cc:609] Unable to register cuFFT factory: Attempting to register factory for #plugin cuFFT when one has already been registered
#2023-10-08 12:55:27.828490: E tensorflow/compiler/xla/stream_executor/cuda/cuda_blas.cc:1518] Unable to register cuBLAS factory: Attempting to register factory for #plugin cuBLAS when one has already been registered
#2023-10-08 12:55:28.330260: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
#2023-10-08 12:55:28.334381: I tensorflow/core/platform/cpu_feature_guard.cc:182] This TensorFlow binary is optimized to use available CPU instructions in #performance-critical operations.
#To enable the following instructions: AVX2 AVX_VNNI FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
#2023-10-08 12:55:38.027499: W tensorflow/compiler/tf2tensorrt/utils/py_utils.cc:38] TF-TRT Warning: Could not find TensorRT
>>> tf.sysconfig.get_build_info()
#OrderedDict([('cpu_compiler', '/usr/lib/llvm-16/bin/clang'), ('cuda_compute_capabilities', ['sm_35', 'sm_50', 'sm_60', 'sm_70', 'sm_75', 'compute_80']), #('cuda_version', '11.8'), ('cudnn_version', '8'), ('is_cuda_build', True), ('is_rocm_build', False), ('is_tensorrt_build', True)])
~~~

[cuda_version問題](https://stackoverflow.com/questions/75614728/cuda-12-tf-nightly-2-12-could-not-find-cuda-drivers-on-your-machine-gpu-will)
tensorflowがcuda12.2,cudnn8.9対応待ち。
