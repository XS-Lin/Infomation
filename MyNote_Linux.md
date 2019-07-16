# Linuxコマンド #

たまに使われ、知らないと困るコマンドのまとめ

~~~sh
# Windowの改行コードをLinuxの改行コードに変更
sed -i 's/\r//' file_name
# treeコマンドがない環境でtree同等機能
pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
~~~
