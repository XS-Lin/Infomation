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

   ~~~powershell
   # key押下
   Add-Type -AssemblyName System.Windows.Forms
   [System.Windows.Forms.SendKeys]::SendWait("^{ESC}") # Windowsキー押下 (ctrl+esc)
   [System.Windows.Forms.SendKeys]::SendWait("run")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("notepad")
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("This is a test script.")
   [System.Windows.Forms.SendKeys]::SendWait("^s") #ctrl+sキーを押す
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("newtext.txt")
   [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
   Start-Sleep -s 1
   [System.Windows.Forms.SendKeys]::SendWait("%{F4}") #Alt+F4キーを押す
   ~~~

   ~~~powershell
   # https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/add-type?view=powershell-6
   $Source = @"
   public class BasicTest
   {
     public static int Add(int a, int b)
       {
         return (a + b);
       }
     public int Multiply(int a, int b)
       {
       return (a * b);
       }
   }
   "@

   Add-Type -TypeDefinition $Source
   [BasicTest]::Add(4, 3)
   $BasicTestObject = New-Object BasicTest
   $BasicTestObject.Multiply(5, 2)
   ~~~
