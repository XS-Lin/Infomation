# 逆引きリファレンス #

仕事でよくある様々なタスクに、各プログラミング言語での実装例

## Oracle Database ##

検証環境:ORACLE11gR2

* Python

~~~python
import cx_Oracle

connection = cx_Oracle.connect('system', 'ora', '192.168.56.102:1521/orcl01')
cursor = connection.cursor()
sql='''
SELECT * FROM dual
'''
cursor.execute(sql)
rows = cursor.fetchall()
for row in rows:
    print(row[0])
cursor.close()
connection.close()
~~~

* PowerShell

~~~powershell
Add-Type -AssemblyName System.Data.OracleClient

$ConnectionString = "Data Source=192.168.56.102:1521/orcl01;User ID=system;Password=ora;Integrated Security=false;"
$OraCon = New-Object System.Data.OracleClient.OracleConnection($ConnectionString)
$dtSet = New-Object System.Data.DataSet
$dtSet.Tables.Add()
$strSQL = @"
SELECT * FROM dual
"@
ForEach($tb in $dtSet.Tables){
    $data = New-Object System.Data.OracleClient.OracleDataAdapter($strSQL, $OraCon)
    [void]$data.Fill($tb)
    $tb | Format-Table
}
$OraCon.close()
~~~

## SqlServer ##

検証環境:SqlServer2017

## Encoding ##

* Python

~~~python

~~~

* PowerShell

~~~powershell
# ver > 6.2
$text | Out-File <filename> -Encoding 932
# 汎用
[System.IO.File]::WriteAllText($args[3],$text,[System.Text.Encoding]::GetEncoding('shift-jis'))
~~~

## XML ##

~~~python

~~~

* PowerShell

~~~powershell

~~~

## CSV ##

* Python

~~~python
import csv
# Read
f = open(path,'r')
for row in reader:
    print row
f.close()
# write
f = open(path,'w')
writer = csv.writer(f, lineterminator='\n')
writer.writerow(['a','b','c'])
f.close()
~~~

* PowerShell

~~~powershell
# Import-Csvの詳細
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv?view=powershell-6
# CSVファイルにヘッダあり
$csv = Import-Csv path -Encoding Default
$csv | Format-Table
foreach($row in $csv) {
    Write-Host $row.PropertyName # PropertyName はCSVファイルのヘッダの名前
}
# CSVファイルにヘッダがない場合、-Headerでヘッダ設定
$csv = Import-Csv path -Header A,B,c -Encoding Default
foreach($row in $csv) {
    Write-Host $row.A # AはCSVファイルのヘッダの名前
}
~~~

## Excel ##

* Python

~~~python
import openpyxl

~~~

* PowerShell

~~~powershell
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false # default false
$excel.DisplayAlerts = $false # default true
$book = $excel.WorkBooks.Open($excelFilePath)
$sheet = $book.Sheets($sheetName)
$value = $sheet.Range("A1").Text
$sheet.Range("A1").Text = $value
$ActiveWorksheet.cells.item(1,2) = "User_Name"
~~~

## Selenium ##

* Python

~~~python

~~~

* PowerShell

~~~powershell
# https://www.seleniumhq.org/download/
$webDriverDllPath = "D:\Site\LearnCSharp\bin\net40\WebDriver.dll" 
# https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
$driverExe = 'D:\Site\LearnCSharp\bin\'
# ブラウザのバージョン、ドライバEXEのバージョン、DLLのバージョンが合わない場合エラーになる。
# また、エラー情報にバージョンの情報が表示される。

Add-Type -Path $webDriverDllPath
$driver = New-Object  OpenQA.Selenium.Edge.EdgeDriver($driverExe)
#$driver = New-Object  OpenQA.Selenium.Chrome.ChromeDriver($driverExe)
$driver.Url = "https://www.google.co.jp/"

$inputBox = $driver.findElementByName("q")
$inputBox.SendKeys("HelloWorld by findElementByName")
Start-Sleep -Seconds 5
$inputBox.clear()
$inputBox = $driver.findElementById("lst-ib")
$inputBox.SendKeys("HelloWorld by findElementById")

#$driver.Quit()
~~~

## Http Post ##

* powershell

~~~powershell
$postText = @{key="70949d2b88c04e869b074597700dd22d";fileName="test.xml";process_method="fun1"} | ConvertTo-Json -Compress
$postBody = [Text.Encoding]::UTF8.GetBytes($postText)
$postUri = "http://localhost:10001/read"
Invoke-RestMethod -Method POST -Uri $postUri -Body $postBody -ContentType application/json

$postText = @{text="日本語"} | ConvertTo-Json -Compress
$postBody = [Text.Encoding]::UTF8.GetBytes($postText)
$postUri = "http://localhost:3000/api/texts"
Invoke-RestMethod -Method POST -Uri $postUri -Body $postBody -ContentType application/json
~~~
