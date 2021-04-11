# Flutter Info #

## My Flutter Enverionment ##

~~~powershell
# add d:/flutter/flutter/bin to Path
flutter doctor

~~~

注意：haxmとHyper-Vと競合
Docker のバックエンドHyper-v または WSL2 依存、WSL2は内部でHyper-V使用

~~~powershell
# 管理者で以下のコマンド実行し、再起動
bcdedit /set hypervisorlaunchtype off
# 戻すコマンド bcdedit /set hypervisorlaunchtype auto
~~~

~~~powershell
PS C:\Users\linxu> flutter doctor --android-licenses
Exception in thread "main" java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
        at com.android.repository.api.SchemaModule$SchemaModuleVersion.<init>(SchemaModule.java:156)
        at com.android.repository.api.SchemaModule.<init>(SchemaModule.java:75)
        at com.android.sdklib.repository.AndroidSdkHandler.<clinit>(AndroidSdkHandler.java:81)
        at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:73)
        at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:48)
Caused by: java.lang.ClassNotFoundException: javax.xml.bind.annotation.XmlSchema
        at java.base/jdk.internal.loader.BuiltinClassLoader.loadClass(BuiltinClassLoader.java:583)
        at java.base/jdk.internal.loader.ClassLoaders$AppClassLoader.loadClass(ClassLoaders.java:178)
        at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:521)
        ... 5 more

$env:JAVA_HOME='C:\Program Files (x86)\Java\jdk1.8.0_161'
PS C:\Users\linxu> flutter doctor --android-licenses
Review licenses that have not been accepted (y/N)? y
~~~

~~~powershell
flutter channel # チャンネル一覧表示
# 2021/02/28時点、stableはandroid studio 4.1.2 未対応のため、開発ブランチ利用
flutter channel dev
flutter upgrade
flutter doctor
flutter devices #検出できない
# Android device の開発者モード有効、debug有効
flutter devices
~~~

~~~powershell
flutter upgrade

PS C:\Users\linxu> flutter --version
Flutter 2.1.0-10.0.pre • channel dev • https://github.com/flutter/flutter.git
Framework • revision cc9b78fc5c (8 days ago) • 2021-02-25 13:26:03 -0800
Engine • revision a252ec09b7
Tools • Dart 2.13.0 (build 2.13.0-77.0.dev)
~~~





