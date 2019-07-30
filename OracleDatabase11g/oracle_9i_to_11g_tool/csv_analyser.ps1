# ソフトウェアインストール制限がある現場が多いため、PowerShellが理想
$ORACLE_9i_11g_DEFAULT_SCHEMA = @(
    'SYS','SYSTEM','PUBLIC','OUTLN','DBSNMP','WMSYS','EXFSYS','CTXSYS','XDB','ORDSYS',
    'ORACLE_OCM','ORDDATA','ORDPLUGINS','OLAPSYS','MDSYS','SYSMAN','APEX_030200','APPQOSSYS',
    'FLOWS_FILES','OWBSYS_AUDIT','OWBSYS','SI_INFORMTN_SCHEMA','SI_INFORMTN_SCHEMA','OPS$ATHENE',
    'PERFSTAT'
);
$ORACLE_9i_11g_DEFAULT_ROLE = @(
    'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','CONNECT','DBA','DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE',
    'EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','GLOBAL_AQ_USER_ROLE','HS_ADMIN_ROLE','IMP_FULL_DATABASE',
    'LOGSTDBY_ADMINISTRATOR','OEM_MONITOR','RECOVERY_CATALOG_OWNER','RESOURCE','SELECT_CATALOG_ROLE',
    'PLUSTRACE','CTXAPP','EJBCLIENT','JAVADEBUGPRIV','JAVAIDPRIV','JAVASYSPRIV','JAVA_ADMIN','JAVA_DEPLOY','WM_ADMIN_ROLE',
    'PERFSTAT'
)
$ORACLE_9i_CONNECT_ROLE_TO_11g_PRIV = 'ALTER SESSION,CREATE SESSION,CREATE CLUSTER,CREATE SYNONYM,CREATE DATABASE LINK,CREATE TABLE,CREATE SEQUENCE,CREATE VIEW'

$csv_objects_9i = ""
$csv_objects_11g = ""

# -------------機能試験場START--------------------

# -------------機能試験場END  --------------------

# 関数定義
function GetDiffrentObjects {
    param (
        [string]$path_csv_objects_9i,
        [string]$path_csv_objects_11g
    )
    $target1 = Import-Csv $path_csv_objects_9i -Encoding Default | Where-Object { ($_.OWNER -notin $ORACLE_9i_11g_DEFAULT_SCHEMA) } | Select-Object -Property OWNER,OBJECT_NAME,SUB_OBJECT_NAME,OBJECT_TYPE
    $target2 = Import-Csv $path_csv_objects_11g -Encoding Default | Where-Object { ($_.OWNER -notin $ORACLE_9i_11g_DEFAULT_SCHEMA) } | Select-Object -Property OWNER,OBJECT_NAME,SUB_OBJECT_NAME,OBJECT_TYPE
    $result = Compare-Object -ReferenceObject $target1 -DifferenceObject $target2 -Property OWNER,OBJECT_NAME,OBJECT_TYPE | Where-Object { $_.SideIndicator -eq "<=" }
    return $result | Select-Object -Property OWNER,OBJECT_TYPE,OBJECT_NAME,SUB_OBJECT_NAME
}

function GetInvalidObjects {
    param (
        [string]$path_csv_objects_11g
    )
    $data = Import-Csv $path_csv_objects_11g -Encoding Default | Where-Object { ($_.OWNER -notin $ORACLE_9i_11g_DEFAULT_SCHEMA[$sid]) -and ($.STATUS -eq "INVALID") } | Select-Object -Property OWNER,OBJECT_NAME,SUB_OBJECT_NAME,OBJECT_TYPE
    return $data
}

function GenerateDdl4Objecdts {
    param (
        $objects
    )
    # "select dbms_metadata.get_ddl('{0}','{1}','{2}') from dual;" -f "OBJECT_TYPE","OBJECT_NAME","OWNER"
    $result = @();
    $result += "set pages 0 lines 10000 echo off  heading off trimout on trimspool on feed off long 99999999 longchunksize 20124"
    $objects | ForEach-Object {
        $result += "spool {0}.{1}.sql" -f $_.OWNER,$_.OBJECT_NAME
        if ($_.OBJECT_TYPE -eq "MATERIALIZED VIEW") {
            $result += "select dbms_metadata.get_ddl('{0}','{1}','{2}') from dual;" -f "MATERIALIZED_VIEW",$_.OBJECT_NAME,$_.OWNER
        }
        elseif ($_.OBJECT_TYPE -eq "PACKAGE BODY") {
            $result += "select dbms_metadata.get_ddl('{0}','{1}','{2}') from dual;" -f "PACKAGE_BODY",$_.OBJECT_NAME,$_.OWNER
        }
        elseif ($_.OBJECT_TYPE -eq "DATABASE LINK") {
            $result += "select dbms_metadata.get_ddl('{0}','{1}','{2}') from dual;" -f "DB_LINK",$_.OBJECT_NAME,$_.OWNER
        }
        else {
            $result += "select dbms_metadata.get_ddl('{0}','{1}','{2}') from dual;" -f $_.OBJECT_TYPE,$_.OBJECT_NAME,$_.OWNER
        }
        $result += "spool off"
    }
    return $result
}

function GenerateCreateSql4Objecdts {
    param (
        $objects
    )
    $objects | ForEach-Object {
        $result += "@" + $_.OWNER + "." + $_.OBJECT_NAME + ".sql`n"
    }
    return $result
}

# 例1:
# GetDiffrentObjects -path_csv_objects_9i C:\Users\linxu\Desktop\work\作業\20190425本番機info\整理後\info\objects_CDBF01.csv -path_csv_objects_11g C:\Users\linxu\Desktop\imp_2\info7\objects_CDBF01.csv
# GenerateDdl4Objecdts -objects @(@{"OWNER"="test";"OBJECT_NAME"="test_obj";"OBJECT_TYPE"="TABLE"})

# 例2:
# . .\csv_analyser.ps1
# $objs = GetDiffrentObjects -path_csv_objects_9i C:\Users\linxu\Desktop\work\作業\20190425本番機info\整理後\info\objects_CDBF01.csv -path_csv_objects_11g C:\Users\linxu\Desktop\imp_2\info7\objects_CDBF01.csv
# GenerateDdl4Objecdts -objects $objs | Out-File get_ddl.sql -Encoding default
# GenerateCreateSql4Objecdts -objects $objs | Out-File create_objects.sql -Encoding default

