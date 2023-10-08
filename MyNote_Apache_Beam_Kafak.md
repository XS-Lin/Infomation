# Apache Beam Kafka#

## 参照 ##

[What is Gradle?](https://docs.gradle.org/current/userguide/what_is_gradle.html#what_is_gradle)

## Apache Beam ##

### 環境設定 ###

PATHバックアップ

~~~txt
C:\Users\linxu\AppData\Local\Microsoft\WindowsApps;C:\Program Files\Microsoft VS Code\bin;C:\Users\linxu\AppData\Local\GitHubDesktop\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\extras\CUPTI\libx64;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\include;C:\tools\cuda\bin;c:\users\linxu\appdata\local\programs\python\python37\Scripts;D:\Program Files\Graphviz\bin;C:\Program Files\Java\jdk-11.0.1\bin;C:\Users\linxu\AppData\Roaming\npm;C:\Program Files\nodejs;C:\Users\linxu\.dotnet\tools;%USERPROFILE%\AppData\Local\Microsoft\WindowsApps;D:\flutter\flutter\bin;%USERPROFILE%\go\bin;C:\Users\linxu\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin;%USERPROFILE%\.dotnet\tools
~~~

環境変数設定

~~~powershell
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-17.0.2', 'User')
[Environment]::SetEnvironmentVariable('GRADLE_HOME', 'D:\develop\JavaDev\gradle-7.5', 'User')
[Environment]::SetEnvironmentVariable("PATH", [Environment]::GetEnvironmentVariable('PATH',[EnvironmentVariableTarget]::User) + ";%JAVA_HOME%\bin;%GRADLE_HOME%\bin", [EnvironmentVariableTarget]::User)
~~~

## Gradle ##

### 基本 ###

[Building Java Applications Sample](https://docs.gradle.org/current/samples/sample_building_java_applications.html)

~~~powershell
gradle init
gradle run
gradle build
gradle clean
~~~

~~~powershell
gradle tasks # list tasks
gradle dependencies # list dependencies
gradle dependencies --configuration runtime # Filer
~~~

## kafka ##

### basic ###

~~~powershell
cd E:\tool\kafka\kafka_2.13-3.5.1
bin\windows\zookeeper-server-start config\zookeeper.properties
bin\windows\kafka-server-start config\server.properties

bin\windows\kafka-topics --create --topic quickstart-events --bootstrap-server localhost:9092

bin\windows\kafka-topics --describe --topic quickstart-events --bootstrap-server localhost:9092

bin\windows\kafka-console-producer --topic quickstart-events --bootstrap-server localhost:9092
This is my first event
This is my second event

bin\windows\kafka-console-consumer --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
~~~
