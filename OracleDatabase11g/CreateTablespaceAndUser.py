# -----------------------インポートスクリプト作成ツール------------------------
# 
# フォルダ作成スクリプト
#   mkdir -p /u01/data/<SID>/<sub>
#   ※subはdba_data_files_SID.csv、dba_temp_files_SID.csv参照
#
# データベース作成スクリプト
#   元情報
#     dba_data_files_SID.csv
#     dba_temp_files_SID.csv
#     dbcaより作成したスクリプト
#   作成要領
#     1. dba_data_files_SID.csv,dba_temp_files_SID.csvの情報より、ファイル格納フォルダ作成
#     2. dbcaより作成したスクリプトのSID.sqlファイルを開いて以下の3行を変更
#     ------------------------------------------------------------------------
#     ACCEPT sysPassword CHAR PROMPT 'Enter new password for SYS: ' HIDE
#     ACCEPT systemPassword CHAR PROMPT 'Enter new password for SYSTEM: ' HIDE
#     host /u01/app/oracle/product/11.2.0/dbhome_1/bin/orapwd file=/u01/app/oracle/product/11.2.0/dbhome_1/dbs/orapwXXXXXX force=y
#     ------------------------------------------------------------------------
#     ↓↓↓↓↓↓↓↓↓↓編集後↓↓↓↓↓↓↓↓↓↓
#     ------------------------------------------------------------------------
#     DEFINE sysPassword=yourpassword
#     DEFINE systemPassword=yourpassword
#     host /u01/app/oracle/product/11.2.0/dbhome_1/bin/orapwd file=/u01/app/oracle/product/11.2.0/dbhome_1/dbs/orapwXXXXXX force=y password=ora
#     ------------------------------------------------------------------------
#     
# テーブルスペース作成スクリプト
#   元情報
#     dba_data_files_SID.csv
#     dba_temp_files_SID.csv 
#   作成要領
#     1.テーブルスペースの名前はTABLESPACE列参照
#     1.同一テーブルスペースに複数データファイル含む場合がある。
#       この場合、ALTERで2個目以後のファイルを追加する。
#     2.データファイルの初期サイズをMB列の値を切り上げとする。
#     3.自動拡張可否はAUTOEXTENSIBLE列に従い、サイズはINCREMENT_BY列参照する。
# 　　　(要検討:データの増加予想かデータファイルのサイズかによって調整？)
#     4.データファイルの初期サイズをMAX_MB列の値を切り上げとする。
#       なお、サイズ≧32768の場合はUNLIMITEDに変更する。
#    特記：
#     1. 9iと11GR2の作成方法が異なるため、一時ファイルはdba_temp_files_SID.csv、
#      dba_temp_files_SID.csvの「CONTENTS」が「TEMPORARY」に種類あります。
#
# ユーザ作成スクリプト
#   元情報
#     user_SID.csv
#     dba_role_privs_SID.csv
#     dba_roles_SID.csv
#     dba_sys_privs_SID.csv
#     dba_tab_privs_SID.csv
#   作成要領
#     1. dba_roles_SID.csvにユーザ作成のロール用コマンド作成
#        (自動作成ロール一覧は調査要)
#     2. dba_role_privs_SID.csv のGRANTEE列、GRANTED_ROLE列をもとに、GRANTコマンドを作成する。
#     3. user_SID.csvのDEFAULT_TABLESPACE列、TEMPORARY_TABLESPACE列をもとに、テーブルスペース設定する。
#     4. dba_sys_privs_SID.csvをもとに、システム権限を設定する。
#     5. dba_tab_privs_SID.csvをもとに、テーブルのアクセス権限個別指定する。
#     6. 既定テーブルスペースがTOOLSの場合、USERSに変更
#   特記
#     1. CONNECTロールの権限変更があるため、別途設定が必要になる。
#     2. 自動作成済みユーザは対象外にする。(ORACLE_9i_11g_DEFAULT_SCHEMAにて自動作成ユーザ定義)
#     3. 作成要領5はインポート完了後実施
#

import os
import io
import csv
import math

TEST_FLG = False
HONBAN_FLG = False

