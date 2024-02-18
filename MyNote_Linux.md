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
od -v -t x1z user.avro #16進数表示
hexdump -C # 16進数表示 (デフォルト2バイトずつ、-C で1バイト)

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

## bash ##

~~~bash
command1 || command2 # if command1 not success, then execute command2
command1 && command2 # if command1 success, then execute command2
command1 ; command2 #  execute command1 , then execute command2

$0 # shell script name  
$1 # first parameter
${10} # 10th parameter
$# # count of parameters
$* # all parameters

myarr=(one two three four five)
echo ${myarr[1]}
echo ${myarr[*]}
unset myarr[1]
unset myarr

printenv HOME
printenv PATH

# 変数スコープ
#   デフォルト: 変数定義するプロセス
#   export: 他プロセスは変数をコピーして利用、子プロセスがこのコピーを再度exportしても元の値に影響しない。

: # 何もしないコマンド

read -p "prompt" varname
echo $varname

read -sn1 -p "press any key to continue." # -s silent -n length

shift # $3が$2,$2が$1になり、$1は削除される
test $PWD == $HOME || cd $HOME

who # login user
write # send message to user 

[[ ]] # パターンマッチ、正規表現
(( )) # 数値計算、数値パラメータ操作、算術テスト

for var in one "This is tow" "Now three" ; do echo "Value: $var" ; done

declare -F 
type quote

$@ # 関数のパラメータを配列として使用
$? # 関数のステータス



~~~

~~~bash
declare -i i=100 # 整数
declare -r x="read only parameter" # readonly コマンドと同じ
declare -a a=("car" "ship" "airplane")
declare -A a=([car]="red" [ship]="green" [airplane]="blue") # dash,ash,mkshで使えない。zshでは$(!array[@])と$(!array[*])による連想配列のインデックスリスト取得できない。
declare -n var="$1" # 関数パラメータの参照渡し
declare -l # 自動小文字変換
declare -u # 自動大文字変換
declare -x # 環境変数, export コマンドと同様
declare -ft # 関数終了時trapコマンド実行
~~~

~~~bash
# <<< 
#   コマンド <<< 文字列  は  echo 文字列 | コマンド と同様、プロセスの違いがある。
~~~

~~~bash
echo {0..10}
echo {0..10..2}
echo {A..F}
echo {a..z..4}
echo {A..z}
echo {A..Z} {a..z}
~~~

~~~bash
# 変数展開
${parameter-default} # 変数未定義の場合default
${parameter:-default} # 変数未定義またはヌルの場合default
${param:=value} # 変数未定義またはヌルの場合、param=valueになる
${param=value} # 変数未定義の場合、param=valueになる
${param:+new value} # 変数未定義でもない、ヌルでもない場合new value。$param は変更しない。
${param+new value} # 変数未定義でない場合new value。$param は変更しない。
${param:?message} # 変数未定義またはヌルの場合,message を標準エラーに出力
${param?message} # 変数未定義の場合,message を標準エラーに出力

str="0123456789abcdef"
echo "Length: ${#str}"
echo "${str:10}"
echo "${str:10:2}"
echo "${str:10:-2}" # 10文字目から末尾2文字を除く
echo "${str: -10}"
echo "${str: -10:2}"
echo "${str: -10:-2}" # 後ろから10文字目から末尾2文字を除く

str="word"
echo "${str^}"
echo "${str^^}"
echo "${str,}"
echo "${str,,}"
echo "${str~}"
echo "${str~~}"

str="/usr/share/bash-comletion/comletions"
echo "${str#*/}" # ${param#pattern} 最短マッチ先頭削除
echo "${str##*/}" # ${param##pattern} 最長マッチ先頭削除
echo "${str%/*}" # ${param%pattern} 最短マッチ末尾削除
echo "${str%%/*}" # ${param%%pattern} 最長マッチ末尾削除
echo "${str/comletion/example}" # ${param/pattern/replacement} マッチ置換1回
echo "${str//comletion/example}" # ${param//pattern/replacement} マッチ置換複数回
echo "${str/#\/usr/example}" # 先頭の /usr を置換
echo "${str/%comletions/example}" # 末尾の comletions を置換

# ${!NAME*} ${!NAME@}
echo ${!s*}

