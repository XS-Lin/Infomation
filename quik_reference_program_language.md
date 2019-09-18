# プログラミング言語のクイックリファレンス #

本文は私が勉強したすべてのプログラミング言語の要項をまとめています。
忘れそうな時に参照の目的ですので、完全な仕様書ではありません。
プログラミング言語を復習の方々にも役立つと思います。

## Python ##

[Python 3.7.4 ドキュメント](https://docs.python.org/ja/3/)

1. 定数と変数

1. 演算子

1. 分岐

1. ループ

1. 関数

1. クラス

1. 名前空間

1. 入力と出力

## Java ##

[Java SE API & ドキュメント - Oracle](https://www.oracle.com/technetwork/jp/java/javase/documentation/api-jsp-316041-ja.html)

## JavaScript ##

[ECMAScript 2019](https://www.ecma-international.org/ecma-262/10.0/index.html)

## C# ##

[C# リファレンス](https://docs.microsoft.com/ja-jp/dotnet/csharp/language-reference/)

1. 定数と変数

1. 演算子

1. 分岐

1. ループ

1. 関数

1. クラス

1. 名前空間

1. 入力と出力

## C++ ##

[Visual C++ ドキュメント | Microsoft Docs](https://docs.microsoft.com/ja-jp/cpp/?view=vs-2019#pivot=workloads&panel=workloads1)

[MicrosoftDocs/cpp-docs: C++ Documentation - GitHub](https://github.com/MicrosoftDocs/cpp-docs)

[ISOCPP](https://isocpp.org/std/the-standard)

## PowerShell ##

[PowerShell Documentation | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/)
[PowerShell 6](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/?view=powershell-6)
[PowerShell 7 preview](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/?view=powershell-7)

1. 定数と変数

   1. 定数宣言

      ~~~powshell
      Set-Variable -Name ConstData -Value "Constant Value" -Option Constant
      ~~~

   1. 変数宣言

      ~~~powshell
      $a = 1
      ~~~

   1. 変数の型

      ~~~powshell
      byte int long double decimal char bool string array xml type DateTime [Object]
      ~~~

   1. スコープ

      ~~~powshell
      scope-modifier>:
        Global
        Local
        Script
        Private
        Numbered Scopes

      $[<scope-modifier>:]<name> = <value>
      ~~~

   1. 定義済み

      ~~~powshell
      $$ Contains the last token in the last line received by the session
      $? Contains the execution status of the last operation.
      $^ Contains the first token in the last line received by the session.
      $_ Same as $PSItem. Contains the current object in the pipeline object.
      $args
      $Error
      $this
      $true
      $false
      $null
      ...
      ~~~

1. 演算子

   1. 算数演算子

      ~~~powshell
      + - * / % [Math]::Pow(x,y)
      = += -= *= /= %=
      ++ --
      -band -bor -bnot -bxor -shl -shr
      ~~~

      注意:「+」は文字列、配列、ハッシュテーブルでも使える

   1. 比較演算子

      ~~~powshell
      -eq -ne -gt -ge -lt -le
      -like -notlike -match -notmatch
      -contains -notcontains -in -notin
      -replace
      -is -isnot
      ~~~

    1.特殊演算子

      ~~~powshell
      Array subexpression operator @( )
      Call operator &
      Ampersand background operator &
      Cast operator [ ]
      Comma operator ,
      Dot sourcing operator .
      Format operator -f
      Index operator [ ]
      Pipeline operator |
      Property dereferences operator .
      Range operator ..
      Static member operator ::
      Subexpression operator $( )
      ~~~

1. 分岐

      ~~~powshell
      if (<test1>)
          {<statement list 1>}
      [elseif (<test2>)
          {<statement list 2>}]
      [else
          {<statement list 3>}]
      ~~~

1. ループ

      ~~~powshell
      for (<Init>; <Condition>; <Repeat>)
      {
          <Statement list>
      }
      ~~~

      ~~~powshell
      foreach ($<item> in $<collection>){<statement list>}
      ~~~

1. 関数

   1. スコープ

      ~~~powshell
      function [<scope:>]<name> [([type]$parameter1[,[type]$parameter2])]
      {
        param([type]$parameter1 [,[type]$parameter2])
        dynamicparam {<statement list>}
        begin {<statement list>}
        process {<statement list>}
        end {<statement list>}
      }
      ~~~

1. クラス

   1. 定義

      ~~~powshell
      class <class-name> [: [<base-class>][,<interface-list]] {
          [[<attribute>] [hidden] [static] <property-definition> ...]
          [<class-name>([<constructor-argument-list>])
            {<constructor-statement-list>} ...]
          [[<attribute>] [hidden] [static] <method-definition> ...]
      }
      ~~~

   1. インスタンス作成

      ~~~powshell
      [$<variable-name> =] [<class-name>]::new([<constructor-argument-list>])
      ~~~

1. 名前空間

      ~~~powshell
      using
      ~~~

1. 入力と出力

   1. コマンド

      ~~~powshell
      Read-Host
      Write-Host
      ~~~

   1. ファイル

      |Stream #|Description|
      |---|---|
      |1|Success Stream|
      |2|Error Stream|
      |3|Warning Stream|
      |4|Verbose Stream|
      |5|Debug Stream|
      |6|Information Stream|
      |*|All Streams|

      |Operator|Description|
      |---|---|
      |>|Send specified stream to a file.|
      |>>|Append specified stream to a file.|
      |>&1|Redirects the specified stream to the Success stream.|

      ~~~powshell
      dir 'C:\', 'fakepath' 2>&1 > .\dir.log
      ~~~

      補足:詳細なファイル制御が必要の場合はSystem.IO名前空間のクラス使用

1. その他

      ~~~powshell
      Get-Command a*
      Get-Command -CommandType Alias|Function|Cmdlet|Application|Script
      Get-Command <command> -Syntax
      Get-Help Get-Help
      Get-Help <command> [-Full]
      ~~~

## Bash ##

[GNU Bash](https://www.gnu.org/software/bash/manual/)

GNU Bash 4.2

1. 定数と変数

   1. 変数宣言

      ~~~bash
      a = 1
      ~~~

   1. 定義済み

      ~~~bash
      $0       # スクリプト名
      $1 ~ $9  # 引数
      $#       # スクリプトに与えた引数の数
      $*       # 全部の引数をまとめて1つとして処理
      $@       # 全部の引数を個別として処理
      $?       # 直前実行したコマンドの終了値（0は成功、1は失敗）
      $$       # このシェルスクリプトのプロセスID
      $!       # 最後に実行したバックグラウンドプロセスID
      ~~~

1. 演算子

   1. q

      ~~~bash
      a = 1
      ~~~

1. 分岐

1. ループ

1. 関数

1. クラス

1. 名前空間

1. 入力と出力