INPUT_INFO_PATH = r'info' # info_all.sqlで取得した情報を配置するフォルダ
OUTPUT_PATH = r'test' # 出力パス
IMP_LOG_DIR = r'log' # サーバでsqlを実行する時、logの出力先
TARGET_INSTANCES = ['orcl01'] # 複数指定可

# オラクル9iと11gのデフォルトスキーマ、ユーザ作成の時に処理から除外
ORACLE_9i_11g_DEFAULT_SCHEMA = [
    'SYS','SYSTEM','PUBLIC','OUTLN','DBSNMP','WMSYS','EXFSYS','CTXSYS','XDB','ORDSYS',
    'ORACLE_OCM','ORDDATA','ORDPLUGINS','OLAPSYS','MDSYS','SYSMAN','APEX_030200','APPQOSSYS',
    'FLOWS_FILES','OWBSYS_AUDIT','OWBSYS','SI_INFORMTN_SCHEMA','SI_INFORMTN_SCHEMA','OPS$ATHENE',
    'PERFSTAT'
]
# オラクル9iと11gのデフォルトロール、ユーザ作成の時に処理から除外
ORACLE_9i_11g_DEFAULT_ROLE = [
    'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','CONNECT','DBA','DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE',
    'EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','GLOBAL_AQ_USER_ROLE','HS_ADMIN_ROLE','IMP_FULL_DATABASE',
    'LOGSTDBY_ADMINISTRATOR','OEM_MONITOR','RECOVERY_CATALOG_OWNER','RESOURCE','SELECT_CATALOG_ROLE',
    'PLUSTRACE','CTXAPP','EJBCLIENT','JAVADEBUGPRIV','JAVAIDPRIV','JAVASYSPRIV','JAVA_ADMIN','JAVA_DEPLOY','WM_ADMIN_ROLE',
    'PERFSTAT','JAVAUSERPRIV'
]
# 11gのCONNECTを9iと同様な権限に付与
GRANT_CONNECT = '\nGRANT ALTER SESSION,CREATE SESSION,CREATE CLUSTER,CREATE SYNONYM,CREATE DATABASE LINK,CREATE TABLE,CREATE SEQUENCE,CREATE VIEW TO CONNECT;\n'

# -----------------CSV読み取り--------------------------------
def readCsvToDic(sid,fileName):
    path = os.path.join(INPUT_INFO_PATH,fileName)
    f = open(path,'r')
    reader_info = csv.DictReader(f)
    result = [dic for dic in reader_info]
    f.close()
    return result
# -----------------出力フォルダ作成--------------------------------
def createOutputFolder(sid):
    output_folder = os.path.join(OUTPUT_PATH,sid)
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

# -----------------DB作成スクリプト出力--------------------------------
def create_db(sid,dataFilesInfoList,tempFileInfoList):
    createOutputFolder(sid)

    output_file_name = '{0}_create_db.sh'.format(sid)
    output_text = '#!/bin/sh\n\n'
    fileNameLsit = []
    fileNameLsit.extend([info['FILE_NAME'] for info in dataFilesInfoList])
    fileNameLsit.extend([info['FILE_NAME'] for info in tempFileInfoList])
    folderNameSet = set(os.path.dirname(fileName) for fileName in fileNameLsit)
    for folderName in sorted(folderNameSet):
        output_text += 'if [ ! -d {0} ]; then mkdir -p {0}; fi\n'.format(folderName)
    output_text += '\n'
    output_text += 'export ORACLE_SID={0}\n'.format(sid)
    output_text += r'${ORACLE_BASE%/}' + '/admin/{0}/scripts/{0}.sh\n'.format(sid)
    output_text += '$ORACLE_HOME/bin/sqlplus system/ora@orcl01 @{0}_create_tablespace.sql\n'.format(sid)
    output_text += '$ORACLE_HOME/bin/sqlplus system/ora@orcl01 @{0}_create_user.sql\n'.format(sid)
    out = open(os.path.join(OUTPUT_PATH,sid,output_file_name),'w',newline="\n")
    out.write(output_text)
    out.close()