# bash >= 4.4
#   @a 変数型
#   @A 変数定義
#   @E エスケープ, echo -e と同様
#   @P \u, \w をサポート
#   @Q 単一引用符
# bash >= 5.0.17
#   @u 先頭大文字
#   @U すべて大文字
#   @L すべて小文字
#   @K 連想配列の時に引用符出力
# bash >= 5.2
#   @k 
declare -A a=([car]="red" [ship]="green" [airplane]="blue")
echo ${a[@]@K} # ship "green" airplane "blue" car "red"
~~~

~~~bash
# プロセス置換
#   cmd1 <(cmd2) コマンド2の結果をファイルとしてコマンド1の入力
#   cmd1 >(cmd2) コマンド1の結果をコマンド2の入力
diff -u <(ls /etc/rc0.d) <(ls /etc/rc1.d)
cat /etc/shells | tee >(grep /usr/bin > filtered.txt) | sort 
~~~


## sed ##

FreeBSD の sed と GNU の sed のオプションは違いがある。macOSのsedはFreeBSDからのもの。

~~~bash
sed '3,5s/sed/Linux sed/gw outfile' myfile # g w 
sed '2c\modify the 2nd line'
sed 'y/abc/ABC/'
sed -e 's/First/XFirst/; s/Second/XSecond/'
~~~

## awk ##

gawk, mawk, tawk, nawk がある。FreeBSD,macOSのOne True Awk はオプションと動作がgawkと違いがある。

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

~~~bash
# CSV
#   format
#      field1: そのまま
#      field2: 最後のver1部分を切り出す、"-"の数不定
#      field3: 最後のver1部分を切り出す
echo "\"name\",\"i-test-ver1-\",\"i-test:ver1\"" | awk '
BEGIN {FS=","; OFS="\",\""}
{
    name=$1;
    f1=$2;
    f2=$3;
    gsub(/"/, "", name);
    gsub(/"/, "", f1);
    gsub(/"/, "", f2);
    n=split(f1,arr,"-");
    v1=arr[n-1];
    match(f2,/:.*$/);
    v2=substr(f2,RSTART+1, RLENGTH);
    printf("%s,%s,%s",name,v1,v2)
}'
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

curl -o test.txt -SL https://test
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

## Tree ##

~~~bash
pwd ; find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g' | less
~~~

## WSL ##

~~~bash
# python 3.10 for Ubuntu 20.04.5 LTS
cat /etc/os-release
sudo apt update
sudo apt upgrade # optional
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.10
# install poetry
curl -sSL https://install.python-poetry.org | python3.10 - # /home/lin/.local/bin/poetry
export PATH="/home/lin/.local/bin:$PATH"
poetry --version
# https://python-poetry.org/docs/basic-usage/
poetry new poetry-demo
poetry shell
exit
~~~

## cron ##

~~~txt
0/1 means starting at 0 every 1
1/1 means starting at 1 every 1
* means all possible values
  For the minutes, hours, and day of week columns the 0/1 and * are equivalent as these are 0 based
  For the Day Of Month and Month columns 1/1 and * are equivalent as these are 1 based
~~~

## other ##

- strace
  - strace -o hello.log ./hello
  - strace -T -o hello.log ./hello

- sar
  - sar -P 0 1 1

- ldd
  - ldd /bin/echo

- dpkg-query (ubuntu)
  - dpkg-query -W | grep ^lib

- cc
  - cc -static -o pause pause.c
  - cc -o pause pause.c
  - cc -o pause -no-pie pause.c
    - readlf -h pause
    - readlf -S pause

- pstree

- man 7 signal
  - SIGKILL
  - SIGHUP
    - nohup
    - bash disdown
  - SIGSEGV
  - SIGUSR1 and SIGUSR2

- kill  
  - PID
  - PGID

- sleep
  - sleep infinity &
  - sleep infinity &
  - jobs
  - fg 1
  - ^Z

- ps
  - ps aux
  - ps ajx
  - ps -eLF

- daemon
  - 端末なし
  - 独自セッション
  - init が親

- time
  - time ./load.py
    - real
    - user
    - sys
      - user+sys > real のパターン
        -timeコマンドの user+sys はサプロセスとブプロセスの合計。複数コアCPUの場合、別のCPUでサブプロセス動作すると発生

- sysctl

- dmesg
  - プロセスが突然終了の時は oom-kill かも

- socket
  - unix
  - tcp

- flock

- fio
