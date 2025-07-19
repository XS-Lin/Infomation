# PowerShell #

## 環境変数 ##

  ~~~powershell
  # 環境変数表示
  $env:JAVA_HOME
  # 環境変数設定
  $env:JAVA_HOME='C:\Program Files (x86)\Java\jdk1.8.0_161'
  # C:\Program Files\Java\jdk-11.0.1
  # D:\Program Files\Android\Android Studio\jre
  [Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-17.0.2', 'User')
  [Environment]::SetEnvironmentVariable('JAVA_HOME', '', [EnvironmentVariableTarget]::User)
  # [Environment]::SetEnvironmentVariable('JAVA_HOME', '', 'Machine')
  ~~~

## python.exeパス取得 ##

  ~~~powershell
  py -c $("import sys`nprint(sys.base_prefix)")
  py -c $("import sys`nprint(sys.executable)")
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
  # (Windows 10 以前は [System.IO.File]::WriteAllLines(test.txt, @("ファイルの内容"), (New-Object "System.Text.TF8Encoding" -ArgumentList @($false))))
  ~~~

## psqlでPostgresql大量接続 ##

  ~~~powershell
  # USERとDB作成
  0 .. 99 | ForEach-Object { "CREATE ROLE testuser{0:00} WITH LOGIN PASSWORD 'testpass{0:00}';" -f $_ } | ut-File create_role.sql -Encoding UTF8
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
  Get-ChildItem -Path C:\Users\linxu\Desktop\work\作業\20190805本番 機info\log -Filter exp_CDBC31_*.log | ort-Object LastWriteTime
  ~~~

  [Powershell数字フォーマット](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/ustom-numeric-format-strings)

  ~~~powershell
  # フォルダ以下のファイル一覧表示(相対パス)
  Get-ChildItem -File -Recurse -Name
  ~~~

## Redmine情報取得 ##

[Redmine API](https://www.redmine.org/projects/redmine/wiki/rest_api#General-topics)

admin/testadmin
testuser/testpass/testfirstname testlastname/testuser@mail.test

  ~~~powershell
  # 
  http://[Redmineurl]/projects.xml
  http://[Redmineurl]/trackers.xml
  http://[Redmineurl]/users.xml
  http://[Redmineurl]/groups.xml
  
  http://[Redmineurl]/projects.xml?limit=200
  ~~~

  ~~~powershell
  # 認証
  #  1. ファイルに記載
  $user='admin'
  $pass= ConvertTo-SecureString 'testadmin' -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential($user,$pass)
  #  2. 入力
  $cred = Get-Credential
  ~~~
  
  [Rest_Users](https://www.redmine.org/projects/redmine/wiki/Rest_Users)
  
  ~~~powershell
  # user
  #  GET
  $uri='http://localhost:80/users.json?status=1'
  $users=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $uri='http://localhost:80/users.json?name=jplang'
  $users=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $uri='http://localhost:80/my/account.json'
  $me=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $me
  #  PUT
  $data='{
      "user": {
          "login": "jplang",
          "firstname": "Jean-Philippe",
          "lastname": "Lang",
          "mail": "jp_lang@yahoo.fr",
          "password": "secret01" 
      }
  }'
  $uri='http://localhost:80/users.json'
  $postBody = [Text.Encoding]::UTF8.GetBytes($data)
  Invoke-RestMethod -URI $uri -Method POST -ContentType 'application/json' -Body $postBody -Credential $cred
  ~~~

[Rest_Projects](https://www.redmine.org/projects/redmine/wiki/Rest_Projects)

~~~powershell
# project
#  GET
$uri='http://localhost:80//projects.json'
$projects=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
$projects
~~~

[Rest_Issues](https://www.redmine.org/projects/redmine/wiki/Rest_Issues)

  ~~~powershell
  $user='testuser'
  $pass= ConvertTo-SecureString 'testpass' -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential($user,$pass)
  # GET Issues LIST
  $uri='http://localhost:80/issues.json'
  $issues=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $issues
  $uri='http://localhost:80/issues.json?project_id=1&tracker_id=1&status_id=open&assigned_to_id=5'
  $issues=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $issues.issues[0].priority.name
  $issues.issues[0].due_date
  # GET Issue
  GET /issues/[id].[format]
  # CREATE Issue
  $data='{
      "issue": {
          "project_id": 1,
          "tracker_id": 1,
          "subject": "テストAPI",
          "description": "テスト専用です",
          "assigned_to_id": 5
      }
  }'
  $uri='http://localhost:80/issues.json'
  $postBody = [Text.Encoding]::UTF8.GetBytes($data)
  Invoke-RestMethod -URI $uri -Method POST -ContentType 'application/json' -Body $postBody -Credential $cred
  ~~~

  ~~~powershell
  # 1. ユーザのログインでuser_id取得
  $uri_base = 'http://localhost:80'
  $uri_get_user_info=$uri_base + '/users.json?status=1'
  $users=Invoke-RestMethod -URI $uri_get_user_info -Method GET -Credential $cred
  $target_users = $users.users | Where-Object { $redmine_logins -contains $_.login } # $redmine_logins 定義から取得
  # 2. プロジェクトid取得
  $uri_get_project_info=$uri_base + '/projects.json'
  $projects=Invoke-RestMethod -URI $uri_get_project_info -Method GET -Credential $cred
  $target_project = $projects.projects | Where-Object { $_.name -eq $project_name } # $project_name 定義から取得
  # 3. トラカーid取得
  $uri_get_tracker=$uri_base + '/trackers.json'
  $trackers=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $target_tracker = $trackers.trackers | Where-Object { $tracker_names -contains $_.name } # $tracker_names 定義から  取得
  # 4. 対象チケット一覧取得(project_id,tracker_id,status_id=open,user_id)
  $uri='http://localhost:80/issues.json?project_id=1&tracker_id=1&status_id=open&assigned_to_id=5'
  $issues=Invoke-RestMethod -URI $uri -Method GET -Credential $cred
  $issues.issues[0].priority.name
  $issues.issues[0].due_date
  # 5. 期日計算(期日直前,期限切れ)※休日計算機能
  # 6. マークダウン形式結果出力
  ~~~

## Teams送信(webhook) ##

[Invoke-RestMethod](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.1)

  ~~~powershell
  [String]$var = "This is a sample content"
  $JSONBody = [PSCustomObject][Ordered]@{
      "@type"      = "MessageCard"
      "@context"   = "http://schema.org/extensions"
      "summary"    = "My first alert summary!"
      "themeColor" = '0078D7'
      "title"      = "My first alert."
      "text"       = "Add detailed description of the alert here!
                           You can also use variables: $var"
  }
  $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
  # ConvertFrom-Json
  $parameters = @{
      "URI"         = '<webhook-URL>'
      "Method"      = 'POST'
      "Body"        = $TeamMessageBody
      "ContentType" = 'application/json'
  }
  Invoke-RestMethod @parameters
  ~~~

  ~~~powershell
  $URI=<webhook-URL>
  Invoke-RestMethod -URI $URI -Method 'POST' -ContentType 'application/json' -Infile message.json
  ~~~
  
  ~~~powershell
  # フォルダ以下のファイル、サブフォルダのファイル一覧表示
  Get-ChildItem -Name -File -Recurese -Path .
  ~~~

## Download ##

  ~~~powershell
  # DownloadFile uri,local file name
  # https://docs.microsoft.com/ja-jp/dotnet/api/system.net.webclient.downloadfile?view=net-5.0
  (New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.  exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
  
  # call演算子 &
  # https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_operators?  view=powershell-7.1
  & $env:Temp\GoogleCloudSDKInstaller.exe
  ~~~

## some test ##

  ~~~powershell
  # 以下のフォルダのリソース利用
  # https://github.com/cloud-ace/gcp-container-textbook/tree/master/06/01_min_cloudrun
  $PROJECT_ID=<your poject id>
  go get cloudace/mincloudrun
  docker build -t gcr.io/$PROJECT_ID/mincloudrun .
  gcloud auth configure-docker # 認証
  docker push gcr.io/$PROJECT_ID/mincloudrun
  gcloud run deploy mincloudrun --image gcr.io/fluent-anagram-326107/mincloudrun --platform managed --region   asia-northeast --allow-unauthenticated
  ~~~

## XML ##

  ~~~powershell
  (Select-Xml -Path C:\work\test1.xml -XPath "/bookstore" -Namespace @{ ns = "urn:newbooks-schema"}).Node.InnerText
  
  ~~~

## 証明書 ##

  ~~~powershell
  $ca = Get-ChildItem cert:\CurrentUser\CA | Where-Object { $_.Subject -eq "CN=name" }
  $ca
  Remove-Item $ca.PSPath
  Import-Certificate -FilePath file_name.crt -CertStoreLocation cert:\CurrentUser\CA
  ~~~

## TimeSpan ##

  ~~~powershell
  New-TimeSpan -Start ([Datetime]"1970-01-01") -End $(Get-Date)
  ~~~

## 文字化け ##

~~~powershell
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')
~~~
