create user CDBC01_N identified by CDBC01_N default tablespace USERS temporary tablespace TEMP;
grant create session,unlimited tablespace to CDBC01_N;
create table CDBC01_N.OBJECTS as select OWNER,OBJECT_NAME,SUBOBJECT_NAME,OBJECT_ID,DATA_OBJECT_ID,OBJECT_TYPE,CREATED,LAST_DDL_TIME,TIMESTAMP,STATUS,TEMPORARY,GENERATED from dba_objects where 1=2;
alter table CDBC01_N.OBJECTS modify ( CREATED VARCHAR2(20), LAST_DDL_TIME VARCHAR2(20));

