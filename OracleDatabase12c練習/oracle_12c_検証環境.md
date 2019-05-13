# Oracle DB 12cR2 検証環境 #

## 背景 ##

データベースのバックアップとリカバリ練習について、
動作可能な検証環境が必要です。
以下は検証環境のセットアップ手順と設定情報です。

## 概要 ##

* Host OS: Windows 10

      ホストとして運用できるPCがある前提とする。

* VM : Virtual Box or Hyper-V

      ホストのOSがHomeの場合、Virtual Boxを使用する。
      ホストのOSがPro以上の場合、Hyper-VとVirtual Boxのどちらを選ぶ。

* Guest OS: Oracle Linux 7.6

      設定を最小限のためにOracle Linuxを使用するが、Centos7.6の場合もほぼ変わらない。
      本ファイルはOracle Linuxベースに説明する。

* DB : Oracle database 12cR2

      事前に準備する。

* 検証用Data : Oracle DB Sample Schemas

  Oracle 12cR2 [サンプルスキーマの説明](https://docs.oracle.com/cd/E82638_01/comsc/installing-sample-schemas.html#GUID-9C9DEE62-E660-49F8-842B-3256ACA65346)
  [ダウンロード](https://github.com/oracle/db-sample-schemas/releases/tag/v12.2.0.1)

* 検証用Tools: mhvtl

      仮想テープデバイスとして使用する。

* オプション

      WinSCP : VMにファイル転送用(VM転送でも代用可)
      Tera Term : リモート接続用(VMで直接操作も可)
      Sql Developer : SQL実行用(DBソフトウェア付随または最新版をダウンロード、SqlPlusで代用可)
      Oracle Client : VM通信用(RMAN等ツールはVM内で使用可能なため、オプショナル)

## 検証環境:基本 ##

* インストールに慣れていない方は以下のファイル参照

  [Oracle VM VirtualBox を用いた Oracle Database 12c Release 1 環境の構築](https://www.oracle.com/technetwork/jp/database/enterprise-edition/documentation/sionvbox-db12101onol6u4-2080482-ja.pdf)

* Virtual-Box + Oracle Linux 7

* ハードウェア設定
  * CPU プロセッサー:2
  * メインメモリ:4GB
  * ハードディスク: 60GB
  * ネットワーク
    * アダプタ1:NAT
    * アダプタ2:HostOnly
* OSインストール
  * ソフトウェア選択: サーバー(GUI)、システム管理ツール
  * ハードディスク自動構成
  * ネットワーク:enp0s3,enp0s8有効にする
  * rootパスワード設定　OraServer2
  * admin/OraAdm0001
* Oracle database 12cR2 インストール
  * rootユーザで以下のコマンドを実行

  ~~~bash
  nmcli d show enp0s8 # ホストからVMへアクセス用IP表示(例:192.168.56.102),切断の場合は以下コマンドを実行してから再実行
  # nmcli c m enp0s8 connection.autoconnect yes
  xhost +
  yum update
  # cd /etc/yum.repos.d # CentOSの場合
  # wget http://public-yum.oracle.com/public-yum-ol7.repo # CentOSの場合
  /usr/bin/ol_yum_configure.sh # OracleLinuxの場合のみ
  yum install oracle-rdbms-server-12cR1-preinstall
  # groupadd -g 54321 oinstall # CentOSの場合
  # groupadd -g 54322 dba # CentOSの場合
  groupadd -g 54323 oper
  groupadd -g 54324 backupdba
  groupadd -g 54325 dgdba
  groupadd -g 54326 kmdba
  groupadd -g 54327 racdba
  usermod -u 1200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle #CentOSの場合、エラー。代わりに以下のコマンド実行
  # useradd -u 1200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba -d /home/oracle oracle

  # /etc/security/limits.conf ファイルに以下の内容を追加
  oracle soft nproc 2047
  oracle hard nproc 16384
  oracle soft nofile 1024
  oracle hard nofile 65536
  oracle soft stack 10240
  oracle hard stack 32768  
  
  mkdir -p /u01/app/oracle
  # winscp などツールでinstallerをアップロードまたはネットからダウンロードし、/u01/app/oracleに配置
  chown -R oracle:oinstall /u01/app/
  chmod -R 775 /u01

  su - oracle
  cd /u01/app/oracle
  unzip ./linuxx64_12201_database.zip
  cd database
  export DISPLAY=:0
  ./runInstaller
  ~~~

  * インストール設定(OUI)
    * セキュリティ・アップデートの構成
      1. セキュリティ・アップデートをMy Oracle Support経由で受け取ります。: チェックを外す
      1. 「次へ」
      1. ダイアログで「はい」
    * インストールオプション
      1. データベース・ソフトウェアのみインストール
      1. 「次へ」
    * データベース・インストールオプション
      1. 単一インスタンス・データベースのインストール
      1. 「次へ」
    * データベースのエディション
      1. Enterprise Edition (7.5GB)]
      1. 「次へ」
    * インストール場所
      1. Oracleベース: /u01/app/oracle
      1. ソフトウェアの場所: /u01/app/oracle/product/12.2.0/dbhome_1
      1. 「次へ」
    * インベントリの作成
      1. インベントリ・ディレクトリ: /u01/app/oraInventory
      1. oraInventoryグループ名: oinstall
      1. 「次へ」
    * オペレーティング・システム・グループ
      1. すべてデフォルトのまま
      1. 「次へ」

  * データベース作成(CDB+PDB)

    ~~~bash
    export ORACLE_BASE=/u01/app/oracle/
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export PATH=$ORACLE_HOME/bin:$PATH
    dbca
    ~~~

    * DBCA
      * データベース操作
        1. データベースの作成
        1. 「次へ」
      * 作成モード
        * 標準構成
          1. グローバル・データベース名: orcl
          1. 記憶域タイプ：ファイルシステム
          1. データベース・ファイルの位置:{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}
          1. 高速リカバリ領域：{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}
          1. データベース文字セット: AL32UTF8
          1. パスワード: ora
          1. コンテナデータベースとして作成:チェックON プラガブル・データベース名：orcl_pdb

  * 接続テスト

    ~~~bash
    export ORACLE_SID=orcl
    sqlplus / as sysdba
    SQL> select * from v$instance;
    SQL> exit
    ~~~

  * NETCA
    1. ローカル・ネット・サービス名
    1. 追加
    1. サービス名：orcl
    1. TCP
    1. ホスト名：localhost.localdomain 標準ポート
    1. はい、テスト実施

  * 接続テスト

    ~~~bash
    sqlplus system/ora@localhost:1521/orcl
    (略)
    SQL> exit
    ~~~

  * サンプルデータ投入
    * サンプルスキーマダウンロードし、/u01/app/oracleに配置

    ~~~bash
    # rootユーザ切り替えて実行
    mkdir /var/log/oracle_sample_schema/
    chown oracle:oinstall /var/log/oracle_sample_schema/
    # 以後はoracleユーザで実行
    cd /u01/app/oracle
    unzip db-sample-schemas-12.2.0.1.zip # 例として、zipを使用。
    cd db-sample-schemas-12.2.0.1
    perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat
    source /usr/local/bin/oraenv
    sqlplus system/ora@localhost:1521/orcl_pdb @mksample ora ora hrpw oepw pmpw ixpw shpw bipw users temp /var/log/oracle_sample_schema/ localhost:1521/orcl_pdb
    # 実行成功の場合は以下になる
    SQL>
    # /var/log/oracle_sample_schema/ に出力したログ確認し、終了
    SQL> exit
    ~~~

  * 終了処理
    * 以下のコマンドを実行し、電源オフにする。

    ~~~bash
    export ORACLE_SID=orcl
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export PATH=$ORACLE_HOME/bin:$PATH
    sqlplus / as sysdba
    SQL> shutdown immediate
    SQL> exit
    rm /u01/app/oracle/linuxx64_12201_database.zip
    rm /u01/app/oracle/db-sample-schemas-12.2.0.1.zip
    ~~~

* 検証環境をコピーして、試験機作成
  * 先に作成環境は「OracleDataba12c検証」とする。

      試験機のリカバリ完了後、検証機とデータ比較して、結果判定とする。

  * コピーした環境は「OracleDataba12c検証_試験機」とする。

  　　試験機でバックアップ、リカバリなどいろいろ操作を実施する。
      試験機が壊れたら、検証機のコピーから再作成する。

ここまで、検証環境構築が完了となる。
以後、oracle_12cシリーズファイルは検証環境を使用する。

* 検証環境の起動について

  リモートで接続できるように、ファイアウォールの設定およびリスナーの起動が必要です。

  ~~~bash
  # ファイアウォールの設定
  # root
  firewall-cmd --add-port=1521/tcp --zone=public --permanent
  firewall-cmd --reload
  ~~~

  ~~~bash
  # oracle
  export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
  export PATH=$ORACLE_HOME/bin:$PATH
  export ORACLE_SID=orcl
  # データベース起動
  sqlplus / as sysdba
  SQL> startup
  SQL> exit
  # リスナー起動
  lsnrctl start
  ~~~

## 検証環境:非CDB ##

* 前提条件
  
  前述「検証環境セットアップ」の「データベース作成(CDB+PDB)」までは同様に新環境を作成する。
  または「検証環境セットアップ」の結果を利用する。

* DBCAでデータベース作成

  * データベース作成(非CDB)

    ~~~bash
    export DISPLAY=:0
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export PATH=$ORACLE_HOME/bin:$PATH
    dbca
    ~~~

    * DBCA
      * データベース操作
        1. データベースの作成
        1. 「次へ」
      * 作成モード
        1. 拡張構成
        1. 「次へ」
      * デプロイタイプ
        1. データベースタイプ
        1. Oracle単一インスタンス・データベース
        1. テンプレート: 汎用またはトランザクション処理
        1. 「次へ」
      * データベース識別
        1. グローバル・データベース名:orcl_noncdb
        1. SID: orclnoncdb
        1. コンテナ・データベースとして作成: チェックオフ
        1. 「次へ」
      * 記憶域オプション
        1. データベース記憶域属性に次を使用
        1. データベース・ファイルの記憶域タイプ: ファイルシステム
        1. データベース・ファイルの位置: {ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}
        1. 「次へ」
      * 高速リカバリオプション
        1. 高速リカバリ領域の指定：チェックON
        1. リカバリ・ファイルの記憶域タイプ：ファイルシステム
        1. 高速リカバリ領域：{ORACLE_BASE}/fast_recover_area/{DB_UNIQUE_NAME}
        1. 高速リカバリ領域のサイズ：8192MB
        1. アーカイブ有効化：チェックON
        1. 「次へ」
      * ネットワーク構成
        1. 新規リスナーの作成
        1. リスナー名:lsnr_noncdb
        1. リスナー・ポート: 1522
        1. 「次へ」
      * Data Vaultオプション
        1. 「次へ」
      * 構成オプション
        * メモリー
          1. 自動メモリー管理の使用 メモリー・ターゲット:1500MB
        * サイズ設定
          1. 処理: 300
        * キャラクタ・セット
          1. 次の文字セットから選択: AL32UTF8
        * 接続サーバー・モード
          1. 専用サーバー・モード
        * サンプルスキーマ
          1. データベースにサンプル・スキーマを追加: チェックON
      * 管理オプション
        1. Enterprise Manager (EM) Database Expressの構成: チェックON
        1. 「次へ」
      * ユーザ資格証明の指定
        1. すべてのアカウントに同じパスワードを使用:ora
        1. 「次へ」
        1. 「はい」
      * 作成オプション
        1. 「次へ」
      * サマリー
        1. 「終了」

  * 接続テスト

    ~~~bash
    export ORACLE_SID=orclnoncdb
    # 日本語環境のNLS_LANG設定範囲: Japanese_Japan.UTF8,Japanese_Japan.JA16SJIS,Japanese_Japan.JA16EUC
    export NLS_LANG=Japanese_Japan.UTF8
    sqlplus / as sysdba
    SQL> select * from v$instance;
    SQL> exit
    ~~~

  * リモート接続を許可する

    ~~~bash
    # リモート接続を許可する
    firewall-cmd --add-port=1522/tcp --zone=public --permanent
    firewall-cmd --add-port=5500/tcp --zone=public --permanent
    firewall-cmd --reload
    ~~~

  * リモート接続テスト

    ~~~bash
    # cmd
    sqlplus system/ora@192.168.56.102:1522/orcl_noncdb
    ~~~

  * オプション：DB追加（リカバリ・カタログ、その他用）

    ~~~bash
    # root でログイン
    xhost +
    su - oracle
    export DISPLAY=:0
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export NLS_LANG=Japanese_Japan.UTF8
    export PATH=$ORACLE_HOME/bin:$PATH
    dbca
    ~~~

    * DBCA
      * データベース操作
        1. データベースの作成
        1. 「次へ」
      * 作成モード
        1. 拡張構成
        1. 「次へ」
      * デプロイタイプ
        1. データベースタイプ
        1. Oracle単一インスタンス・データベース
        1. テンプレート: 汎用またはトランザクション処理
        1. 「次へ」
      * データベース識別
        1. グローバル・データベース名:orcl_other
        1. SID: orclother
        1. コンテナ・データベースとして作成: チェックオフ
        1. 「次へ」
      * 記憶域オプション
        1. データベース記憶域属性に次を使用
        1. データベース・ファイルの記憶域タイプ: ファイルシステム
        1. データベース・ファイルの位置: {ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}
        1. 「次へ」
      * 高速リカバリオプション
        1. 「次へ」
      * ネットワーク構成
        1. 新規リスナーの作成
        1. リスナー名:lsnr_other
        1. リスナー・ポート: 1523
        1. 「次へ」
      * Data Vaultオプション
        1. 「次へ」
      * 構成オプション
        * メモリー
          1. 自動メモリー管理の使用 メモリー・ターゲット:1500MB
        1. 「次へ」
      * 管理オプション
        1. Enterprise Manager (EM) Database Expressの構成: チェックOFF
        1. 「次へ」
      * ユーザ資格証明の指定
        1. すべてのアカウントに同じパスワードを使用:ora
        1. 「次へ」
        1. 「はい」
      * 作成オプション
        1. 「次へ」
      * サマリー
        1. 「終了」

    ~~~bash
    # oracle ユーザ
    export ORACLE_SID=orclother
    sqlplus / as sysdba
    SQL> select log_mode from v$database;
    LOG_MODE
    ------------
    NOARCHIVELOG
    SQL> shutdown immediate
    SQL> startup mount
    SQL> alter databse archivelog;
    SQL> shutdown immediate
    SQL> exit
    # power off して、VMのメモリを6Gに変更
    ~~~

    ~~~bash
    # 前提条件：ORACLE RESTART等DB再起動ツールは未使用
    # oracle ユーザ
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export NLS_LANG=Japanese_Japan.AL32UTF8
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORACLE_SID=orclother
    sqlplus / as sysdba
    SQL> CREATE TABLESPACE tools
    2>     DATAFILE '/u01/app/oracle/oradata/orcl_other/tools.dbf'
    3>       SIZE 60M AUTOEXTEND ON NEXT 15M MAXSIZE 512M;
    表領域が作成されました。
    SQL> CREATE USER rco IDENTIFIED BY ora
    2>     TEMPORARY TABLESPACE temp
    3>     DEFAULT TABLESPACE tools
    4>     QUOTA UNLIMITED ON tools;
    ユーザが作成されました。
    SQL> GRANT RECOVERY_CATALOG_OWNER TO rco;
    権限付与が成功しました。
    SQL> exit
    lsnrctl start lsnr_other
    (略)
    rman catalog rco/ora@localhost:1523/orcl_other
    リカバリ・カタログ・データベースに接続されました。
    RMAN> CREATE CATALOG;
    リカバリ・カタログが作成されました。
    RMAN> exit
    sqlplus rco/ora@localhost:1523/orcl_other
    SQL> SELECT TABLE_NAME FROM USER_TABLES;
    (略)
    SQL> exit
    export ORACLE_SID=orclnoncdb
    rman target / catalog rco/ora@localhost:1523/orcl_other
    RMAN> STARTUP MOUNT;
    (略)
    RMAN> REGISTER DATABASE;
    データベースがカタログに登録されました。
    リカバリ・カタログの完全再同期を開始しています
    完全再同期が完了しました
    RMAN> REPORT SCHEMA;
    (略)
    RMAN> CREATE SCRIPT full_backup
    2> {
    3>   BACKUP DATABASE PLUS ARCHIVELOG;
    4>   DELETE OBSOLETE;
    5> }
    スクリプトfull_backupが作成されました
    RMAN> LIST SCRIPT NAMES;
    (略)
    RMAN> PRINT SCRIPT full_backup;
    (略)
    RMAN> RUN
    2> {
    3>   EXECUTE SCRIPT full_backup;
    4> }
    (略)
    RMAN> exit
    sqlplus sys/ora@localhost:1523/orcl_other as sysdba
    SQL> shutdown immediate
    SQL> exit
    sqlplus / as sysdba
    SQL> shutdown immediate
    SQL> exit
    # power off
    ~~~

    仮想プライベート・カタログ

    ~~~bash
    # oracle ユーザ
    export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
    export NLS_LANG=Japanese_Japan.AL32UTF8
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORACLE_SID=orclother
    lsnrctl start lsnr_other

    sqlplus / as sysdba
    SQL> CREATE TABLESPACE vpcusers
    2>     DATAFILE '/u01/app/oracle/oradata/orcl_other/vpcusers.dbf'
    3>       SIZE 15M AUTOEXTEND ON NEXT 1M MAXSIZE 100M;
    表領域が作成されました。
    SQL> CREATE USER vpc1 IDENTIFIED BY ora
    2>     DEFAULT TABLESPACE vpcusers
    3>     QUOTA UNLIMITED ON vpcusers;
    ユーザが作成されました。
    SQL> GRANT CREATE SESSION TO vpc1;
    権限付与が成功しました。
    SQL> CREATE USER vpc2 IDENTIFIED BY ora
    2>     DEFAULT TABLESPACE vpcusers
    3>     QUOTA UNLIMITED ON vpcusers;
    ユーザが作成されました。
    SQL> GRANT CREATE SESSION TO vpc2;
    権限付与が成功しました。
    SQL> EXIT;

    # 仮想プライベート・カタログの有効化
    sqlplus / as sysdba
    SQL> @$ORACLE_HOME/rdbms/admin/dbmsrmanvpc.sql -vpd rco
    (略)
  
    rman catalog rco/ora@localhost:1523/orcl_other
    RMAN> upgrade catalog
    リカバリ・カタログの所有者はRCOです。
    UPGRADE CATALOGのコマンドを再入力し、カタログのアップグレードを確認してください。
    RMAN> upgrade catalog
    (略)
    RMAN> list db_unique_name all;
    データベースリスト
    DBキー DB名      DBID      データベース・ロール Db_unique_name
    ------ -------- ---------- ------------------ ------------
    1      ORCL_NON 3635247963 PRIMARY            ORCL_NONCDB
    RMAN> GRANT CATALOG FOR DATABASE ORCL_NON TO vpc1;
    権限付与が成功しました。
    RMAN> GRANT REGISTER DATABASE TO vpc2;
    権限付与が成功しました。
    RMAN> exit

    rman catalog vpc1/ora@localhost:1523/orcl_other
    RMAN> CREATE VIRTUAL CATALOG;
    (略)
    RMAN> list db_unique_name all;
    データベースリスト
    DBキー DB名      DBID      データベース・ロール Db_unique_name
    ------ -------- ---------- ------------------ ------------
    1      ORCL_NON 3635247963 PRIMARY            ORCL_NONCDB
    RMAN> exit

    rman catalog vpc2/ora@localhost:1523/orcl_other
    RMAN> CREATE VIRTUAL CATALOG;
    (略)
    RMAN> list db_unique_name all;

    RMAN> exit
    ~~~

## 検証環境:CDB + GI + RAC + OSB ##

* Hyper-v10 + CentOs7 Minimal

* ハードウェア設定
  * CPU プロセッサー:2
  * メインメモリ:8GB
  * ハードディスク: 127GB
  * ネットワーク
    * アダプタ1:VNET10 (ブリッジ)
* OSインストール
  * ソフトウェア選択: 最小インストール
  * ハードディスク自動構成 (swap 10GBに設定)
  * rootパスワード設定 OraServer2
  * admin/OraAdm0001
* Oracle database 12cR2 等インストール
  * rootユーザで以下のコマンドを実行

    ~~~bash
    nmcli d
    nmcli c m eth0 connection.autoconnect yes
    yum update -y
    yum -y groupinstall "GNOME Desktop"
    # https://docs.oracle.com/cd/E82638_01/ladbi/supported-red-hat-enterprise-linux-7-distributions-for-x86-64.html#GUID-2E11B561-6587-4789-A583-2E33D705E498
    # I:インストール済み(yum list installed <lib_name> で確認) N:プラットフォームのため不要
    # I # binutils-2.23.52.0.1-12.el7 (x86_64)
    yum install bcompat-libcap1 # bcompat-libcap1-1.10-3.el7 (x86_64)
    # N # compat-libstdc++-33-3.2.3-71.el7 (i686)
    yum install compat-libstdc++-33 # compat-libstdc++-33-3.2.3-71.el7 (x86_64)
    # N # glibc-2.17-36.el7 (i686)
    # I # glibc-2.17-36.el7 (x86_64)
    # N # glibc-devel-2.17-36.el7 (i686)
    yum install glibc-devel # glibc-devel-2.17-36.el7 (x86_64)
    yum install ksh # ksh
    # N # libaio-0.3.109-9.el7 (i686)
    # I # libaio-0.3.109-9.el7 (x86_64)
    # N # libaio-devel-0.3.109-9.el7 (i686)
    yum install libaio-devel # libaio-devel-0.3.109-9.el7 (x86_64)
    # N # libgcc-4.8.2-3.el7 (i686)
    # I # libgcc-4.8.2-3.el7 (x86_64)
    # N # libstdc++-4.8.2-3.el7 (i686)
    # I # libstdc++-4.8.2-3.el7 (x86_64)
    # N # libstdc++-devel-4.8.2-3.el7 (i686)
    yum install libstdc++-devel # libstdc++-devel-4.8.2-3.el7 (x86_64)
    # N # libxcb-1.9-5.el7 (i686)
    # I # libxcb-1.9-5.el7 (x86_64)
    # N # libX11-1.6.0-2.1.el7 (i686)
    # I # libX11-1.6.0-2.1.el7 (x86_64)
    # N # libXau-1.0.8-2.1.el7 (i686)
    # I # libXau-1.0.8-2.1.el7 (x86_64)
    # N # libXi-1.7.2-1.el7 (i686)
    # I # libXi-1.7.2-1.el7 (x86_64)
    # N # libXtst-1.2.2-1.el7 (i686)
    # I # libXtst-1.2.2-1.el7 (x86_64)
    # N # libXrender (i686)
    # I # libXrender (x86_64)
    # N # libXrender-devel (i686)
    yum install libXrender-devel # libXrender-devel (x86_64)
    # I # make-3.82-19.el7 (x86_64)
    # I # net-tools-2.0-0.17.20131004git.el7 (x86_64) (Oracle RACおよびOracle Clusterware用)
    # I # nfs-utils-1.3.0-0.21.el7.x86_64 (Oracle ACFS用)
    # I # smartmontools-6.2-4.el7 (x86_64)
    # I # sysstat-10.1.5-1.el7 (x86_64)

    groupadd -g 54321 oinstall
    groupadd -g 54322 dba
    groupadd -g 54323 oper
    groupadd -g 54324 backupdba
    groupadd -g 54325 dgdba
    groupadd -g 54326 kmdba
    groupadd -g 54327 racdba
    useradd -u 1200 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba -d /home/oracle oracle

    # /etc/security/limits.conf ファイルに以下の内容を追加
    oracle soft nproc 2047
    oracle hard nproc 16384
    oracle soft nofile 1024
    oracle hard nofile 65536
    oracle soft stack 10240
    oracle hard stack 32768  

    mkdir -p /u01/app/oracle
    chown -R oracle:oinstall /u01/app/oracle
    chmod -R 775 /u01

    startx
    xhost +

    # WinSCP upload "linuxx64_12201_grid_home.zip" to "/var/tmp/"
    # WinSCP upload "linuxx64_12201_database.zip" to "/var/tmp/"

    # oracle ユーザ
    su - oracle
    # TODO: GIインストール
    # mkdir -p /u01/app/oracle/grid
    # unzip /var/tmp/linuxx64_12201_grid_home.zip -d /u01/app/oracle/grid
    unzip /var/tmp/linuxx64_12201_database.zip -d /u01/app/oracle
    export ORACLE_BASE=/u01/app/oracle
    export DISPLAY=:0
    ~~~

    ~~~bash
    $ORACLE_BASE/database/runInstaller
    ~~~

    * インストール設定(OUI)
      * セキュリティ・アップデートの構成
        1. セキュリティ・アップデートをMy Oracle Support経由で受け取ります。: チェックを外す
        1. 「次へ」
        1. ダイアログで「はい」
      * インストールオプション
        1. データベース・ソフトウェアのみインストール
        1. 「次へ」
      * データベース・インストールオプション
        1. Oracle Real Application Clustersデータベースのインストール
        1. 「次へ」
      * データベースのエディション
        1. Enterprise Edition (7.5GB)]
        1. 「次へ」
      * インストール場所
        1. Oracleベース: /u01/app/oracle
        1. ソフトウェアの場所: /u01/app/oracle/product/12.2.0/dbhome_1
        1. 「次へ」
      * インベントリの作成
        1. インベントリ・ディレクトリ: /u01/app/oraInventory
        1. oraInventoryグループ名: oinstall
        1. 「次へ」
      * オペレーティング・システム・グループ
        1. すべてデフォルトのまま
        1. 「次へ」

    ~~~bash
    export ORACLE_HOME=$ORACLE_BASE/product/12.2.0/dbhome_1
    ~~~

## 高可用性環境セットアップ ##

試験の一部問題は高可用性にかかわるため、動作環境作成する。
高可用性の概要は以下の資料参照

[高可用性構成](https://www.oracle.com/technetwork/jp/database/articles/kusakabe/kusakabe-4-4648839-ja.html)