# Python 門外から初心者までの道 #

## Pythonとは ##

Pythonは「少ないコード量（文量）で簡単にプログラムがかける」「コードが読みやすい」といったメリットのあるプログラミング言語です。今話題の「人工知能(AI)」や「Web開発」、「教育の分野」など広い分野で使われています。

[ダウンロード](https://www.python.org/downloads/)

## Pythonの実行 ##

インストールが終わったら、Pythonの実行環境を試しましょう。
まずは任意テキストエディタを開いて、「print("hello world")」を入力し、ファイル名は「test.py」として保存してください。

コマンドプロンプトで「py test.py」で「Enter」キーを押すと、次の行に「"hello world"」が表示されるはずです。
この「py ファイル名.py」はPythonファイルの実行です。

Pythonをファイルにまとめず、一行ずつ実行もできます。(一行ずつ実行はインタプリタといいます。)
インタプリタを起動するにはコマンドプロンプトで「py」だけでできます。

コマンドプロンプトで「py」実行すると、「>>>」が表示されます。これはPythonの受け入れ準備ができだという意味です。
ここで、「print("hello world")」を入力し、「Enter」キーを押すと、次の行に「"hello world"」が表示されます。

## Pythonでプログラムを作るための最低限の知識 ##

1. 変数定義

   ~~~python
   a = 3
   x = 5
   s = 'name'
   ~~~

1. 数値の演算

   ~~~python
   1 + 2 + 3 + 4 + 5
   2 * 3
   3 ** 2
   1.0 - 2.5
   ~~~

1. 文字列操作

   ~~~python
   print("hello world" + "!")
   ~~~

1. 関数定義

   ~~~python
   def testF(p):
       return p + 1
   ~~~

1. 入力と出力

   1. 出力

      ~~~python
      print("hello world")
      ~~~

   1. 入力

      ~~~python
      import sys
      print('sys.argv[0]      : ', sys.argv[0])
      ~~~

      ~~~python
      val = input()
      print(val)
      ~~~

## Pythonのドキュメント ##

[ここから始めましょう](https://docs.python.org/ja/3/tutorial/index.html)
