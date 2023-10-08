# AI #

## local ##

C:\Users\linxu\AppData\Local\Programs\Python\Python310\

## tensorflow ##

### Setting ###

[tensorflow install](https://www.tensorflow.org/install/pip)
[tensorflow テスト済みのビルド構成](https://www.tensorflow.org/install/source?hl=ja#gpu)

~~~powershell
# python3.11 only support tensorflow 2.12+
# Anything above 2.10 is not supported on the GPU on Windows Native

cd C:\Users\linxu\AppData\Local\Programs\Python\Python310\
.\python.exe -m pip install "tensorflow<2.11" 

# 環境変数に設定済み
$env:CUDA_PATH = "C:\tools\cudnn\cudnn-8.6_cuda11\cudnn\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\include;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\extras\CUPTI\lib64;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\bin;"
$env:PATH = $env:CUDA_PATH+$env:PATH

# 以下の任意コマンドでtensorflow設定確認可能
.\python.exe -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
.\python.exe -c 'from tensorflow.python.client import device_lib; print(device_lib.list_local_devices())'
.\python.exe -c "import tensorflow as tf; print('Num GPUs Available: ', len(tf.config.list_physical_devices('GPU')))"
~~~
