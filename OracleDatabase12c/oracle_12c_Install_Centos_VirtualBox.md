# Oracle DB 12cR1 インストール #

## 資材 ##

VirtualBox-6.1.4-136177-Win.exe
Centos-7-x86_64-Minimal-1908.iso
linuxamd64_12102_database_1of2.zip
linuxamd64_12102_database_2of2.zip

## 概要 ##

* Host OS: Windows 10

      ホストとして運用できるPCがある前提とする。

* VM : Virtual Box

* Guest OS: Centos-7.8

* DB : Oracle database 12cR1

## ソフトウェアインストール ##

* Virtual-Box 6.1 + CentOs 7.8

* ハードウェア設定
  * CPU プロセッサー:1
  * メインメモリ:4GB
  * ハードディスク: 40GB
  * ネットワーク
    * アダプタ1:NAT
    * アダプタ2:HostOnly
* OSインストール
  * ソフトウェア選択: 最小
  * ハードディスク自動構成
  * rootパスワード設定
* Oracle database 12cR1 インストール
  * rootユーザで以下のコマンドを実行

    ~~~bash
    nmcli d show
    nmcli c m eno0s3 connection.autoconnect yes
    ip a # 接続ip確認
    export http_proxy=<proxy server:port>
    export https_proxy=<proxy server:port>
    export ftp_proxy=<proxy server:port>
    yum update
    yum groupinstall "GNOME Desktop"
    yum install ksh

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
    chown -R oracle:oinstall /u01/app
    chmod -R 775 /u01

    startx
    xhost +

    # oracle ユーザ
    su - oracle
    # linuxamd64_12102_database_1of2.zip,linuxamd64_12102_database_1of2.zip を /home/oracle に配置
    unzip linuxamd64_12102_database_1of2.zip -d /home/oracle
    unzip linuxamd64_12102_database_1of2.zip -d /home/oracle
    export ORACLE_BASE=/u01/app/oracle
    export DISPLAY=:0
    /home/oracle/database/runInstaller -jreLoc `dirname $(dirname $(readlink $(readlink $(which java))))`
    ~~~

  * インストール設定(OUI)
    * セキュリティ・アップデートの構成
      1. セキュリティ・アップデートをMy Oracle Support経由で受け取ります。: チェックを外す
      1. 「次へ」
      1. ダイアログで「はい」
    * インストールオプション
      1. データベースの作成および構成
      1. 「次へ」
    * システムクラス
      1. デスクトップクラス
      1. 「次へ」
    * 標準インストール
      1. Oracleベース
          * /u01/app/oracle
      1. ソフトウェアの場所
          * /u01/app/oracle/product/12.1.0/dbhome_1
      1. データベース・ファイルの位置
          * /u01/app/oracle/oradata
      1. データベースのエディション
          * Enterprise Edtion (6.4GB)
      1. キャラクター・セット
          * Unicode (AL32UTF8)
      1. OSDBAグレープ
          * dba
      1. グローバル・データベース名
          * orcl.localdomain
      1. コンテナデータベースとして作成
          * チェックを外す
      1. 「次へ」
    * インベントリの作成
      1. インベントリ・ディレクトリ: /u01/app/oraInventory
      1. oraInventoryグループ名: oinstall
      1. 「次へ」

    ~~~bash
    export ORACLE_SID=orcl
    sqlplus / as sysdba
    SQL> select * from v$instance;
    SQL> exit
    ~~~