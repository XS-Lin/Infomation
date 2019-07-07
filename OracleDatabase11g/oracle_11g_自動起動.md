# Redhat Linux 7 / Cent OS 7 の Oracle データベースの自動起動について #

## 動作確認環境 ##

Redhat Linux 7 (Kernel 3.10.0-862.el7.x86_64)
CentOS Linux 7 (Kernel 3.10.0-957.10.1.el7.x86_64)
Oracle Database 11.2.0.1.0

## 自動起動(systemd) ##

1. 環境変数

   ~~~sh
   # ~/.bash_profile
   export ORACLE_BASE=/u01/app/oracle
   export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
   export NLS_LANG=Japan_Japanese.JA16SJIS
   export PATH=$ORACLE_HOME/bin:$PATH
   ~~~

1. 設定ファイル編集

   ~~~sh
   # /etc/oratab
   # データ構造 sid:$ORCLE_HOME:[N|Y|W]
   orcl01:/u01/app/oracle/product/11.2.0/dbhome_1:Y
   orcl02:/u01/app/oracle/product/11.2.0/dbhome_1:Y
   ~~~

   ~~~sh
   # /usr/lib/systemd/system/all-oracle-db.service
   # 起動用コマンド $ORACLE_HOME/bin/dbstart $ORACLE_HOME
   [Unit]
   Description=All Oracle Database service
   After=network.target

   [Service]
   Type=forking
   ExecStart=/u01/app/oracle/product/11.2.0/dbhome_1/bin/dbstart /u01/app/oracle/product/11.2.0/dbhome_1
   ExecStop=/u01/app/oracle/product/11.2.0/dbhome_1/bin/dbshut /u01/app/oracle/product/11.2.0/dbhome_1
   User=oracle

   [Install]
   WantedBy=multi-user.target
   ~~~

1. 自動起動有効化

   ~~~sh
   systemctl daemon-reload
   systemctl enable all-oracle-db.service
   ~~~

## 参考情報 ##

[Oracle Database 12c Release 2 : 自動起動の設定](https://www.server-world.info/query?os=CentOS_7&p=oracle12c&f=6)