# -----------------テーブルスペース作成スクリプト出力--------------------------------
def createSql_TABLESPACE(sid,dataFileInfoList,tempFileInfoList):
    createOutputFolder(sid)
    output_file_name = '{0}_create_tablespace.sql'.format(sid)
    output_text = ''
    output_text += 'SPOOL ' + IMP_LOG_DIR + r'/${ORACLE_SID}_create_tablespace.log' + '\n'
    
    output_text += 'set echo off\n'
    output_text += 'set serveroutput on\n'
    output_text += "select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') from dual;\n"
    output_text += 'set echo on\n'

    output_text += '\n-- テーブルスペース作成\n'
    # UNDOテーブルスペース個別処理
    #   DBCAの汎用データベースのデフォルトUNDOテーブルスペースはUNDOTBS1
    #   仮に移行元のUNDOテーブルスペースの名前はUNDOTBSの場合、個別処理を行う
    output_text += 'ALTER TABLESPACE UNDOTBS1 RENAME TO UNDOTBS;\n'
    output_text += '\n'
    # データファイルファイルの数が多い場合、同時openファイル数変更が必要(デフォルトは200)
    #   判定基準:dba_data_files_<sid>.csvとdba_temp_files_SID.csvの行数和が190+
    output_text += 'ALTER SYSTEM SET DB_FILES=300 SCOPE=SPFILE;\n'
    output_text += 'shutdown immediate\n'
    output_text += 'startup\n'

    for i in range(0,len(dataFileInfoList)):
        dataFileInfo = dataFileInfoList[i]

        block_size = 8192
        init_size_str = '32G'
        max_str = '' 
        auto_extend_str = ''

        init_size = math.ceil(float(dataFileInfo['MB'])) # 初期サイズ
        auto_extend_size = math.ceil(int(dataFileInfo['INCREMENT_BY'])) # 自動拡張サイズ
        max_size = math.ceil(float(dataFileInfo['MAX_MB'])) if math.ceil(float(dataFileInfo['MAX_MB'])) > init_size else init_size # 最大サイズ

        if init_size < 32 * 1024:
            init_size_str = str(init_size) + 'M'
        if dataFileInfo['AUTOEXTENSIBLE'] == 'YES':
            auto_extend_size_str = str(auto_extend_size * block_size)
            auto_extend_str = ' AUTOEXTEND ON NEXT ' + auto_extend_size_str
        else:
            auto_extend_str = ' AUTOEXTEND OFF'
        
        # サイズが32GB以上の場合はUNLIMITED
        if max_size == 0 or dataFileInfo['AUTOEXTENSIBLE'] == 'NO':
            max_str = ''
        elif max_size < 32 * 1024:
            max_size_str = str(max_size) + 'M'
            max_str = ' MAXSIZE ' + max_size_str
        else:
            max_str = ' MAXSIZE UNLIMITED'
        
        # 9iの「TEMPORARY」のデータファイルは11gで一時ファイルとして作成必要
        if dataFileInfo['CONTENTS'] == 'TEMPORARY':
            tempFileInfoList.append(dataFileInfo)
            continue

        # 複数データファイル構成のテーブルスペース対応
        if i - 1 < 0 or dataFileInfo['TABLESPACE'] != dataFileInfoList[i - 1]['TABLESPACE']:
            # DBCAで作成したテーブルスペースは対象外とする
            #   ※dbcaの汎用データベーステンプレートのデフォルトテーブルスペース:SYSTEM,SYSAUX,USERS,TEMP,UNDOTBS1
            # 9iのTOOLSテーブルスペースはなくなる。代わりにUSERSを使用する。
            # IF文の中に実行する理由はDBCAで作成したテーブルスペースにデータファイルを追加する処理を対応
            #   ※例:
            #      CREATE TABLESPACE UNDOTBS DATAFILE ・・・ は生成されないが、
            #      ALTER TABLESPACE UNDOTBS ADD DATAFILE ・・・ が生成される
            if dataFileInfo['TABLESPACE'] in ['SYSTEM','TOOLS','UNDOTBS']:
                continue
            output_text += "CREATE TABLESPACE {0} DATAFILE '{1}' SIZE {2}{3}{4};\n".format(
                dataFileInfo['TABLESPACE'],
                dataFileInfo['FILE_NAME'],
                init_size_str,
                auto_extend_str,
                max_str
            )
        else:
            output_text += "ALTER TABLESPACE {0} ADD DATAFILE '{1}'  SIZE {2}{3}{4};\n".format(
                dataFileInfo['TABLESPACE'],
                dataFileInfo['FILE_NAME'],
                init_size_str,
                auto_extend_str,
                max_str
            )
    output_text += '\n-- 一時テーブルスペース作成\n'

    # CDBC11の一時テーブルスペースのファイル名がデフォルトと重複のため、名前変更
    if sid == 'CDBC11' :
        output_text += 'ALTER TABLESPACE TEMP RENAME TO CSPCDMCTEMP;\n'
    
    for i in range(0,len(tempFileInfoList)):    
        tempFileInfo = tempFileInfoList[i]

        block_size = 8192
        init_size_str = '32G'
        max_str = '' 
        auto_extend_str = ''

        init_size = math.ceil(float(tempFileInfo['MB'])) # 初期サイズ
        auto_extend_size = math.ceil(int(tempFileInfo['INCREMENT_BY'])) # 自動拡張サイズ
        max_size = math.ceil(float(tempFileInfo['MAX_MB'])) if math.ceil(float(tempFileInfo['MAX_MB'])) > init_size else init_size # 最大サイズ

        if init_size < 32 * 1024:
            init_size_str = str(init_size) + 'M'
        if tempFileInfo['AUTOEXTENSIBLE'] == 'YES':
            auto_extend_size_str = str(auto_extend_size * block_size)
            auto_extend_str = ' AUTOEXTEND ON NEXT ' + auto_extend_size_str
        else:
            auto_extend_str = ' AUTOEXTEND OFF'
        
        # サイズが32GB以上の場合はUNLIMITEDに変換
        if max_size == 0 or tempFileInfo['AUTOEXTENSIBLE'] == 'NO':
            max_str = ''
        elif max_size < 32 * 1024:
            max_size_str = str(max_size) + 'M'
            max_str = ' MAXSIZE ' + max_size_str
        else:
            max_str = ' MAXSIZE UNLIMITED'

        if i - 1 < 0 or tempFileInfo['TABLESPACE'] != tempFileInfoList[i - 1]['TABLESPACE']:
            if tempFileInfo['TABLESPACE'] in ['TEMP']:
                continue
            if sid == 'CDBC11' and tempFileInfo['TABLESPACE'] in ['CSPCDMCTEMP']:
                continue
            output_text += "CREATE TEMPORARY TABLESPACE {0} TEMPFILE '{1}' SIZE {2}{3}{4};\n".format(
                tempFileInfo['TABLESPACE'],
                tempFileInfo['FILE_NAME'],
                init_size_str,
                auto_extend_str,
                max_str
            )
        else:
            output_text += "ALTER TABLESPACE {0} ADD TEMPFILE '{1}'  SIZE {2}{3}{4};\n".format(
                tempFileInfo['TABLESPACE'],
                tempFileInfo['FILE_NAME'],
                init_size_str,
                auto_extend_str,
                max_str
            )
    output_text += 'set echo off\n'
    output_text += "select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') from dual;\n"
    output_text += '\nspool off\n'
    output_text += 'exit'
    out = open(os.path.join(OUTPUT_PATH,sid,output_file_name),'w')
    out.write(output_text)
    out.close()
    return
