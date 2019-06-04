# LPCI1 学習メモ #

## 1.システムアーキテクチャ ##

1. ハードウェアの基本知識と設定

   ~~~sh
   /dev # デバイス
   /proc # カーネル認識しているデバイス
   lsusb # USBデバイス
   lsmod # デバイスドライバー一覧(ロードされているカーネルモジュール)
   modprobe # 手動でデバイスドライバーロード
   # 起動の流れ：BIOS/UEFI->ブートローダ->カーネル->init/systemd
   shutdown [-h -r -f -F -k -c] <time> [<message>]
   ~~~

   * SysVinit

   ~~~sh
   # 1. /etc/inittab
   # 2. /etc/rc.sysinit
   # 3. /etc/rc
   # 4. /ect/rc<label>.d/*
   runlevel #N 3
   init 1
   # カーネルメッセージ
   dmesg
   ~~~

   * systemd

   ~~~sh
   # main deamon process
   systemd
   systemd-journald
   systemd-logind
   systemd-networkd
   systemd-timesyncd
   systemd-resolved
   systemd-udevd
   # unit
   service
   device
   mount
   swap
   target
   timer
   # startup
   ls -l /etc/systemd/system/default.target
   ln -s /lib/systemd/system/graphical.target /etc/systemd/system/default.target
   # runlevel -> target
   0 -> poweroff.target
   1 -> rescue.terget
   2,3,4 -> multi-user.target
   5 -> graphical.target
   6 -> reboot.target
   # systemctlでsystemd管理
   start,stop,restart,reload,status,is-active,enable,disable,mask,unmask,
   list-dependencies,list-units,list-unit-files,reboot,poweroff
   # mulit-user.targetに含まれるUnitを確認
   ls /etc/systemd/system/multi-user.target.wants/
   # サービス一覧表示
   sudo systemctl list-unit-files -t service
   # システム起動時自動起動サービス一覧表示
   sudo systemctl list-unit-files -t service --state=enabled
   # カーネルメッセージ
   journalctl
   ~~~

## 2.ハードディスクのレイアウト設計 ##

1. Linuxインストールに必要なパテーション

   ~~~sh
   # rootとswapは必須、一般的に以下となる
   /home # 一般ユーザ用、再インストールの時に引継ぐ
   /var # ログ,メールスプール等更新頻度の高いファイル配置
   /usr # プログラム、ライブラリ、ドキュメント
   /boot # ディスク先頭パテーションとして使用、数百MB
   EFIシステムパテーション(ESP) # OSブートローダやデバイスドライバ使用
   スワップ領域 # 物理メモリ不足の時や休止状態の時使用、物理メモリの1～2倍程度
   / #復旧しやすいためできるだけ小さく設定
   ~~~

   ~~~sh
   # ファイルサーバ(ROM200GB/RAM1GB)
   swap 1GB
   /boot 100MB
   /usr 10GB
   /var 10GB
   / 1GB
   /home 約180GB
   # Webサーバ(ROM100GB/RAM4GB)
   swap 4GB
   /boot 100MB
   /usr 10GB
   /var 20GB
   /var/log 50GB
   / 15GB
   # DBサーバ(ROM8TB/RAM32GB)
   swap 32GB
   /opt
   /data
   /usr
   /var
   /var/log
   /
   # LVM
   ~~~

1. ブートローダのインストール

   ~~~sh
   vi /etc/default/grub
   grub-mkconfig -o /boot/grub/grub.cfg
   ~~~

   ~~~sh
   # システム起動中「E」を押す
   grub append>ro root=/dev/VolGroup00/LogVol00 rhgb quiet
   # single入力、1~5入力等
   grub append>ro root=/dev/VolGroup00/LogVol00 rhgb quiet single
   ~~~

1. 共有ライブラリ管理

   ~~~sh
   ldd # 必要な共有ライブラリ確認
   /etc/ld.so.conf
   ldconfig # /etc/ld.so.cache再構築
   LD_LIBRARY_PATH # 共有ライブラリ検索対象に追加
   # 共有ライブラリ検索優先順：1.LD_LIBRARY_PATH 2./etc/ld.so.cache 3./usr/lib
   ~~~

