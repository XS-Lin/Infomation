# FTP メモ #

## 詳細 ##

### tcpdumpでPASVパラメータの見方 ###

[RFC 959](https://tools.ietf.org/html/rfc959)
[RFC 2428](https://tools.ietf.org/html/rfc2428)
[FTP: a deeper look at a 'Passive' file transfer](https://www.ibm.com/support/pages/ftp-deeper-look-passive-file-transfer)

FTPサーバにPASVコマンド送信、応答が「227 Entering Passive Mode. A1,A2,A3,A4,a1,a2」の場合、data channelの接続先IPはA1.A2.A3.A4、ポートはa1*256+a2

~~~txt
227 Entering Passive Mode (192,168,3,2,234,26) -> 192.168.3.2:59930
~~~

FTPサーバにEPSVコマンド送信、応答がポート番号

~~~txt
229 Entering Extended Passive Mode (|||5008|) -> 5008
~~~

### tcpdumpフィルター ###

[tcpdump man](https://linuxjm.osdn.jp/html/tcpdump/man1/tcpdump.1.html)

~~~bash
tcpdump host ip 192.168.3.8
tcpdump dst host 192.168.3.8
tcpdump src host 192.168.3.8
tcpdump -nn -vv -X ftp or ftp-data
~~~

### Wireshark フィルター ###

~~~txt
ip.addr=192.168.3.8
ip.src=192.168.3.8
ip.dst=192.168.3.8
ftp or ftp-data
(ip.src_host==192.168.3.8 or ip.dst_host== 192.168.3.2) and (ip.src_host == 192.168.3.2 or ip.dst_host == 192.168.3.2)
~~~

### IIS FTP Log ###

[Flush IIS HTTP and FTP Logs to Disk](https://blogs.iis.net/owscott/flush-iis-http-and-ftp-logs-to-disk)

6minまたは64KB毎にログをディスクに書き出す。(httpは1minまたは64KB)

~~~powershell
Param($siteName = "Default Web Site")
 
#Get MWA ServerManager
[System.Reflection.Assembly]::LoadFrom( "C:\windows\system32\inetsrv\Microsoft.Web.Administration.dll" ) | Out-Null
$serverManager = new-object Microsoft.Web.Administration.ServerManager 
 
$config = $serverManager.GetApplicationHostConfiguration()
 
#Get Sites Collection
$sitesSection = $config.GetSection("system.applicationHost/sites")
$sitesCollection = $sitesSection.GetCollection()
 
#Find Site
foreach ($item in $sitesCollection){
 
    if ($item.Attributes.Item($elementTagName).Value -eq $siteName){
        $site = $item
    }
}
#Validation
if ($site -eq $null) { 
    Write-Host "Site '$siteName' not found"
    return
}
if (!($ftpServer.ChildElements.Count)){
    Write-Host "Site '$siteName' does not have FTP bindings set"
    return
}
 
#Flush the Logs
$ftpServer = $site.ChildElements.Item("ftpServer")
$ftpServer.Methods.Item("FlushLog").CreateInstance().Execute()
~~~
