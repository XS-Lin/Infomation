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

## Javaコマンド ##

~~~java
javac -classpath "." Main.java
java -classpath "." Main
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

## Learn Java SE6 ##

### System properties ###

~~~bash
java -Dstreet=sesame MainClassName # System.getProperty("street")
~~~

### ClassPath ###

~~~bash
CLASSPATH=/path # 環境変数
javac -classpath /path # or パラメータ
javac -d /path # 参照するclassファイルフォルダー指定
~~~

### JShell ###

JShellは、Javaプログラミング言語の宣言、文および式を対話しながら評価する手段となり、言語の習得、よく知らないコードおよびAPIの試用、複雑なコードの試作がしやすくなります。Javaの文、変数定義、メソッド定義、クラス定義、インポート文および式が使用可能です。入力されたコードの断片をスニペットと呼びます。

~~~java
/exit
~~~

### jar ###

~~~bash
# c - create 
# t - list
# x - extract
# v - verbose
# f - file
jar -cvf jarFile path [path]
jar -tvf jarFile path [path]
jar -xvf jarFile path [path]
~~~

### Language ###

* primitive types are passed "by value" ※値をコピーする
* reference types are passed "by reference" ※参照をコピーする
* anonymous inner class
  * 1回のみのクラスが作成できる。 new ClassName(){prop;fun;}
* assert
  * 問題発見のために利用、パラメータチェックと単体テスト目的ではない。
* String
  * 演算子はオーバーロードできない、equalsはできる。== はインスタンス一致を比較するが、Javaは同じ文字列で別のインスタンス作成できるので、equalsで比較すること。
  * 正規表現
    * [java21 regex](https://docs.oracle.com/javase/jp/21/docs/api/java.base/java/util/regex/Pattern.html)
    * jshell> Pattern.matches("(?i)[^@]+@[^@]+\\.[a-z]+","good@some.domain")

### Threads ###

* Process 内のstatic and instance level variablesを共有するが、local variablesは共有しない。
* Thread and Runnnable
  * Runnnable 基本的にこちらを使う
  * Thread 本当にThreadクラスの大部分の機能の場合は継承して利用
* Control
  * Thread.sleep()
  * wait() and join()
  * notify()
  * interrupt()
* Threadの状態※getState()
  * NEW - 作成後未起動の状態
  * RUNNABLE - 活動中、I/O待ちを含む
  * BLOCKED - 同期実行待ち
  * WAITING,TIMED_WAITING - 待ち状態
  * TERMINATED - 終止
  * start()
  * stop()
  * suspend()
  * resume()
* Threadの終了条件
  * run()の return
  * 未処理のruntime exception
  * stop()の実行
* Virtual Threads (Java21)
  * 物理スレッドの数より多い仮想スレッド作成できる
* Performance
  * 同期コスト(Virtual Threadsのほうが低い)

### I/O ###

* Stream Wrappers
  * DataInputStream, DataOutputStream - String(as chars), primitive types
  * BufferedInputStream, BufferedOutputStream, BufferedReader, BufferedWriter - a specified size buffer
  * PrintWriter, PrintReader - with a set of Print methods
  * FileInputStream, FileOutputStream - file opration
* NIO
  * Asynchronous I/O
  * Mapped and Locked Files - MappedByteBuffer
  * Channels - isOpen() and close()
    * FileChannel
    * Pipe.SinkChannel, Pipe.SourceChannel
    * SocketChannel, ServerSocketChannel, DatagramChannel

### Lambda ###

~~~java
import java.util.function.*
IntFunction inc = x -> x + 1
inc.apply(1)
~~~

~~~java
Stream.generate(()->42).limit(3).forEach(System.out::println)
IntStream.iterate(1,i->i+1).limit(5).forEach(System.out::println)
var names = new String[]{"Fozzie","Gonzo","Kermit","Piggy"}
String[] names = {"Fozzie","Gonzo","Kermit","Piggy"}
var names = new ArrayList<String>(Arrays.asList("Fozzie","Gonzo","Kermit","Piggy"))
var names = Arrays.asList("Fozzie","Gonzo","Kermit","Piggy")

names.stream().filter(n -> n.indexOf("o") > -1).count()
names.stream().map(n -> n + "xx").forEach(System.out::println)
List<String> onames = names.stream().filter(n -> n.indexOf("o") > -1).collect(Collectors.toList())
~~~

Reducing and Collecting

* Terminal reduction operations
  * count()
  * findAny()
  * findFirst()
  * matchAll()
  * matchAny()
  * min()
  * max()
* Custom reduction
  * [パッケージjava.util.stream](https://docs.oracle.com/javase/jp/21/docs/api/java.base/java/util/stream/package-summary.html)
  * [Stream](https://docs.oracle.com/javase/jp/21/docs/api/java.base/java/util/stream/Stream.html)
* Collectors
  * [Collectors](https://docs.oracle.com/javase/jp/21/docs/api/java.base/java/util/stream/Collectors.html)

~~~java
var one = BigInteger.ONE
Stream.iterate(one,count->count.add(one)).limit(12).reduce(one,(a,b)->a.multiply(b))
~~~
  






