# Oracle12c データ転送とアーカイブ #

## 長期格納用データベース・コピーを作成する場合のデータのアーカイブ ##

### アーカイブ・バックアップ ###

## 1つのデータベースまたはホストから別のデータベースまたはホストにデータを移動する場合のデータ送信 ##

### データベースの複製:非CDB ###

* 使用環境

  環境A:[検証環境:非CDB]のオプション「DB追加（リカバリ・カタログ、その他用）」を実施したVM
  環境B:[検証環境:非CDB]のオプション「DB追加（リカバリ・カタログ、その他用）」を実施ないVM
  環境C:Oracle Client 12c R2をインストール済みのホストPC

* 目標
  
  環境Aのアクティブなデータベース「orcl_other」を環境Bに複製します。
  なお、データベースのパラメータおよび構成を維持します。

* データベースを複製する手順
  [引用元](https://docs.oracle.com/cd/E82638_01/bradv/rman-duplicating-databases.html#GUID-CAC32870-C67F-465F-9449-EC87AC95BF95)

  1. 選択した複製方法の前提条件を満たしていることを確認します。
  1. データベースの複製を開始する前に必要な計画タスクを完了します。
  1. 複製データベースの作成時に使用される補助インスタンスを準備します。
  1. RMANを起動して、必要なデータベースに接続します。
  1. ソース・データベースを適切な状態に設定します(必要な場合)。
  1. (オプション) RMANチャネルを構成して、複製のパフォーマンスを向上させます。
  1. DUPLICATEコマンドを使用して、ソース・データベースを複製します。
  
* 実施

   環境A,環境Bがパワーオフ状態からスタートとします。

1. 環境A起動し、対象データベースをopenにします。

   ~~~bash
   # oracleユーザ
   export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
   export NLS_LANG=Japanese_Japan.AL32UTF8
   export PATH=$ORACLE_HOME/bin:$PATH
   export ORACLE_SID=orclother
   lsnrctl start lsnr_other
   sqlplus / as sysdba
   SQL> startup
   SQL> exit
   nmcli d show enp0s8 # 192.168.56.101
   ~~~

1. 環境B起動し、補助インスタンスを準備します。

   ~~~bash
   # rootユーザ
   xhost +
   su - oracle
   # oracleユーザ
   export DISPLAY=:0
   export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
   export NLS_LANG=Japanese_Japan.AL32UTF8
   export PATH=$ORACLE_HOME/bin:$PATH
   export ORACLE_SID=orclother
   # 複製データベースのディレクトリの作成
   mkdir /u01/app/oracle/oradata/orcl_other
   # 補助インスタンス用の初期化パラメータ・ファイルの作成
   # テキストエディタでファイルファイル作成
   #   ファイルパス /u01/app/oracle/product/12.2.0/dbhome_1/dbs/
   #   ファイル名   initorclother.ora
   #   設定内容     DB_NAME=orcl_oth
   sqlplus / as sysdba
   SQL> startup nomount
   SQL> exit
   netca
   ~~~
  
   * NETCA
     1. リスナー構成
     1. 追加
     1. リスナー：lsnr_other
     1. TCP
     1. 別ポート番号使用：1523
     1. 別のリスナーを構成しますか。いいえ
     1. 開始するリスナー:lsnr_other

   ~~~bash
   # oracleユーザ
   # 補助インスタンス用のパスワード・ファイルの作成
   orapwd file=$ORACLE_HOME/dbs/orapworclother password=ora format=12
   
   ~~~

1. 環境CでRMANを起動し、環境Aと環境Bに接続します。

   ~~~cmd
   

   ~~~

1. 複製実施します。

   ~~~cmd
   

   ~~~

1. 環境Bで、複製結果確認します。

   ~~~bash
   # oracleユーザ

   ~~~

### トランスポータブル表領域でデータ転送 ###