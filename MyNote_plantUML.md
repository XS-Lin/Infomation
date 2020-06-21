# MyNote VSCode PlantUML (windows) #

## インストール ##

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
