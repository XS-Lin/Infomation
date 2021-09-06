# Windows Tips #

## Ctrl + Alt+ Del ##

リモートデスクトップのマシンへ送信：Ctrl + Alt + End
リモートデスクトップのマシン経由でリモートデスクトップのマシンへ送信：Ctrl + Alt + Shift + End

## ファイル分割(セキュリティ理由で7zipなどが使えない時) ##

~~~powershell
makecab /f split.txt
~~~

split.txt

~~~txt
.Set CabinetNameTemplate=splitfile*.cab
.Set DiskDirectoryTemplate="c:\work"
.Set MaxDiskSize=104857600
.Set Cabinet=on
.Set Compress=off
.Set InfileName=NUL
.Set RptFileName=NUL
"c:\temp\target"
~~~

