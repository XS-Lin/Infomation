REM //////////////////////////////////////////////////////////////////////
REM  File Name : info_all.sql
REM  Explain   : Gather Oracle Database Property Informations.
REM              Execution check on Oracle Database 11gR1 / 11gR2
REM //////////////////////////////////////////////////////////////////////

REM //////////////   DIRECTORY  PARAMETER SET  ///////////////////////////
DEFINE  infodir='&1'
DEFINE  sid='&2'
REM //////////////////////////////////////////////////////////////////////

REM  Start Current Session ID check
SET TERMOUT ON  LINESIZE 300 TRIMSPOOL ON

COLUMN program  FORMAT A30
COLUMN terminal FORMAT A10
COLUMN machine  FORMAT A25
COLUMN osuser   FORMAT A12
COLUMN logon    FORMAT A18

SPOOL '&infodir/0000_Current_session_&sid..log'
SELECT
    sid
   ,serial#
   ,program
   ,terminal
   ,machine
   ,osuser
   ,TO_CHAR(logon_time,'YY/MM/DD HH24:MI:SS') logon
FROM
    v$session
WHERE
    sid = (SELECT DISTINCT(sid) FROM v$mystat);

COLUMN "Stop Command" FORMAT A60
SELECT 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||''' IMMEDIATE;' "Stop Command" FROM v$session WHERE sid = (SELECT DISTINCT(sid) FROM v$mystat);

SPOOL OFF

REM  pause   Please Check SID and SERIAL#. Press EnterKey Start script.
REM  End Current Session ID check

SET HEAD OFF
SPOOL '&infodir/0000_Current_session_&sid..log' append
SELECT 'Start Date: '|| TO_CHAR(SYSDATE,'yyyy-mm-dd hh24:mi:ss') FROM dual;
SPOOL OFF
SET HEAD ON

SET TERM OFF  TIMING OFF  TIME OFF  NUMWIDTH 20

SPOOL '&infodir/info_all_&sid..log'

SET TRIMSPOOL ON  TRIMOUT ON  LINESIZE 10000  FEED OFF LONG 1000000000  HEAD ON  ECHO OFF  PAGESIZE 10000  SERVEROUTPUT OFF

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

SELECT TO_CHAR(SYSDATE,'YYYY/MM/DD HH:MI:SS') FROM DUAL;

SELECT * FROM V$VERSION;

column comp_name for a40
column version for a10
column status for a10
SELECT COMP_NAME,VERSION,STATUS FROM DBA_REGISTRY
/

column parameter for a40
column value for a10
SELECT * FROM V$OPTION ORDER BY PARAMETER
/

SELECT * FROM GV$INSTANCE
/

select log_mode from gv$database
/

SELECT PARAMETER,VALUE
FROM NLS_DATABASE_PARAMETERS
WHERE PARAMETER = 'NLS_CHARACTERSET'
OR PARAMETER = 'NLS_NCHAR_CHARACTERSET'
/

PROMPT 
PROMPT 
PROMPT MAXINSTANCES(REDO THREAD),MAXLOGFILES(REDO LOG),MAXDATAFILES(DATAFILE),MAXLOGHISTORY(LOG HISTORY)
select type, records_total
from v$controlfile_record_section
where type in ('REDO LOG', 'DATAFILE','REDO THREAD','LOG HISTORY');

PROMPT 
PROMPT 
select dimlm as MAXLOGMEMBERS from x$kccdi;

SET  HEAD OFF

SPOOL OFF

REM   #################################################################
REM   INSTANCE INFOMATION
REM   #################################################################

SPOOL '&infodir/instance_&sid..csv'

PROMPT INST_ID,INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,VERSION,STARTUP_TIME,STATUS,PARALLEL,THREAD#,ARCHIVER,LOG_SWITCH_WAIT,LOGINS,SHUTDOWN_PENDING,DATABASE_STATUS,INSTANCE_ROLE,ACTIVE_STATE,BLOCKED

SELECT
        inst_id                    ||','||
        instance_number            ||','||
        instance_name              ||','||
        host_name                  ||','||
        version                    ||','||
        startup_time               ||','||
        status                     ||','||
        parallel                   ||','||
        thread#                    ||','||
        archiver                   ||','||
        log_switch_wait            ||','||
        logins                     ||','||
        shutdown_pending           ||','||
        database_status            ||','||
        instance_role              ||','||
        active_state               ||','||
        blocked
FROM
        gv$instance
/

SPOOL OFF

REM   #################################################################
REM   DATAFILE INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_data_files_&sid..csv'

PROMPT FILE_ID,TABLESPACE,FILE_NAME,MB,STATUS,AUTOEXTENSIBLE,INCREMENT_BY,MAX_MB,EXTENT_MANAGEMENT,CONTENTS,SEGMENT_SPACE_MANAGEMENT,INITIAL_EXTENT,NEXT_EXTENT,PCT_INCREASE,MIN_EXTENTS,MAX_EXTENTS,ALLOCATION_TYPE

SELECT
        f.FILE_ID                  ||','||
        f.TABLESPACE_NAME          ||','||
        f.FILE_NAME                ||','||
        f.BYTES/1024/1024          ||','||
        f.STATUS                   ||','||
        f.AUTOEXTENSIBLE           ||','||
        f.INCREMENT_BY             ||','||
        f.MAXBYTES/1024/1024       ||','||
        t.EXTENT_MANAGEMENT        ||','||
        t.CONTENTS                 ||','||
        t.SEGMENT_SPACE_MANAGEMENT ||','||
        t.INITIAL_EXTENT           ||','||
        t.NEXT_EXTENT              ||','||
        t.PCT_INCREASE             ||','||
        t.MIN_EXTENTS              ||','||
        t.MAX_EXTENTS              ||','||
        t.ALLOCATION_TYPE
FROM
        DBA_DATA_FILES f,
        DBA_TABLESPACES t
WHERE
	f.TABLESPACE_NAME=t.TABLESPACE_NAME
ORDER BY f.TABLESPACE_NAME,f.FILE_NAME,f.BYTES
/

SPOOL OFF

REM   #################################################################
REM   TEMPFILE INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_temp_files_&sid..csv'

PROMPT FILE_ID,TABLESPACE,FILE_NAME,MB,STATUS,AUTOEXTENSIBLE,INCREMENT_BY,MAX_MB,EXTENT_MANAGEMENT,CONTENTS,SEGMENT_SPACE_MANAGEMENT,INITIAL_EXTENT,NEXT_EXTENT,PCT_INCREASE,MIN_EXTENTS,MAX_EXTENTS,ALLOCATION_TYPE

SELECT
        f.FILE_ID                  ||','||
        f.TABLESPACE_NAME          ||','||
        f.FILE_NAME                ||','||
        f.BYTES/1024/1024          ||','||
        f.STATUS                   ||','||
        f.AUTOEXTENSIBLE           ||','||
        f.INCREMENT_BY             ||','||
        f.MAXBYTES/1024/1024       ||','||
        t.EXTENT_MANAGEMENT        ||','||
        t.CONTENTS                 ||','||
        t.SEGMENT_SPACE_MANAGEMENT ||','||
        t.INITIAL_EXTENT           ||','||
        t.NEXT_EXTENT              ||','||
        t.PCT_INCREASE             ||','||
        t.MIN_EXTENTS              ||','||
        t.MAX_EXTENTS              ||','||
        t.ALLOCATION_TYPE
FROM
        DBA_TEMP_FILES f,
        DBA_TABLESPACES t
WHERE
	f.TABLESPACE_NAME=t.TABLESPACE_NAME
ORDER BY f.TABLESPACE_NAME,f.FILE_NAME,f.BYTES
/

SPOOL OFF

REM   #################################################################
REM   TABLESPACE QUOTAS INFORMATION
REM   #################################################################

SPOOL '&infodir/dba_ts_quotas_&sid..csv'

PROMPT TABLESPACE_NAME,USERNAME,BYTES,MB,MAX_BYTES,BLOCKS,MAX_BLOCKS,DROPPED

SELECT
        TABLESPACE_NAME         ||','||
        USERNAME                ||','||
        BYTES                   ||','||
        BYTES/1024/1024         ||','||
        MAX_BYTES               ||','||
        BLOCKS                  ||','||
        MAX_BLOCKS              ||','||
        DROPPED
FROM
        dba_ts_quotas
ORDER BY TABLESPACE_NAME
/
SPOOL OFF


REM   #################################################################
REM   REDO LOG FILE INFOMATION
REM   #################################################################

SPOOL '&infodir/redo_log_&sid..csv'

PROMPT GROUP#,MEMBER,MB,THREAD#,SEQUENCE#,MEMBERS,ARCHIVED,STATUS,STATUS,FIRST_CHANGE#,FIRST_TIME

SELECT
        V$LOG.GROUP#            ||','||
        V$LOGFILE.MEMBER        ||','||
        V$LOG.BYTES/1024/1024   ||','||
        V$LOG.THREAD#           ||','||
        V$LOG.SEQUENCE#         ||','||
        V$LOG.MEMBERS           ||','||
        V$LOG.ARCHIVED          ||','||
        V$LOG.STATUS            ||','||
        V$LOGFILE.STATUS        ||','||
        V$LOG.FIRST_CHANGE#     ||','||
        V$LOG.FIRST_TIME
FROM    
		V$LOG,
		V$LOGFILE
WHERE   
		V$LOG.GROUP# = V$LOGFILE.GROUP#
ORDER BY V$LOG.GROUP#,V$LOGFILE.MEMBER
/

SPOOL OFF

SPOOL '&infodir/redo_log_history_&sid..csv'

PROMPT SEQUENCE#,FIRST_TIME

SELECT
		SEQUENCE#		||','||
		FIRST_TIME				
FROM
		V$LOG_HISTORY
ORDER BY SEQUENCE#
/

SPOOL OFF

REM   #################################################################
REM   CONTROLFILE INFOMATION
REM   #################################################################

SPOOL '&infodir/controlfile_&sid..csv'

PROMPT STATUS,NAME

SELECT
         STATUS               ||' , '||
         NAME
FROM
         V$CONTROLFILE
ORDER BY NAME
/

SPOOL OFF

REM   #################################################################
REM   ROLLBACK SEGMENT INFOMATION
REM   #################################################################

SPOOL '&infodir/online_rbs_&sid..csv'

PROMPT USN,SEGMENT_NAME,STATUS,FILE_ID,TABLESPACE,EXTENTS,OPTSIZE,INITIAL_EXT,NEXT_EXT,PCT_INC,MIN_EXT,MAX_EXT

SELECT
        S.USN                ||','||
        D.SEGMENT_NAME       ||','||
        S.STATUS             ||','||
        D.FILE_ID            ||','||
        D.TABLESPACE_NAME    ||','||
        S.EXTENTS            ||','||
        S.OPTSIZE            ||','||
        D.INITIAL_EXTENT     ||','||
        D.NEXT_EXTENT        ||','||
        D.PCT_INCREASE       ||','||
        D.MIN_EXTENTS        ||','||
        D.MAX_EXTENTS
FROM
        DBA_ROLLBACK_SEGS D,
        V$ROLLNAME N,
        V$ROLLSTAT S
WHERE
        D.SEGMENT_NAME=N.NAME
AND
        N.USN = S.USN
ORDER BY S.USN
/

SPOOL OFF

SPOOL '&infodir/rbs_&sid..csv'

PROMPT SEGMENT_NAME,FILE_ID,TABLESPACE_NAME,INITIAL_EXTENT,NEXT_EXTENT,PCT_INCREASE,MIN_EXTENTS,MAX_EXTENTS,STATUS

SELECT
        SEGMENT_NAME       ||','||
        FILE_ID            ||','||
        TABLESPACE_NAME    ||','||
        INITIAL_EXTENT     ||','||
        NEXT_EXTENT        ||','||
        PCT_INCREASE       ||','||
        MIN_EXTENTS        ||','||
        MAX_EXTENTS        ||','||
        STATUS
FROM
        DBA_ROLLBACK_SEGS
ORDER BY SEGMENT_NAME
/

SPOOL OFF

REM   #################################################################
REM   TABLE INFOMATION
REM   #################################################################
SPOOL '&infodir/table_&sid..csv'

PROMPT OWNER,TABLE_NAME,TABLESPACE,LAST_ANALYZED,PCT_FREE,PCT_USED,INITIAL_EXT,NEXT_EXT,PCT_INC,MIN_EXT,MAX_EXT,NUM_ROWS,BLOCKS,EMPTY_BLOCKS,AVG_SPACE,CHAIN_CNT,AVG_ROW_LEN,LAST_ANALYZED,COMPRESSION,COMPRESS_FOR
SELECT
        OWNER               ||','||
        TABLE_NAME          ||','||
        TABLESPACE_NAME     ||','||
        LAST_ANALYZED       ||','||
        PCT_FREE            ||','||
        PCT_USED            ||','||
        INITIAL_EXTENT      ||','||
        NEXT_EXTENT         ||','||
        PCT_INCREASE        ||','||
        MIN_EXTENTS         ||','||
        MAX_EXTENTS         ||','||
        NUM_ROWS            ||','||
        BLOCKS              ||','||
        EMPTY_BLOCKS        ||','||
        AVG_SPACE           ||','||
        CHAIN_CNT           ||','||
        AVG_ROW_LEN         ||','||
        LAST_ANALYZED       ||','||
        COMPRESSION         
FROM
        DBA_TABLES
WHERE
        OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY OWNER,TABLE_NAME
/

SPOOL OFF

REM   #################################################################
REM   LOB INFOMATION
REM   #################################################################

SPOOL '&infodir/lob_&sid..csv'

PROMPT OWNER,TABLE_NAME,SECUREFILE,COMPRESSION

SELECT
*
FROM
        DBA_LOBS
WHERE
        OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY 1
/

SPOOL OFF

SPOOL '&infodir/part_table_&sid..csv'

PROMPT OWNER,TABLE_NAME,COLUMN_NAME,PARTITIONING_TYPE,SUBPARTITIONING_TYPE,PARTITION_COUNT,DEF_TABLESPACE_NAME,DEF_PCT_FREE,DEF_PCT_USED,DEF_INI_TRANS,DEF_MAX_TRANS,DEF_INITIAL_EXTENT,DEF_NEXT_EXTENT,DEF_MIN_EXTENTS,DEF_MAX_EXTENTS,DEF_PCT_INCREASE,DEF_FREELISTS,DEF_FREELIST_GROUPS

SELECT
        T.OWNER                 ||','||
        T.TABLE_NAME            ||','||
        K.COLUMN_NAME           ||','||
        T.PARTITIONING_TYPE     ||','||
        T.SUBPARTITIONING_TYPE  ||','||
        T.PARTITION_COUNT       ||','||
        T.DEF_TABLESPACE_NAME   ||','||
        T.DEF_PCT_FREE          ||','||
        T.DEF_PCT_USED          ||','||
        T.DEF_INI_TRANS         ||','||
        T.DEF_MAX_TRANS         ||','||
        T.DEF_INITIAL_EXTENT    ||','||
        T.DEF_NEXT_EXTENT       ||','||
        T.DEF_MIN_EXTENTS       ||','||
        T.DEF_MAX_EXTENTS       ||','||
        T.DEF_PCT_INCREASE      ||','||
        T.DEF_FREELISTS         ||','||
        T.DEF_FREELIST_GROUPS
FROM
        DBA_PART_TABLES T,
        DBA_PART_KEY_COLUMNS K
WHERE
        T.OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND
        T.TABLE_NAME=K.NAME
ORDER BY T.OWNER,T.TABLE_NAME
/

SPOOL OFF

SPOOL '&infodir/dba_tab_partitions_&sid..csv'

PROMPT  TABLE_OWNER,TABLE_NAME,COMPOSITE,PARTITION_NAME,SUBPARTITION_COUNT,HIGH_VALUE_LENGTH,PARTITION_POSITION,TABLESPACE_NAME,PCT_FREE,PCT_USED,INI_TRANS,MAX_TRANS,INITIAL_EXTENT,NEXT_EXTENT,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS,NUM_ROWS,BLOCKS,EMPTY_BLOCKS,AVG_SPACE,CHAIN_CNT,AVG_ROW_LEN,LAST_ANALYZED,COMPRESSION,COMPRESS_FOR

SELECT
        TABLE_OWNER         ||','||
        TABLE_NAME          ||','||
        COMPOSITE           ||','||
        PARTITION_NAME      ||','||
        SUBPARTITION_COUNT  ||','||
        HIGH_VALUE_LENGTH   ||','||
        PARTITION_POSITION  ||','||
        TABLESPACE_NAME     ||','||
        PCT_FREE            ||','||
        PCT_USED            ||','||
        INI_TRANS           ||','||
        MAX_TRANS           ||','||
        INITIAL_EXTENT      ||','||
        NEXT_EXTENT         ||','||
        MIN_EXTENT          ||','||
        MAX_EXTENT          ||','||
        PCT_INCREASE        ||','||
        FREELISTS           ||','||
        FREELIST_GROUPS     ||','||
        NUM_ROWS            ||','||
        BLOCKS              ||','||
        EMPTY_BLOCKS        ||','||
        AVG_SPACE           ||','||
        CHAIN_CNT           ||','||
        AVG_ROW_LEN         ||','||
        LAST_ANALYZED       ||','||
        COMPRESSION         
FROM
        DBA_TAB_PARTITIONS
WHERE
        TABLE_OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY TABLE_OWNER,TABLE_NAME,PARTITION_POSITION
/

SPOOL OFF

SET HEAD ON
COLUMN TABLE_OWNER FOR A100
COLUMN TABLE_NAME FOR A100
COLUMN PARTITION_NAME FOR A100
COLUMN HIGH_VALUE FOR A110
SPOOL '&infodir/dba_tab_partitions_&sid..log'

SELECT
        TABLE_OWNER,TABLE_NAME,PARTITION_NAME,HIGH_VALUE
FROM
	DBA_TAB_PARTITIONS
WHERE
        TABLE_OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY TABLE_OWNER,TABLE_NAME,PARTITION_POSITION
/

SPOOL OFF
SET HEAD OFF


REM   #################################################################
REM   INDEX INFOMATION
REM   #################################################################

SPOOL '&infodir/index_&sid..csv'

PROMPT INDEX_OWNER,INDEX_NAME,INDEX_TABLESPACE,UNIQUENESS,INDEX_TYPE,COMPRESSION,DEGREE,CONSTRAINT_TYPE,TABLE_OWNER,TABLE_NAME,COLUMN_POSITION,COLUMN_NAME,TABLE_TYPE,INITIAL_EXT,NEXT_EXT,MIN_EXT,MAX_EXT,PCT_INC,STATUS,PARTITIONED,LAST_ANALYZED

SELECT
      DBA_INDEXES.OWNER               ||','||
      DBA_INDEXES.INDEX_NAME          ||','||
      DBA_INDEXES.TABLESPACE_NAME     ||','||
      DBA_INDEXES.UNIQUENESS          ||','||
      DBA_INDEXES.INDEX_TYPE          ||','||
      DBA_INDEXES.COMPRESSION         ||','||
      DBA_INDEXES.DEGREE              ||','||
      DBA_CONSTRAINTS.CONSTRAINT_TYPE ||','||
      DBA_INDEXES.TABLE_OWNER         ||','||
      DBA_INDEXES.TABLE_NAME          ||','||
      DBA_IND_COLUMNS.COLUMN_POSITION ||','||
      DBA_IND_COLUMNS.COLUMN_NAME     ||','||
      DBA_INDEXES.TABLE_TYPE          ||','||
      DBA_INDEXES.INITIAL_EXTENT      ||','||
      DBA_INDEXES.NEXT_EXTENT         ||','||
      DBA_INDEXES.MIN_EXTENTS         ||','||
      DBA_INDEXES.MAX_EXTENTS         ||','||
      DBA_INDEXES.PCT_INCREASE        ||','||
      DBA_INDEXES.STATUS              ||','||
      DBA_INDEXES.PARTITIONED         ||','||
      DBA_INDEXES.LAST_ANALYZED
FROM
      DBA_INDEXES,
      DBA_CONSTRAINTS,
      DBA_IND_COLUMNS
WHERE
      DBA_INDEXES.OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND
      DBA_INDEXES.INDEX_NAME=DBA_CONSTRAINTS.INDEX_NAME(+)
AND
      DBA_INDEXES.OWNER=DBA_CONSTRAINTS.OWNER(+)
AND
      DBA_INDEXES.INDEX_NAME=DBA_IND_COLUMNS.INDEX_NAME
AND
      DBA_INDEXES.OWNER=DBA_IND_COLUMNS.INDEX_OWNER
ORDER BY DBA_INDEXES.OWNER,DBA_INDEXES.INDEX_NAME,DBA_INDEXES.TABLE_NAME,COLUMN_POSITION
/

SPOOL OFF


SPOOL '&infodir/part_index_&sid..csv'

PROMPT OWNER,INDEX_NAME,TABLE_NAME,COLUMN_NAME,PARTITIONING_TYPE,SUBPARTITIONING_TYPE,PARTITION_COUNT,DEF_TABLESPACE_NAME,DEF_PCT_FREE,DEF_INI_TRANS,DEF_MAX_TRANS,DEF_INITIAL_EXTENT,DEF_NEXT_EXTENT,DEF_MIN_EXTENTS,DEF_MAX_EXTENTS,DEF_PCT_INCREASE,DEF_FREELISTS,DEF_FREELIST_GROUPS

SELECT
        I.OWNER			||','||
        I.INDEX_NAME		||','||
        I.TABLE_NAME		||','||
	K.COLUMN_NAME		||','||
        I.PARTITIONING_TYPE	||','||
        I.SUBPARTITIONING_TYPE	||','||
        I.PARTITION_COUNT	||','||
        I.DEF_TABLESPACE_NAME	||','||
	I.DEF_PCT_FREE		||','||
	I.DEF_INI_TRANS		||','||
	I.DEF_MAX_TRANS		||','||
	I.DEF_INITIAL_EXTENT	||','||
	I.DEF_NEXT_EXTENT	||','||
	I.DEF_MIN_EXTENTS	||','||
	I.DEF_MAX_EXTENTS	||','||
	I.DEF_PCT_INCREASE	||','||
	I.DEF_FREELISTS		||','||
	I.DEF_FREELIST_GROUPS
FROM
        DBA_PART_INDEXES I,
	DBA_PART_KEY_COLUMNS K
WHERE
        I.OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND
	I.INDEX_NAME=K.NAME
ORDER BY I.OWNER,I.INDEX_NAME
/

SPOOL OFF


SPOOL '&infodir/dba_ind_partitions_&sid..csv'

PROMPT  INDEX_OWNER,INDEX_NAME,COMPOSITE,PARTITION_NAME,SUBPARTITION_COUNT,HIGH_VALUE_LENGTH,PARTITION_POSITION,STATUS,TABLESPACE_NAME,PCT_FREE,INI_TRANS,MAX_TRANS,INITIAL_EXTENT,NEXT_EXTENT,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS

SELECT
        INDEX_OWNER		||','||
        INDEX_NAME		||','||
        COMPOSITE		||','||
        PARTITION_NAME		||','||
        SUBPARTITION_COUNT	||','||
        HIGH_VALUE_LENGTH	||','||
        PARTITION_POSITION	||','||
        STATUS			||','||
        TABLESPACE_NAME		||','||
        PCT_FREE		||','||
        INI_TRANS		||','||
        MAX_TRANS		||','||
        INITIAL_EXTENT		||','||
        NEXT_EXTENT		||','||
        MIN_EXTENT		||','||
        MAX_EXTENT		||','||
        PCT_INCREASE		||','||
        FREELISTS		||','||
        FREELIST_GROUPS
FROM
	DBA_IND_PARTITIONS
WHERE
        INDEX_OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY INDEX_OWNER,INDEX_NAME,PARTITION_POSITION
/

SPOOL OFF

SET HEAD ON
COLUMN INDEX_OWNER FOR A28
COLUMN INDEX_NAME FOR A28
COLUMN PARTITION_NAME FOR A28
COLUMN HIGH_VALUE FOR A110
SPOOL '&infodir/dba_ind_partitions_&sid..log

SELECT
        INDEX_OWNER,INDEX_NAME,PARTITION_NAME,HIGH_VALUE
FROM
	DBA_IND_PARTITIONS
WHERE
        INDEX_OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY INDEX_OWNER,INDEX_NAME,PARTITION_POSITION
/

SPOOL OFF
SET HEAD OFF


REM   #################################################################
REM   OBJECTS INFOMATION
REM   #################################################################

SPOOL '&infodir/objects_&sid..csv'

PROMPT OWNER,OBJECT_NAME,SUBOBJECT_NAME,OBJECT_ID,DATA_OBJECT_ID,OBJECT_TYPE,CREATED,LAST_DDL_TIME,TIMESTAMP,STATUS,TEMPORARY,GENERATED

SELECT
        OWNER                ||','||
        OBJECT_NAME          ||','||
        SUBOBJECT_NAME       ||','||
        OBJECT_ID            ||','||
        DATA_OBJECT_ID       ||','||
        OBJECT_TYPE          ||','||
        CREATED              ||','||
        LAST_DDL_TIME        ||','||
        TIMESTAMP            ||','||
        STATUS               ||','||
        TEMPORARY            ||','||
        GENERATED
FROM
        DBA_OBJECTS
WHERE
        OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND     OBJECT_NAME NOT LIKE 'BIN$%'
ORDER BY OWNER,OBJECT_NAME,OBJECT_TYPE
/
SPOOL OFF


SPOOL '&infodir/tenki_objects_&sid..csv'

PROMPT OWNER,OBJECT_NAME,OBJECT_TYPE,STATUS

SELECT
        OWNER                ||','||
        OBJECT_NAME          ||','||
        OBJECT_TYPE          ||','||
        STATUS               
FROM
        DBA_OBJECTS
WHERE 
      OBJECT_NAME NOT IN (SELECT INDEX_NAME FROM DBA_INDEXES WHERE INDEX_TYPE = 'LOB')
AND   OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND   OBJECT_NAME NOT LIKE 'BIN$%'
UNION ALL
SELECT 
      OWNER ||','||
      DECODE(INDEX_TYPE,'LOB','LOB INDEX',INDEX_TYPE)
FROM  DBA_INDEXES
WHERE INDEX_TYPE = 'LOB'
AND   OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY 1
/
SPOOL OFF

SPOOL '&infodir/objects_count_&sid..csv'

PROMPT OWNER,OBJECT_TYPE,COUNT(*)

SELECT 
      OWNER ||','||
      OBJECT_TYPE ||','||
      COUNT(*)
FROM  DBA_OBJECTS
WHERE 
      OBJECT_NAME NOT IN (SELECT INDEX_NAME FROM DBA_INDEXES WHERE INDEX_TYPE = 'LOB')
AND   OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND   OBJECT_NAME NOT LIKE 'BIN$%'
GROUP BY OWNER,OBJECT_TYPE
UNION
SELECT 
      OWNER ||','||
      DECODE(INDEX_TYPE,'LOB','LOB INDEX',INDEX_TYPE) ||','||
      COUNT(*)
FROM  DBA_INDEXES
WHERE INDEX_TYPE = 'LOB'
AND   OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
GROUP BY OWNER,INDEX_TYPE
ORDER BY 1
/
SPOOL OFF


SPOOL '&infodir/objects_invalid_&sid..csv'

PROMPT OWNER,OBJECT_TYPE,OBJECT_NAME,STATUS

SELECT
        OWNER                ||','||
        OBJECT_TYPE          ||','||
        OBJECT_NAME          ||','||
        STATUS
FROM
        DBA_OBJECTS
WHERE
        (OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')) AND (STATUS='INVALID')
ORDER BY OWNER,OBJECT_TYPE
/
SPOOL OFF


REM   ################################################
REM   check public_synonyms
REM   ################################################

set head on
SPOOL '&infodir/check_public_synonyms_&sid..log'

PROMPT OWNER,COUNT(*)

select owner,count(*) from dba_synonyms where table_owner!='SYS' group by owner
/

set head off
SPOOL OFF


REM   #################################################################
REM   SYNONYMS INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_synonyms_&sid..csv'

PROMPT OWNER,SYNONYM_NAME,TABLE_OWNER,TABLE_NAME,DB_LINK

SELECT
        OWNER               ||','||
        SYNONYM_NAME        ||','||
        TABLE_OWNER         ||','||
        TABLE_NAME          ||','||
        DB_LINK             
FROM
        DBA_SYNONYMS
WHERE   OWNER  NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY owner,synonym_name,table_owner,table_name,db_link
/

SPOOL OFF

SPOOL '&infodir/tenki_dba_synonyms_&sid..csv'

PROMPT OWNER,SYNONYM_NAME,TABLE_OWNER,TABLE_NAME,DB_LINK

SELECT
        OWNER               ||','||
        SYNONYM_NAME        ||','||
        TABLE_OWNER         ||','||
        TABLE_NAME          ||','||
        DB_LINK             
FROM
        DBA_SYNONYMS
WHERE   TABLE_OWNER  NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY owner,synonym_name,table_owner,table_name,db_link
/

SPOOL OFF

REM   #################################################################
REM   EXTENT INFOMATION
REM   #################################################################

SPOOL '&infodir/extent_sum_&sid..csv'

PROMPT OWNER,SEGMENT_NAME,TABLESPACE_NAME,SEGMENT_TYPE,SUM_EXTENTS,SUM_BYTES,SUM_MEGA_BYTES,SUM_BLOCKS

SELECT
       OWNER                 ||','||
       SEGMENT_NAME          ||','||
       TABLESPACE_NAME       ||','||
       SEGMENT_TYPE          ||','||
       EXTENTS               ||','||
       BYTES                 ||','||
       BYTES/1024/1024       ||','||
       BLOCKS
FROM
        DBA_SEGMENTS
WHERE   OWNER  NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY OWNER,SEGMENT_NAME,BLOCKS
/

SPOOL OFF

REM   #################################################################
REM   FREE SPACE INFOMATION
REM   #################################################################

SPOOL '&infodir/free_space_&sid..csv'

PROMPT TABLESPACE,FILE_ID,BLOCK_ID,BYTES,MB,BLOCKS,RELATIVE_FNO

SELECT
        TABLESPACE_NAME   ||','||
        FILE_ID           ||','||
        BLOCK_ID          ||','||
        BYTES             ||','||
        BYTES/1024/1024   ||','||
        BLOCKS            ||','||
        RELATIVE_FNO
FROM
        DBA_FREE_SPACE
ORDER BY TABLESPACE_NAME,BYTES
/

SPOOL OFF

SPOOL '&infodir/free_space_sum_&sid..csv'

PROMPT TABLESPACE,SUM(BYTES),MEGA_SUM(BYTES),MAX(BYTES),MEGA_MAX_BYTES

SELECT 
        TABLESPACE_NAME      ||','||
        SUM(BYTES)           ||','||
        SUM(BYTES)/1024/1024 ||','||
        MAX(BYTES)           ||','||
        MAX(BYTES)/1024/1024
FROM
        DBA_FREE_SPACE
GROUP BY TABLESPACE_NAME
ORDER BY TABLESPACE_NAME,SUM(BYTES)
/

SPOOL OFF


SPOOL '&infodir/dba_data_files_USED_RATE_&sid..csv'

PROMPT TABLESPACE,FILE_NAME,"SIZE[MB]","FREE_SIZE[MB]","USED_RATE[%]",AUTOEXTENSIBLE


select
       x."TABLESPACE"                                                        ||','||
       x."FILE_NAME"                                                         ||','||
       round(x."SIZE[MB]",1)                                                 ||','||
       round(x."FREE_SIZE[MB]",1)                                            ||','||
       round((1-(x."FREE_SIZE[MB]"/x."SIZE[MB]"))*100,1)                     ||','||
       x."AUTOEXTENSIBLE"  
from
(
select
d."TABLESPACE",
d."FILE_NAME",
d."SIZE[MB]",
sum(f.BYTES)/1024/1024 "FREE_SIZE[MB]",
d."AUTOEXTENSIBLE",
t.EXTENT_MANAGEMENT,
t.CONTENTS,
t.TABLESPACE_NAME
from
(select
TABLESPACE_NAME "TABLESPACE",
FILE_NAME          "FILE_NAME",
BYTES/1024/1024 "SIZE[MB]",
--INCREMENT_BY*(select value from v$parameter where name='db_block_size')/1024/1024  "AUTOEXTENSIBLE(Next)(MB)",
AUTOEXTENSIBLE "AUTOEXTENSIBLE",
FILE_ID
from dba_data_files) d,
dba_free_space f,dba_tablespaces t
where d.FILE_ID=f.FILE_ID(+)
and d."TABLESPACE"=t.TABLESPACE_NAME
group by
d."TABLESPACE",
d."FILE_NAME",
d."SIZE[MB]",
d."AUTOEXTENSIBLE",
t.EXTENT_MANAGEMENT,
t.CONTENTS,
t.TABLESPACE_NAME
union
select
d."TABLESPACE",
d."FILE_NAME",
d."SIZE[MB]",
sum(f.BYTES_FREE)/1024/1024 "FREE_SIZE[MB]",
d."AUTOEXTENSIBLE",
t.EXTENT_MANAGEMENT,
t.CONTENTS,
t.TABLESPACE_NAME
from
(select
TABLESPACE_NAME "TABLESPACE",
FILE_NAME          "FILE_NAME",
BYTES/1024/1024 "SIZE[MB]",
--INCREMENT_BY*(select value from v$parameter where name='db_block_size')/1024/1024  "AUTOEXTENSIBLE(Next)(MB)",
AUTOEXTENSIBLE "AUTOEXTENSIBLE",
FILE_ID
from dba_temp_files) d,
V$TEMP_SPACE_HEADER f,dba_tablespaces t
where d.FILE_ID=f.FILE_ID(+)
and d."TABLESPACE"=t.TABLESPACE_NAME
group by
d."TABLESPACE",
d."FILE_NAME",
d."SIZE[MB]",
d."AUTOEXTENSIBLE",
t.EXTENT_MANAGEMENT,
t.CONTENTS,
t.TABLESPACE_NAME
order by 6,7,8
) x
/

SPOOL OFF


REM   #################################################################
REM   SEQUENCE  INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_sequence_&sid..csv'

PROMPT SEQUENCE_OWNER,SEQUENCE_NAME,MIN_VALUE,MAX_VALUE,INCREMENT_BY,CYCLE_FLAG,ORDER_FLAG,CACHE_SIZE,LAST_NUMBER

SELECT
      SEQUENCE_OWNER          ||','||
      SEQUENCE_NAME           ||','||
      MIN_VALUE               ||','||
      MAX_VALUE               ||','||
      INCREMENT_BY            ||','||
      CYCLE_FLAG              ||','||
      ORDER_FLAG              ||','||
      CACHE_SIZE              ||','||
      LAST_NUMBER
FROM  
      DBA_SEQUENCES
WHERE
      SEQUENCE_OWNER  NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY SEQUENCE_OWNER,SEQUENCE_NAME
/

SPOOL OFF


REM   #################################################################
REM   VIEW  INFOMATION
REM   #################################################################

SPOOL '&infodir/view_&sid..csv'

PROMPT OWNER,VIEW_NAME,TEXT_LENGTH,TYPE_TEXT_LENGTH,TYPE_TEXT,OID_TEXT_LENGTH,OID_TEXT,VIEW_TYPE_OWNER,VIEW_TYPE

SELECT
       OWNER                 ||','||
       VIEW_NAME             ||','||
       TEXT_LENGTH           ||','||
       TYPE_TEXT_LENGTH      ||','||
       TYPE_TEXT             ||','||
       OID_TEXT_LENGTH       ||','||
       OID_TEXT              ||','||
       VIEW_TYPE_OWNER       ||','||
       VIEW_TYPE
FROM
       DBA_VIEWS
WHERE
      OWNER NOT IN  ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY OWNER,VIEW_NAME
/

SPOOL OFF


REM   #################################################################
REM   DATABASE LINK INFOMATION
REM   #################################################################

SPOOL '&infodir/db_link_&sid..csv'

PROMPT  OWNER,DB_LINK,USERNAME,HOST,CREATED

SELECT
       OWNER         ||','||
       DB_LINK       ||','||
       USERNAME      ||','||
       HOST          ||','||
       CREATED
FROM
       DBA_DB_LINKS
ORDER BY OWNER,DB_LINK
/

SPOOL OFF

REM   #################################################################
REM   USER INFOMATION
REM   #################################################################

SPOOL '&infodir/user_&sid..csv'

PROMPT USERNAME,USER_ID,PASSWORD,ACCOUNT_STATUS,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,CREATED,PROFILE,EXTERNAL_NAME

SELECT
       USERNAME              ||','||
       USER_ID               ||','||
       PASSWORD              ||','||
       ACCOUNT_STATUS        ||','||
       LOCK_DATE             ||','||
       EXPIRY_DATE           ||','||
       DEFAULT_TABLESPACE    ||','||
       TEMPORARY_TABLESPACE  ||','||
       CREATED               ||','||
       PROFILE               ||','||
       EXTERNAL_NAME
FROM 
       DBA_USERS
ORDER BY USERNAME
/

SPOOL OFF


SPOOL '&infodir/dba_profiles_&sid..csv'

PROMPT PROFILE,RESOURCE_TYPE,RESOURCE_NAME,LIMIT

SELECT
       PROFILE               ||','||
       RESOURCE_TYPE         ||','||
       RESOURCE_NAME         ||','||
       LIMIT  
FROM
       DBA_PROFILES
ORDER BY PROFILE,RESOURCE_TYPE
/


REM   #################################################################
REM   PRIVILEGE INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_tab_privs_&sid..csv'

PROMPT GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY

SELECT
        grantee     ||','||
        owner       ||','||
        table_name  ||','||
        grantor     ||','||
        privilege   ||','||
        grantable   ||','||
        hierarchy
FROM
        DBA_TAB_PRIVS
 WHERE 
        grantee NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
ORDER BY OWNER,TABLE_NAME
/
SPOOL OFF

REM SPOOL '&infodir/tenki_tab_privs_&sid..csv

REM select * from dba_tab_privs
REM where owner not in ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN')
REM order by owner,table_name,privilege
REM /
REM SPOOL OFF

SPOOL '&infodir/dba_sys_privs_&sid..csv'

PROMPT GRANTEE,PRIVILEGE,ADMIN_OPTION
SELECT
        grantee         ||','||
        privilege       ||','||
        admin_option
FROM DBA_SYS_PRIVS
ORDER BY GRANTEE,PRIVILEGE
/
SPOOL OFF


SPOOL '&infodir/dba_roles_&sid..csv'

PROMPT ROLE,PASSWORD_REQUIRED

SELECT
        role                ||','||
        password_required
FROM DBA_ROLES
ORDER BY ROLE
/
SPOOL OFF

SPOOL '&infodir/dba_role_privs_&sid..csv'

PROMPT GRANTEE,GRANTED_ROLE,ADMIN_OPTION,DEFAULT_ROLE
SELECT
        grantee         ||','||
        granted_role    ||','||
        admin_option    ||','||
        default_role
FROM DBA_ROLE_PRIVS
ORDER BY GRANTEE,GRANTED_ROLE
/

SPOOL OFF

SPOOL '&infodir/archived_log_&sid..csv'

PROMPT recid,stamp,name,dest_id,thread#,sequence#,resetlogs_change#,resetlogs_time,resetlogs_id,first_change#,first_time,next_change#,next_time,blocks,block_size,creator,registrar,standby_dest,archived,applied,deleted,status,completion_time,dictionary_begin,dictionary_end,end_of_redo,backup_count,archival_thread#,activation#,is_recovery_dest_file,compressed,fal,end_of_redo_type,backed_by_vss
SELECT
        recid               ||','||
        stamp               ||','||
        name                ||','||
        dest_id             ||','||
        thread#             ||','||
        sequence#           ||','||
        resetlogs_change#   ||','||
        resetlogs_time      ||','||
        resetlogs_id        ||','||
        first_change#       ||','||
        first_time          ||','||
        next_change#        ||','||
        next_time           ||','||
        blocks              ||','||
        block_size          ||','||
        creator             ||','||
        registrar           ||','||
        standby_dest        ||','||
        archived            ||','||
        applied             ||','||
        deleted             ||','||
        status              ||','||
        completion_time     ||','||
        dictionary_begin    ||','||
        dictionary_end      ||','||
        end_of_redo         ||','||
        backup_count        ||','||
        archival_thread#    ||','||
        activation#         ||','||
        is_recovery_dest_file   ||','||
        compressed          ||','||
        fal                 ||','||
        end_of_redo_type    
FROM
        v$archived_log
ORDER BY recid
/

SPOOL OFF

set head off

REM   #################################################################
REM   JOB INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_jobs_&sid..log'

--SET HEAD ON
--SET LINESIZE 1000
--COLUMN JOB FOR 99999
--COLUMN LOG_USER FOR A20
--COLUMN PRIV_USER FOR A20
--COLUMN SCHEMA_USER FOR A20
--COLUMN INTERVAL FOR A30
--COLUMN WHAT FOR A30
--COLUMN NLS_ENV FOR A190
--COLUMN MISC_ENV FOR A30

PROMPT JOB,LOG_USER,PRIV_USER,SCHEMA_USER,LAST_DATE,THIS_DATE,NEXT_DATE,TOTAL_TIME,BROKEN,INTERVAL,FAILURES,WHAT,NLS_ENV,MISC_ENV,INSTANCE
SELECT
        JOB         ||','||
        LOG_USER    ||','||
        PRIV_USER   ||','||
        SCHEMA_USER ||','||
        LAST_DATE   ||','||
        THIS_DATE   ||','||
        NEXT_DATE   ||','||
        TOTAL_TIME  ||','||
        BROKEN      ||','||
        INTERVAL    ||','||
        FAILURES    ||','||
        WHAT        ||','||
        NLS_ENV     ||','||
        MISC_ENV    ||','||
        INSTANCE
FROM
       DBA_JOBS
ORDER BY JOB,BROKEN
/
SPOOL OFF
SET HEAD OFF
SET LINESIZE 200

REM   #################################################################
REM   DIRECTORIES INFOMATION
REM   #################################################################

SPOOL '&infodir/dba_directories_&sid..csv'

PROMPT  OWNER,DIRECTORY_NAME,DIRECTORY_PATH

SELECT
       OWNER            ||','||
       DIRECTORY_NAME   ||','||
       DIRECTORY_PATH
FROM
       DBA_DIRECTORIES
ORDER BY OWNER,DIRECTORY_NAME
/

SPOOL OFF

REM   #################################################################
REM   PARAMETER INFOMATION
REM   #################################################################

SPOOL '&infodir/parameter_&sid..csv'

PROMPT NAME,VALUE,ISDEFAULT

SELECT
       NAME          ||','||
       VALUE         ||','||
       ISDEFAULT
FROM
       V$PARAMETER2
ORDER BY NAME
/

SPOOL OFF

REM   #################################################################
REM   CONSTRAINTS
REM	  TRIGGERS
REM	  LONG_LONGRAW_BCLOB
REM	  DATAFILE_USED_RATE INFORMATION
REM   #################################################################

SPOOL '&infodir/constraints_&sid..csv'

--PROMPT OWNER,CONSTRAINT_NAME,CONSTRAINT_TYPE,TABLE_NAME,SEARCH_CONDITION,R_OWNER,R_CONSTRAINT_NAME,DELETE_RULE,STATUS,DEFERRABLE,DEFERRED,VALIDATED,GENERATED,BAD,RELY,LAST_CHANGE,INDEX_OWNER,INDEX_NAME,INVALID,VIEW_RELATED
PROMPT OWNER,CONSTRAINT_NAME,CONSTRAINT_TYPE,TABLE_NAME,R_OWNER,R_CONSTRAINT_NAME,DELETE_RULE,STATUS,DEFERRABLE,DEFERRED,VALIDATED,GENERATED,BAD,RELY,LAST_CHANGE,INDEX_OWNER,INDEX_NAME,INVALID,VIEW_RELATED
SELECT
        owner               ||','||
        constraint_name     ||','||
        constraint_type     ||','||
        table_name          ||','||
--        search_condition    ||','||
        r_owner             ||','||
        r_constraint_name   ||','||
        delete_rule         ||','||
        status              ||','||
        deferrable          ||','||
        deferred            ||','||
        validated           ||','||
        generated           ||','||
        bad                 ||','||
        rely                ||','||
        last_change         ||','||
        index_owner         ||','||
        index_name          ||','||
        invalid             ||','||
        view_related
FROM
        dba_constraints
WHERE
        OWNER NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
/
SPOOL OFF

SPOOL '&infodir/triggers_&sid..csv'

PROMPT OWNER,TRIGGER_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,TABLE_OWNER,BASE_OBJECT_TYPE,TABLE_NAME,COLUMN_NAME,REFERENCING_NAMES,WHEN_CLAUSE,STATUS,ACTION_TYPE

SELECT
        owner               ||','||
        trigger_name        ||','||
        trigger_type        ||','||
        triggering_event    ||','||
        table_owner         ||','||
        base_object_type    ||','||
        table_name          ||','||
        column_name         ||','||
        referencing_names   ||','||
        when_clause         ||','||
        status              ||','||
        action_type
FROM dba_triggers
WHERE
        owner NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
/

SPOOL OFF

SPOOL '&infodir/LONG_LONGRAW_BCLOB_&sid..csv'

PROMPT OWNER,TABLE_NAME,COLUMN_NAME,DATA_TYPE,DATA_TYPE_MOD,DATA_TYPE_OWNER,DATA_LENGTH,DATA_PRECISION,DATA_SCALE,NULLABLE,COLUMN_ID,DEFAULT_LENGTH,NUM_DISTINCT,LOW_VALUE,HIGH_VALUE,DENSITY,NUM_NULLS,NUM_BUCKETS,LAST_ANALYZED,SAMPLE_SIZE,CHARACTER_SET_NAME,CHAR_COL_DECL_LENGTH,GLOBAL_STATS,USER_STATS,AVG_COL_LEN,CHAR_LENGTH,CHAR_USED,V80_FMT_IMAGE,DATA_UPGRADED,HISTOGRAM

SELECT
        owner               ||','||
        table_name          ||','||
        column_name         ||','||
        data_type           ||','||
        data_type_mod       ||','||
        data_type_owner     ||','||
        data_length         ||','||
        data_precision      ||','||
        data_scale          ||','||
        nullable            ||','||
        column_id           ||','||
        default_length      ||','||
        num_distinct        ||','||
        low_value           ||','||
        high_value          ||','||
        density             ||','||
        num_nulls           ||','||
        num_buckets         ||','||
        last_analyzed       ||','||
        sample_size         ||','||
        character_set_name  ||','||
        char_col_decl_length    ||','||
        global_stats        ||','||
        user_stats          ||','||
        avg_col_len         ||','||
        char_used           ||','||
        v80_fmt_image       ||','||
        data_upgraded       ||','||
        histogram
FROM
        dba_tab_columns
WHERE
        owner NOT IN ('SYS','SYSMAN','SYSTEM','APPQOSSYS','WMSYS','DBSNMP','DIP','MGMT_VIEW','ORACLE_OCM','OUTLN','MDSYS','XDB')
AND     data_type IN ('LONG','LONG RAW','BLOB','CLOB')
/

SPOOL OFF



REM   #################################################################
REM   RESOURCE_LIMIT info
REM   #################################################################

--SET  LINESIZE 10000
--SET  LONG 1000000000
--SET  PAGES 10000
--SET	 colsep ','
--SET	 head on
--SET TERM OFF

SPOOL '&infodir/resource_limit_&sid..csv'

PROMPT RESOURCE_NAME,CURRENT_UTILIZATION,MAX_UTILIZATION,INITIAL_ALLOCATION,LIMIT_VALUE
SELECT
        resource_name       ||','||
        current_utilization ||','||
        max_utilization     ||','||
        initial_allocation  ||','||
        limit_value
FROM
        v$resource_limit
/
SPOOL OFF


REM   #################################################################
REM   MEMORY info
REM   #################################################################
clear col

SPOOL '&infodir/SGA_&sid..csv'
PROMPT NAME,VALUE

SELECT
        name    ||','||
        value
FROM
        v$sga
/

PROMPT COMPONENT,CURRENT_SIZE,MIN_SIZE,MAX_SIZE,USER_SPECIFIED_SIZE,OPER_COUNT,LAST_OPER_TYPE,LAST_OPER_MODE,LAST_OPER_TIME,GRANULE_SIZE

SELECT
        component       ||','||
        current_size    ||','||
        min_size        ||','||
        max_size        ||','||
        user_specified_size ||','||
        oper_count      ||','||
        last_oper_type  ||','||
        last_oper_mode  ||','||
        last_oper_time  ||','||
        granule_size
FROM
        v$sga_dynamic_components
/

SPOOL OFF

SPOOL '&infodir/PGA_&sid..csv'
PROMPT NAME,VALUE,UNIT
SELECT
        name    ||','||
        value   ||','||
        unit
FROM
        v$pgastat
/

SPOOL OFF

REM ********************************************************************#
REM check AWR (for 10g or later version)
REM ********************************************************************#

SPOOL '&infodir/AWR_&sid..csv'
PROMPT DBID,SNAP_INTERVAL,RETENTION,TOPNSQL
SELECT
        dbid            ||','||
        snap_interval   ||','||
        retention       ||','||
        topnsql
FROM
        dba_hist_wr_control
/

SPOOL OFF

set head off term on
SPOOL '&infodir/0000_Current_session_&sid..log' append
select 'End Date: '|| to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;
SPOOL OFF
set head on

clear col

exit

