# 練習課題 #

## 目的 ##

試験を合格することは目的ではなく、スキルを検証の手段である。
前回の不合格によって、実機の操作が足りないことがわかる。
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
     * [Debian](https://www.debian.org/distrib/)
       * [Debian 10](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.0.0-amd64-netinst.iso)

1. シェル練習

   /etc/profile -> ~/.bash_profile -> ~/.bash_login -> ~/.profile -> ~/.bashrc -> /etc/bashrc
   /etc/bash.bashrc #Debian系

   1. 環境変数

      ~~~bash
      # 環境変数確認
      env
      printenv
      printenv 変数名
      echo $変数名
      # 環境変数設定
      export TEST=test
      declare -x TEST=test
      # 環境変数解除
      export -n TEST
      unset TEST
      ~~~

   1. シェル環境

      ~~~sh
      # シェル環境確認
      set -o
      # シェル環境設定
      set -o オプション
      # シェル環境設定解除
      set +o オプション
      ~~~

      * 主なオプション
         * allexport
         * emacs
         * ignoreeof
         * noclobber
         * noglob
         * vi

   1. エイリアス

      ~~~sh
      # エイリアス確認
      alias
      # エイリアス設定
      alias ls='ls -l'
      alias lsless='ls -l | less'
      # エイリアス解除
      unalias ls
      unalias lsless
      # エイリアス一時解除
      \ls
      ~~~

   1. 関数

      bashでは関数名と変数名を区別しないため、以下は関数名も変数名と呼ぶようにする。

      ~~~sh
      # 関数確認
      set
      declare -f 変数名
      # 関数定義:構文1
      [function] 変数名() { コマンド; }
      # 関数定義:構文2
      [function]
      変数名()
      {
        コマンド
      }
      # 関数削除
      unset 変数名
      ~~~

   1. bashの設定ファイル

      ~~~sh
      /etc/profile # ログイン時、全ユーザ
      /etc/bash.bashrc # bash起動時、全ユーザ
      /etc/bashrc # ~/.bashrcから参照
      ~/.bash_profile # ログイン時
      ~/.bash_login # ~/.bash_profileがない場合のログイン時
      ~/.profile # ~/.bash_profileも~/.bash_loginもない場合のログイン時
      ~/.bashrc # bash起動時に実行される
      ~/.bash_logout # ログアウト時
      ~~~

   1. シェル実行

      ~~~sh
      bash ファイル名
      . ファイル名
      source ファイル名
      ファイル名 # 実行権限必要
      exec コマンド # プロセス切り替え
      # シェル引数
      $0,$#,$@,$*,$?
      ~~~

   1. 条件文

      ~~~sh
      test 条件文
      [ 条件文 ]
      ~~~

      * 条件文
        * ファイル形式:-f,-d,-r,-w,-x,-s,-L
        * ファイル特性:-e,-nt,-ot
        * 数値:-eq,-ge,-gt,-le,-lt,-ne
        * 文字列:-n,-z,=,!=
        * 論理演算:!,-a,-o

   1. 制御構造

     ~~~sh
     if list; then list; [ elif list; then list; ] ... [ else list; ] fi
     case word in [ [(] pattern [ | pattern ] ... ) list ;; ] ... esac
     for name [ [ in [ word ... ] ] ; ] do list ; done
     for (( expr1 ; expr2 ; expr3 )) ; do list ; done
     select name [ in word ] ; do list ; done
     while list-1; do list-2; done
     until list-1; do list-2; done
     ~~~

1. デスクトップ

   1. /etc/X11/xorg.conf

     * 主なセクション
       * Files
       * Module
       * InputDevice
       * InputClass
       * Device
       * Monitor
       * Screen
       * ServerLayout

   1. /etc/X11/xorg.conf.d

      /etc/X11/xorg.conf の設定を上書きする。[情報源](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/6/html/deployment_guide/s2-x-server-config-xorg.conf.d)

   1. GUIエラー

     ~/.xsession-errors,/var/log/Xorg.0.log

   1. XクライアントとXサーバの関係

      * Xサーバ: キーボードとディスプレイ等デバイスを管理
      * Xクライアント: OSからメッセージを取得して描画リクエストをXサーバに送信、Xサーバからボタン押下などメッセージを受信してOSに通知

   1. ネットワークでX利用

      STEP1:ローカルホストでXサーバ接続を許可する。

      ~~~sh
      # Xサーバ接続許可リストに存在かを確認
      xauth list
      # Xサーバ接続許可リストに追加
      xhost +remotpc
      # Xサーバ接続許可リストから削除
      xhost -remotpc
      # 接続許可リストは無視され、すべてのホストXサーバ接続許可
      xhost +
      # 接続許可リストにあるホストのみXサーバ接続許可
      xhost -
      ~~~

      STEP2:リモートホストで表示対象ディスプレイ設定する。

      ~~~sh
      # リモートホストで表示対象ディスプレイ設定
      export DISPLAY=localpc:0.0
      # 上記設定の略
      export DISPLAY=:0
      ~~~

      STEP3:リモートホストでXクライアント起動する。

      ~~~sh
      rxvt &
      ~~~

   1. グラフィカルデスクトップ

     * 概念
       * ディスプレイマネージャー(代表例:XDM,GDM,KDE,SDDM,LightDM)
       * ウィンドウマネージャー(代表例:twm,FVWM,Enlightenment,Mutter,Fluxbox,Compiz,KWin)
       * 統合デスクトップ環境
         | ツール                 | GNOME      | KDE Plasma | Xfce     | LXDE               | MATE |
         | ---                    |:--         |:--         |:--       |:--                 |:--|
         | テキストエディタ         | gedit     | KEdit      | Mousepad | *                  | Pluma |
         | 端末                    | GNOME端末 | Konsole    | *        | LXTerminal          | MATE Terminal |
         | ファイルマネージャー     | Nautilus  | Dolphin    | Thunar    | PCMan File Manager | Caja |
         | ディスプレイマネージャー  | GDM      | SDDM       | xfdesktop | LXDM               | MDM |
         | ウィンドウマネージャー    | Mutter   | KWin       | xfwm4     | Openbox            | Marco |

     [XFCEプロジェクト](https://www.xfce.org/projects/)

   1. リモートデスクトップ

      ~~~sh
      # VNC (Windows,Linux,macOS等)
      vncserver :1
      vncserver -kill :1
      # RDP (Windows)
      # SPICE (Windows,Linux,macOS等)
      # XDMCP (Linux)
      ~~~

      注目[SPICE](https://www.atmarkit.co.jp/ait/articles/1006/29/news083_2.html)[SPICE Download](https://www.spice-space.org/download.html)

      補足: XDMCPはデフォルトで暗号化されないため、SSH経由に注意

   1. アクセシビリティ

      * ハイコントラスト/ラージプリントデスクトップのテーマ
        * ハイコントラスト:画像の表示における明暗の差
        * ラージプリント:大文字
      * 点字表示: 視覚障害者向けの点字を表示
      * スクリーンルーペ: 拡大
      * オンスクリーンキーボード:
      * スティッキ/リピートキー
        * スティッキーキー: [Ctrl] [L] = [Ctrl+L]
        * リピートキー:キー押下から連続入力として認識までの時間調整
      * スロー/バウンス/トグルキー
        * スローキー: キー押下から認識までの時間調整
        * バウンスキー: 連続キー押下の時に入力として認識してから次回入力として認識する時間調整
        * トグルキー:[NumLock][CapsLock][Scrollock]を押すと、ビープ音が鳴らす(on 1回、off ２回)
      * マウスキー: テンキーでマウス操作をする
      * ジェスチャー
      * 音声認識

1. アカウント管理

      ~~~sh
      # ユーザ表示
      cat /etc/passwd # ユーザ名:パスワード:UID:GID:コメント:ホームディレクトリ:デフォルトシェル
      id [ユーザ名]
      getent passwd
      # グループ表示
      cat /etc/group # グループ名:グループパスワード:GID:グループメンバー
      getent group
      # ユーザ追加
      useradd [-c コメント -d ホームディレクトリ -g グループ名/GID -G グループ名/GID -s デフォルトシェル -D -m] ユーザ名
      # ユーザ変更
      usermod [-c コメント -d ホームディレクトリ -g グループ名/GID -G グループ名/GID -s デフォルトシェル -L -U] ユーザ名
      # ユーザ削除
      userdel [-r] ユーザ名
      # グループ追加
      groupadd [-g GID] グループ名
      # グループ変更
      groupmod [-g GID] グループ名
      # グループ削除
      groupdel グループ名
      # ユーザホームディレクトリのデフォルトファイル
      /etc/skel/*
      ~~~

      ~~~sh
      /etc/shadow # ユーザ名:$暗号化種別$パスワード:最終変更日:最小間隔日数:最大間隔日数:警告通知日数:変更猶予日数:アカウント有効期間:未使用
      passwd [-d -e -l -n 最小間隔日数 -u -x 最大間隔日数 -w 警告通知日数 -i 変更猶予日数] ユーザ名
      chage [-d 最終変更日 -m 最小間隔日数 -M 最大間隔日数 -W 警告通知日数 -l 変更猶予日数 -E アカウント有効期間] ユーザ名
      ~~~

1. ジョブ管理

   1. crontab

      ~~~sh
      crontab [-e -l -r -i -u ユーザ名] # -e は環境変数EDITORで指定したエディタを開く
      # 書式:分 時 日 月 曜日 コマンド
      ~~~

      * 書式詳細
        * 分
          * 数値: 0~59
          * すべて: *
          * 5分間隔で繰り返す: */5
          * 複数指定: 5,15,45
        * 時
          * 数値: 0~23
          * すべて: *
          * 2時間隔で繰り返す: */2
          * 複数指定: 5,15
        * 日
          * 数値: 1~31
          * すべて: *
          * 2日隔で繰り返す: */2
          * 複数指定: 5,15
        * 月
          * 数値: 1~12
          * 文字列: jan~dec
          * すべて: *
          * 2月隔で繰り返す: */2
          * 複数指定: 1,4,7,10
        * 曜日
          * 数値: 0~7 (0,7は日曜)
          * 文字列: sun~mon
          * すべて: *
          * 複数指定: 1,4

      * ディレクトリ
        * /etc/crontab
        * /etc/cron.{d,daily,hourly,monthly,weekly}/
        * /var/spool/cron

      * 制御
        * /etc/cron.allow も /etc/cron.deny もなければすべてのユーザ利用可能
        * /etc/cron.allow があれば、記載されているユーザ利用可能(/etc/cron.denyは無視)
        * /etc/cron.allow がなければ、/etc/cron.deny に記載されていないユーザ利用可能

   1. at

      ~~~sh
      atq/at -l # 予約中ジョブ一覧表示
      atrm/at -d/at -r ジョブ# 予約中ジョブ一覧から削除
      at -f my_jobs 15:00 tomorrow
      ~~~

      * 日時指定詳細
        * 午後10時: 22:00 / 10pm
        * 正午: noon
        * 真夜中: midnight
        * 今日: today
        * 明日: tomorrow
        * 3日後: now + 3 days
        * 2週間後22時: 10pm + 2 weeks

      * 制御
        * /etc/cron.allow も /etc/cron.deny もなければ root のみ利用可能
        * /etc/cron.allow があれば、記載されているユーザ利用可能(/etc/cron.denyは無視)
        * /etc/cron.allow がなければ、/etc/cron.deny に記載されているユーザ利用不可

   1. systemd

      ~~~sh
      # timer unit表示
      systemctl list-timers
      # timer unit作成
      /etc/systemd/system/my_job.timer
      # ---------------------
      [Unit]
      Description=test

      [Timer]
      OnBootSec=10min
      OnUnitActiveSec=1w

      [Install]
      WantedBy=timer.target
      # --------------------
      ~~~

      ~~~sh
      # 一時的な .timer ユニット
      systemd-run --unit=jobtest --on-active=1s --on-unit-active=2s uptime
      systemd-run --on-active="12h 30m" --unit someunit.service
      journalctl -u jobtest
      systemctl stop jobtest.timer
      ~~~

1. 国際化

   1. ロケール

      ~~~sh
      locale # 現在のロケール /usr/bin/locale
      locale -a # 利用可能なロケール
      locale -m # 利用可能な文字コード
      ~~~

      * ロケールの主なカテゴリ
        * LC_CTYPE
        * LC_COLLATE
        * LC_MESSAGES
        * LC_MONETARY
        * LC_NUMERIC
        * LC_TIME

      * 主なロケール名
        * C
        * POSIX
        * ja_JP.utf8
        * ja_JP.eucJP
        * ja_JP.shiftJIS
        * en_US.utf8

      ~~~sh
      # ロケール一時変更
      LANG=C man ls
      ~~~

   1. 文字コード

     * 主な文字コード
       * ASCII
       * ISO-8859: ASCIIの拡張(256種類)
       * UTF8
       * EUC-JP
       * SHIFT-JIS
       * ISO-2022-JP: 電子メールなどで使う日本の文字用の文字符号化方式。JISコード

      ~~~sh
      iconv -l
      iconv [-f 入力文字コード -t 出力文字コード] 入力ファイル名
      ~~~

   1. タイムゾーン

      ~~~sh
      # タイムゾーン一覧表示
      ls /usr/share/zoneinfo
      # システムタイムゾーン表示
      ls -l /etc/localtime
      # タイムゾーン設定
      export TZ="Asia/Tokyo"
      echo "Asia/Tokyo" > /etc/timezone # すべてのユーザ使用可能
      tzselect
      tz
      ~~~

1. 必須サービス

   1. システム時刻

      ~~~sh
      # システム時刻表示
      date
      date "+%Y/%m/%d %H:%M:%S"
      date "+%b-%d (%a) %Y"
      # システム時刻設定
      # 書式: [MMDDhhmm[[CC]YY][.ss]]
      date 121020002018
      ~~~

      ~~~sh
      # ハードウエア時刻表示
      hwclock / hwclock -r
      # システム時刻をハードウエアに設定
      hwclock -w / hwclock --systohc
      # ハードウエア時刻をシステムに設定
      hwclock -s / hwclock --hctosys
      ~~~

      ~~~sh
      # systemdで管理するシステムの場合
      timedatectl status
      timedatectl set-time [YYYY-MM-DD] [HH:MM:SS]
      timedatectl list-timezones # タイムゾーン一覧表示
      timedatectl set-timezone Asia/Tokyo # タイムゾーン設定
      timedatectl set-ntp yes|no
      ~~~

      ~~~sh
      # NTPサーバ現在時刻取得
      ntpdate ntp.nict.jp # 国立開発研究法人　情報通信研究機構（NICT）
      # NTPサーバ運用
      systemctl start ntpd.service
      ntpq -p  localhost
      cat /etc/ntp.conf # pool.ntp.org ランダムTNPサーバのIP取得
      ~~~

      ~~~sh
      # NTPサーバ運用
      systemctl start chronyd.service
      chronyc activity
      chronyc sources
      chronyc sourcesats
      chronyc tracking
      cat /etc/chrony.conf
      ~~~

      補足1:ntpdとchronydの同時使用はできない。

      補足2:[pool.ntp.org](https://www.pool.ntp.org/zone/jp)

   1. システムログ

      ~~~sh
      cat -n /etc/rsyslog.conf
      # モジュールロード部分
      #    6  #### MODULES ####
      #    9  $ModLoad imuxsock
      # グローバル部分
      #   23  #### GLOBAL DIRECTIVES ####
      #   26  $WorkDirectory /var/lib/rsyslog
      # ルール部分 書式: ファシリティ.プライオリティ 出力先
      #   46  #### RULES ####
      #   57  authpriv.* /var/log/secure
      vi /etc/rsyslog.conf
      systemctl restart rsyslog
      ~~~

      * 主なプラグインモジュール
        * imuxsock
          UNIXソケットのサポート(loggerなど)
        * imjournal
          systemdのジャーナルのサポート
        * imklog
          カーネルのサポート
        * immark
          マーク出力(--MARK--)
        * imudp
          UDPでメッセージ受信
        * imtcp
          TCPでメッセージ受信

      * ファシリティ
        * auth,authpriv
        * cron
        * daemon
        * kern
        * lpr
        * mail
        * user
        * local0 ~ local7

      * プライオリティ
        * emerg
        * alert
        * crit
        * err
        * warning
        * notice
        * info
        * debug
        * none

      * 出力先
        * /var/log/message
        * /dev/tty1
        * @sv.example.com
        * @@sv.example.com
        * violet
        * *

      ~~~sh
      logger -p syslog.info -t Test "logger test message" # -p ファシリティ.プライオリティ -t タグ
      systemd-cat uptime # systemdのジャーナル出力
      journalctl -xe # -e 最近のメッセージ表示 -x 詳細表示

      cat /var/log/messages
      tail -f /var/log/messages
      cat /var/log/secure # 認証関連ログ
      ~~~

      ~~~sh
      # ログインユーザ表示
      who # /var/run/utmp
      # ログインユーザとシステム情報表示
      w # /var/run/utmp
      # 最近ログインしたユーザ一覧
      last # /var/log/wtmp
      # ユーザ一ごとにログイン一覧
      lastlog /var/log/lastlog
      # systemdログ
      journalctl [-f -r -e -x -b -p プライオリティ -u UNIT名 --full --no-pager] # /var/log/journal または /run/log/journal
      cat /etc/systemd/journald.conf # Storage=auto の場合、ログは自動削除(デフォルト),永続保存の場合はStorage=persistent
      man 5 journald.conf
      ~~~

      ~~~sh
      # ローテーション
      cat /etc/logrotate.conf
      ~~~

   1. メール転送

      * 代表MTA: sedmail,Postix,exim
      * 代表MDA:
      * 代表MUA:

      ~~~sh
      # MTA起動
      systemctl start postfix.service
      # メール送信
      mail [-s title] [mailアドレス または ユーザ名]
      本文入力
      .
      EOT
      # メール受信確認
      mail
      # メール転送
      /etc/aliases
      # 記述例:rootのメールをadminとoraでも受信できる
      # root:admin,ora
      newaliases # /etc/aliases の変更を有効にする
      ~~~

      ~~~sh
      ~/.forward # 転送先を記載
      ~~~

   1. プリンター

      ~~~sh
      /etc/cups/cupsd.conf # ポート番号やクライアント接続許可など情報
      /etc/cups/printers.conf # プリンターに関する情報
      ~~~

      ~~~sh
      # プリントキュー
      lpq [-P プリンター名] [ユーザ名] [ジョブ番号]
      # 印刷
      lpr [-P プリンター名 -# 部数] [ファイル名]
      dmesg | lpr
      # プリントキューから削除
      lprm [-P プリンター名 -] [ジョブ番号]
      ~~~

1. リソース使用率監視

   1. 総合的なリソース使用率

      ~~~sh
      top [-b] [-d 秒] [-n 回] [-u ユーザ] [-p PID]
      vmstat [間隔] [回数]
      iostat [-c -d -k -t] [間隔] [回数]
      sar {-A -b -c -f ファイル -n DEV -n EDEV -r -u -P id|ALL -R -W} [-s 開始時刻] [-e 終了時刻] [-f ログファイル名] [間隔] [回数]
      sadf 
      w [-h -s]
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

   1. TCP,UDP,ICMPの主な違い

      * TCP
        * コネクション型
        * エラーパケット再送
        * 転送順序整列
      * UDP
        * コネクションレス型
        * エラー確認なし(映像、音声によく使われる)
      * ICMP
        * コネクションレス型
        * エラーメッセージや制御メッセージ転送

   1. プライベートIPアドレス

      * A : 10.0.0.0 ~ 10.255.255.255
      * B : 172.16.0.0 ~ 172.31.255.255
      * C : 192.168.0.0 ~ 192.168.255.255

   1. IPv4とIPv6の主な違い

      * IPv6のマルチキャストはIPv4のブロードキャスト相当

   1. 主なネットワークに関するファイルと用途

      * /etc/services
        * 用途: ポート番号とサービスの対応を記述
      * /etc/hostname
        * 用途: ホスト名記述
      * /etc/hosts
        * 用途: IPとホスト名の対応を記述
        * 書式: IP ホスト名 別名
      * /etc/network/interfaces
        * 用途: Debian系のネットワークインターフェース定義を記述
        * 書式
          * auto lo
          * iface lo inet loopbacklo
          * iface eth0 inet static
          * address 192.168.11.2
          * netmask 255.255.255.0
          * broadcast 192.168.11.255
          * gateway 192.168.11.1
          * dns-domain example.com
          * dns-nameservers 192.168.11.1
      * /etc/sysconfig/network-scripts/
        * /etc/sysconfig/network-scripts/ifcfg-eth0
          * 用途: Red Hat系のネットワークインターフェース定義を記述
          * 書式
            * TYPE=Ethernet
            * BOOTPROTO=static
            * NAME=eth0
            * ONBOOT=YES
            * HWADDR=00:00:00:00:00:00
            * DNS1=192.168.11.1
            * DOMAIN=example.com
            * IPADDR=192.168.11.13
            * NETMASK=255.255.255.0
            * GATEWAY=192.168.11.1
      * /etc/resolv.conf
        * DNSサーバ参照先
        * 書式
          * domain example.com
          * search example.com
          * nameserver 192.168.11.1
          * nameserver 8.8.8.8
      * /etc/nsswitch.conf
        * 名前解決順序
        * 書式
          * 
      * /etc/systemd/resolved.conf
        * systemdを採用の名前解決

   1. 主なネットワーク設定・管理コマンド

      ~~~sh
      ping [-c 回数] [-i 間隔] # ping6
      traceroute ホスト名はたはIP # traceroute6 # 結果に **** は応答せずフォワーディングのみを意味する。
      hostname [ホスト名]
      netstat [-a -c -i -n -p -r -t -u] # n IPのまま表示 r ルーティングテーブル表示
      nc [-l -p ソースポート -u -o ファイル] [ホスト] [ポート]
      route [-F -C] # RoutingTable: Destination Gateway Genmask Flags Metric Ref Use Iface
      route add -net 192.168.0.0 netmask 255.255.255.0 gw 172.30.0.254 # 192.168.0.0/24 ネットワークのパケットをゲートウェイ 172.30.0.254 に転送
      route add default gw 172.30.0.1
      route del -net 192.168.0.0 netmask 255.255.255.0 gw 172.30.0.254
      echo 1 > /proc/sys/net/ipv4/ip_forward # 1 異なるネットワークのパケット転送許可(デフォルト)、Linuxをルータとして運用の前提条件
      ip link show
      ip addr show
      ip route show
      ip addr add 192.168.11.12/24 dev eth0 # eth0のIPを192.168.11.12/24に設定
      ip route add default via 192.168.11.1 # デフォルトゲートウェイ192.168.11.1に設定
      ifconfig eth0 192.168.11.12 netmask 255.255.255.0 # eth0のIPを192.168.11.12/24に設定
      ifup eth0
      ifdown eth0
      # DNS
      host [-v] ホスト名またはIP [DNSサーバ]
      dig [-x] [@DNSサーバ] ホスト名またはIP [a aaaa any mx ns]
      ~~~

   1. NetworkManager

       CentOs7.6基準でnmcliコマンドと設定ファイルの関係を確認する。

       ~~~sh
       # nmcli 主なコマンド
       nmcli general status
       nmcli general hostname # /etc/hostname
       nmcli general hostname ホスト名 # /etc/hostname更新
       nmcli networking on | off
       nmcli networking connectivity [check] # nmcli general status の CONNECTIVITY
       nmcli radio wifi # nmcli general status の WIFI
       nmcli radio wifi on | off
       nmcli radio wwan # nmcli general status の WWAN
       nmcli radio wwan on | off
       nmcli radio all on | off
       nmcli connection show [--active]
       nmcli connection add COMMON_OPTIONS TYPE_SPECIFIC_OPTIONS SLAVE_OPTIONS IP_OPTIONS [-- ([+|-]<setting>.<property> <value>)+]
       nmcli connection modify ID ([+|-]<setting>.<property> <value>)+ #
       nmcli connection delete ID
       nmcli connection up ID
       nmcli connection down ID
       nmcli device [status] # 認識しているデバイス表示
       nmcli device show [<ifname>]
       nmcli device modify <ifname> ([+|-]<setting>.<property> <value>)+ #
       nmcli device connect <ifname>
       nmcli device disconnect <ifname>
       nmcli device delete <ifname>
       nmcli device monitor <ifname>
       nmcli device wifi list
       nmcli device wifi connect SSID
       nmcli device wifi hostpot
       nmcli device wifi rescan
       ~~~

       [6.4. NMCLI を使用したホスト名の設定](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_host_names_using_nmcli)




   1. 目的別コマンド整理

       ~~~sh
       # ホスト名設定
       vi /etc/hostname
       nmcli general hostname ホスト名
       hostnamectl set-hostname ホスト名
       # ルーティングテーブル表示
       netstat -r
       route
       route -F

       ~~~

   ~~~sh
   / etc / hostname
   /etc/hosts
   /etc/nsswitch.conf
   /etc/resolv.conf
   nmcli
   hostnamectl
   ifup
   ifdown

   ip
   hostname
   ss
   ping
   ping6
   traceroute
   traceroute6
   tracepath
   tracepath6
   netcat
   ifconfig
   netstat
   route

   /etc/hosts
   /etc/resolv.conf
   /etc/nsswitch.conf
   host
   dig
   getent

   ip
   ifconfig
   route
   arp
   iw
   iwconfig
   iwlist

   ip
   ifconfig
   route
   arp
   ss
   netstat
   lsof
   ping, ping6
   nc
   tcpdump
   nmap

   ip
   ifconfig
   route
   ss
   netstat
   /etc/network/, /etc/sysconfig/network-scripts/
   ping, ping6
   traceroute, traceroute6
   mtr
   hostname
   /var/log/syslog, /var/log/messages などのシステムログと、システムジャーナル
   dmesg
   /etc/resolv.conf
   /etc/hosts
   /etc/hostname, /etc/HOSTNAME
   /etc/hosts.allow、/etc/hosts.deny
   # DNS
   /etc/named.conf
   /var/named/
   /usr/sbin/rndc
   kill
   host
   dig
   /var/named/
   ゾーンファイルの書式
   リソースレコードの書式
   named-checkzone
   named-compilezone
   masterfile-format
   dig
   nslookup
   host
   /etc/named.conf
   /etc/passwd
   DNSSEC
   dnssec-keygen
   dnssec-signzone

   ~~~

1. セキュリティ

   1. TCP Wrapper

      * host.allow と host.deny
        * 評価順:ホストがhost.allowにあれば許可。host.allowにないかつhost.allowにもなければ許可。
        * /etc/host.allow
          * 書式
            * サービス名:対象ホストリスト
            * 例
              * sshd: .lpic.jp
              * ALL:192.168.2.
        * /etc/host.deny
            * サービス名:対象ホストリスト
            * 例
              * ALL:ALL

      * 主なワイルドカード
        * ALL
        * A EXCEPT B
        * LOCAL
        * PARANOID

      補足: host.allow と host.deny の変更はサービス再起動しなくても有効になる。

   1. 開いているポート確認

      ~~~sh
      netstat -atu
      ss -atu
      lsof -i
      nmap 対象ホスト
      fuser -n tcp 1521 # 結果はPID
      lsof -i:1521 #
      ~~~

   1. SUIDが設定されているファイル

      ~~~sh
      find / -perm -u+s -ls
      find / -perm -g+s -ls
      ~~~

   1. ログイン禁止

      ~~~sh
      touch /etc/nologin # root以外ログイン禁止
      usermod -s /sbin/nologin test # testユーザのログイン禁止
      vipw
      # ---------------
      test:x:502:502::/home/test:/sbin/nolog
      # ----------------
      ~~~

   1. ユーザ切り替え

      ~~~sh
      su [- [ユーザ名]]
      ~~~

   1. sudo

      ~~~sh
      visudo
      vi /etc/sudoers
      # ---------------
      test1 ALL=(ALL) ALL
      test2 ALL=(ALL) /sbin/shutdown
      %test ALL=(ALL) NOPASSWD:ALL
      # ----------------
      sudo -l # 一般ユーザで許可されているsudoコマンド確認
      sudo [-i -s -u ユーザ] # i 変更先ユーザでシェル起動(ログイン処理を行う) s 変更先ユーザでシェル起動
      ~~~

   1. システムリソースの制限

      ~~~sh
      ulimit [-a -c サイズ -f サイズ -n 数 -u プロセス数 -v サイズ] # c コアファイルサイズ n 同時に開けるファイル数 v 仮想メモリサイズ
      ~~~

   1. OpenSSH

      * /etc/ssh/sshd_config
        * Port
        * Protocol
          * 1 or 2
        * HostKey
          * ssh_host_key
          * ssh_host_dsa_key
          * ssh_host_rsa_key
          * ssh_host_ecdsa_key
          * ssh_host_ed25519_key
          * ssh_host_key.pub
          * ssh_host_dsa_key.pub
          * ssh_host_rsa_key.pub
          * ssh_host_ecdsa_key.pub
          * ssh_host_ed25519_key.pub
        * PermitRootLogin
        * RSAAuthentication
        * PubkeyAuthentication
        * AuthorizedKeysFile
        * PermitEmptyPasswords
        * PasswordAuthentication
        * X11Forwarding

      ~~~sh
      ssh [-i identity_file] [-l login_name] [-p port] [[ユーザ名@]ホスト]
      ssh root@192.168.56.102/ssh -l root -p 22 192.168.56.102
      # 初回の場合、yesで接続以下のファイルに記載
      #   LINUX: ~/.ssh/known_hosts
      #   Windows10: ~/.ssh/known_hosts
      ssh-keygen [-t rsa1|rsa|dsa|ecdsa|ed25519] [-p] [-f ファイル名] [-R ホスト名] [-b ビット長]
      # dsaキー作成して公開鍵をsv1.lpic.jpに登録
      ssh-keygen -t dsa
      scp ~/.ssh/id_dsa.pub sv1.lpic.jp:publickey
      ssh sv1.lpic.jp
      cat publickey >> ~/.ssh/authorized_keys
      chmod 600 ~/.ssh/authorized_keys
      ~~~

      ~~~sh
      scp [-p -r -R ポート] コピー元ファイル名 [ユーザ名@]コピー先ホスト:[コピー先ファイル名] # upload
      scp [-p -r -R ポート] [ユーザ名@]コピー元ホスト:コピー元ファイル名 コピー先ファイル名 # download
      ~~~

      ~~~sh
      ssh-agent bash
      ssh-add
      ssh-add -l
      ~~~

      ~~~sh
      # ポートフォワーディング
      ssh -f -N -L 10110:pop.example.net:110 student@pop.example.net # ローカルの10110を接続すると、pop.example.netを接続する。f バックグラウンド N 転送のみ
      ~~~

      ~~~sh
      /etc/ssh/sshd_config # X11Forwarding yes
      ssh -X remote.example.net
      ~~~

   ~~~sh
   find
   passwd
   fuser
   lsof
   nmap
   chage
   netstat
   sudo
   /etc/sudoers
   su
   usermod
   ulimit
   who、w、last

   / etc / nologin
   /etc/passwd
   / etc / shadow
   /etc/xinetd.d/
   /etc/xinetd.conf
   systemd.socket
   /etc/inittab
   /etc/init.d/
   /etc/hosts.allow
   /etc/hosts.deny

   ssh
   ssh-keygen
   ssh-agent
   ssh-add
   ~/.ssh/id_rsa and id_rsa.pub
   ~/.ssh/id_dsa and id_dsa.pub
   〜/ .ssh / id_ecdsaとid_ecdsa.pub
   〜/ .ssh / id_ed25519とid_ed25519.pub
   /etc/ssh/ssh_host_rsa_key and ssh_host_rsa_key.pub
   /etc/ssh/ssh_host_dsa_key and ssh_host_dsa_key.pub
   / etc / ssh / ssh_host_ecdsa_keyおよびssh_host_ecdsa_key.pub
   / etc / ssh / ssh_host_ed25519_keyおよびssh_host_ed25519_key.pub
   ~/.ssh/authorized_keys
   ssh_known_hosts
   gpg
   gpg-agent
   ~/.gnupg/

   /proc/sys/net/ipv4/
   /proc/sys/net/ipv6/
   /etc/services
   iptables
   ip6tables

   vsftpd.conf
   Pure-FTPdの重要なコマンドオプション

   ssh
   sshd
   /etc/ssh/sshd_config
   /etc/ssh/
   秘密鍵と公開鍵のファイル
   PermitRootLogin、PubKeyAuthentication、AllowUsers、PasswordAuthentication、Protocol
   telnet
   nmap
   fail2ban
   nc
   iptables
   /etc/openvpn/
   openvpn
   ~~~

1. システムメンテナンス

   ~~~sh
   # ソースからソフトウェアインストール
   # バックアップ
   # ユーザへのシステム管理情報の通知
   ~~~
