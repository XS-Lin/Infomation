﻿# PowerShell #

## 環境変数 ##

   ~~~powershell
   # 環境変数表示
   $env:JAVA_HOME
   # 環境変数設定
   $env:JAVA_HOME='C:\Program Files (x86)\Java\jdk1.8.0_161'
   # C:\Program Files\Java\jdk-11.0.1
   ~~~

## ファイル存在チェック ##

   ~~~powershell
   Test-Path $path -PathType Leaf
   ~~~

## テキストファイル出力 ##

   ~~~powershell
   "aaa" | Out-File test.txt -Encode ASCII
   ~~~

## テキストファイル出力(LF) ##

   ~~~powershell
   0..99 | ForEach-Object { "a,b,c,{0:00}`n" -f $_ } | Out-File test.csv -Encode ASCII -NoNewline
   ~~~

## CSV操作 ##

   ~~~powershell
   # CSV 読み取り(headerあり)
   $data = Import-Csv -Path <csvpath> -Encoding UTF8
   # CSV 読み取り(headerなし)
   $data = Import-Csv -Path <csvpath> -Header Col1,Col2,Col3
   ~~~

   ~~~powershell
   # CSV エクスポート
   @(
     [pscustomobject]@{ product_code = 'TEST00001'; product_name = 'ボールペン'; price = 100 },
     [pscustomobject]@{ product_code = 'TEST00002'; product_name = '消しゴム'; price = 50 }
   ) | Export-Csv -NoTypeInformation products.csv -Encoding UTF8

   @'[
       { "product_code": "TEST00001", "product_name ": "ボールペン", "price ": 100 },
       { "product_code": "TEST00002", "product_name ": "消しゴム", "price ": 50 }
    ]'@ | ConvertFrom-Json | Export-Csv -NoTypeInformation products.csv -Encoding UTF8

   @' "product_code","product_name ","price "
      "TEST00001","ボールペン","100"
      "TEST00002","消しゴム","50"
   '@ | ConvertFrom-Csv | Export-Csv -NoTypeInformation products.csv -Encoding UTF8
   # Note: PowershellのUTF8はBOMあり、BOMなしにしたいときはASCII
   # (Windows 10 以前は [System.IO.File]::WriteAllLines(test.txt, @("ファイルの内容"), (New-Object "System.Text.UTF8Encoding" -ArgumentList @($false))))
   ~~~

## psqlでPostgresql大量接続 ##

   ~~~powershell
   # USERとDB作成
   0 .. 99 | ForEach-Object { "CREATE ROLE testuser{0:00} WITH LOGIN PASSWORD 'testpass{0:00}';" -f $_ } | Out-File create_role.sql -Encoding UTF8
   0 .. 999 | ForEach-object { "CREATE DATABASE testdb{0:000};" -f $_ } | Out-File create_db.sql -Encoding UTF8
   # ローカルの接続テスト
   funciton StartTestinfo {
     Param(
       [int]$userCount,
       [int]$dbCount,
       [string]$server = "localhost",
       [int]$port = 5432
     )
     for ($i = 0; $i -lt $userCount; $i++) {
       for ($j = 0; $j -lt $dbCount; $j++) {
         $usr = "testuser{0:00}" -f $i
         $db = "testdb{0:000}" -f $j
         $sql = Resolve-Path "test.sql"
         Start-Job -ScriptBlock {
           psql -h $arg[0] -p $arg[1] -U $arg[2] -d $arg[3] -f $arg[4]
         } -Arguments $server,$port,$usr,$db,$sql
       }
     }
   }
   ~~~

## その他 ##

   ~~~powershell
   chcp 65001 # 接続先の文字コードがUTF8の場合
   ssh root@192.168.0.50
   ~~~

   ~~~powershell
   Get-Process > process.txt # process.txt ファイルの文字コードがUnicode
   Get-Process | Out-File process.txt # process.txt ファイルの文字コードがUnicode
   Get-Process | Out-File process.txt -Encoding default # process.txt ファイルの文字コードがutf-8
   Get-Process | Out-File process.txt -Encoding 932 # PowerShell6.2以後
   ~~~

   ~~~powershell
   netsh wlan show profiles | %{ $_.Split(":")[1]} | `
   Where-Object{$_ -ne $null -and ( $_  -notmatch "^\s*$" ) } | `
   ForEach-Object{$_.trim()} | `
   ForEach-Object{ netsh wlan show profile name="$_" key=clear} | `
   Where-Object{ $_ -like "*主要なコンテンツ*" -or ( $_ -like "*SSID 名*" ) }
   ~~~

   ~~~powershell
   # key押下
   Add-Type -AssemblyName System.Windows.Forms
   [System.Windows.Forms.SendKeys]::SendWait("^{ESC}") # Windowsキー押下 (ctrl+esc)
   [System.Windows.Forms.SendKeys]::SendWait("run")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("notepad")
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("This is a test script.")
   [System.Windows.Forms.SendKeys]::SendWait("^s") #ctrl+sキーを押す
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("newtext.txt")
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("%{F4}") #Alt+F4キーを押す
   ~~~

   ~~~powershell
   # https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/add-type?view=powershell-6
   $Source = @"
   public class BasicTest
   {
     public static int Add(int a, int b)
       {
         return (a + b);
       }
     public int Multiply(int a, int b)
       {
       return (a * b);
       }
   }
   "@

   Add-Type -TypeDefinition $Source
   [BasicTest]::Add(4, 3)
   $BasicTestObject = New-Object BasicTest
   $BasicTestObject.Multiply(5, 2)
   ~~~

   ~~~powershell
   # 指定フォルダのファイルを更新時間順で一覧表示
   Get-ChildItem -Path C:\Users\linxu\Desktop\work\作業\20190805本番 機info\log -Filter exp_CDBC31_*.log | Sort-Object LastWriteTime
   ~~~

   [Powershell数字フォーマット](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/custom-numeric-format-strings)
