# Linuxコマンド #

## たまに使われ、知らないと困るコマンドのまとめ ##

~~~sh
# Windowの改行コードをLinuxの改行コードに変更
sed -i 's/\r//' file_name
# treeコマンドがない環境でtree同等機能
pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
~~~

## rootパスワードリセット ##

[26.10. ブート中のターミナルメニューの編集](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-terminal_menu_editing_during_boot#proc-Resetting_the_Root_Password_Using_rd.break)

~~~bash
# 1 システムを起動し、GRUB 2 ブート画面で e キーを押して編集を行います。
# 2 rhgb パラメーターおよび quiet パラメーターを、最後または末前 (linux16 行、UEFI システムの場合は linuxefi) から削除します。
# 3 64 ビット IBM Power シリーズの場合は linux 行、x86-64 BIOS ベースシステムの場合は linux16 行、または UEFI システムの場合は linuxefi 行の最後に以下のパラメーターを追加します。
rd.break enforcing=0
# 4 Ctrl+x を押して変更したパラメーターでシステムを起動します。
# 5 ファイルシステムを書き込み可能で再マウントします。
mount -o remount,rw /sysroot
# 6 書き込みが有効な状態でファイルシステムが再マウントされます。
chroot /sysroot
# 7 passwd コマンドを入力し、rootパスワード変更
# 8 パスワードファイルを更新すると、SELinux セキュリティーコンテキストが正しくないファイルが作成されます。次回のシステムのブート時にすべてのファイルを再ラベルするには、以下のコマンドを入力します。
touch /.autorelabel
~~~
