# メモ #

## Java ##

1. Zip解凍の制約
[java.util.zip.ZipInputStream.java](https://github.com/openjdk/jdk/blob/master/src/java.base/share/classes/java/util/zip/ZipInputStream.java)
[zip定義](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT)
[ZIP (ファイルフォーマット) wiki](https://ja.wikipedia.org/wiki/ZIP_(%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88))
   * java.util.zipはDEFLATED,STORED のみサポートする。
   * windowのデフォルトツールでzip圧縮の時に、2GB以下はDEFLATED、2GBを超える場合はDEFLATED64のcompression methodで圧縮する。
   * zipのcompression methodはファイルヘッダの9と10バイトで確認できる。

   ~~~bash
   xxd -u -l 4 test.zip # 504B 0304 zipファイルヘッダ シグネチャ
   xxd -s 8 -l 2 test.zip # 0800 deflated 0900 deflated64
   ~~~

2. JVM調査メモ(java11)

[jcmd](https://docs.oracle.com/en/java/javase/11/tools/jcmd.html#GUID-59153599-875E-447D-8D98-0078A5778F05)
[jstat](https://docs.oracle.com/en/java/javase/11/tools/jps.html#GUID-6EB65B96-F9DD-4356-B825-6146E9EEC81E)
[jps](https://docs.oracle.com/en/java/javase/11/tools/jstat.html#GUID-5F72A7F9-5D5A-4486-8201-E1D1BA8ACCB5)

   ~~~bash
   # 実行中のjava process確認
   jcmd -l
   jps
   # Process id が 1 とする
   jcmd 1 GC.class_histogram # クラスのインスタンスのヒープ領域使用量
   jcmd 1 Thread.print # 各Threadのスタックトレース取得、結果のnid=0xFFはThreadId
   # ps コマンドでThreadId Id取得
   ps aux -L # LWP列
   docker top <ContainerId> aux -L # LWP列
   # pid、lwpを16進数変換
   printf "%X\n" 12345
   ~~~


## OJDBC ##

引用元 [Oracle JDBC FAQ](https://www.oracle.com/technetwork/jp/database/application-development/jdbc/overview/default-090281-ja.html#01_01)

1. Oracle JDBCのリリースとJDKのバージョン

   |Oracle Databaseのバージョン|リリース固有のJDBC jarファイル|
   |---|---|
   |18.3|ojdbc8.jar（JDK 8、JDK 9、JDK 10およびJDK 11）|
   |12.2または12c R2|ojdbc8.jar（JDK 8）|
   |12.1または12c R1|ojdbc7.jar（JDK 7およびJDK 8） ojdbc6.jar（JDK 6)|
   |11.2または11g R2|ojdbc6.jar（JDK 6、JDK 7、およびJDK 8）**（注：JDK 7とJDK 8は、11.2.0.3と11.2.0.4のみでサポートされます）** ojdbc5.jar（JDK 5）|

1. Oracle DBバージョンのクライアント/サーバー相互運用性マトリックスまたは認定マトリックス

   | 相互運用性マトリックス | Database 18.3 | Database 12.2および12.1 | Database 11.2.0.x |
   |---|---|---|---|
   | JDBC 18.3 | 対応 | 対応 | 対応 |
   | JDBC 12.2および12.1 | 対応 | 対応 | 対応 |
   | JDBC 11.2.0.x | 対応 | 対応 | 対応 |

1. Oracle JDBCのリリースとJDBCの仕様の関連

   | Oracle Databaseのバージョン | JDBC仕様の準拠 |
   |---|---|
   | 18.3 | ojdbc8.jarのJDBC 4.2 |
   | 12.2または12c R2 | ojdbc8.jarのJDBC 4.2 |
   | 12.1または12c R1 | ojdbc7.jarのJDBC 4.1、ojdbc6.jarのJDBC 4.0 |
   | 11.2または11g R2 | ojdbc6.jarのJDBC 4.0、ojdbc5.jarのJDBC 3.0 |

1. JDBC jarファイルはどこから入手できますか。

   必要なJDBC jarファイルは、Oracle Technology Networkの[SQLJ & JDBCダウンロード・ページ](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html)からダウンロードしてください。
