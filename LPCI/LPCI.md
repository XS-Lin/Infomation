# LPCI1,2 学習メモ #

[LPCI1 概要](https://www.lpi.org/ja/our-certifications/lpic-1-overview)
[LPIC2 概要](https://www.lpi.org/ja/our-certifications/lpic-2-overview)

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

1. 基本的なファイル管理

   ~~~sh
   # gzip [-d -c -r] [filename]
   gzip datafile
   gzip -c datafile > datafile.gz
   # bzip2 [-d -c] [filename]
   # gunzip [filename]
   # bunzip2
   # xz [-d -k -l] [filename]
   # zcat bzcat xzcat
   ~~~

1. アーカイブの作成、展開

   ~~~sh
   # tar [-c -x -t -f -z -j -v -u -r -N -M --delete] ファイル名またはディレクトリ名
   tar cvf /dev/st0 /home #/homeのアーカイブをSCSIのテープドライブに作成
   tar xvzf software.tar.gz
   tar xvf /dev/sdb1 var/log/secure # /varの場合先頭の「/」がなくても可
   # cpio <-i -o -p> [-A -d -r -t -v]
   ls | cpio -o > /tmp/backuo # カレントディレクトリ以下を/tmp/backupファイルとしてバックアップ
   ~~~

1. パーミッション設定

   ~~~sh
   # chmod
   #    オプション -R
   #    対象 u g o a
   #    操作 + - =
   #    許可の種別 r w x s t
   chmod go+w samplefile
   chmod o-rw samplefile
   chmod 644 samplefile
   chmod u+s samplefile
   chmod g+s samplefile
   chmod o+t sampledir
   umask
   umask 027
   # chown [-R] user[:group] ファイル名またはディレクトリ名
   chown lpic:lpic testfile
   # chgrp [-R] group ファイル名またはディレクトリ名
   chgrp lpic testfile
   ~~~

1. ハードリンクとシンボリックリンク

   ~~~sh
   # ln [-s] リンク元(実体) リンクファイル
   ln file.original file.link_hard
   ln -s file.original file.link_sym
   ~~~

1. プロセスの管理

   ~~~sh
   # ps [a f u x -e -l -p -C -w]
   ps ax
   ps -e
   # top
   # pstree
   # kill -[シグナル名またはシグナルID] PID
   # kill -s [シグナル名またはシグナルID] PID
   # kill -SIG[シグナル名] PID
   kill 560
   kill -15 560
   kill -s 15 560
   kill -TERM 560
   kill -SIGTERM 560
   kill -KILL 560
   kill 570 571
   ~~~

   |id|name|description|
   |---|---|---|
   |1|HUP|端末制御不能もしくは切断による終了|
   |2|INT|Ctrl+C|
   |9|KILL|強制終了|
   |15|TERM|終了(デフォルト)|
   |18|CONT|継続|
   |19|STOP|一時停止|

   ~~~sh
   # pgrep [-u -g] プロセス名
   # killall
   # pkill [-u -g] [シグナル] プロセス名
   pkill -u lpic vim
   # jobs
   updatedb &
   jobs
   # nohup
   nohup updatedb & # ログアウトでも実行
   # バックグラウンドへ
   tail -f /var/log/messages
   bg 1
   # フォアグラウンドへ
   jobs
   fg 2
   # free [-m|-s 秒]
   # uptime
   # uname
   # uname -a
   # watch [-n 秒|-d|-t] コマンド
   watch -n 10 uptime
   ~~~

1. プロセスの実行優先度

   ~~~sh
   ps -l
   # nice [-n ナイス値] コマンド
   nice -n -10 updatedb # ナイス値をマイナスにはrootユーザのみ
   # renice [-n] ナイス値 [[-p] PID] [[-u] ユーザ名]
   renice -10 -p 1200
   renice 5 -u lpic
   ~~~

## 5.デバイスとLinuxファイルシステム ##

1. パーティションとファイルシステムの作成

   ~~~sh
   /dev/sda # disk1
   /dev/sdb # disk2
   /dev/sdc # disk3
   /dev/sdd # disk4
   /dev/sr0 # cd/dvd drive 1
   /dev/st0 # tape drive 1
   lsblk
   ~~~

   ~~~sh
   # 基本パーティションは最大4
   # 基本パーティションは拡張でき、論理パーティションを配置になる
   # 論理パーティションは必ず/dev/sda5以後
   /dev/sda1 #基本1
   /dev/sda2 #基本2
   /dev/sda3 #基本3(拡張)
   /dev/sda5 #論理1
   /dev/sda6 #論理2
   /dev/sda7 #論理3
   /dev/sda4 #基本4
   # UEFIベースのシステムはEFIシステムパテーションと1つ以上の基本パーティション使用可能
   # 拡張パテーションと論理パーティションは使用しない
   # パテーション分割のメリット:ファイルシステム障害の時に
   # 1.エラー範囲を1パテーションに限定できる
   # 2.大量ログで空き容量が不足の場合、被害を限定できる
   ~~~

   ~~~sh
   # / の下の/homeや/varは別のパーティションにすることが一般、耐障害と保守性を高める
   ~~~

   |パーティション|ディレクトリ|
   |---|---|
   |MBR|-|
   |/dev/sda1|/boot|
   |/dev/sda2|/|
   |/dev/sda3(swap)|-|
   |/dev/sda4|-|
   |/dev/sda5|/var|
   |/dev/sda6|/home|
   |/dev/sda7|/tmp|

   ~~~sh
   # fdisk [-l] デバイス名
   fdisk -l /dev/sda # パーティションテーブルの状態表示
   # fdisk
   #   l n d p t a w q m
   fdisk /dev/sdb # 500MBパーティション作成
   p
   n
   p
   1
   +500M
   p
   w
   # gdisk [-l] デバイス名
   gdisk /dev/sdc # 500MBパーティション作成
   n
   1
   +500M
   p
   w
   y
   # parted デバイス名 [-s サブコマンド]
   #    check 番号
   #    mklabel [gpt|msdos]
   #    mkpart 種類 開始 終了
   #    rm 番号
   #    print|p
   #    quit|q
   parted /dev/sdd
   mklabel gpt
   mkpart
   primary
   1
   500M
   p
   q
   # 対話ではなく一括処理
   parted /dev/sdb -s mkpart primary ext4 1 1G
   parted /dev/sdb -s p
   ~~~

   |ファイルシステム|説明|
   |---|---|
   |ext2|Linuxの標準|
   |ext3|ext2にジャーナリング追加|
   |ext4|ext3のkinou機能拡張|
   |XFS|SGI社開発,CentOs7/RHAT7の標準|
   |JFS|IBM社開発,元々はAIX用|
   |Btrfs|開発中|
   |iso9660|CD-ROM|
   |msdos|MS-DOS|
   |vfat|SDカードや古いWindows|
   |exFat|FATの後継,フラッシュメモリ向け|

   ~~~sh
   # mkfs [-t ファイルシステムタイプ] [-c] デバイス名
   #   ext2 ext3 ext4 XFS VFAT exFAT Btrfs
   mkfs -t ext4 /dev/sdb1
   # make2fs [-t ファイルシステムタイプ] [-j -c] デバイス名
   #   ext2 ext3 ext4
   # mkfs.btrfs デバイス名
   mkfs.btrfs /dev/sdb1 /dev/sdb2
   # mkswap デバイス名
   mkswap /dev/sda6
   ~~~

1. ファイルシステムの管理

   ~~~sh
   # ファイルシステムに書き込み失敗の原因
   #   1.空き容量が不足
   #   2.使用できるiノードがない
   # df [-h -H -k -i] [デバイス名またはディレクトリ名]
   df -h # 容量をMB単位で表示(1M=1048576)
   df -i # iノード表示
   # du [-a -l -c -k -m -s -S -h] [ファイル名またはディレクトリ名]
   # fsck [-t -a -r -A -N] [デバイス名]
   # e2fsck [-p -y -n] [デバイス名] # ext2,ext3,ext4のみ
   # tune2fs [-c -i -j -L] # ext2,ext3,ext4のみ
   tune2fs -j /dev/sda5
   # XFSの主なコマンド
   #   mkfs.xfs xfs_info xfs_db xfs_check xfs_admin xfs_fsr xfs_repair
   mkfs.xfs /dev/sdb1
   ~~~

1. ファイルシステムのマウントとアンマウント

   ~~~sh
   /etc/fstab
   # デバイス名 マウントポイント ファイルシステムの種類 マウントオプション dumpフラグ ブート時にfsckがチェックする順序
   #    主なマウントオプション
   #        async auto noauto defaults exec noexec ro rw unhide suid user users nouser
   # /dev/sda1 /boot ext3 defaults 1 2
   blkid
   # mount [オプション]
   # mount [オプション] デバイス名 マウントポイント
   #    主なオプション -a | -t ファイルシステム名 | -o
   mount
   mount -t ext4 /dev/sdb3 /data
   mount /data # /etc/fstab にデバイス名とマウントポイントの記載必要
   # unmount [オプション]
   # unmount [オプション] デバイス名またはマウントポイント
   #    主なオプション -a | -t ファイルシステム名
   # /etc/mtabは編集しない
   unmout /data
   unmout /dev/sdb3
   unmout -at xfs
   ~~~

1. ファイルの配置と検索

   ~~~sh
   # FHS ファイルシステム階層標準
   /bin # 基本的にコマンド、一般ユーザでも実行可
   /sbin # システム管理必須コマンド、rootユーザのみ実行可
   /etc # システムやアプリケーションの設定情報、スクリプトファイル
   /dev # ハードディスクやCDROMなどデバイスファイル
   /lib # 共有ライブラリやカーネルモジュール
   /media # DVD-ROM等リムーバブルメディアのマウントポイント
   /mnt # 一時的にマウントするファイルシステムのマウントポイント
   /opt # パケージ管理の仕組みを使ってプログラムがインストールされるディレクトリ
   /proc # カーネル内部情報にアクセスための仮想的なファイルシステム、実際は存在しない
   /root # スーパーユーザrootのホーン
   /boot # 起動時必要な設定やカーネルイメージ
   /home # ユーザごとのホームディレクトリがある
   /tmp # 一時ファイル、すべてのユーザが読み書き可能
   /var # ログファイル、メールやプリンタのスプールなど、頻繁に書き換えのファイル
   /var/cache # manコマンドで表示するために整形したデータなど
   /var/lock # アプリケーションが排他制御に使うためのロックファイル
   /var/log # システムログファイルmessages,メールシステムのmaillog(mail.log)など
   /var/run # システムの状態を示すファイル、pid調査可能(systemdの場合は不可)
   /var/spool # 印刷待ち(/var/spool/lpd)や予約されたジョブ(/var/spool/at)など
   /usr # コマンドやユーティリティ
   /usr/bin # ユーザが一般的に使うコマンド、緊急保守で使用しないもの
   /usr/sbin # システム管理コマンド、緊急保守で使用しないもの
   /usr/lib # プログラムに必要な共有ライブラリ
   /usr/local # ローカルシステムに必要とされるコマンド、ライブラリ、ドキュメントなど。さらにbin,sbin,libなど細分化
   /usr/share # x86やx86_64といったシステムアーキテクチャに依存しないファイル
   /usr/src # カーネルソースなど、ソースコードが配置される

   # find [検索ディレクトリ] [検索式]
   #   -name ファイル名
   #   -atime 日時
   #   -mtime 日時
   #   -perm
   #   -size
   #   -type
   #   -user
   #   -print
   #   -exec
   #   -ok
   #   -and
   #   -or
   #   -not
   find /home -name "*.rpm"
   find /usr/bin -type f -perm -u+s
   find ./work/ -name \*4\* -or -perm 766
   find ./work/ -name \*.dat -exec zip ./work/test.zip {}  \; #workディレクトリ内の拡張子.datを探し、圧縮ファイルtest.zipに追加
   # locate 検索パターン
   locate "*.h"
   # updatedb [-e path]
   updatedb -e /home
   # which コマンド名
   which useradd
   # whereis [-b -m -s] コマンド名
   whereis useradd
   # type コマンド
   type cat
   # locateはfindより高速
   # whichはPATHの通ったコマンドのみ検索
   ~~~

## 6.シェルとシェルスクリプト ##

1. シェル環境のカスタマイズ

   ~~~sh
   # 環境変数:コマンドや別のシェルで有効
   # シェル変数:シェル内有効
   # export でシェル変数を環境変数へ
   # env/printenv 環境変数
   # set 環境変数+シェル変数
   # set [-o][+o] [allexport emacs ignoreeof noglob vi]
   #    -o 有効にする +o 無効にする
   alias ls='ls -l'
   \ls # エイリアス使用しない
   alias lsless='ls -l | less'
   unalias lsless
   # [function] 関数名() { コマンド; } # 注意：{}の前後スペースが必要
   # [function] 関数名() {
   # {
   #     コマンド
   # }
   function lslink() { ls -l | grep '^l'; }
   function lslink() {
       ls -l $1 | grep '^l'
   }
   declare -f lslink # 関数定義表示
   unset lslink
   # bash設定ファイル
   /etc/profile # ログイン時に実行され、すべてのユーザ参照できる
   /etc/bash.bashrc # bash起動時に実行され、すべてのユーザ参照できる
   /etc/bashrc # ~/.bashrcから参照
   ~/.bash_profile # ログイン時に実行される
   ~/.bash_login # ~/.bash_profileがない場合、ログイン時に実行される
   ~/.profile # ~/.bash_profileも~/.bash_loginもない場合、ログイン時に実行される
   ~/.bashrc # bash起動時に実行される
   ~/.bash_logout # ログアウト時に実行される
   ~~~

   **/etc以下の設定ファイルははすべてユーザ影響、ホームはユーザーごと**

   * bash 起動時設定ファイルの実行順番

      ~~~sh
      # ログイン
      #   ↓
      # /etc/profile
      #   ↓
      # /etc/bash.bashrc
      #   ↓              なければ ↓       なければ ↓
      # ~/.bash_profile | ~/.bash_login | ~/.profile
      #   ↓              なければ ↓
      # ~/.bashrc                ↓
      #   ↓                      ↓
      # /etc/bashrc              ↓
      #   ↓
      # bash起動
      ~~~

      ~~~sh
      # 対話型シェル
      # ~/.bashrc      なければ   ↓
      #   ↓                      ↓
      # /etc/bashrc              ↓
      #   ↓
      # bash起動
      ~~~

1. シェルスクリプト

   ~~~sh
   # lsld スクリプトがある場合
   cat lsld
   bash lsld
   source lsld
   . lsld
   chmod a+x lsld
   ./lsld
   # exec コマンド
   zhs # 現在のプロセスを待機し、新しいzshプロセス起動
   exec zhs # 現在のプロセスをzshに変更
   ~~

   |変数名|意味|
   |---|---|
   |$0|ファイル名(フルパス)|
   |$1|1番目の引数|
   |$2|2番目の引数|
   |$#|引数の数|
   |$@|すべての引数(スペース区切り)|
   |$*|すべての引数(環境変数IFSで指定文字区切り)|

   ~~~sh
   # 戻り値
   $? #0:正常終了
   ~~~

   ~~~sh
   # ファイルチェック
   # test 条件
   # [ 条件 ]
   # 主な条件式
   #   -f ファイル
   #   -d ディレクトリ
   #   -r ファイル
   #   -w ファイル
   #   -x ファイル
   #   -s ファイル
   #   -L ファイル
   #   -e ファイル
   #   ファイル1 -nt ファイル2
   #   ファイル1 -ot ファイル2
   #   数値1 -eq 数値2
   #   数値1 -ge 数値2
   #   数値1 -gt 数値2
   #   数値1 -le 数値2
   #   数値1 -lt 数値2
   #   数値1 -ne 数値2
   #   -n 文字列
   #   -z 文字列
   #   文字列1 = 文字列2
   #   文字列1 != 文字列2
   #   ! 条件
   #   条件1 -a 条件2
   #   条件1 -o 条件2
   # 制御構造
   #   if
   #     if
   #     then
   #       実行文1
   #     else
   #       実行文2
   #     fi
   #   case
   #     case 式 in:
   #       値1)
   #         実行文1 ;;
   #       値2)
   #         実行文2 ;;
   #     esac
   # 繰り返し
   #   for
   #     for 変数名 in 変数代入する値リスト
   #     do
   #       実行文
   #     done
   for i in `seq 10 15`
   do
     echo $i
   done
   #   while
   #     while 条件文
   #     do
   #       実行文
   #     done
   # 標準入力
   #   read 変数
   # 実行環境
   # ファイルの一行目: #!/bin/bash
   ~~~

## 7.ユーザーインターフェースとデスクトップ ##

   ~~~sh
   /etc/X11/xorg.conf
   # Files Moudule InputDevice InputClass Device Monitor Modes Screen ServerLayout
   # xhost [+-] ホスト名
   xhost +remotepc # local
   DISPLAY=localpc:0 # remote
   export DISPLAY # remote
   rxvt & # remote

   systemctl enable lightdm.service # GUIの自動有効
   ~~~

## 8.管理タスク ##

1. ユーザとグループの管理

   ~~~sh
   /etc/passwd
   # <ユーザ名>:<パスワード>:<UID(ユーザID)>:<GID(グループID)>:<GECOS(コメント)>:<ホームディレクトリ>:<デフォルトシェル>
   /etc/shadow # パスワード保存(rootユーザのみ)
   /etc/group
   # <グループ名>:<グループパスワード>:<GID(グループID)>:<グループメンバー>
   # useradd [-c -d -g -G -s -D -m] ユーザー名
   useradd -c "Linux user" -d /home/linux -s /bin/bash linuxuser
   /etc/skel # ホームディレクトリ作成の時に、自動コピーする
   # usermod [-c -d -g -G -s -L -U] ユーザー名
   usermod -G bproject lpic
   # userdel [-r] ユーザー名
   userdel -r lpicjp
   # passwd [-l -u] [ユーザー名]
   # groupadd グループ名
   # groupmod [-g -n] グループ名
   groupmod -n develop devel
   # groupdel グループ名
   groupdel sales # グループに所属するユーザがある場合削除失敗
   # id [ユーザー名]
   id student
   # getent [passwd|group]
   getent passwd
   ~~~

1. ジョブスケジューリング

   ~~~sh
   # ユーザ
   # /var/spool/cron/ユーザ名/ または /var/spool/cron/crontabs/ユーザ名/
   # crontab [-e -l -r -i -u]
   # 分[0-59] 時[0-23] 日[1-31] 月[1-12]|[jan-dec] 曜日[0-7][Sun-Sat] コマンド
   15 23 * * * /usr/local/bin/backup #毎日23:15にbackupプログラム実行
   0 9,12 * * 1 /usr/local/bin/syscheck #毎週月曜9時と12時syscheck実行
   0 */2 * * * /usr/local/bin/syscheck #2時間毎にsyscheck実行
   # システム
   # /etc/crotab
   # /etc/cron.d/
   # /etc/cron.hourly/
   # /etc/cron.daily/
   # /etc/cron.weekly/
   # /etc/cron.monthly/
   ~~~

   ~~~sh
   # at オプション
   # at [-f ファイル名] 日時
   at 5:00 tomorrow
   at> /usr/local/sbin/backup
   at> ^D #crtl+d
   at -f my_jobs 23:30
   # 日時
   #   22:00 10pm noon midnight today tomorrow
   #   now + 3 days
   #   10pm + 2 weeks
   ~~~

   ~~~sh
   /etc/cron.allow # 優先
   /etc/cron.deny
   # どちらもなければすべてのユーザ利用可能
   /etc/at.allow # 優先
   /etc/at.deny
   # どちらもなければrootユーザのみ利用可能
   ~~~

   ~~~sh
   /etc/systemd/system/lpic.timer #書式はman 7 systemd.time
   systemd-run --unit=lpictest --on-active=1s --on-unit-active=60s uptime # lpictest60秒毎に実行
   systemctl list-timers
   journalctl -u lpictest # 実行結果確認
   systemctl stop lpictest.timer
   ~~~

1. ローカライゼーションと国際化

   ~~~sh
   # ロケールの主なカテゴリ
   LC_CTYPE LC_COLLATE LC_MESSAGE LC_MONETARY LC_NUMERIC LC_TIME
   # 主なロケール名
   C POSIX # 英語
   ja_JP.utf8(ja_JP.UTF8)
   ja_JP.eucJP
   ja_JP.shiftJIS
   en_US.utf8
   # locale [-a -m]
   LANG=C man ls # 一時的にlsのマニュアルを英語表示
   # 文字コード
   ASCII ISO-8859 UTF-8 EUC-JP SHIFT-JIS ISO-2022-JP
   # iconv [-f -t -l]
   iconv -f eucjp -t utf8 report.euc.txt > report.utf8.txt
   iconv -l

   ls /usr/share/zoneinfo/
   cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
   export TZ="Asia/Tokyo"

   /etc/timezone # すべてのユーザ適用
   tzselect
   19
   1
   ~~~

## 9.必須サービス ##

1. システムクロック

   ~~~sh
   date "+%Y/%n/%d (%a)"# %Y %m %d %H %M %a %b
   # date [MMDDhhmm[CC]YY[.SS]] システムクロック設定
   tar czf `data "+%Y%m%d"`.tar.gz /data # 20181210.tar.gzのアーカイブ作成
   hwclock -r # ハードウェアクロック表示
   hwclock -w(--systohc)
   hwclock -s(--hctosys)
   # timedatectl [status set-time set-timezone list-timezone set-ntp]
   timedatectl set-time 2019-03-12 12:24:00
   timedatectl set-ntp yes
   timedatectl list-timezones | grep -i tokyo
   timedatectl set-timezone Asia/Tokyo
   # ntpdate サーバ名
   ntpdate time.server.lpic.jp
   /etc/init.d/ntpd.start
   systemctl start ntpd.service
   ntpq -p localhost
   /etc/ntp.conf
   /etc/chrony.conf
   # chronyd [acrtivity sources sourcestats tracking quit]
   chronyc sources
   # 注意：ntpとchronycは同時使用不可
   /etc/rsyslog.conf
   /etc/rsyslog.d
   # rsyslogの主なプラグインモジュール
   #   imuxsock imjournal imklog immark imudp imtcp
   #   rsyslog.confの書式
   #     ファシリティ.プライオリティ 出力先
   #       ファシリティ:auth,cron,daemon,kern,lpr,mail,user,local0-7
   #       プライオリティ:emerg,alert,crit,err,warning,notice,info,debug,none
   #       出力先:/var/log/messages,/dev/tty1,@sv.example.com,@@sv.example.com,violet,*
   #kern.* -/var/log/kern.log
   #authpriv.* /var/log/secure
   #*.*;authrpiv.none /var/log/messages
   systemctl restart rsyslog
   # logger [-p ファシリティ.プライオリティ] [-t タグ] メッセージ
   logger -p syslog.info -t Test "logger test message"
   # systemd-cat コマンド
   systemd-cat uptime
   journalctl -xe
   # /var/log/message (Debain or Ubuntu の場合 /var/log/syslog)
   #   日時 出力元ホスト名 メッセージ出力元 メッセージ
   tail -f /var/log/message
   grep eth0 /var/log/message
   # /var/log/secure
   who
   w
   last
   lastlog
   # journalctl [-f -r -e -x -k -b -p -u --full --no-pager]
   journalctl -u ssh.service
   /etc/systemd/journald.conf
   sudo systemctl restart systemd-journald # rsyslogdが出力しない場合がある。その時rsyslog.serviceも再起動
   # ログのローテーション
   /etc/logrotate.conf
   ~~~

1. メール管理

   ~~~sh
   netstat -atnp | grep 25
   /etc/init.d/postfix start
   systemctl start postfix.service
   mail -s samplemail student
   #Hello!
   #.
   mail
   1
   q
   # /etc/aliases
   newaliases
   # .forward 各ユーザのホームに定義
   mailq
   ~~~

1. プリンター

   ~~~sh
   #/etc/cups/cupsd.conf
   #/etc/cups/printers.conf
   /etc/init.d/cups start
   systemctl start cups.service
   netstat -at | grep ipp
   #lpr [-# -P] filename
   lpdr -#5 /etc/passwd
   dmesg | lpdr
   #lpq [-P printername] [username] [jobnumber]
   lpq
   #lprm [-P p]
   lprm - # rootユーザの場合はすべてのユーザの印刷ジョブ削除
   ~~~

## 10.ネットワークの基礎 ##

1. TCP/IP

   |クラス|IP範囲|プライベートIP範囲|
   |---|---|---|
   |A|0.0.0.0-127.255.255.255|10.0.0.0-10.255.255.255|
   |B|128.0.0.0-127.255.255.255|172.16.0.0-172.31.255.255|
   |C|192.0.0.0-223.255.255.255|192.168.0.0-192.168.255.255|

   ~~~sh
   /etc/services # port
   /etc/hostname
   /etc/hosts
   /etc/sysconfig/network-scripts # /etc/network/interfaces
   systemctl status NetworkManager
   # nmcli
   #   general
   #     status
   #     hostname
   #     hostname ホスト名
   #   networking
   #     on|off
   #     connectivity [check]
   #   radio
   #     wifi
   #     wifi on|off
   #     wwan
   #     wwan on|off
   #     all on|off
   #   connection
   #     show [--active]
   #     modify インターフェース名 パラメータ
   #     up <id>
   #     down <id>
   #   device
   #     status
   #     show インターフェース名
   #     modify インターフェース名 パラメータ
   #     connect インターフェース名
   #     disconnect インターフェース名
   #     delete インターフェース名
   #     monitor インターフェース名
   #     wifi list
   #     wifi connect <ssid>
   #     wifi hotspot
   #     wifi rescan
   nmcli general status
   nmcli radio wifi on
   nmcli connection show
   nmcli connection add type ethernet ifname enp0s3 con-name eth1
   nmcli connection modify eth1 ipv4.method auto
   # hostnamectl [status set-hostname]
   hostnamectl set-hostname vm2
   ~~~

1. ネットワークトラブルシューティング

   ~~~sh
   #ping [-c -i]
   ping -c 4 www.lpi.org # ping6
   traceroute pepper.lpic.jp # traceroute6
   tracepath pepper.lpic.jp # tracepath6
   hostname
   # netstat [-a -c -i -n -p -r -t -u]
   netstat -at
   netstat -r
   # nc [-l -p -u -o] host port
   nc -l -p 12345 -o listen.org # ポート12345を待ち状態にして、受信データをlisten.orgに保存
   nc centos7.example.com 12345 <data.txt
   # route [-F -C]
   # route add
   # route del
   # ルーティングテーブルの項目
   #   Destination Gateway Genmask Flags Metric Ref Use Iface
   route add -net 192.168.0.0 netmask 255.255.255.0 gw 172.30.0.254
   route add default gw 172.30.0.1
   route del -net 192.168.0.0 netmask 255.255.255.0 gw 172.30.0.254
   echo 1 > /proc/sys/net/ipv4/ip_forward
   # ip link|addr|route [show|add] [デバイス]
   ip link show
   ip route show
   ip addr show eth0
   ip addr add 192.168.11.12/24 dev eth0
   ip route add default via 192.168.11.1
   # RHAT7/CentOS7 はroute,netstat,ifconfigを廃止して、ip,ss推奨
   # ifconfig [ネットワークインターフェース名] [パラメータ]
   ifconfig
   ifconfig eth0 192.168.0.50 netmask 255.255.255.0 # 再起動すると失われる。永久設定はファイルに
   ifup
   ifdown
   /etc/hosts
   /etc/resolv.donf
   /etc/nsswitch.conf
   /etc/systemd/resolved.conf
   sysytemctl restart systemd-resolved.service
   # host [-v] ホスト名またはIP [DNSサーバ]
   host www.lpi.jp
   host 192.168.0.6
   # dig [-x] [@DNSサーバ] ホスト名またはIP [a|aaaa|any|mx|ns]
   dig lpi.jp mx
   ~~~

## 11.セキュリティ ##

1. ホストレベルのセキュリティ

   ~~~sh
   /etc/xinetd.conf
   # instances log_type log_on_success log_on_failure cps includedir
   /etc/xinetd.d
   # disable socket_type wait user server server_args log_on_failure nice only_from on_access access_times
   /etc/init.d/xinetd restart

   /etc/systemd/system/telnet.socket
   /etc/systemd/system/telnet.service

   /etc/hosts.allow
   /etc/hosts.deny
   # ALL
   # A EXCEPT B
   # LOCAL
   # PARANOID

   netstat -atu
   ss -atu
   lsof -i
   nmap
   fuser -n tcp 8888
   find / -perm -u+s -ls # SUID濫用は危険
   ~~~

1. ユーザーに対するセキュリティ管理

   ~~~sh
   #change [-l -m -M -d -W -E]
   # 3日以内パスワード変更,有効期限28日,期限きれ7日前に警告,期限きれるとロック,2019-12-31まで使用可
   change -m 3 -M 28 -W 7 -I 0 -E 2019-12-31 student
   touch /etc/nologin # root以外のユーザログイン禁止
   usermod -s /sbin/nologin lpic # ユーザlpicログイン禁止
   # su [- [username]]
   /etc/sudoers
   # ユーザー名 ホスト名 実行ユーザー名 コマンド NOPASSED:
   student ALL=(ALL) /sbin/shutdown
   student ALL=(ALL) ALL # rootと同等になる
   %wheel ALL=(ALL) NOPASSWS:ALL # wheelグループすべてのrootコマンドパスワード不要
   sudo /sbin/shutdown -h now
   sudo -l
   # sudo [-l -i -s -u ユーザー] [コマンド]
   # ulimit [-a -c -f -n -v [リミット]]
   ulimit -a
   ~~~

1. Open SSH

   ~~~sh
   /etc/ssh/sshd_config
   # Port Protocol HostKey PermitRootLogin RSAAuthentication AuthorizedKeysFile
   # PermitEmptyPasswords PasswordAuthentication X11Forwarding
   /etc/init.d/sshd start
   /etc/init.d/ssh start
   systemctl start sshd.service
   # ssh [[ログインユーザ@]ホスト]
   ssh sv1.lpic.jp
   ssh student@sv1.lpic
   ~/.ssh/known_hosts # 公開認証鍵保存
   # ssh-keygen [-t -p -f -R -b]
   ssh-keygen -t dsa
   # idenity id_dsa id_rsa id_ecdsa id_ed25519
   scp ~/.ssh/id_dsa.pub sv1.lpic.jp:publickey # pulickey転送
   ssh sv1.lpicljp # 接続(パスワード必要)
   cat publickey >> ~/.ssh/authorized_keys # 公開鍵追加
   ~~~

1. GnuPG

   ~~~sh

   ~~~

[第10章 SYSTEMD によるサービス管理](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd)

## 知識要項と練習 ##

* トピック101：システムアーキテクチャ
  * 101.1ハードウェア設定の決定と設定(総重量： 2)

    説明： 候補者は、基本的なシステムハードウェアを決定して構成できる必要があります

    主な知識分野：

    * 内蔵周辺機器を有効/無効にします。
    * さまざまな種類の大容量記憶装置を区別します。
    * デバイスのハードウェアリソースを決定します。
    * さまざまなハードウェア情報を一覧表示するためのツールとユーティリティ（lsusb、lspciなど）。
    * USBデバイスを操作するためのツールとユーティリティ
    * sysfs、udev、dbusの概念的な理解。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。
      / sys /
      / proc /
      / dev /
      modprobe
      lsmod
      lspci
      lsusb

  * 101.2システムを起動する(総重量： 3)

    説明： 候補者は、ブートプロセスを通じてシステムを誘導できる必要があります。

    主な知識分野：

    * 起動時に共通のコマンドをブートローダに提供し、オプションをカーネルに提供する。
    * BIOS / UEFIからのブートシーケンスの知識を試してブートを完了させてください。
    * SysVinitとsystemdの理解。
    * アップスタートの意識。
    * ログファイルのブートイベントを確認します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      dmesg
      journalctl
      BIOS
      UEFI
      bootloader
      kernel
      initramfs
      INIT
      SysVinit
      systemd

  * 101.3ランレベル/ブートターゲットを変更し、システムをシャットダウンまたは再起動する(総重量： 3)

    説明： 候補者は、システムのSysVinitランレベルまたはシステムブートターゲットを管理できる必要があります。 この目的には、シングルユーザーモードへの変更、システムのシャットダウンまたは再起動が含まれます。 候補者は、ランレベル/ブートターゲットを切り替えてプロセスを適切に終了する前に、ユーザーに警告する必要があります。 この目的には、デフォルトのSysVinitランレベルまたはシステムブートターゲットの設定も含まれます。 また、SysVinitまたはsystemdの代替としてのUpstartの認識も含まれています。

    主な知識分野：

    * デフォルトのランレベルまたはブートターゲットを設定します。
    * シングルユーザーモードを含むランレベル/ブートターゲット間の変更。
    * コマンドラインからシャットダウンして再起動します。
    * ランレベル/ブートターゲットやその他の主要なシステムイベントを切り替える前に、ユーザーに警告してください。
    * プロセスを適切に終了します。
    * acpidの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/inittab
      shutdown
      INIT
      /etc/init.d/
      telinit
      systemd
      systemctl
      /etc/systemd/
      /usr/lib/systemd/
      wall
* トピック102：Linuxのインストールとパッケージ管理
  * 102.1デザインのハードディスクレイアウト(総重量： 2)

    説明： 候補者は、Linuxシステム用のディスク・パーティション・スキームを設計できるはずです。

    主な知識分野：

    * ファイルシステムを割り当て、スペースを別のパーティションやディスクにスワップします。
    * 設計をシステムの意図された使用に合わせる。
    * /bootパーティションが、ブートに必要なハードウェアアーキテクチャの要件を満たしていることを確認します。
    * LVMの基本機能についての知識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /（root）ファイルシステム
      /varファイルシステム
      /homeファイルシステム
      /bootファイルシステム
      EFIシステムパーティション（ESP）
      スワップスペース
      マウントポイント
      パーティション
  * 102.2ブートマネージャをインストールする(総重量： 2)

    説明： 候補者は、ブートマネージャを選択、インストール、設定できる必要があります。

    主な知識分野：

    * 代替ブート場所とバックアップブートオプションを提供する。
    * GRUB Legacyなどのブートローダをインストールして設定します。
    * GRUB 2の基本的な設定変更を実行します。
    * ブートローダと対話します。
    以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      menu.lst、grub.cfg、grub.conf
      grub-install
      grub-mkconfig
      MBR

  * 102.3共有ライブラリを管理する(総重量： 1)

    説明： 候補者は、実行可能プログラムが依存する共有ライブラリを決定し、必要に応じてインストールすることができます。

    主な知識分野：

    * 共有ライブラリを識別する。
    * システムライブラリの一般的な場所を特定します。
    * 共有ライブラリをロードします。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      ldd
      ldconfig
      /etc/ld.so.conf
      LD_LIBRARY_PATH

  * 102.4 Debianパッケージ管理を利用する(総重量： 3)

    説明： Debianパッケージツールを使用してパッケージ管理を実行できるはずです。

    主な知識分野：

    * Debianバイナリパッケージをインストール、アップグレード、アンインストールします。
    * インストールされている場合とインストールされていない場合がある特定のファイルまたはライブラリを含むパッケージを探します。
    * バージョン、コンテンツ、依存関係、パッケージの完全性、インストール状態（パッケージのインストールの有無）などのパッケージ情報を取得します。
    * aptの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/apt/sources.list
      dpkg
      dpkg-reconfigure
      apt-get
      apt-cache

  * 102.5 RPMとYUMパッケージ管理を使用する(重量： 3)

    説明： 候補者は、RPM、YUM、およびZypperを使用してパッケージ管理を実行できる必要があります。

    主な知識分野：

    * RPM、YUM、およびZypperを使用してパッケージをインストール、再インストール、アップグレード、および削除します。
    * RPMパッケージのバージョン、ステータス、依存性、完全性、署名などの情報を取得します。
    * パッケージが提供するファイルを特定し、特定のファイルがどのパッケージから来るかを調べる。
    * dnfの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      rpm
      rpm2cpio
      /etc/yum.conf
      /etc/yum.repos.d/
      yum
      zypper

  * 102.6仮想化ゲストとしてのLinux(総重量： 1)

    説明： 候補者は、Linuxゲストシステム上での仮想化とクラウドコンピューティングの関係を理解する必要があります。

    主な知識分野：

    * 仮想マシンとコンテナの一般的な概念を理解する。
    * コンピューティングインスタンス、ブロックストレージ、ネットワーキングなど、IaaSクラウド内の共通要素の仮想マシンを理解する。
    * システムが複製されたりテンプレートとして使用されたときに変更しなければならないLinuxシステムの固有のプロパティを理解する。
    * 仮想マシン、クラウドインスタンス、およびコンテナの展開にシステムイメージを使用する方法を理解する。
    * Linuxと仮想化製品を統合するLinux拡張を理解する。
    * クラウド初期化の意識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      仮想マシン
      Linuxコンテナ
      アプリケーションコンテナ
      ゲストドライバー
      SSHホストキー
      DバスマシンID

* トピック103：GNUとUnixコマンド
  * 103.1コマンドラインでの作業(重要度：4)

    説明： コマンドラインを使って、シェルやコマンドを利用できる。 対象はBashシェルを想定しています。

    主な知識分野：

    * シングルシェルコマンドと1行のコマンドシーケンスを使用して、コマンドラインで基本的な作業を実行します。
    * 環境変数の定義、参照、およびエクスポートを含むシェル環境の使用と変更。
    * コマンド履歴を使用して編集します。
    * 定義されたパスの内側と外側のコマンドを呼び出します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      bash
      echo
      env
      export
      pwd
      set
      unset
      type
      which
      man
      uname
      history
      .bash_history
      Quoting

  * 103.2フィルターを使用してテキストストリームを処理する(総重量： 2)

    説明： 候補者は、テキストストリームにフィルタを適用できる必要があります。

    主な知識分野：

    * テキストファイルと出力ストリームをテキストユーティリティフィルタで送信して、GNU textutilsパッケージの標準UNIXコマンドを使用して出力を変更します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      bzcat
      cat
      cut
      head
      less
      md5sum
      nl
      od
      paste
      sed
      sha256sum
      sha512sum
      sort
      split
      tail
      tr
      uniq
      wc
      xzcat
      zcat

  * 103.3基本的なファイル管理を実行する(総重量： 4)

    説明： 基本的なLinuxコマンドを使用して、ファイルとディレクトリを管理できます。

    主な知識分野：

    * ファイルとディレクトリを個別にコピー、移動、削除します。
    * 再帰的に複数のファイルとディレクトリをコピーします。
    * 再帰的にファイルとディレクトリを削除します。
    * コマンドにはシンプルで高度なワイルドカード指定を使用します。
    * findを使用して、タイプ、サイズ、または時間に基づいてファイルを検索し、それに基づいて動作します。
    * tar、cpio、ddの使い方。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      cp
      find
      mkdir
      mv
      ls
      rm
      rmdir
      touch
      tar
      cpio
      dd
      file
      gzip
      gunzip
      bzip2
      bunzip2
      xz
      unxz
      file globbing

  * 103.4ストリーム、パイプ、リダイレクトを使用する(総重量： 4)

    説明： 候補者は、テキストデータを効率的に処理するために、ストリームをリダイレクトして接続できる必要があります。 タスクには、標準入力、標準出力、および標準エラーのリダイレクト、あるコマンドの出力を別のコマンドの入力にパイプし、あるコマンドの出力を別のコマンドの引数として使用し、stdoutとファイルの両方に出力を送ります。

    主な知識分野：

    * 標準入力、標準出力、および標準エラーをリダイレクトします。
    * あるコマンドの出力を別のコマンドの入力にパイプします。
    * あるコマンドの出力を別のコマンドの引数として使用します。
    * stdoutとファイルの両方に出力を送信します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      tee
      xargs

  * 103.5プロセスの作成、監視、終了(総重量： 4)

    説明： 候補者は、基本的なプロセス管理を実行できる必要があります。

    主な知識分野：

    * フォアグラウンドとバックグラウンドでジョブを実行します。
    * ログアウト後にプログラムを実行し続けるように指示します。
    * アクティブなプロセスを監視します。
    * 表示するプロセスを選択してソートします。
    * シグナルをプロセスに送信します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      ＆
      bg
      fg
      jobs
      kill
      nohup
      ps
      top
      free
      uptime
      pgrep
      pkill
      killall
      watch
      screen
      tmux

  * 103.6プロセス実行の優先順位を変更する(総重量： 2)

    説明： 候補者は、プロセスの実行優先度を管理できる必要があります。

    主な知識分野：

    * 作成されたジョブのデフォルトの優先順位を知る。
    * デフォルトよりも高いまたは低い優先順位でプログラムを実行します。
    * 実行中のプロセスの優先順位を変更します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      nice
      ps
      renice
      top

  * 103.7正規表現を使ってテキストファイルを検索する(総重量： 3)

    説明： 候補者は、正規表現を使用してファイルとテキストデータを操作できる必要があります。 この目的には、いくつかの表記要素を含む単純な正規表現の作成と、基本正規表現と拡張正規表現の違いの理解が含まれます。 また、正規表現ツールを使用して、ファイルシステムまたはファイルコンテンツを介して検索を実行することも含まれます。

    主な知識分野：

    * いくつかの表記要素を含む単純な正規表現を作成します。
    * 基本正規表現と拡張正規表現の違いを理解する。
    * 特殊文字、文字クラス、数量子、アンカーの概念を理解する。
    * 正規表現ツールを使用して、ファイルシステムまたはファイルコンテンツを検索します。
    * 正規表現を使用して、テキストの削除、変更、置換を行います。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      grep
      egrep
      fgrep
      sed
      正規表現（7）

  * 103.8基本的なファイル編集(総重量： 3)

    説明： 候補者は、viを使用してテキストファイルを編集できる必要があります。 この目的は、viナビゲーション、viモード、挿入、編集、削除、コピー、およびテキストの検索を含みます。 また、他の一般的なエディタの認識とデフォルトエディタの設定も含まれます。

    主な知識分野：

    * viを使用してドキュメントをナビゲートします。
    * viモードを理解し、使用する。
    * viにテキストを挿入、編集、削除、コピー、検索する。
    * Emacs、nano、vimの認識。
    * 標準エディタを設定します。
    * 用語とユーティリティ：

      vi
      /、？
      h、j、k、l
      i, o, a
      d、p、y、dd、yy
      ZZ、：w !,：q！
      EDITOR

* トピック104：デバイス、Linuxファイルシステム、ファイルシステム階層標準

  * 104.1パーティションとファイルシステムを作成する(総重量： 2)

    説明： 候補者は、ディスクパーティションを構成してから、ハードディスクなどのメディアにファイルシステムを作成することができます。 これには、スワップパーティションの処理も含まれます。

    主な知識分野：

    * MBRとGPTパーティションテーブルを管理する
    * さまざまなmkfsコマンドを使用して、次のようなさまざまなファイルシステムを作成します。
      ext2 / ext3 / ext4
      XFS
      VFAT
      exFAT

    * マルチデバイスファイルシステム、圧縮およびサブボリュームを含む、Btrfsの基本的な機能に関する知識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      fdisk
      gdisk
      parted
      mkfs
      mkswap

  * 104.2ファイルシステムの整合性を維持する(総重量： 2)

    説明： 候補者は、標準のファイルシステムと、ジャーナリングファイルシステムに関連する余分なデータを維持できる必要があります。

    主な知識分野：

    * ファイルシステムの整合性を検証する。
    * 空き領域とinodeを監視します。
    * 単純なファイルシステムの問題を修復する。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      du
      df
      fsck
      e2fsck
      mke2fs
      fstrim
      xfs_repair
      xfs_fsr
      xfs_db

  * 104.3ファイルシステムのマウントとアンマウント(総重量： 3)

    説明： ファイルシステムのマウントを設定できる必要があります。

    主な知識分野：

    * ファイルシステムを手動でマウントおよびアンマウントする
    * 起動時のファイルシステムのマウントを設定します。
    * ユーザーがマウント可能なリムーバブルファイルシステムを構成します。
    * ファイルシステムの識別とマウントにラベルとUUIDを使用する。
    * システムマウントユニットの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/fstab
      /media/
      mount
      umount
      blkid
      lsblk

  * 104.4が削除されました
  * 104.5ファイルのパーミッションと所有権を管理する(総重量： 3)

    説明： 受験者は、パーミッションと所有権を適切に使用してファイルへのアクセスを制御できる必要があります。

    主な知識分野：

    * 通常のファイルや特別なファイル、ディレクトリのアクセス権を管理する。
    * セキュリティを維持するには、suid、sgid、スティッキービットなどのアクセスモードを使用します。
    * ファイル作成マスクを変更する方法を理解する。
    * グループフィールドを使用して、グループメンバーへのファイルアクセスを許可します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      chmodコマンド
      umask
      chownコマンド
      chgrpコマンド

  * 104.6ハードリンクとシンボリックリンクの作成と変更(総重量： 2)

    説明： ファイルへのハードリンクとシンボリックリンクを作成して管理できる必要があります。

    主な知識分野：

    * リンクを作成します。
    * ハードリンクおよび/またはソフトリンクを特定します。
    * コピーとファイルのリンク。
    * リンクを使用して、システム管理タスクをサポートします。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      ln
      ls

  * 104.7システムファイルを検索し、ファイルを正しい場所に配置する(総重量： 2)

    説明： 一般的なファイルの場所やディレクトリの分類など、ファイルシステム階層標準（FHS）に精通している必要があります。

    主な知識分野：

    * FHSの下にあるファイルの正しい場所を理解する。
    * Linuxシステムでファイルとコマンドを見つける。
    * FHSで定義されているような重要なファイルとディレクトリの場所と目的を理解する。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      find
      locate
      updatedb
      whereis
      which
      type
      /etc/updatedb.conf

* トピック105：シェルとシェルスクリプト
  * 105.1シェル環境をカスタマイズして使用する(重要度：4)

    説明： 候補者は、ユーザーのニーズを満たすためにシェル環境をカスタマイズできる必要があります。 候補者は、グローバルおよびユーザープロファイルを変更できる必要があります。

    主な知識分野：

    * ログイン時や新しいシェルの作成時に環境変数（PATHなど）を設定します。
    * 頻繁に使用される一連のコマンドには、Bash関数を記述します。
    * 新しいユーザーアカウントのスケルトンディレクトリを更新します。
    * 適切なディレクトリでコマンド検索パスを設定します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      .
      source
      /etc/bash.bashrc
      / etc / profile
      env
      export
      set
      unset
      〜/ .bash_profile
      〜/ .bash_login
      〜/ .profile
      〜/ .bashrc
      〜/ .bash_logout
      function
      alias

  * 105.2簡単なスクリプトをカスタマイズする(総重量： 4)

    説明： 候補者は既存のスクリプトをカスタマイズしたり、単純な新しいBashスクリプトを書くことができます。

    主な知識分野：

    * 標準のsh構文（ループ、テスト）を使用します。
    * コマンド置換を使用します。
    * 成功または失敗の戻り値、またはコマンドによって提供されるその他の情報をテストします。
    * 連鎖コマンドを実行します。
    * スーパーユーザーに条件付きメーリングを実行します。
    * シバン（＃！）行からスクリプトインタープリタを正しく選択してください。
    * スクリプトの場所、所有権、実行、suid-rightsを管理します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      for
      while
      test
      if
      read
      seq
      exec
      ||
      &&
* トピック106：ユーザーインターフェースとデスクトップ
  * 106.1 X11のインストールと設定(総重量： 2)

    説明： 候補者はX11をインストールして設定できるはずです。

    主な知識分野：

    * X11アーキテクチャの理解
    * X Window設定ファイルの基本的な理解と知識。
    * キーボードレイアウトなど、Xorg設定の特定の側面を上書きします。
    * ディスプレイマネージャやウィンドウマネージャなどのデスクトップ環境のコンポーネントを理解する。
    * Xサーバへのアクセスを管理し、リモートXサーバ上のアプリケーションを表示します。
    * ウェイランドの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/X11/xorg.conf
      /etc/X11/xorg.conf.d/
      〜/ .xsession-errors
      xhost
      xauth
      DISPLAY
      X

  * 106.2グラフィカルデスクトップ(総重量： 1)

    説明： 候補者は主要なLinuxデスクトップを認識する必要があります。 さらに、候補者は、リモートデスクトップセッションにアクセスするために使用されるプロトコルに注意する必要があります。

    主要な知識分野:

    * 主要なデスクトップ環境の認識
    * リモートデスクトップセッションにアクセスするためのプロトコルの認識
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      KDE
      Gnomeの
      Xfce
      X11
      XDMCP
      VNC
      スパイス
      RDP

  * 106.3アクセシビリティ(総重量： 1)

    説明： アクセシビリティ技術の知識と意識を示す。

    主な知識分野：

    * 視覚設定とテーマの基礎知識。
    * 補助技術の基礎知識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      ハイコントラスト/ラージプリントデスクトップのテーマ。
      スクリーンリーダー。
      点字表示。
      スクリーンルーペ。
      オンスクリーンキーボード。
      スティッキ/リピートキー。
      スロー/バウンス/トグルキー。
      マウスキー。
      ジェスチャー
      音声認識。
* トピック107：管理タスク
  * 107.1ユーザーおよびグループアカウントと関連するシステムファイルを管理する(総重量： 5)

    説明： 候補者は、ユーザーアカウントの追加、削除、一時停止、および変更が可能でなければなりません。

    主な知識分野：

    * ユーザーとグループを追加、変更、削除します。
    * パスワード/グループデータベースのユーザー/グループ情報を管理します。
    * 特別目的および限定的な口座の作成および管理。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/passwd
      / etc / shadow
      /etc/group
      / etc / skel /
      chage
      getent
      groupadd
      groupdel
      groupmod
      passwd
      useradd
      userdel
      usermod

  * 107.2ジョブのスケジュール設定によるシステム管理タスクの自動化(総重量： 4)

    説明： 受験者は、cronとsystemdのタイマーを使用して定期的にジョブを実行し、atを使用して特定の時間にジョブを実行できる必要があります。

    主な知識分野：

    * cronとatのジョブを管理します。
    * cronおよびatサービスへのユーザーアクセスを設定します。
    * システムタイマーの単位を理解する。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/cron.{d,daily,hourly,monthly,weekly}/
      /etc/at.deny
      /etc/at.allow
      / etc / crontab
      /etc/cron.allow
      /etc/cron.deny
      / var / spool / cron /
      crontab
      at
      atq
      atrm
      systemctl
      システム実行

  * 107.3のローカリゼーションと国際化(総重量： 3)

    説明： 候補者は、英語とは異なる言語でシステムをローカライズできる必要があります。 同様に、LANG = Cの理由を理解することは、スクリプト作成時に役立ちます。

    主な知識分野：

    * ロケール設定と環境変数を設定します。
    * タイムゾーン設定と環境変数を設定します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      / etc / timezone
      / etc / localtime
      / usr / share / zoneinfo /
      LC_ *
      LC_ALL
      LANG
      TZ
      / usr / bin / locale
      tzselect
      timedatectl
      date
      iconv
      UTF-8
      ISO-8859
      ASCII
      Unicode

* トピック108：必須システムサービス
  * 108.1システム時刻を更新する(総重量： 3)

    説明： 候補者は、システム時間を適切に維持し、NTPを介してクロックを同期させることができるはずです。

    主な知識分野：

    * システムの日付と時刻を設定します。
    * ハードウェアクロックをUTCで正しい時刻に設定します。
    * 正しいタイムゾーンを設定します。
    * ntpdとchronyを使った基本的なNTP設定。
    * pool.ntp.orgサービスの使用に関する知識。
    * ntpqコマンドの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      / usr / share / zoneinfo /
      / etc / timezone
      / etc / localtime
      /etc/ntp.conf
      /etc/chrony.conf
      date
      hwclock
      timedatectl
      ntpd
      ntpdate
      クロニク
      pool.ntp.org

  * 108.2システムロギング(総重量： 4)

    説明： 候補者はrsyslogを設定できる必要があります。 この目的には、ログ出力を中央ログサーバーに送信するか、ログ出力を中央ログサーバーとして受け入れるようにログデーモンを構成することも含まれます。 systemdジャーナル・サブシステムの使用方法が説明されています。 また、代替ロギングシステムとしてのsyslogおよびsyslog-ngの認識も含まれています。

    主な知識分野：

    * rsyslogの基本設定。
    * 標準的な施設、優先順位、および行動の理解。
    * systemdジャーナルを照会します。
    * 日付、サービスまたは優先度などの基準別にジャーナルデータをフィルタリングします。
    * 永続的なシステム・ジャーナル・ストレージおよびジャーナル・サイズを構成します。
    * 古いsystemdジャーナルデータを削除します。
    * レスキューシステムまたはファイルシステムのコピーからsystemdジャーナルデータを取得します。
    * rsyslogとsystemd-journaldのやりとりを理解する。
    * logrotateの設定
    * syslogとsyslog-ngの認識。
    * 用語とユーティリティ：

      /etc/rsyslog.conf
      / var / log /
      logger
      logrotate
      /etc/logrotate.conf
      /etc/logrotate.d/
      journalctl
      systemd-cat
      /etc/systemd/journald.conf
      / var / log / journal /

  * 108.3メール転送エージェント（MTA）の基本(総重量： 3)

    説明： 候補者は、一般的に利用可能なMTAプログラムを認識し、クライアントホスト上で基本的な転送およびエイリアス設定を実行できる必要があります。 その他の設定ファイルは対象外です。

    主な知識分野：

    * 電子メールエイリアスを作成します。
    * 電子メール転送を構成します。
    * 一般的に利用可能なMTAプログラム（postfix、sendmail、exim）に関する知識（設定なし）
    用語とユーティリティ：

      〜/ .forward
      sendmailをエミュレートするコマンド群
      newaliases
      mail
      mailq
      postfix
      sendmail
      exim

  * 108.4プリンタの管理と印刷(総重量： 2)

    説明： 受験者は、CUPSとLPD互換インターフェースを使用して印刷キューとユーザー印刷ジョブを管理できる必要があります。

    主な知識分野：

    * 基本CUPS設定（ローカルプリンタとリモートプリンタ用）。
    * ユーザーの印刷キューを管理します。
    * 一般的な印刷の問題のトラブルシューティングを行います。
    * 構成済みのプリンタキューからジョブを追加および削除します。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      CUPS configuration files, tools and utilities
      / etc / cups /
      lpd legacy interface (lpr, lprm, lpq)

* トピック109：ネットワークの基礎
  * 109.1インターネットプロトコルの基礎(総重量： 4)

    説明： 受験者は、TCP / IPネットワークの基礎を正しく理解していることを証明する必要があります。

    主な知識分野：

    * ネットワークマスクとCIDR表記の理解を示します。
    * プライベートとパブリック "ドットクワッド" IPアドレスの違いを知る。
    * 一般的なTCPおよびUDPポートとサービスに関する知識（20、21、22、23、25、53、80、110、123、139、143、161、162、389、443、465、514、636、993、995） 。
    * UDP、TCP、ICMPの違いと主要な特徴についての知識。
    * IPv4とIPv6の主な違いについての知識。
    * IPv6の基本機能に関する知識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/services
      IPv4, IPv6
      Subnetting
      TCP、UDP、ICMP

  * 109.2固定ネットワーク構成(総重量： 4)

    説明： 候補者は、Linuxホストの永続的なネットワーク構成を管理できるはずです。

    主な知識分野：

    * 基本的なTCP / IPホスト構成を理解する。
    * NetworkManagerを使用して、イーサネットおよびWi-Fiネットワーク構成を設定します。
    * systemd-networkdの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      / etc / hostname
      /etc/hosts
      /etc/nsswitch.conf
      /etc/resolv.conf
      nmcli
      hostnamectl
      ifup
      ifdown

  * 109.3基本的なネットワークのトラブルシューティング(総重量： 4)

    説明： 候補者は、クライアントホスト上のネットワーキングの問題をトラブルシューティングできる必要があります。

    主な知識分野：

    * iproute2を使用してネットワークインターフェイスの設定を表示および変更するなど、手動でネットワークインターフェイスを設定します。
    * iproute2を使用して、ルーティングテーブルの表示と変更、デフォルトルートの設定など、手動でルーティングを設定します。
    * ネットワーク構成に関連する問題をデバッグします。
    * 従来のnet-toolsコマンドの認識。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

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

  * 109.4クライアント側のDNSを設定する(重要度：2)

    説明： 候補者は、クライアントホストでDNSを設定できる必要があります。

    主な知識分野：

    * リモートDNSサーバーを照会します。
    * ローカル名解決を構成し、リモートDNSサーバーを使用します。
    * 名前解決が行われる順序を変更します。
    * 名前解決に関連するエラーをデバッグします。
    * システムの認識が解決されました。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/hosts
      /etc/resolv.conf
      /etc/nsswitch.conf
      host
      dig
      getent

* トピック110：セキュリティ
  * 110.1セキュリティ管理タスクを実行する(総重量： 3)

    説明： 候補者は、ローカルセキュリティポリシーに従ってホストのセキュリティを保証するためにシステム構成を確認する方法を知っている必要があります。

    主な知識分野：

    * システムを監査して、suid / sgidビットが設定されたファイルを検索します。
    * ユーザーパスワードとパスワードエージング情報を設定または変更します。
    * nmapとnetstatを使って、システム上のオープンポートを発見することができます。
    * ユーザーのログイン、プロセス、およびメモリ使用の制限を設定します。
    * どのユーザーがシステムにログインしているのか、または現在ログインしているのかを判断します。
    * 基本的なsudoの設定と使い方。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

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

  * 110.2セットアップホストセキュリティ(総重量： 3)

    説明： 候補者は、基本レベルのホストセキュリティを設定する方法を知っている必要があります。

    主な知識分野：

    * シャドウパスワードの認識とその働き
    * 使用していないネットワークサービスをオフにします。
    * TCPラッパーの役割を理解する。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

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

  * 110.3暗号化によるデータの保護(総重量： 4)

    説明： 候補者は、公開鍵技術を使用してデータと通信を保護する必要があります。

    主な知識分野：

    * 基本的なOpenSSH 2クライアントの設定と使用法を実行します。
    * OpenSSH 2サーバのホスト鍵の役割を理解する。
    * 基本的なGnuPGの設定、使用、取り消しを実行します。
    * GPGを使用して、ファイルを暗号化、復号化、署名、検証します。
    * SSHポートトンネル（X11トンネルを含む）について理解する。
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

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
    * 将来の変更に関する考慮事項
      将来の目標の変更には、以下が含まれます。
      ifup / ifdownとlegacy net-toolsコマンドを削除する
      TCPラッパーを削除する

* トピック200：キャパシティプランニング
  * 200.1リソース使用量の測定とトラブルシューティング(総重量： 6)

    説明： 候補者は、ハードウェアリソースとネットワーク帯域幅を測定し、リソースの問題を特定し、トラブルシューティングすることができる必要があります。

    主な知識分野：

    * CPU使用率を測定する
    * メモリ使用量を測定する
    * ディスクI / Oを測定する
    * ネットワークI / Oを測定する
    * ファイアウォールとルーティングのスループットを測定する
    * クライアントの帯域幅使用量を識別する
    * 問題の可能性があるシステムの症状を識別して修正する
    * ネットワーキングを含むシステムのスループットを見積もり、ボトルネックを特定する
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      iostat
      netstat
      w
      top
      sar
      I/Oでブロックするプロセス
      ブロックの書き出し
      vmstat
      pstree、ps
      Isof
      uptime
      swap
      ブロックの読み込み

  * 200.2 未来の資源ニーズを予測する(総重量： 2)

    説明： 候補者は、将来のリソースニーズを予測するために、リソースの使用状況を監視できる必要があります。

    主な知識分野：

    * 監視および測定ツールを使用して、ITインフラストラクチャの使用状況を監視する
    * 構成における容量のブレークポイントを予測する
    * 容量使用率の増加率を観察する
    * 容量使用の傾向をグラフ表示する
    * Icinga2、Nagios、collectd、MRTG、Cactiなどの監視ソリューションに対する理解
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      診断
      成長予測
      リソースの枯渇
* トピック201：Linuxカーネル
  * 201.1カーネルコンポーネント(総重量： 2)

    説明： 候補者は、特定のハードウェア、ハードウェアドライバ、システムリソース、および要件に必要なカーネルコンポーネントを利用できる必要があります。 この課題には、さまざまな種類のカーネルイメージの実装、安定したカーネルとパッチの特定、カーネルモジュールの使用が含まれます。

    主な知識分野：

    * カーネル2.6.x、3.x、4.xのドキュメント
    * 用語とユーティリティ：

      /usr/src/linux/
      /usr/src/linux/Documentation/
      zImage
      bzImage
      xz圧縮

  * 201.2カーネルのコンパイル(総重量： 3)

    説明： 必要に応じて、Linuxカーネルに特定の機能を含めるか、または無効にして、カーネルを適切に構成できる必要があります。 この課題は、必要に応じてLinuxカーネルを再コンパイルし、新しいカーネルの変更点を更新し、initrdイメージを作成し、新しいカーネルをインストールすることを含みます。

    主な知識分野：

    * /usr/src/linux/
    * カーネルのMakefiles
    * カーネル2.6.x / 3.xのターゲットをmakeする
    * 現在のカーネル構成をカスタマイズする
    * 新しいカーネルと適切なカーネルモジュールをビルドする
    * 新しいカーネルとモジュールをインストールする
    * ブートマネージャーが新しいカーネルと関連ファイルを見つけることができることを確認する
    * モジュール構成ファイル
    * DKMSを使用してカーネルモジュールをコンパイルする
    * dracutに関する知識
    * 用語とユーティリティ：

      mkinitrd
      mkinitramfs
      make
      make targets (all, config, xconfig, menuconfig, gconfig, oldconfig, mrproper, zImage, bzImage, modules, modules_install, rpm-pkg, binrpm-pkg, deb-pkg)
      gzip
      bzip2
      module tools
      /usr/src/linux/.config
      /lib/modules/kernel-version/
      depmod
      dkms

  * 201.3カーネルランタイム管理とトラブルシューティング(総重量： 4)

    説明： 候補者は、2.6.x、3.xまたは4.xカーネルとそのロード可能モジュールを管理および/または照会できなければなりません。 候補者は、一般的な起動および実行時の問題を特定して修正できる必要があります。 候補者はudevを使用してデバイスの検出と管理を理解する必要があります。 この課題には、udevルールのトラブルシューティングが含まれます。

    主な知識分野：

    * コマンドラインユーティリティを使用して、現在実行中のカーネルお​​よびカーネルモジュールに関する情報を取得する
    * カーネルモジュールの手動ロードとアンロード
    * いつモジュールをアンロードできるかを決定する
    * モジュールが受け入れるパラメータを決定する
    * ファイル名以外の名前でモジュールをロードするようにシステムを構成する
    * /procファイルシステム
    * /、/boot/、/lib /modules /の内容
    * 利用可能なハードウェアに関する情報を分析するためのツールとユーティリティ
    * udevルール
    * 用語とユーティリティ：

      /lib/modules/kernel-version/modules.dep
      /etc/にある、モジュールの設定ファイル。
      /proc/sys/kernel/
      /sbin/depmod
      /sbin/rmmod
      /sbin/modinfo
      /bin/dmesg
      /sbin/lspci
      /usr/bin/lsdev
      /sbin/lsmod
      /sbin/modprobe
      /sbin/insmod
      /bin/uname
      /usr/bin/lsusb
      /etc/sysctl.conf、/etc/sysctl.d/
      /sbin/sysctl
      udevmonitor
      udevadm モニタ
      /etc/udev/

* トピック202：システム起動
  * 202.1 SysV-initシステムの起動をカスタマイズする(総重量： 3)

    説明： 候補者は、さまざまなターゲット/実行レベルでシステムサービスの動作を照会および変更できる必要があります。 systemd、SysV Init、およびLinuxブートプロセスの完全な理解が必要です。 この課題は、systemdのターゲットと、SysV initの実行レベルの操作を含みます。

    主な知識分野：

    * Systemd
    * SysV init
    * Linux標準ベース仕様（LSB）
    * 用語とユーティリティ：

      /usr/lib/systemd/
      /etc/systemd/
      /run/systemd/
      systemctl
      systemd-delta
      /etc/inittab
      /etc/init.d/
      /etc/rc.d/
      chkconfig
      update-rc.d
      init と telinit

  * 202.2システムの復旧(総重量： 4)

    説明： 候補者は、ブートプロセスとリカバリモードの両方でLinuxシステムを適切に操作できる必要があります。 この課題には、initユーティリティとinit関連のカーネルオプションの両方を使用することが含まれます。 候補者は、ロード時のエラー原因を特定し、ブートローダを適切に使用できる必要があります。 特に、GRUBバージョン2とGRUB Legacyは、重要なブートローダです。 BIOSとUEFIシステムの両方も含まれています。

    主な知識分野：

    * BIOSとUEFI
    * NVMeの起動
    * GRUBバージョン2とLegacy
    * grub shell
    * ブートローダーの起動とカーネルへのハンドオフ
    * カーネルロード
    * ハードウェアの初期化とセットアップ
    * デーモン/サービスの初期化とセットアップ
    * ハードディスクまたはリムーバブルデバイスにおける、様々なブートローダのインストール位置に関する知識
    * ブートローダの標準オプションを上書きして、ブートローダシェルを使用する
    * systemdのレスキューモードと緊急モードの利用
    * 用語とユーティリティ：

      mount
      fsck
      inittab、 telinit、および、SysV initを含むinit
      /boot/, /boot/grub/ および /boot/efi/ の内容
      EFIシステムパーティション（ESP）
      GRUB
      grub-install
      efibootmgr
      UEFI シェル
      initrd、initramfs
      Master boot record
      systemctl

  * 202.3代替ブートローダ(総重量： 2)

    説明：候補者は、標準的ではないブートローダーとその主な機能について認識している必要があります。

    主な知識分野：

    * SYSLINUX、ISOLINUX、PXELINUX
    * BIOSとUEFIの両方におけるPXEの理解
    * systemd-bootとU-Bootへの理解
    * 用語とユーティリティ：

      syslinux
      extlinux
      isolinux.bin
      isolinux.cfg
      isohdpfx.bin
      efiboot.img
      pxelinux.0
      pxelinux.cfg/
      uefi/shim.efi
      uefi/grubx64.efi

* トピック203：ファイルシステムとデバイス

  * 203.1 Linuxファイルシステムの操作(総重量： 4)

    説明： 候補者は、標準のLinuxファイルシステムを適切に構成し、ナビゲートできる必要があります。 この課題には、さまざまなファイルシステムタイプの設定とマウントが含まれます。

    主な知識分野：

    * fstab構成の概念
    * スワップパーティションとファイルを扱うためのツールとユーティリティ
    * ファイルシステムの識別とマウントにUUIDを使用する
    * systemdにおけるマウント・ユニットの理解
    * 用語とユーティリティ：

      /etc/fstab
      /etc/mtab
      /proc/mounts
      mount と umount
      blkid
      sync
      swapon
      swapoff

  * 203.2 Linuxファイルシステムの管理(総重量： 3)

    説明： 候補者は、システムユーティリティを使用してLinuxファイルシステムを適切に維持できるべきです。 この課題には、標準ファイルシステムの操作とSMARTデバイスの監視が含まれます。

    主な知識分野：

    * ext2、ext3、ext4を操作するためのツールとユーティリティ
    * サブボリュームとスナップショットを含む基本的なBtrfs操作を実行するためのツールとユーティリティ
    * XFSを操作するためのツールとユーティリティ
    * ZFSに対する知識
    * 用語とユーティリティ：

      mkfs (mkfs.*)
      mkswap
      fsck (fsck.*)
      tune2fs, dumpe2fs and debugfs
      btrfs、btrfs-convert
      xfs_info, xfs_check, xfs_repair, xfsdump and xfsrestore
      smartd、smartctl

  * 203.3ファイルシステムオプションの作成と設定(総重量： 2)

    説明： AutoFSを使用して自動マウントファイルシステムを構成できる必要があります。 この課題には、ネットワークおよびデバイスファイルシステム用の自動マウントの設定が含まれます。 また、CD-ROMなどのデバイス用のファイルシステムと、暗号化されたファイルシステムの基本的な機能に関する知識も含まれています。

    主な知識分野：

    * autofs設定ファイル
    * オートマウントユニットの理解
    * UDFおよびISO9660ツールおよびユーティリティ
    * 他のCD-ROMファイルシステム（HFS）の理解
    * CD-ROMファイルシステム拡張の認識（Joliet、Rock Ridge、El Torito）
    * データ暗号化の基本的な機能知識（dm-crypt / LUKS）
    * 用語とユーティリティ：

      /etc/auto.master
      /etc/auto.[dir]
      mkisofs
      cryptsetup

* トピック204：高度なストレージデバイスの管理
  * 204.1 RAIDの設定(総重量： 3)

    説明： 候補者は、ソフトウェアRAIDを設定して実装できる必要があります。 この課題には、RAID 0、1、5の使用と設定が含まれます。

    主な知識分野：

    * ソフトウェアRAID構成ファイルとユーティリティ
    * 用語とユーティリティ：

      mdadm.conf
      mdadm
      /proc/mdstat
      パーティションタイプ 0xFD

  * 204.2 ストレージデバイスのアクセスを調整する(総重量： 2)

    説明： 候補者は、さまざまなドライブをサポートするためにカーネルオプションを構成できる必要があります。 この目的には、iSCSIデバイスを含むハードディスク設定を表示および変更するためのソフトウェアツールが含まれます。

    主な知識分野：

    * ATAPIおよびSATAを含むIDEデバイス用のDMAを構成するツールおよびユーティリティ
    * AHCIおよびNVMeを含むソリッド・ステート・ドライブを構成するツールおよびユーティリティ
    * システムリソースを操作または分析するツールおよびユーティリティ（割り込みなど）
    * sdparmコマンドの知識とその使用法
    * iSCSI用のツールとユーティリティ
    * 関連するプロトコル（AoE、FCoE）を含むSANの認識
    * 用語とユーティリティ：

      hdparm、sdparm
      nvme
      fstrim
      fstream
      sysctl
      /dev/hd*, /dev/sd*, /dev/nvme*
      iscsiadm, scsi_id, iscsid and iscsid.conf
      WWID, WWN, LUN numbers

  * 204.3 論理ボリュームマネージャ(総重量： 3)

    説明： 論理ボリューム、ボリュームグループ、および物理ボリュームを作成および削除できる必要があります。 この課題には、スナップショットと論理ボリュームのサイズ変更が含まれます。

    主な知識分野：

    * LVMツールのスイート
    * 論理ボリューム、ボリュームグループ、物理ボリュームのサイズ変更、名称変更、作成、削除
    * スナップショットの作成と保守
    * ボリュームグループの有効化
    * 用語とユーティリティ：

      /sbin/pv*
      /sbin/lv*
      /sbin/vg*
      mount
      /dev/mapper/
      lvm.conf

* トピック205：ネットワーク設定
  * 205.1 基本的なネットワーク設定(総重量： 3)

    説明： ローカルな有線またはワイヤレス、および広域ネットワークに接続できるようにネットワークデバイスを設定できる必要があります。 この課題は、IPv4とIPv6の両方を含む、単一のネットワーク内のさまざまなサブネット間で通信できることを含みます。

    主な知識分野：

    * イーサネットインターフェイスを設定および操作するユーティリティ
    * ワイヤレスネットワークへの基本アクセスの設定
    * 用語とユーティリティ：

      ip
      ifconfig
      route
      arp
      iw
      iwconfig
      iwlist

  * 205.2 高度なネットワーク構成とトラブルシューティング(総重量： 4)

    説明： 候補者は、さまざまなネットワーク認証方式を使用するようにネットワークデバイスを設定できる必要があります。 この課題には、マルチホームネットワークデバイスの設定と通信上の問題の解決が含まれます。

    主な知識分野：

    * ルーティングテーブルを操作するユーティリティ
    * イーサネットインターフェイスを設定および操作するユーティリティ
    * ネットワークデバイスの状態を分析するユーティリティ
    * TCP / IPトラフィックを監視および分析するためのユーティリティ
    * 用語とユーティリティ：

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

  * 205.3 ネットワークの問題のトラブルシューティング(総重量： 4)

    説明： 候補者は、一般的なネットワーク設定の問題を特定して修正できる必要があります。これには基本的なコマンドと設定ファイルの位置に関する知識を含みます。

    主な知識分野：

    * アクセス制限ファイルの場所と内容
    * イーサネットインターフェイスを設定および操作するユーティリティ
    * ルーティングテーブルを管理するユーティリティ
    * ネットワーク状態を一覧表示するユーティリティ。
    * ネットワーク構成に関する情報を得るユーティリティ
    * 認識され使用されているハードウェアデバイスに関する情報の表示
    * システム初期化ファイルとその内容（SysV initプロセス）
    * NetworkManagerの知識とネットワーク構成への影響
    * 用語とユーティリティ：

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

* トピック206：システムメンテナンス
  * 206.1 ソースからプログラムを作成してインストールする(総重量： 2)

    説明： 候補者は、ソースから実行可能プログラムをビルドしてインストールできる必要があります。 この課題は、ソースファイルを展開することを含みます。

    主な知識分野：

    * 一般的な圧縮およびアーカイブユーティリティを使用してソースコードを展開する
    * makeを呼び出してプログラムをコンパイルする基本を理解する
    * configureスクリプトにパラメータを適用する
    * ソースがデフォルトで保存されている場所に関する知識
    * 用語とユーティリティ：

      / usr / src /
      gunzip
      gzip
      bzip2
      xz
      tar
      configure
      make
      uname
      install
      patch

  * 206.2 バックアップ操作(総重量： 3)

    説明： 候補者は、システムツールを使用して重要なシステムデータをバックアップできる必要があります。

    主な知識分野：

    * バックアップに含める必要のあるディレクトリに関する知識
    * Amanda、Bacula、Bareos、BackupPCなどのネットワークバックアップソリューションに関する知識
    * テープ、CDR、ディスクまたはその他のバックアップメディアの利点と欠点に関する知識
    * 部分バックアップと手動バックアップを実行する
    * バックアップファイルの整合性を検証する
    * バックアップの一部または全部をリストアする
    * 用語とユーティリティ：

      /bin/sh
      dd
      tar
      /dev/st* と /dev/nst*
      mt
      rsync

  * 206.3 システム関連の問題についてユーザーに通知する(総重量： 1)

    説明： システムに関連する最新の問題について、ユーザーに通知することができる必要があります。

    主な知識分野：

    * ログオンメッセージを通じて自動的にユーザーに通知する
    * アクティブなユーザにシステムメンテナンスを知らせる
    * 用語とユーティリティ：

      /etc/issue
      /etc/issue.net
      /etc/motd
      wall
      /sbin/shutdown
      systemctl

* トピック207：ドメインネームサーバー
  * 207.1 DNSサーバ設定の基本(総重量： 3)

    説明： 候補者は、キャッシュ専用DNSサーバーとして機能するようにBINDを構成できる必要があります。 この課題には、実行中のサーバーを管理し、ログを構成する機能が含まれます。

    主な知識分野：

    * BIND 9.x設定ファイル、用語およびユーティリティ
    * BIND設定ファイル内のBINDゾーンファイルの場所の定義
    * 変更された構成ファイルとゾーンファイルの再ロード
    * 代替ネームサーバとしてのdnsmasq、djbdns、およびPowerDNSの知識
    * 以下のリストは、使用されるファイル、用語、およびユーティリティの一部です。

      /etc/named.conf
      /var/named/
      /usr/sbin/rndc
      kill
      host
      dig

  * 207.2 DNSゾーンの作成と保守(総重量： 3)

    説明： 候補者は、正引きゾーンまたは逆引きゾーンのゾーンファイル、およびルートサーバーのヒントファイルを作成できる必要があります。 この課題には、レコードへの適切な値の設定、ゾーン内のホストの追加、DNSへのゾーンの追加が含まれます。 また、候補者はゾーンを別のDNSサーバーに委任できる必要があります。

    主な知識分野：

    * BIND 9設定ファイル、用語、ユーティリティ
    * DNSサーバーから情報を取り出すユーティリティ
    * BINDゾーンファイルのレイアウト、コンテンツ、およびファイルの場所
    * ゾーンファイルに新しいホストを追加するさまざまな方法（逆引きゾーンを含む）
    * 用語とユーティリティ：

      /var/named/
      ゾーンファイルの書式
      リソースレコードの書式
      named-checkzone
      named-compilezone
      masterfile-format
      dig
      nslookup
      host

  * 207.3 DNSサーバーを保護する(総重量： 2)

    説明： 候補者は、ルート以外のユーザーとして実行し、chroot jailで実行するようにDNSサーバーを構成できる必要があります。 この課題は、DNSサーバー間の安全なデータ交換を含みます。

    主な知識分野：

    * BIND 9の設定ファイル
    * BINDをchroot jailで実行するように設定する
    * forwardersステートメントを使用してBINDの構成を分割する
    * トランザクションシグネチャの設定と使用（TSIG）
    * DNSSECと基本ツールの認識
    * DANEと関連レコードの認識
    * 用語とユーティリティ：

      /etc/named.conf
      /etc/passwd
      DNSSEC
      dnssec-keygen
      dnssec-signzone

* トピック208：Webサービス
  * 208.1 Webサーバーの実装(総重量： 4)

    説明： 候補者はWebサーバーをインストールして構成できる必要があります。 この課題には、サーバーの負荷とパフォーマンスの監視、クライアントユーザーへのアクセス制限、モジュールによるスクリプト言語サポートの構成、およびクライアントユーザー認証の設定が含まれます。 また、リソースの使用を制限するためのサーバーオプションの設定も含まれています。 候補者は、仮想ホストを使用してファイルアクセスをカスタマイズするようにWebサーバーを構成できる必要があります。

    主な知識分野：

    * Apache 2.4の設定ファイル、用語、ユーティリティ
    * Apacheログファイルの設定と内容
    * アクセス制限の方法とファイル
    * mod_perlとPHPの設定
    * クライアントユーザー認証ファイルとユーティリティ
    * リクエスト数、およびサーバーとクライアントの最大数の構成
    * Apache 2.4仮想ホストの実装（専用IPアドレスの有無にかかわらず）
    * Apacheの設定ファイルでリダイレクト文を使用してファイルアクセスをカスタマイズする
    * 用語とユーティリティ：

      アクセスログとエラーログ
      .htaccess
      httpd.conf
      mod_auth_basic、 mod_authz_host、および mod_access_compat
      htpasswd
      AuthUserFile、AuthGroupFile
      apachectl、apache2ctl
      httpd、apache2

  * 208.2 HTTPS用のApache構成(重要度：3)
    説明： 候補者は、HTTPSを提供するようにWebサーバーを構成できる必要があります。

    主な知識分野：

    * SSL設定ファイル、ツール、ユーティリティ
    * 商用CAを利用する際の、サーバー秘密鍵とCSRを生成する
    * 自己署名証明書を生成する
    * 鍵と証明書を、中間CAを含めてインストールする
    * サーバー名表記を使用した仮想ホスティングの設定 (SNI)
    * 仮想ホスティングとSSLの使用に関する知識
    * SSLのセキュリティ問題、安全でないプロトコルや暗号を無効にする
    * 用語とユーティリティ：

      Apache2 の設定ファイル
      /etc/ssl/, /etc/pki/
      openssl、CA.pl
      SSLEngine、SSLCertificateKeyFile、SSLCertificateFile
      SSLCACertificateFile、SSLCACertificatePath
      SSLProtocol、SSLCipherSuite、ServerTokens、ServerSignature、TraceEnable

  * 208.3 プロキシサーバーの実装(総重量： 2)

    説明： 候補者は、アクセスポリシー、認証、リソースの使用など、プロキシサーバーをインストールして構成できる必要があります。

    主な知識分野：

    * Squid 3.xの設定ファイル、用語、ユーティリティ
    * アクセス制限方法
    * クライアントユーザーの認証方法
    * Squid構成ファイルにおけるACLの書式と内容
    * 用語とユーティリティ：

      squid.conf
      acl
      http_access

  * 208.4 NginxのWebサーバーおよびリバースプロキシとしての設定(総重量： 2)

    説明： 候補者は、リバースプロキシサーバとしてNginxをインストールして構成することができる必要があります。これには、Nginxを基本的なHTTPサーバとして構成することを含みます。

    主な知識分野：

    * nginx
    * リバースプロキシ
    * 基本的なWebサーバー
    * 用語とユーティリティ：

      /etc/nginx/
      nginx

* トピック209：ファイル共有
  * 209.1 SAMBAサーバーの設定(総重量： 5)

    説明： 候補者は、さまざまなクライアントのためにSambaサーバを設定できる必要があります。この課題には、Sambaをスタンドアロンサーバーとしてセットアップすること、およびSambaをActive Directoryのメンバーとして統合することを含みます。また、シンプルなCIFSとプリンタ共有を構成することも含みます。さらに、Sambaサーバを使用するためのLinuxクライアントの設定も含みます。 インストールのトラブルシューティングもテストされます。

    主な知識分野：

    * Samba 4のドキュメント
    * Samba 4設定ファイル
    * Samba 4のツール、ユーティリティ、およびデーモン
    * LinuxにおけるCIFS共有のマウント
    * Windowsユーザー名をLinuxユーザー名にマッピングする
    * ユーザーレベル、共有レベル、およびADセキュリティ
    * 用語とユーティリティ：

      smbd、nmbd、winbindd
      smbcontrol、smbstatus、testparm、smbpasswd、nmblookup
      samba-tool
      net
      smbclient
      mount.cifs
      /etc/samba/
      /var/log/samba/

  * 209.2 NFSサーバー構成(総重量： 3)

    説明： 候補者は、NFSを使用してファイルシステムをエクスポートできる必要があります。 この課題には、アクセス制限、クライアントにNFSファイルシステムをマウントすること、NFSを保護することが含まれます。

    主な知識分野：

    * NFSバージョン3の設定ファイル
    * NFSツールとユーティリティ
    * 特定のホスト、および/または、サブネットへのアクセス制限
    * サーバーとクライアントのマウントオプション
    * TCPラッパー
    * NFSv4の知識
    * 用語とユーティリティ：

      /etc/exports
      exportfs
      showmount
      nfsstat
      /proc/mounts
      /etc/fstab
      rpcinfo
      mountd
      portmapper

* トピック210：ネットワーククライアント管理
  * 210.1 DHCP設定(総重量： 2)

    説明： 候補者はDHCPサーバーを構成できる必要があります。 この課題には、デフォルトおよびクライアントごとのオプションの設定、スタティックホストとBOOTPホストの追加が含まれます。また、DHCPリレーエージェントの設定とDHCPサーバのメンテナンスも含まれています。

    主な知識分野：

    * DHCPの構成ファイル、用語およびユーティリティ
    * サブネットと動的に割り当てられる範囲の設定
    * DHCPv6およびIPv6ルーター広告に関する知識
    * 用語とユーティリティ：

      dhcpd.conf
      dhcpd.leases
      syslogもしくはsystemdジャーナルにおけるDHCPログメッセージ
      arp
      dhcpd
      radvd
      radvd.conf

  * 210.2 PAM認証(総重量： 3)

    説明： 候補者は、さまざまな利用可能な方法を使用して認証をサポートするようにPAMを設定できる必要があります。 これには基本的なSSSD機能が含まれます。

    主な知識分野：

    * PAM構成ファイル、用語およびユーティリティ
    * passwdとshadowパスワード
    * LDAP認証にsssdを使用する
    * 用語とユーティリティ：

      /etc/pam.d/
      pam.conf
      nsswitch.conf
      pam_unix、pam_cracklib、pam_limits、pam_listfile、pam_sss
      sssd.conf

  * 210.3 LDAPクライアントの使用法(重要度：2)

    説明： 候補者は、LDAPサーバーに対する照会および更新を実行できる必要があります。 また、アイテムのインポートと追加だけでなく、ユーザーの追加と管理も含まれています。

    主な知識分野：

    * データ管理と問い合わせ用のLDAPユーティリティ
    * ユーザーのパスワードを変更する
    * LDAPディレクトリのクエリ
    * 用語とユーティリティ：

      ldapsearch
      ldappasswd
      ldapadd
      ldapdelete

  * 210.4 OpenLDAPサーバの設定(総重量： 4)

    説明： 候補者は、LDIF形式と基本的なアクセス制御の知識を持ち、基本的なOpenLDAPサーバーを構成できる必要があります。

    主な知識分野：

    * OpenLDAP
    * ディレクトリごとの設定
    * アクセス制御
    * 識別名
    * Changetype操作
    * スキーマとWhitepages
    * ディレクトリ
    * オブジェクトID、属性、およびクラス
    * 用語とユーティリティ：

      slapd
      slapd-config
      LDIF
      slapadd
      slapcat
      slapindex
      /var/lib/ldap/
      loglevel

* トピック211：電子メールサービス
  * 211.1 電子メールサーバー(総重量： 4)

    説明： 候補者は、電子メールのエイリアス、クォータ、仮想ドメインの設定などを行い、メールサーバーを管理できる必要があります。この課題には、内部的なメールリレーの構成と、メールサーバーの監視が含まれます。

    主な知識分野：

    * postifxの設定ファイル
    * postfixの基本的なTLS設定
    * SMTPプロトコルの基本知識
    * sendmailとeximの知識
    * 用語とユーティリティ：

      postfixの設定ファイルとコマンド
      /etc/postfix/
      /var/spool/postfix/
      sendmailをエミュレートするコマンド群
      /etc/aliases
      /var/log/にあるメール関係のログ

  * 211.2 メール配送を管理する(総重量： 2)

    説明： 候補者は、着信したユーザーのメールを、フィルタ、分類、監視するメール管理ソフトウェアを実装できる必要があります。

    主な知識分野：

    * Sieveの機能、構文、演算子の理解
    * Sieveを使用して、送信者、受信者、ヘッダー、およびサイズなどで、メールのフィルタリングと分類を行う
    * procmailの知識
    * 用語とユーティリティ：

      条件と比較の操作
      keep、fileinto、redirect、reject、discard、stop
      Dovecotのvacation拡張

  * 211.3 リモートへのメール配送を管理する(総重量： 2)

    説明： POPおよびIMAPデーモンをインストールして構成できる必要があります。

    主な知識分野：

    * Dovecotにおける、IMAPとPOP3の設定と管理
    * Dovecotの基本的なTLS設定
    * Courierに対する知識
    * 用語とユーティリティ：

      /etc/dovecot/
      dovecot.conf
      doveconf
      doveadm

* トピック212：システムセキュリティ
  * 212.1 ルータの設定(総重量： 3)

    説明： 候補者は、IPパケットを転送し、ネットワークアドレス変換（NAT、IPマスカレード）を実行するようにシステムを構成して、適切なネットワーク保護を行える必要があります。 この課題には、ポート転送の設定、フィルタルールの管理、攻撃からの防衛が含まれます。

    主な知識分野：

    * iptablesとip6tables設定ファイル、ツール、ユーティリティ
    * ルーティングテーブルを管理するためのツール、コマンド、ユーティリティ
    * プライベートアドレス範囲（IPv4）と固有ローカルアドレス、リンクローカルアドレス（IPv6）
    * ポート転送とIPフォワーディング
    * プロトコルや送信元と送信先のポートとアドレスに基づいて、IPパケットを受け入れるかブロックするかを定めるルールやフィルタを、一覧したり作成する
    * フィルタリング設定の保存と再読み込み
    * 用語とユーティリティ：

     /proc/sys/net/ipv4/
     /proc/sys/net/ipv6/
     /etc/services
     iptables
     ip6tables

  * 212.2 FTPサーバーを保護する(総重量： 2)

    説明： 候補者は、匿名のダウンロードとアップロードのために、FTPサーバーを設定できる必要があります。 この課題には、匿名アップロードが許可されていて、かつ、ユーザーアクセスが設定されている場合に必要な予防措置が含まれます。

    主な知識分野：

    * Pure-FTPdとvsftpdの設定ファイル、ツール、ユーティリティ
    * ProFTPdに関する知識
    * FTP接続のパッシブモードとアクティブモードに関する理解
    * 用語とユーティリティ：

      vsftpd.conf
      Pure-FTPdの重要なコマンドオプション

  * 212.3 セキュアシェル（SSH）(総重量： 4)

    説明： 候補者は、SSHデーモンの安全な設定ができる必要があります。 この課題には、キーの管理とユーザー用のSSHの設定が含まれます。 また、SSHを介してアプリケーションプロトコルを転送したり、SSHログインを管理することもできる必要があります。

    主な知識分野：

    * OpenSSHの設定ファイル、ツール、ユーティリティ
    * スーパーユーザーと通常ユーザーのログイン制限
    * ログイン時にパスワードを求めるか否かを制御するために、サーバーとクライアントの鍵を管理し、使用する
    * 設定変更時にリモートホストへの接続を失わないように、複数のホストから複数の接続を使用する
    * 用語とユーティリティ：

      ssh
      sshd
      /etc/ssh/sshd_config
      /etc/ssh/
      秘密鍵と公開鍵のファイル
      PermitRootLogin、PubKeyAuthentication、AllowUsers、PasswordAuthentication、Protocol

  * 212.4 セキュリティのタスク(総重量： 3)

    説明： 候補者は、さまざまなソースからセキュリティ警告を受信し、侵入検知システムをインストール、設定、実行し、セキュリティパッチとバグ修正を適用することができる必要があります。

    主な知識分野：

    * サーバー上のポートをスキャンしてテストするためのツールとユーティリティ
    * Bugtraq、CERTなどのセキュリティ警告をレポートする機関や情報源
    * 侵入検知システム（IDS）を実装するためのツールとユーティリティ
    * OpenVASとSnortの知識
    * 用語とユーティリティ：

      telnet
      nmap
      fail2ban
      nc
      iptables

  * 212.5 OpenVPN(総重量： 2)

    説明： 候補者は、VPN（仮想プライベートネットワーク）を構成し、安全なポイントツーポイント接続またはサイトツーサイト接続を作成できる必要があります。

    主な知識分野：

    * OpenVPN
    * 用語とユーティリティ：

      /etc/openvpn/
      openvpn

## トレーニング ##

* トピック101：システムアーキテクチャ
* トピック102：Linuxのインストールとパッケージ管理
* トピック103：GNUとUnixコマンド
* トピック104：デバイス、Linuxファイルシステム、ファイルシステム階層標準
* トピック105：シェルとシェルスクリプト
* トピック106：ユーザーインターフェースとデスクトップ
* トピック107：管理タスク
* トピック108：必須システムサービス
* トピック109：ネットワークの基礎
* トピック110：セキュリティ
* トピック200：キャパシティプランニング

  1. リソース使用率

    ~~~sh
    top [-b | -d <seconds> | -n <times> | -u <user> -p <PID>]
    ~~~

    | 位置 | 内容 |
    | --- | --- |
    | 行1 | datetime,up,users,load average (1min 5min 15min) |
    | 行2 | tasks    total,running,sleeping,stopped,zombie |
    | 行3 | %Cpu(s)  us,sy,ni,id,wa,hi,si,st |
    | 行4 | KiB Mem  total,free,used,buff/cache |
    | 行5 | Kib Swap total,free,used,avail Mem |
    | 表 | PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,COMMAND |

  * 注意点

    * load average > logical processors の場合チューニングが必要
    * zombie とは終了のプロセスがプロセステーブルから削除されないプロセス
    * us:user,sy:system,ni:nice,id:idle,wa:io wait,hi:hardware interrupt,si:software interrupt,st:steal (仮想環境ゲストが要求してからの待ち時間)
    * メモリについて:

    | top | /proc/meminfo |
    |---|---|---|
    | Mem.total | MemTotal |
    | Mem.free | MemFree |
    | Mem.used | - |
    | Mem.buff/cache | Buffers + Cached |
    | Swap.total | SwapTotal |
    | Swap.free | SwapFree |
    | Swap.used | - |
    | Swap.avail Mem | MemAvailable |

    * PR,NI について

    |カーネル内部|chrt|top(PR)|ps(rtprio)|ps(pri)|ps(priority)|nice|
    |--:|--:|--:|--:|--:|--:|--:|--:|
    |  1| 99| RT| 99|139|-100|   |
    |  2| 98| ? | 98|138| -99|   |
    | 99|  1| ? |  1| 41|  -2|   |
    |100|  0|  0| - | 39|   0|-20|
    |120|  0| 20| - | 19|  20|  0|
    |139|  0| 39| - |  0|  39| 19|

    TODO: top の PR 列の「RT」は-99か-100か？以下の記事の内容が違うため、要確認

    [プロセスの優先度＠CetnOS 5.5](https://www.mazn.net/blog/2010/09/18/311.html)
    [real-time priority の確認](https://qiita.com/mykysyk@github/items/70fd180faaf06121930e)

    * VIRT,RES,SHRについて

      [仮想記憶](https://ja.wikipedia.org/wiki/%E4%BB%AE%E6%83%B3%E8%A8%98%E6%86%B6)
      [TopコマンドのRES,VIRT,SHR](http://neko32.blogspot.com/2013/06/topresvirtshr.html)
      [TOP](https://linuxjm.osdn.jp/html/procps/man1/top.1.html)

      VIRT(使用中の仮想メモリKB) = タスクが使用している仮想メモリの総量。 コード・データ・共有ライブラリ・スワップアウトされているページが含まれる(まだ使用されていないものを含む,windowsのコミットチャージ相当)
      RES(物理メモリKB) = タスクが使用しているスワップされていない物理メモリ。(windowsのワーキングセット相当)
      SHR(共有メモリKB) = タスクが利用している共有メモリの総量。 他のプロセスと共有される可能性のあるメモリを単純に反映している。

    * S について
      プロセス状態、以下のどちらである
      * 'D' = 割り込み不可能なスリープ状態
      * 'R' = 実行中
      * 'S' = スリープ状態
      * 'T' = トレース中/停止された
      * 'Z' = ゾンビ

    ~~~sh
    vmstat [表示間隔(秒)] [回数]
    ~~~
  
  * vmstat
    * proc
      * r ランタイム待ちのプロセス数
      * b 割り込み不可能なスリープ状態にあるプロセス数
    * memory
      * swpd(KB) = /proc/meminfo.SwapTotal - /proc/meminfo.SwapFree
      * free(KB) = /proc/meminfo.MemFree
      * buff(KB)  = /proc/meminfo.Buffers
      * cache(KB) = ?
    * swap
      * si(KB/s) スワップ(ディスク)⇒メモリ
      * so(KB/s) メモリ⇒スワップ(ディスク)
    * io
      * bi(block/s) ブロックデバイス(ディスク)⇒メモリ
      * bo(block/s) メモリ⇒ブロックデバイス(ディスク)
    * system
      * in 一秒あたりの割り込み回数。クロック割り込みも含む
      * cs 一秒あたりのコンテキストスイッチ(プログラムの実行を切り替える)の回数
    * cpu
      * us
      * sy
      * wa
      * st ゲストOSがCPUを割り当てられなかった時間の割合(要求の通り割り当てられる場合は0%、ホストOSや他のゲストとCPUを奪い合う場合は0%以外)

    ~~~sh
    iostat [-c | -d | -k | -t] [表示間隔(秒)] [回数]
    iotop # CentOs 7 にデフォルトインストールしていない
    ~~~

    ~~~sh
    sar # 履歴情報を見る
    ~~~

    ~~~sh
    ps [a | e | x | u | r | l | U <username>| -C <cmd>| -e | -f | -l | -p <PID>| -t <tty> | -u <UID>]
    ~~~

* トピック201：Linuxカーネル

  [The Linux Kernel Archives](https://https://www.kernel.org/)
  [Documentation](https://www.kernel.org/doc/html/latest/)

    ~~~sh

    ~~~

* トピック202：システム起動
* トピック203：ファイルシステムとデバイス
* トピック204：高度なストレージデバイスの管理
* トピック205：ネットワーク設定
* トピック206：システムメンテナンス
* トピック207：ドメインネームサーバー
* トピック208：Webサービス
* トピック209：ファイル共有
* トピック210：ネットワーククライアント管理
* トピック211：電子メールサービス
* トピック212：システムセキュリティ
