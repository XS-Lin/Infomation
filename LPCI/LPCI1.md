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