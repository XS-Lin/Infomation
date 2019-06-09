# 逆引きリファレンス #

仕事でよくある様々なタスクに、各プログラミング言語での実装例

## Oracle Database ##

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

* C#

~~~csharp

~~~

* Java

~~~java

~~~

* Bash

~~~bash
# オラクルの場合、sqlplus
~~~

## Encoding ##

* Python

~~~python
import openpyxl

~~~

* PowerShell

~~~powershell

~~~

~~~csharp

~~~

~~~java

~~~

~~~bash

~~~

## XML ##

~~~python

~~~

* PowerShell

~~~powershell

~~~

~~~csharp

~~~

~~~java

~~~

~~~bash
# xmllint
~~~

## CSV ##

* Python

~~~python
import csv
# Read
path = os.path.join(INPUT_INFO_PATH,fileName)
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

~~~

~~~csharp

~~~

~~~java

~~~

## Excel ##

* Python

~~~python
import openpyxl

~~~

* PowerShell

~~~powershell

~~~

~~~csharp

~~~

~~~java

~~~

~~~bash
# 実務に見たことがない
~~~

## Selenium ##

* Python

~~~python
import openpyxl

~~~

* PowerShell

~~~powershell

~~~

~~~csharp

~~~

~~~java

~~~

~~~bash

~~~
