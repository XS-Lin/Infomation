# PowerShell #

## その他 ##

   ~~~powershell
   chcp 65001 # 接続先の文字コードがUTF8の場合
   ssh root@192.168.0.50
   ~~~

   ~~~powershell
   netsh wlan show profiles | %{ $_.Split(":")[1]} | `
   Where-Object{$_ -ne $null -and ( $_  -notmatch "^\s*$" ) } | `
   ForEach-Object{$_.trim()} | `
   ForEach-Object{ netsh wlan show profile name="$_" key=clear} | `
   Where-Object{ $_ -like "*主要なコンテンツ*" -or ( $_ -like "*SSID 名*" ) }
   ~~~
