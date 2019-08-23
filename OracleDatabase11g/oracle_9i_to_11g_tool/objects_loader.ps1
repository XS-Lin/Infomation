function LoadCsv_objects {
    param (
        [string]$csvFile,
        [string]$Encoding = [System.Text.Encoding]::Default.HeaderName,
        [string]$db_user,
        [string]$db_pass,
        [string]$db_tnsname,
        [string]$tb_owner,
        [string]$tb_name,
        [string]$temp_dir="."
    )

    if (-not (Test-Path -Path $csvFile -PathType Leaf)) {
        Write-Host "入力ファイルは存在しません。$csvFile"
        return 0
    }

    if (-not (Test-Path -Path $temp_dir -PathType Container)) {
        Write-Host "指定の一時フォルダは存在しません。$temp_dir" 
        return 0
    }
    
    Add-Type -AssemblyName System.Data.OracleClient
    $column_names = "OWNER,OBJECT_NAME,SUBOBJECT_NAME,OBJECT_ID,DATA_OBJECT_ID,OBJECT_TYPE,CREATED,LAST_DDL_TIME,TIMESTAMP,STATUS,TEMPORARY,GENERATED"
    $ConnectionString = "Data Source="+$db_tnsname+";User ID="+$db_user+";Password="+$db_pass+";Integrated Security=false;"
    #Write-Host $ConnectionString
    $OraCon = New-Object System.Data.OracleClient.OracleConnection($ConnectionString)
    $sql_get_user = "select count(*) from dba_users where username='" + $tb_owner + "'"
    $data = New-Object System.Data.OracleClient.OracleDataAdapter($sql_get_user, $OraCon)
    $dtSet = New-Object System.Data.DataSet
    [void]$data.Fill($dtSet)

    $connStr = $db_user+"/"+$db_pass+"@"+$db_tnsname
    $tempFileName =Join-Path $temp_dir "create_$tb_owner.sql"
    if (($dtSet.Tables.Count -eq 1) -and ($dtSet.Tables[0].Rows[0][0] -eq 0)) {
        # create user u1 identified by u1 default tablespace USERS temporary tablespace TEMP;
        # create table ...
        if ( -not (Test-Path -Path $tempFileName -PathType Leaf)) {
            $sql = "create user " + $tb_owner + " identified by " + $tb_owner + " default tablespace USERS temporary tablespace TEMP;`r`n"
            $sql += "grant create session,unlimited tablespace to " + $tb_owner + ";`r`n"
            $sql += "create table " + $tb_owner +"." + $tb_name + " as select " + $column_names + " from dba_objects where 1=2;`r`n"
            $sql += "alter table " + $tb_owner +"." + $tb_name + " modify ( CREATED VARCHAR2(20), LAST_DDL_TIME VARCHAR2(20));`r`n"
            $sql += "exit`r`n"
            $sql | Out-File $tempFileName -Encoding default
        }
        $sqlFile = "@"+$tempFileName
        sqlplus.exe $connStr $sqlFile
    }

    $tempCrtlFileName =Join-Path $temp_dir "load_$($tb_owner)_$($tb_name).ctl"
    if ( -not (Test-Path -Path $tempCrtlFileName -PathType Leaf)) {
        $text = "OPTIONS(SKIP=1)`r`n"
        $text += "LOAD DATA`r`n"
        $text += "INFILE '" + $csvFile + "'`r`n"
        $text += "INTO TABLE $tb_owner.objects`r`n"
        $text += "TRUNCATE`r`n"
        $text += "FIELDS TERMINATED BY ','`r`n"
        $text += "($column_names)"
        $text | Out-File $tempCrtlFileName -Encoding default
    }
    sqlldr.exe $connStr $tempCrtlFileName
}
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC01_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBC01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC11_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBC11.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC21_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBC21.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC31_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBC31.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC41_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBC41.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBE01_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBE01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBE11_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBE11.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBF01_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBF01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBF02_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBF02.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBH01_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBH01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBW01_N -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\export\info_sjis\objects_CDBW01.csv

# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC01_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBC01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC11_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBC11.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC21_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBC21.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC31_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBC31.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBC41_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBC41.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBE01_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBE01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBE11_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBE11.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBF01_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBF01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBF02_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBF02.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBH01_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBH01.csv
# LoadCsv_objects -db_user system -db_pass ora -db_tnsname 192.168.56.102:1521/orcl01 -tb_owner CDBW01_N1 -tb_name OBJECTS -csvFile C:\Users\linxu\Desktop\work\作業\database_scripts\import\info1\objects_CDBW01.csv