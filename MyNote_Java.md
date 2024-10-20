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


## Java Performancd ##

[Java® Development Kitバージョン21ツール仕様](https://docs.oracle.com/javase/jp/21/docs/specs/man/index.html)

* jar - クラスおよびリソースのアーカイブを作成し、アーカイブから個々のクラスまたはリソースを操作またはリストア
* jarsigner - Java Archive (JAR)ファイルに署名して確認
* java - Javaアプリケーションを起動
* javac - Javaクラスおよびインタフェースの定義を読み取り、バイトコードおよびクラス・ファイルにコンパイル
* javadoc - Javaソース・ファイルからのAPIドキュメントのHTMLページの生成
* javap - 1つまたは複数のクラス・ファイルを逆アセンブル
* jcmd - 実行中のJava Virtual Machine (JVM)への診断コマンド・リクエストの送信
* jconsole - Javaアプリケーションを監視および管理するためのグラフィカルなコンソールの起動
* jdb - Javaプラットフォーム・プログラムでバグを検索して修正
* jdeprscan - 非推奨のAPI要素を使用するためにjarファイル(クラス・ファイルの他の集約)をスキャンする静的分析ツール
* jdeps - Javaクラス依存性アナライザを起動
* jfr - Flight Recorderファイルを解析および印刷
* jhsdb - Javaプロセスにアタッチするか、postmortemデバッガを起動して、クラッシュしたJava Virtual Machine (JVM)からのコア・ダンプの内容を分析
* jinfo - 指定されたJavaプロセスのJava構成情報を生成
* jlink - 一連のモジュールとその依存性を作成し、カスタム・ランタイム・イメージに最適化
* jmap - 指定プロセスの詳細を印刷
* jmod - JMODファイルの作成と、既存のJMODファイルの内容のリスト
* jpackage - 自己完結型のJavaアプリケーションをパッケージ化します
* jps - ターゲット・システムのインストゥルメントされたJVMをリスト
* jrunscript - 対話モードおよびバッチ・モードをサポートするコマンドライン・スクリプト・シェルを実行
* jshell - Javaプログラミング言語の宣言、文および式をread-eval-printループ (REPL)で対話形式で評価
* jstack - 指定されたJavaプロセスのJavaスレッドのJavaスタック・トレースのプリント
* jstat - JVM統計の監視
* jstatd - 計測されたJava HotSpot VMの作成と終了のモニター
* jwebserver - Java Simple Web Serverの起動
* keytool - 暗号化キー、X.509証明連鎖および信頼できる証明書のキーストア(database)を管理
* rmiregistry - 現在のホストの指定したポートで、リモート・オブジェクト・レジストリを作成および起動
* serialver - 展開するクラスへのコピーに適した形式で、1つ以上のクラスの`serialVersionUID`を返す

### JVM tools ###

* jcmd - 実行中のJava Virtual Machine (JVM)への診断コマンド・リクエストの送信
  * jcmd [pid | main-class] command... | PerfCounter.print | -f filename
    * GC.class_histogram (-all がなければ Full GCが発生する.)
      * [I - int[].class.getName()
      * [S - short[].class.getName()
      * [F - float[].class.getName()
      * [D - double[].class.getName()
      * [J - long[].class.getName()
      * [B - byte[].class.getName()
      * [C - char[].class.getName()
      * [Z - boolean[].class.getName()
      * [Ljava.lang.Object; - Object[].class.getName()
      * [[[I - int[][][].class.getName()
      * java.lang.Object - Object.class.getName()
    * GC.heap_info
* jinfo - 指定されたJavaプロセスのJava構成情報を生成
  * スクリプトで利用が多い
  * 個別フラグ調査
  * 場合によって変更もできる
* jmap - 指定プロセスの詳細を印刷
  * jmap [options] pid
* jps - ターゲット・システムのインストゥルメントされたJVMをリスト
* jstack - 指定されたJavaプロセスのJavaスレッドのJavaスタック・トレースのプリント
  * jstack [options] pid
    * gcutil option
      * S0: Survivor領域0の使用率(現在の容量に対するパーセンテージ)。
      * S1: Survivor領域1の使用率(現在の容量に対するパーセンテージ)。
      * E: Eden領域の使用率(現在の容量に対するパーセンテージ)。
      * O: Old領域の使用率(現在の容量に対するパーセンテージ)。
      * M: メタスペースの使用率(現在の容量に対するパーセンテージ)。
      * CCS: 圧縮されたクラス領域使用率をパーセンテージで指定します。
      * YGC: Young世代のGCイベントの数。
      * YGCT: Young世代のガベージ・コレクション時間。
      * FGC: フルGCイベントの数。
      * FGCT: フル・ガベージ・コレクションの時間。
      * GCT: ガベージ・コレクションの総時間。

* jstat - JVM統計の監視
  * jstat outputOptions [-t] [-h lines] vmid [interval [count]]

* JFR
  * -XX:+FlightRecorder オプション有効が前提

~~~bash
jcmd -l # 実行されているプロセス一覧
jcmd $process_id VM.uptime #
jcmd $process_id VM.system_properties # jinfo -sysprops
jcmd $process_id VM.version
jcmd $process_id VM.command_line
jcmd $process_id VM.flags -all # 単一flagの場合 jinfo -flag -PrintGCDetails pidのようにもできる
jcmd $process_id GC.class_histogram -all
jcmd $process_id GC.finalizer_info
jcmd $process_id GC.heap_dump [options] filename
jcmd $process_id GC.heap_dump -all "C:\Temp\test_dump.out"
jcmd $process_id GC.heap_info
jcmd $process_id JFR.check [options]
jcmd $process_id JFR.configure [options]
jcmd $process_id Thread.print -e -l # jstack $process_id
jcmd $process_id VM.classloaders
jcmd $process_id VM.classloader_stats
jcmd $process_id VM.class_hierarchy # クラス階層を示す
jcmd $process_id VM.command_line
jcmd $process_id VM.events log
jcmd $process_id VM.events max
jcmd $process_id VM.info
jcmd $process_id VM.log list
jcmd $process_id VM.flags -all
jcmd $process_id VM.metaspace vslist
jcmd $process_id 
jcmd $process_id 
jcmd $process_id 
~~~

~~~bash
jstat -gcutil $process_id 1000 # 1秒間隔出力、指定しない場合は1回のみ
S0     S1     E      O      M     CCS    YGC     YGCT     FGC    FGCT     CGC    CGCT       GCT
-      49.81  50.00  52.09  97.68  92.75      8     0.031     2     0.011     0     0.000     0.042
~~~

### メモリ ###

~~~powershell
E:\tool\visualvm_217\bin\visualvm.exe --jdkhome "C:\tools\jdk\oracle\jdk-21.0.2" --userdir "C:\Temp\visualvm_userdir"
~~~

