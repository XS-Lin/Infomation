# MyNote VSCode PlantUML Install (windows) #

## インストール(Local) ##

1. Javaインストール

   1. JAVA_HOME="C:\Program Files\Java\jdk-11.0.1"
   1. PATHに追加「%JAVA_HOME%\bin」

2. Graphviz

   1. [download](https://graphviz.org/download/)
   2. 「Stable 2.44 Windows install packages」※2020/06/20時点
   3. 「Environment: build_system=msbuild; Configuration: Release」
   4. 「artifacts」
   5. 「graphviz-windows.zip」
   6. 解凍
   7. PATHに追加「D:\Program Files\Graphviz\bin」

3. VSCodeにPlantUML(ver 2.11.2)追加

**[2020/06/20時点]上記ローカルRender設定について、2.11.2以後はエラーになる。2.11.3以後はServer版のみ使用可能になる。**

## インストール(PlantUML Server Docker) ##

1. Docker (Windows Home はインストールできない)

1. PlantUML Server

[PlantUML Server](https://github.com/plantuml/plantuml-server)

## インストール(PlantUML Server Tomcat) ##

1. 必要な資材をダウンロード

   * [Java Download (JDK8以後)](http://jdk.java.net/)

   * [Tomcat Download(apache-tomcat-9.0.36-windows-x64.zip)](https://tomcat.apache.org/download-90.cgi)

   * [PlantUML Download(plantuml-v1.2020.13.war)](https://github.com/plantuml/plantuml-server/releases)

   * [Graphviz download(graphviz-windows.zip)](https://graphviz.org/download/)

     **以下の順番でクリックするとダウンロード開始**
       1. Stable 2.44 Windows install packages
       1. Environment: build_system=msbuild; Configuration: Release
       1. artifacts
       1. graphviz-windows.zip

1. JavaとTomcatを解凍、PlantUMLをTomcatに配置

   **例**

   ~~~dosbatch
   # D:\Program Files\PlantUML_Server\jdk-14.0.1
   # D:\Program Files\PlantUML_Server\apache-tomcat-9.0.36
   # D:\Program Files\PlantUML_Server\Graphviz
   # D:\Program Files\PlantUML_Server\apache-tomcat-9.0.36\webapps\plantuml-v1.2020.13.war
   SET JAVA_HOME=D:\Program Files\PlantUML_Server\jdk-14.0.1
   SET GRAPHVIZ_DOT=D:\Program Files\PlantUML_Server\Graphviz\bin\dot.exe
   SET CATALINA_HOME=D:\Program Files\PlantUML_Server\apache-tomcat-9.0.36
   # 起動
   "%CATALINA_HOME%\bin\startup.bat"
   # 停止
   "%CATALINA_HOME%\bin\shutdown.bat"
   #http://localhost:8080/plantuml-v1.2020.13
   ~~~

1. VSCodeにPlantUML追加

   **設定変更**

   ~~~json
   plantuml.server=http://localhost:8080/plantuml-v1.2020.13
   plantuml.render=PlantUMLServer
   ~~~

## 使用 ##

[PlantUML公式サイト](https://plantuml.com/ja/)

## クラス図 ##

~~~plantuml
@startuml name
Class01 <|-- Class02
Class03 *-- Class04
Class05 o-- Class06
Class07 .. Class08
Class09 -- Class10
@enduml
~~~

## シーケンス図 ##

~~~plantuml
@startuml
autonumber 10 10 "<b>[000]"
Bob -> Alice : Authentication Request
Bob <- Alice : Authentication Response

autonumber stop
Bob -> Alice : dummy

autonumber resume "<font color=red><b>Message 0  "
Bob -> Alice : Yet another authentication Request
Bob <- Alice : Yet another authentication Response

autonumber stop
Bob -> Alice : dummy

autonumber resume 1 "<font color=blue><b>Message 0  "
Bob -> Alice : Yet another authentication Request
Bob <- Alice : Yet another authentication Response
@enduml
~~~
