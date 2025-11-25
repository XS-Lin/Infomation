# Julesでアプリ生成結果 #

[生成結果 github](https://github.com/XS-Lin/Jules_test)

## 補足 ##

- 設定ファイルに、Gemini APIキーとpgvectorの接続を指定
- novel_generator.pyの38行の使えなくなった gemini-1.5-pro を gemini-2.5-flash に変更
- 最新のpythonでは依存関係が壊れるため、python 3.11 で実行

~~~powershell
py -3.11 -m venv .venv
. .venv\Scripts\activate
pip install -r requirements.txt
streamlit run app.py
~~~
