# 練習課題 #

## 目的 ##

試験を合格することは目的ではなく、スキルを検証の手段である。前回の不合格によって、実機の操作がたりないことがわかる。
そのため、LPICのチェックリストに合わせて実機で練習を行い、再挑戦とする。

## 課題 ##

1. インストール

   1. 試験環境

     * ホストA
       * OS:Windows10 Home
       * VM:Virtual Box

     * ホストB
       * OS:Windows10 Pro
       * VM:Hyper-V

   1. ゲストOSイメージ

     * [CentOS](https://www.centos.org/download/)
       * [CentOS-7-x86_64-Minimal-1810.iso](http://ftp-srv2.kddilabs.jp/Linux/packages/CentOS/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso)
     * [ubuntu](https://www.ubuntulinux.jp/download)
       * [Ubuntu Server 19.04](https://www.ubuntu.com/download/server/thank-you/?version=19.04&architecture=amd64&_ga=2.92709533.1862725024.1563508894-2126992079.1561080257)

1. 


1. リソース使用率監視

   ~~~sh
   top
   vmstat
   iostat
   sar/sadf
   w
   ~~~

   ~~~sh
   # CPU
   ps
   # MEMORY
   free
   # DISK
   df
   # ネットワーク
   netstat
   iptables
   ~~~

   ~~~sh
   # リソース監視
   collectd
   Nagios
   MRTG
   Cacti
   Icinga2
   ~~~

1. カーネル

   ~~~sh
   # バージョン確認
   uname
   ~~~

   ~~~sh
   # モジュール管理
   lsmod
   insmod
   rmmod
   modprobe
   depmod
   modinfo
   ~~~

   ~~~sh
   # カーネルコンパイル
   ~~~

   ~~~sh
   # カーネルパラメータ変更
   sysctl
   /etc/sysctl.conf
   ~~~

   ~~~sh
   # カーネル管理
   ~~~

1. システム起動

   ~~~sh
   # SysVinit
   # systemd
   ~~~

   ~~~sh
   # システム回復
   ~~~

1. デバイスとファイルシステム

   ~~~sh
   # ファイルシステム操作
   # ファイルシステム作成
   # ファイルシステム保守
   ~~~

1. ストレージ管理

   ~~~sh
   # RAID
   # LVM
   # 記憶装置へのアクセス
   ~~~

1. ネットワーク

   ~~~sh

   ~~~

1. システムメンテナンス

   ~~~sh
   # ソースからソフトウェアインストール
   # バックアップ
   # ユーザへのシステム管理情報の通知
   ~~~
