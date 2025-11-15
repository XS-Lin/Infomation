# MyNote_AI_voice #

## Common ##

## voice cloning ##

[OpenVoice 2](https://huggingface.co/myshell-ai/OpenVoiceV2)

## 環境構築 ##

~~~bash
mkdir -p /mnt/e/tool/python313_for_wsl2_project_x
cd /mnt/e/tool/python313_for_wsl2_project_x
python3.13 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install uv
uv init
uv add yt-dlp

# os に変換ツール追加
sudo apt update
sudo apt install ffmpeg
ffmpeg -version

# os にlib追加, [No module named '_bz2']の対応pythonの環境作成が必要
sudo apt-get install libbz2-dev

# os にlib追加, [No module named '_sqlite3']の対応pythonの環境作成が必要
sudo apt-get install libsqlite3-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev libssl-dev tcl-dev tk-dev libreadline-dev

# 環境音、クローン対象以外の音声除去
#   Spleeter (AI音源分離) pip install spleeter, TensorFlowベース
#   Demucs (AI音源分離) pip install -U demucs, PyTorchとPython環境が必要
#   Audacity (デスクトップアプリ)手動編集

# download (-k でオリジナルを保持)
yt-dlp -x --audio-format wav -P ./reference_audio -o "Sayla_Mass.%(ext)s" https://www.youtube.com/watch?v=y4ef24DBeX0&list=PLB8nIpVmuKQ3nREoAzJWjY8RrXTKrPof0

# 
~~~

~~~bash
# OpenVoice2 インストール
#  Python 3.9
#  sudo apt purge python3.9
wget https://www.python.org/ftp/python/3.9.25/Python-3.9.25.tgz
tar -xf Python-3.9.25.tgz
cd Python-3.9.25/
./configure --enable-optimizations
make -j 8
sudo make altinstall
python3.9 --version

cd ..
python3.9 -m venv .venv
. .venv/bin/activate
cd OpenVoice
pip install -e .
pip install git+https://github.com/myshell-ai/MeloTTS.git
python -m unidic download

pip install faster-whisper # [No module named 'faster_whisper']の対応
pip install whisper_timestamped # [No module named 'whisper_timestamped']

# module 'botocore.exceptions' has no attribute 'HTTPClientError'
#  https://github.com/myshell-ai/MeloTTS/issues/118
pip install botocore==1.34.88 cached_path==1.6.2

pip install wavmark # [No module named 'wavmark']

~~~