1. Debianパッケージの管理

   ~~~sh
   #<パッケージの名称>_<バージョン番号>-<Debianリビジョン>_<アーキテクチャ>.<拡張子>
   #<tree>_<1.6.0>-<1>_<i386>.<deb>
   tree_1.6.0-1_i386.deb
   # dpkg [-E -G -R] [-i -r -P -l -S -L -s --configure --unpack]
   dpkg -i apache2_2.4.29-1ubuntu4.5_amd64.deb
   # apt-get [-d -s] [clean dist-upgrade install remove update upgrade]
   /etc/apt/sources.list
   #<deb|deb-src> <URI> <バージョン名> <main|universe|restricted|multiverse|contrib|non-free>
   deb http://archive.ubuntu.com bionic main restricted
   # apt-cache <search|shwo|showpkg|depends>
   # apt [-c -d -y --no-install-recommends --install-suggests --reinstall] <update|install|remove|purge|upgrade|full-upgrade|shwo |list|list --installed|search|depends|autoremove>
   ~~~

1. RPMパッケージの管理

   ~~~sh
   # <パケージの名称>-<バージョン番号>-<リリース番号>.<アーキテクチャ>.<拡張子>
   # <bash>-<4.2.46>-<30.el7>.<x86_64>.<rpm>
   bash-4.2.46-30.el7.x86_64.rpm
   # rpm
   #   -i -U -F [-v -h --nodeps --force --test]
   #   -e [--nodeps]
   #   -q [-a -f -p -c -d -i -l -R --changelog]
   rpm -ivh zsh-5.0.2-28.el7.x86_64.rpm
   rpm -Fvh ~/rpms/*.rpm
   rpm -qa | grep vim
   rpm -qi bash
   rpm -qf /bin/bash
   rpm -qlp bash-4.2.46-30.el7.x86_64.rpm
   rpm -K httpd-2.4.6-80.el7.centos.1.x86_64.rpm
   rpm2cpio tree-1.6.0-10.el7.x86_64.rpm | cpio -id
   # yum
   /etc/yum.conf
   ls /etc/yum.repos.d/
   yum [check-update|update|install|remove|info|list|repolist|search|search all|group list|group install]
   ~~~

## 3.GNUとUNIXコマンド ##

1. コマンドライン操作

   ~~~sh
   /etc/shells
   # sh,bash,csh,tsh,ksh,zsh
   # Bourneシェル(sh) --改良-> bash
   # Cシェル(csh) --拡張-> tcsh
   # Kornシェル(ksh) --ksh+bash+tcsh-> zsh
   # プロンプト記号「#」スーパーユーザ 「$」一般ユーザ
   # 基本操作
   #   補完機能 [Tab]
   #   カーソル移動 [ctrl+A][ctrl+E]
   #   コマンドラインの編集 [ctrl+D][ctrl+H][ctrl+L]
   #   実行制御 [ctrl+C][ctrl+S][ctrl+Q][ctrl+Z]
   # ディレクトリの指定
   #   ~
   #   .
   #   ..
   #   ~username
   # シェル変数と環境変数
   #   よく使われる環境変数
   #     EDITOR,HISTFILE,HISTFILESIZE,HISTSIZE,HOME,HOSTNAME,LANG,LOGNAME,PATH,PS1,PS2,PWD,TERM,USER
   #   変数
   #     変数名=値
   #     echo <文字列|$変数名>
   #     unset 変数名
   #     export 変数名[=値]
   # コマンド実行
   #     コマンド　[オプション]　[引数]
   #     コマンド1;コマンド2 #コマンド1に続いてコマンド2
   #     コマンド1&&コマンド2 #コマンド1が正常終了の場合コマンド2
   #     コマンド1||コマンド2 #コマンド1が正常終了ではない場合コマンド2
   #     (コマンド1||コマンド2) #コマンドグループとして実行
   #     {コマンド1||コマンド2} #現在のシェルにコマンド実行
   # 引用符
   #   ' 文字列
   #   " 文字列(変数があれば展開)
   #   ` 文字列(コマンドがあれば実行結果を展開)
   #   \ エスケープ文字
   # コマンド履歴
   history
   !文字列
   !?文字列
   !!
   !履歴番号
   # マニュアル参照
   #   man [-a -f -k -w] [1-9] コマンド名またはキーワード
   man man
   #   マンページの見出し
   #     NAME,SYNOPSIS,DESCRIPTION,OPTIONS,FILES,ENVIRONMENT,NOTES,BUGS,SEE ALSO,AUTHOR
   #  less
   #     k,j,f,b,q,/,?,h
   man -f
   whatis
   man -k
   apropos
   # ファイル操作
   #   ls [-a -A -d -F -i -l -t -h] [ファイル名またはディレクトリ名]
   ls -ld /home/lpic
   #   cp [-f -i -p -r -d -a] コピー元ファイル名 コピー先ファイル名またはディレクトリ
   cp -rp /home/lpic .
   #   mv [-f -i] 移動元ファイルかディレクトリ 移動先ファイルかディレクトリ
   mv sample.txt ~
   #   mkdir [-m -p] ディレクトリ名
   mkdir -m 700 mydir
   #   rm [-f -i -r] ファイル名
   #   rmdir [-p] ディレクトリ名
   #   touch [-t -a -m] ファイル名
   #     [[CC]YY]MMDDhhmm[.SS]
   #   file ファイル名
   file /etc/hosts
   #   ls [メタキャラクタ]
   #    メタキャラクタ * ? [] {}
   ~~~

1. パイプとリダイレクト

   ~~~sh
   # 標準入出力
   #   0 -> 標準入力(キーワード)
   #   1 -> 標準出力(端末)
   #   2 -> 標準エラー出力(端末)
   # パイプ
   ls | wc -l
   dmesg | less
   #   tee [-a] ファイル名
   ls -l | tee ls_log | wc -l
   # 使い方
   #   コマンド > ファイル
   #   コマンド < ファイル
   #   コマンド >> ファイル
   #   コマンド 2> ファイル
   #   コマンド 2>> ファイル
   #   コマンド > ファイル 2>&1
   #   コマンド >> ファイル 2>&1
   #   コマンド << 終了文字
   #   コマンド1 | コマンド2
   #   コマンド1 2>&1 | コマンド2
   #   コマンド | tee ファイル名 | コマンド2
   #   コマンド &> ファイル
   #   コマンド > /dev/null 2>&1
   ~~~

1. テキスト処理フィルタ

   ~~~sh
    # cat [-n] [ファイル名]
    cat file1 file2 > new file
    # nl [-b -h -f ] <a|t|n>
    nl /etc/passwd
    # od [-t] <c|o|x> [ファイル名]
    od /etc/localtime
    od -t x /etc/localtime
    # head [-n 行数 -行数 -c バイト数] [ファイル名]
    head -5 /etc/services
    # tail [-n 行数 -行数 -c バイト数 -f] [ファイル名]
    tail -f /var/log/messages
    # cut [-c 文字数 -d 区切り文字 -f フィールド] [ファイル名]
    cut -d: -f 6 /etc/passwd
    # paste [-d] ファイル名1 ファイル名2 ...
    paste -d";" sample1.txt sample2.txt
    # tr [-d -s] [文字列1 [文字列2]]
    #    [:alpha:][:lower:][:upper:][:digit:][:alnum:][:space:]
    cat /etc/hosts | tr [:lower:] [:upper:]
    tr -d : < file1
    # sort [-b -f -r -n] [+開始位置 [-終了位置]] [ファイル名]
    # split [-行数] [入力ファイル名 [出力ファイル名]]
    # uniq [-d -u] [入力ファイル名 [出力ファイル名]]
    # wc [-c -l -w] [ファイル名]
    # xargs 標準入力から受け取る文字列を引数で実施
    find . -mtime +60 -type f | xargs rm　# 60日更新がないファイルを削除
    # md5sum,sha1sum,sha256sum,sha512sum
    # grep [-c -f -i -n -v -E] 検索パターン [ファイル名]
    # grep [-f ファイル名] [ファイル名]
    egrep '\s(22|53)/tcp' /etc/services
    grep -E '\s(22|53)/tcp' /etc/services
    grep -v '^#' /etc/httpd/conf/httpd.conf
    # sed [オプション] コマンド [ファイル]
    # sed [オプション] -e コマンド1 [-e コマンド2 ...] [ファイル]
    # sed [オプション] -f スクリプト [ファイル]
    sed '1,5d' file1.txt > file2.txt # file1.txtの1行目から5行目まで削除しfile2.txtに保存
    sed s/linux/Linux/ file1.txt # file1.txtのlinuxを大文字に変換
    sed -i 's/\r//' file1.sh # file1.shの\rを削除(windowsで編集したファイルをlinuxで実行など)
    sed '1,5s/^/>/' /etc/passwd # /etc/passwdの1行から5行目に>を追加
    sed y/ABC/123/ sample.txt # sample.txtのA->1,B->2,C->3に変更する
   ~~~

1. ファイルの基本的な編集

   ~~~sh
   # vi [-R] [ファイル名]
   # vi の編集モード
   #    i a I A o O
   #    x X dd dw yy p P r
   # vi のコマンドモード
   #    h l k j 0 $ H L gg G nG :n
   #    :q :q! :wq ZZ :W :e! :r :!コマンド :r!コマンド
   # vi の検索
   #    /パターン ?パターン n N :noh :%s/A/B :%s/A/B/g
   # vi の設定変更
   #    :set nu
   #    :set nonu
   #    :set ts=タブ幅
   ~~~

## 4.ファイルとプロセスの管理 ##

