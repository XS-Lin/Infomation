# Linuxコマンド #

## たまに使われ、知らないと困るコマンドのまとめ ##

[GNUオペレーティング・システム](https://www.gnu.org/software/)
[sed](https://www.gnu.org/software/sed/manual/html_node/index.html)
[awk](https://www.gnu.org/software/gawk/manual/gawk.html)

~~~sh
# Windowの改行コードをLinuxの改行コードに変更
sed -i 's/\r//' file_name
# treeコマンドがない環境でtree同等機能
pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'

# awk [option][command][file]
ls -t | awk "/^[0-9A-F]{24}$/{if(++n>2048)print;}" #フォルダ内WALファイルが最新の2048個以外のWALファイル削除

cp -p # パーミッションと所有者とタイムスタンプ保持

ls -t # ファイル更新日時の新しい順

du -s /tmp #/tmpのサイズを調べる（単位:kB）, -hで適当な単位表示

xxd # 16進数表示(-c 表示桁数1~256 default:16)
sed 's \x15\x42\x02 \x12\x12\x02 g' test | xxd -c 6 # バイト置き換え16進数表示
# sed 注意:0x24 $ 0x5E ^ 0x5c \ は特別な意味があるため、変換時は要注意

# 0byte ファイル削除
find . -name "*.txt" -type f -size 0 -delete
~~~

~~~sh
# test_sjis.txt の21~28バイトは8桁の日付で、最小値が00000000、最大値が99999999、Postgresqlに登録するときエラーがあるため置換が必要。
# マルチバイト文字があるため、バイト単位で置換が必要。（41バイト固定長）
cat test_sjis.txt | awk -b '/^.{20}0{8}.*${printf "%s%s%s%s",substr($1,1,20),"        ",substr($1,29,length($1)-28)}' | xxd -c 41 -p # 21~28byteの"00000000"を"        "に置き換え
cat test_sjis.txt | awk -b '
BEGIN { FIELDWIDTHS = "20 8 12" }
{
    str = $2
    if (str == "00000000") {
        printf "%s%s%s%s",$1,"        ",$3,"\n"
    }
    else if (str == "99999999") {
        printf "%s%s%s%s",$1,"20991231",$3,"\n"
    }
    else {
        printf "%s%s%s%s",$1,$2,$3,"\n"
    }
}' | xxd -c 41 -p # 21~28byteの"00000000"を"        "に、"99999999"を"20991231"に置き換え
~~~

~~~sh
tail -c 1 # ファイルの末尾1 byte取得
if [ "`tail -c 1 filename | xxd -p`" = "0a" ]; then echo "1"; fi # ファイルの末尾が改行か確認
~~~

~~~sh
# sqlldrのコントロールファイルよりテーブル名確認
grep -n -dskip -e "INTO TABLE" sqlldr/*
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

## awk ##

Sqlldrのコントロールファイルからテーブル名とカラム名取得

~~~awk
#!/bin/awk -f 
#    get_ctl_info.awk /path/*.ctl
BEGIN {
    output_header = "ctl_name,table_name,column_name,byte,start_position"
    ctlInfoRowIndex = 1
}
BEGINFILE {
    current_file_name = FILENAME
    sub(".*/", "", current_file_name)
}
{
    if (match($0,/INTO\s+TABLE\s+(\w+)\s*/,arrTable)) {
        ctlTableName = arrTable[1]
    }

    if (match($0, /\s*(\w+)\s+POSITION\(([0-9]+):([0-9]+)\)\s*(\S*),?/, arrPostion)) {
        gsub("^0*", "", arrPostion[2])
        gsub("^0*", "", arrPostion[3])
        gsub(",$", "", arrPostion[4])

        ctlInfoArr[ctlInfoRowIndex][1] = current_file_name
        ctlInfoArr[ctlInfoRowIndex][2] = ctlTableName
        ctlInfoArr[ctlInfoRowIndex][3] = arrPostionh[1]
        ctlInfoArr[ctlInfoRowIndex][4] = strtonum(arrPostionh[3]) - strtonum(arrPostionh[2]) + 1
        ctlInfoArr[ctlInfoRowIndex][5] = strtonum(arrPostionh[2])
        ctlInfoArr[ctlInfoRowIndex][6] = arrPostionh[4]

        printf "%s,%s,%s,%s,%s,%s\n",ctlInfoArr[ctlInfoRowIndex][1],ctlInfoArr[ctlInfoRowIndex][2],ctlInfoArr[ctlInfoRowIndex][3],ctlInfoArr[ctlInfoRowIndex][4],ctlInfoArr[ctlInfoRowIndex][5],ctlInfoArr[ctlInfoRowIndex][6]

        ctlInfoRowIndex ++
    }
}
ENDFILE {}
END {}
~~~

個別ファイル読み取り

~~~awk
# awk -v test=test.csv ...
if (system("test -f " test) == 0) {
    input = "cat " test
    while((input | getline) > 0) {
        patsplit($0,arrR,"([^,]+)|(\"[^\"]+\")")
        print arrR[1],arrR[2] #arrR[3]...
    }
}
~~~

個別ファイル出力

~~~awk
print "field1","field2","field3" > "test.csv"
~~~

## curl ##

~~~bash
# ステータス取得
# -L,--location -I,--head -w,--write-out -s,--silent
curl -LI http://www.google.co.jp -o /dev/null -w '%{http_code}\n' -s

# HEADER
# -D,--dump-header <filename>

# POST
# --data-binary --data-raw --data-urlencode -d,--data -o,--output

# FTP
# -a,--append --ftp-create-dirs --disable-eprt --disable-epsv -P,--ftp-port --fep-pasv --ftp-account <data> 

# TLS
# -E,--cert <certificate[:password]> --key
~~~

## ファイルサイズ ##

physical_block_size デバイスが動作できる最小の内部ユニット
logical_block_size  デバイス上の場所指定に外部で使用される
alignment_offset    基礎となる物理的なアライメントのオフセットとなるLinuxブロックデバイス(パーティション/MD/LVM)の先頭部分のバイト数
minimum_io_size     ランダムIOに対して推奨のデバイスの最小ユニット
optimal_io_size     ストリーミングIOに対して推奨のデバイスの最小ユニット

~~~bash
# NAME,       device name
# KNAME,      internal kernel device name
# FSTYPE,     file system
# MOUNTPOINT, where the device is mounted
# RA,         read-ahead of the device
# MIN-IO,     minimum I/O size 
# OPT-IO,     optimal I/O size
# PHY-SEC,    physical sector size
# LOG-SEC     logical sector size
lsblk -o NAME,KNAME,FSTYPE,MOUNTPOINT,RA,MIN-IO,OPT-IO,PHY-SEC,LOG-SEC
~~~

## システム状態監視 ##

~~~bash
vmstat -n 10
vmstat -dn 10
# top 対話モード 'W'コマンドで ~/.toprcl に設定保存 (グローバル設定は/etc/toprc)
# top 対話モード '1'コマンドで CPUs使用率をサマリと各コア表示に切り替え
top -b -d 60 -n 30 > top_result.txt
while true; do df /tmp; sleep 30s; done
~~~

## 並行 ##

~~~bash
wait
~~~