# -----------------ユーザ作成スクリプト出力--------------------------------
def createSql_USER(sid,userList,privsList,roleList,sysPrivList):
    createOutputFolder(sid)
    output_file_name = '{0}_create_user.sql'.format(sid)
    output_text = '' 
    output_text += 'SPOOL ' + IMP_LOG_DIR + r'/${ORACLE_SID}_create_user.log' + '\n'

    output_text += 'set echo off\n'
    output_text += 'set serveroutput on\n'
    output_text += "select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') from dual;\n"
    output_text += 'set echo on\n'

    output_text += '\n-- CONNECT ロール権限付与\n'
    output_text += GRANT_CONNECT
    
    # 本番DBのユーザがカスタマイズロールを使用した場合、ロールを作成
    targetRoles = [role for role in roleList if role['ROLE'] not in ORACLE_9i_11g_DEFAULT_ROLE]
    if len(targetRoles) > 0:
        output_text += '\n-- ロール作成\n'
        for role in targetRoles:
            output_text += 'CREATE ROLE {0};\n'.format(role['ROLE'])
            for priv in privsList:
                if priv['GRANTEE'] == role['ROLE']:
                    output_text += 'GRANT {0} TO {1}{2};\n'.format(
                        priv['GRANTED_ROLE'],
                        role['ROLE'],
                        ' WITH ADMIN OPTION' if priv['ADMIN_OPTION'] == 'YES' else ''
                        )
            for priv in sysPrivList:
                if priv['GRANTEE'] == role['ROLE']:
                    output_text += 'GRANT {0} TO {1}{2};\n'.format(
                        priv['PRIVILEGE'],
                        role['ROLE'],
                        ' WITH ADMIN OPTION' if priv['ADMIN_OPTION'] == 'YES' else ''
                        )

    output_text += '\n-- ユーザ作成\n'
    for user in userList:
        if user['USERNAME'] in ORACLE_9i_11g_DEFAULT_SCHEMA:
            continue

        if user['TEMPORARY_TABLESPACE'] == 'SYSTEM':
            output_text += 'CREATE USER {0} IDENTIFIED BY {1} DEFAULT TABLESPACE {2} TEMPORARY TABLESPACE {3};\n'.format(
                user['USERNAME'],
                user['USERNAME'],
                user['DEFAULT_TABLESPACE'],
                'TEMP'
            )
        elif user['DEFAULT_TABLESPACE'] == 'TOOLS':
            output_text += 'CREATE USER {0} IDENTIFIED BY {1} DEFAULT TABLESPACE {2} TEMPORARY TABLESPACE {3};\n'.format(
                user['USERNAME'],
                user['USERNAME'],
                'USERS',
                user['TEMPORARY_TABLESPACE']
            )
        else:
            output_text += 'CREATE USER {0} IDENTIFIED BY {1} DEFAULT TABLESPACE {2} TEMPORARY TABLESPACE {3};\n'.format(
                user['USERNAME'],
                user['USERNAME'],
                user['DEFAULT_TABLESPACE'],
                user['TEMPORARY_TABLESPACE']
            )

    output_text += '\n-- ロール付与\n'
    for privs in privsList:
        option = '' if privs['ADMIN_OPTION'] == 'NO' else ' WITH ADMIN OPTION'
        if privs['GRANTEE'] in ORACLE_9i_11g_DEFAULT_ROLE:
            continue
        elif privs['GRANTEE'] in ORACLE_9i_11g_DEFAULT_SCHEMA:
            continue
        else:
            output_text += 'GRANT {0} TO {1}{2};\n'.format(
                privs['GRANTED_ROLE'],
                privs['GRANTEE'],
                option,
                privs['GRANTEE'])

    output_text += '\n-- システム権限付与\n'
    for privs in sysPrivList:
        if privs['GRANTEE'] in ORACLE_9i_11g_DEFAULT_ROLE:
            continue
        elif privs['GRANTEE'] in ORACLE_9i_11g_DEFAULT_SCHEMA:
            continue
        else:
            output_text += 'GRANT {0} TO {1};\n'.format(
                privs['PRIVILEGE'],
                privs['GRANTEE'])

    output_text += 'set echo off\n'
    output_text += "select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') from dual;\n"

    output_text += '\nspool off\n'
    output_text += 'exit'

    out = open(os.path.join(OUTPUT_PATH,sid,output_file_name),'w')
    out.write(output_text)
    out.close()
    return

# ------------------一括実施-------------------------------
def run():
    for sid in TARGET_INSTANCES:
        dataFilesInfoList = readCsvToDic(sid,'dba_data_files_{0}.csv'.format(sid))
        tempFileInfoList = readCsvToDic(sid,'dba_temp_files_{0}.csv'.format(sid))
        roleInfoList = readCsvToDic(sid,'dba_role_privs_{0}.csv'.format(sid))
        rolesList = readCsvToDic(sid,'dba_roles_{0}.csv'.format(sid))
        userList = readCsvToDic(sid,'user_{0}.csv'.format(sid))
        sysPrivList = readCsvToDic(sid,'dba_sys_privs_{0}.csv'.format(sid))
        
        create_db(sid,dataFilesInfoList,tempFileInfoList)
        createSql_TABLESPACE(sid,dataFilesInfoList,tempFileInfoList)
        createSql_USER(sid,userList,roleInfoList,rolesList,sysPrivList)
run()



