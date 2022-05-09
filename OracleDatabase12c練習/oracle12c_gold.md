# Oracle 12c Gold 試験勉強メモ #

以下はオラクルGold試験勉強のためのメモです。※2019/03/13現在

タイトル引用元：[チェックリスト](https://education.oracle.com/ja/product/pexam_1Z0-063)

タイトル以外はオラクルのドキュメントより個人整理したメモです。
資格を取ろうとする方に役が立つと幸いです。
詳細情報について、最後の参考資料をご確認いただければと思います。

## 1. Oracle データ保護ソリューション ##

### Oracle のバックアップとリカバリのソリューションを説明する ###

1. データベース障害のタイプを説明する

   ~~~sql
   --メディア障害
   --  ディスク・ファイルの読取りまたは書込みの障害
   --ユーザー・エラー
   --  アプリケーション・ロジックのエラーまたは手作業の誤りによって、データベース内のデータが誤って変更あるいは削除
   --アプリケーション・エラー
   --  物理的な破損(メディア破損とも呼ぶ)
   ~~~

2. バックアップとリカバリのタスクに使用できるツールを説明する

   ~~~sql
   --Recovery Manager (RMAN)
   --Oracle Enterprise Manager Cloud Control
   --Zero Data Loss Recovery Appliance (リカバリ・アプライアンス)
   --ユーザー管理のバックアップおよびリカバリ
   ~~~

3. RMAN および最大の可用性のアーキテクチャを説明する

   * ターゲット・データベース(最低限)
   * RMANクライアント(最低限)
   * 高速リカバリ領(オプション)
   * メディア管理ソフトウェア(オプション)
   * リカバリ・カタログ(オプション)

   ~~~sql
   rman
   RMAN> CONNECT TARGET "sbu@prod AS SYSBACKUP" --'"sbu@prod AS SYSBACKUP"' シングルコーテーションは必要か？
   RMAN> EXIT
   ~~~

   ~~~sql
   RMAN
   [TARGET connectStringSpec
     { CATALOG connectStringSpec}
     LOG ['] filename ['] [ APPEND ]
     .
     .
     .
   ] ...

   connectStringSpec::=
   ['][userid][/ [password]][@net_service_name][']
   ~~~

4. SYSBACK 権限を使用する

   ~~~sql
   RMAN> CONNECT TARGET "sbu@prod AS SYSBACKUP"
   ~~~

5. RMAN のスタンドアロン・コマンドとジョブ・コマンドを使用する

   ~~~sql
   --スタンドアロン・コマンド:個々に実行される
   --ジョブ・コマンド:RUNコマンドで中括弧でくくられてグループで実行される
   ~~~

## 2. リカバリ能力の構成 ##

### RMAN の設定を構成および管理する ###

1. RMAN の永続的な設定を構成する

   ~~~sql
   RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;
   ~~~

1. 永続的な設定を表示する

   ~~~sql
   rman
   RMAN> CONNECT TARGET "/ as SYSBACKUP"
   RMAN> SHOW ALL;
   ~~~

1. 保存ポリシーを指定する

   ~~~sql
   RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
   RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 10 DAYS;
   ~~~

### 高速リカバリ領域を設定する ###

1. 高速リカバリ領域を説明する

   ~~~sql
   --リカバリ関連ファイルを一元的に管理するためのディスク領域
   ~~~

1. 高速リカバリ領域を設定する

   ~~~sql
   -- db_recovery_file_dest 位置
   -- db_recovery_file_dest_size サイズ
   -- TYPE '1','ブール','2','文字列','3','整数','4','パラメータ・ファイル','5','予約済','6','大整数'
   SELECT NAME,TYPE,DISPLAY_VALUE FROM V$SYSTEM_PARAMETER WHERE NAME LIKE 'db_recovery_file%'
   ~~~

### リカバリ可能性のために制御ファイルと REDO ログ・ファイルを設定する ###

1. 制御ファイルを多重化する

   ~~~sql
   SELECT NAME,TYPE,DISPLAY_VALUE FROM V$SYSTEM_PARAMETER WHERE NAME LIKE 'control_files%'
   ~~~

1. REDO ログ・ファイルを多重化する

   ~~~sql
   SELECT * FROM V$LOG;
   SELECT * FROM V$LOGFILE;
   SELECT * FROM V$LOG_HISTORY;
   ~~~

## 3. バックアップ計画の実装 ##

### RMAN のさまざまなバックアップ・タイプおよび計画を使用する ###

1. ARCHIVELOG モードを有効にする

   ~~~sql
   SQL> ARCHIVE LOG LIST;
   SQL> SHUTDOWN IMMEDIATE;
   SQL> ALTER DATABASE ARCHIVELOG;
   ~~~

1. テープおよびディスク・ベースのバックアップを作成する

   ~~~sql
   RMAN> CONFIGURE DEFAULT DEVICE TYPE TO disk;
   RMAN> CONFIGURE DEFAULT DEVICE TYPE TO sbt;
   --明示指定
   RMAN> BACKUP DEVICE TYPE SBT DATABASE;
   RMAN> RUN {
   2> ALLOCATE CHANNEL DEVICE TYPE STB;
   3>   PARMS 'SBT_LIBRARY=<MMLのファイルパス>,ENV=(<パラメータ名>=<パラメータ値>)'
   4>   BACKUP ...;
   5> }
   ~~~

1. データベース全体のバックアップを作成する

   ~~~sql
   RMAN> BACKUP DATABASE;
   ~~~

1. 一貫性バックアップと非一貫性バックアップを作成する

   ~~~sql
   --一貫性バックアップ:MOUNT
   RMAN> SHUTDOWN IMMEDIATE;
   RMAN> STARTUP MOUNT;
   RMAN> BACKUP DATABASE;
   --非一貫性バックアップ:OPEN
   RMAN> BACKUP DATABASE;
   ~~~

1. バックアップ・セットおよびイメージ・コピーを作成する

   ~~~sql
   RMAN> BACKUP AS BACKUPSET DATABASE;
   RMAN> BACKUP AS COPY DATABASE;
   ~~~

1. 読取り専用表領域のバックアップを作成する

   ~~~sql
   --???
   ~~~

1. データ・ウェアハウスのバックアップのベスト・プラクティスを使用する

   ~~~sql
   --???
   ~~~

## 4. RMAN バックアップ・オプションの設定および非データベース・ファイルのバックアップの作成 ##

### バックアップを向上させる方法を使用する ###

1. バックアップを向上させる方法を使用する

   ~~~sql
   --増分更新バックアップは、全体バックアップに対して増分バックアップをあらかじめ適用しておくことで、更新されたイメージコピー形式のバックアップを作成しておく方法です。障害発生時の復旧作業において、増分を適用する必要がないため、復旧に要する時間を短縮できます。この方法をオラクル社は推奨バックアップ計画と呼んでいます。
   RUN
   {
     RECOVER COPY OF DATABASE WITH TAG 'incr_update';
     BACKUP INCREMENTAL LEVEL 1
       FOR RECOVER OF COPY WITH TAG 'incr_update'
       DATABASE;
   }
   ~~~

   ~~~sql
   --イメージコピーのリストアを省いた復旧
   RMAN> ALTER TABLESPACE users OFFLINE IMMEDIATE;
   RMAN> SWITCH TABLESPACE users TO COPY;
   RMAN> RECOVER TABLESPACE users;
   RMAN> ALTER TABLESPACE users ONLINE;
   ~~~

1. 圧縮バックアップを作成する

   ~~~sql
   RMAN> CONFIGURE DEVICE TYPE DISK BACKUP TYPE TO COMPRESSED BACKUPSET;
   RMAN> CONFIGURE COMPRESSION ALGORITHM 'MEDIUM'; --BASIC,HIGH,MEDIUM,LOW
   RMAN> BACKUP DATABASE;
   ~~~

1. 非常に大きいファイルのマルチセクション・バックアップを作成する

   ~~~sql
   RMAN> BACKUP DATAFILE 5 SECTION SIZE=300M;
   ~~~

1. プロキシ・コピーを作成する

   ~~~sql
   --???
   ~~~

1. 多重化バックアップ・セットを作成する

   ~~~sql
   --永続
   CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE <device type> TO <copies>;
   CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE <device type> TO <copies>;
   CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT 'output1','output2',...;
   --一時
   BACKUP DEVICE TYPE DISK COPIES <copies> <backup target> [PLUS ARCHIVELOG] FORMAT 'output1','output2',...;
   BACKUP DEVICE TYPE SBT COPIES <copies> <backup target> [PLUS ARCHIVELOG];
   ~~~

1. バックアップ・セットのバックアップを作成する

   ~~~sql
   BACKUP DEVICE TYPE sbt BACKUPSET ALL;
   BACKUP DEVICE TYPE sbt BACKUPSET ALL DELETE INPUT;
   ~~~

1. アーカイブ・バックアップを作成する

   ~~~sql
   --FOREVER : リカバリカタログは必要
   --UNTIL TIME : 書式NLS_DATE_FORMATまたは'SYSDATE+365'
   --RESTORE POINT: バックアップ直後のSCN
   BACKUP KEEP {FOREVER | UNTIL TIME='<datetime>'} [RESTORE POINT <restore point>] DATABASE;
   ~~~

### 非データベース・ファイルのバックアップを実行する ###

1. トレースする制御ファイルをバックアップする

   ~~~sql
   ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
   SELECT * FROM V$PARAMETER WHERE NAME LIKE 'user_dump_dest'
   --/u01/app/oracle/product/12.2.0/dbhome_1/rdbms/log

   ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS '<outfile>';
   ~~~

1. アーカイブ REDO ログ・ファイルをバックアップする

   ~~~sql
   BACKUP ARCHIVELOG <範囲>;
   ~~~

1. ASM ディスク・グループ・メタデータをバックアップする

   ~~~sql
   asmcmd md_backup <バックアップファイル> [-G '<ディスクグループ名>[,<ディスクグループ名>,...]']
   ~~~

## 5. 障害の診断 ##

### 自動診断ワークフローを説明する ###

1. 自動診断リポジトリを使用する

   ~~~sql
   SELECT * FROM V$DIAG_INFO
   ~~~

1. ADRCI を使用する

   ~~~sql
   adrci> show problem
   ~~~

1. メッセージ出力およびエラー・スタックを検索および解釈する

   ~~~sql
   --???
   ~~~

1. データ・リカバリ・アドバイザを使用する

   ~~~sql
   RMAN> LIST FAILURE;
   RMAN> ADVISE FAILURE;
   RMAN> REPAIR FAILURE PREVIEW;
   RMAN> REPAIR FAILURE;
   ~~~

### ブロックの破損を処理する ###

1. RMAN を使用してブロックの破損を検出する

   ~~~sql
   VALIDATE DATABASE;
   SELECT FILE#,BLOCK#,BLOCKS,CORRUTPTION FROM v$database_block_corruption;
   ~~~

1. RMAN を使用してブロックのリカバリを実行する

   ~~~sql
   RECOVER CORRUPTION LIST;
   ~~~

## 6. RMAN を使用したファイルのリカバリ ##

### SPFILE、制御ファイル、REDO ログ・ファイルのリカバリを実行する ###

   ~~~sql
   RMAN> RECOVER DATABASE;
   RMAN> RECOVER TABLESPACE <表領域名>;
   RMAN> RECOVER DATAFILE { <ファイル番号>｜'<ファイルパス>'};

   RMAN> ALTER TABLESPACE user OFFLINE IMMEDIATE;
   RMAN> RESTORE DATAFILE 'xxx'
   RMAN> RECOVER DATAFILE 'xxx'
   RMAN> ALTER TABLESPACE user ONLINE;

   RMAN> STARTUP MOUNT
   RMAN> RESTORE DATABASE;
   RMAN> RECOVER DATABASE;
   RMAN> ALTER DATABASE OPEN;

   --NOACHIVELOGモード 全体バックアップを用いた復旧
   RMAN> STARTUP MOUNT
   RMAN> RESTORE CONTROLFILE FROM AUTOBACKUP;
   RMAN> ALTER DATABASE MOUNT;
   RMAN> RESTORE DATABASE;
   RMAN> ALTER DATABASE OPEN RESETLOGS;
   --NOACHIVELOGモード 増分バックアップを用いた復旧
   RMAN> STARTUP MOUNT
   RMAN> RESTORE CONTROLFILE FROM AUTOBACKUP;
   RMAN> ALTER DATABASE MOUNT;
   RMAN> RESTORE DATABASE;
   RMAN> RECOVER DATABASE NOREDO;
   RMAN> ALTER DATABASE OPEN RESETLOGS;
   ~~~

### バックアップから表のリカバリを実行する ###

   ~~~sql
   --Point-in-Timeリカバリ、不完全リカバリ
   SQL> STARTUP --ORA-00313
   SQL> SELECT g.group#,g.SEQUENCE#,g.status,m.member FROM v$log g,v$logfile m WHERE g.group# = m.group# ORDER BY g.group#,m.member;
   --group 4,SEQUENCE 11 error
   SQL> ALTER DATABASE CLEAR LOGFILE GROUP 4;
   SQL> ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 4;
   SQL> exit
   RMAN> RUN {
   2> SET UNTIL SEQUENCE = 11;
   3> RESTORE DATABASE;
   4> RECOVER DATABASE;
   5> }
   RMAN> ALTER DATABASE OPEN RESETLOGS;

   SELECT * FROM v$log;
   SELECT * FROM v$archived_log;

   RECOVER TABLE <スキーマ>.<表名>
     [ UNTIL SCN <SCN>
     | UNTIL SEQUENCE <ログ順序番号> [THREAD <スレッド番号>]
     | UNTIL TIME '<日時文字列>'
     | TO RESTORE POINT <リストアポイント名>]
     AUXILIARY DESTINATION '<補助インスタンスを作成するディレクトリのパス>'
     [ REMAP TABLE '<スキーマ>'.'<古い表名>':'<新しい表名>' ]
   ~~~

### 索引、読取り専用表領域、一時ファイルのリカバリを実行する ###

   ~~~sql
   --一時ファイル
   ALTER DATABASE TEMPFILE '<一時ファイルのパス>' DROP;
   ALTER TABLESPACE <一時表領域名> ADD TEMPFILE '<一時ファイルのパス>' SIZE <サイズ> [AUTOEXTEND ON] [RESUE];
   --またはDATABASE再起動

   --索引専用表領域
   --A 表領域を作成し、索引を再作成
   --B リストア、リカバリを実施※ただし、NOLOGGING操作で作成した索引は再作成

   --読取り専用表領域
   --リストアのみ
   ~~~

   ~~~sql
   --SPFILEの復旧
   STARTUP NOMOUNT
   SET DBID <DBID>
   RESTORE SPFILE FROM AUTOBACKUP DB_RECOVERY_FILE_DEST='<高速リカバリ領域のパス>' DB_NAME='dbname'
   RESTORE SPFILE FROM '<バックアップピースのファイル名>'
   STARTUP FORCE

   --SPFILE再作成
   --1.PFILE作成
   --2.<ORACLE_HOME>/dbs/init<ORACLE_SID>.ora に配置
   --3.SQL*Plusで CREATE spfile FROM pfile
   --4.STARTUP
   ~~~

   ~~~sql
   --制御ファイルの復旧
   STARTUP NOMOUNT
   RESTORE CONTROLFILE FROM AUTOBACKUP;
   ALTER DATABASE OPEN RESETLOGS;

   --制御ファイルが一部損失した場合
   SHUTDOWN ABORT
   --ファイルコピーとcontrol_files設定
   STARTUP
   ~~~

### 新しいホストにデータベースをリストアする ###

   ~~~sql
   RUN {
     SET UNTIL SCN <SCN番号> ## 最後のアーカイブログファイルのSCNを指定
     RESTORE DATABASE;
     RECOVER DATABASE;
   }
   ~~~

## 7. フラッシュバック・テクノロジの使用 ##

### フラッシュバック・テクノロジを説明する ###

1. フラッシュバック・テクノロジを使用するデータベースを設定する

   ~~~sql
   SELECT * FROM v$parameter WHERE name like 'undo%'
   ~~~

1. UNDO 保存を保証する

   ~~~sql
   ALTER TABLESPACE <UNDO表領域名> RETENTION GUARANTEE;
   ALTER TABLESPACE <UNDO表領域名> RETENTION NOGUARANTEE;
   ~~~

### フラッシュバックを使用してデータを問い合せる ###

1. フラッシュバック問合せを使用する

   ~~~sql
   SELECT * FROM T AS OF TIMESTAMP TO_TIMESTAMP('18-01-25 20:46:51.012507') WHERE n=1;
   ~~~

1. フラッシュバック・バージョン問合せを使用する

   ~~~sql
   SELECT timestamp_to_scn(systimestamp) FROM dual;

   SELECT versions_starttime,versions_endtime,versions_operation,id,sal
   FROM t
   VERSIONS BETWEEN SCN 1853450 AND 1853457
   ORDER BY id,versions_starttime NULLS FIRST;
   ~~~

1. フラッシュバック・トランザクション問合せを使用する

   ~~~sql
   SELECT xid,start_timestamp,logon_user,operation,table_name,undo_sql
   FROM FLASHBACK_TRANSACTION_QUERY
   WHERE start_timetamp
     BETWEEN to_timestamp('2018-01-19 18:52:40','YYYY-MM-DD HH24:MI:SS')
     AND to_timestamp('2018-01-19 18:52:50','YYYY-MM-DD HH24:MI:SS')
   AND TABLE_NAME='T'
   ORDER BY START_SCN;
   ~~~

1. トランザクションをフラッシュバックする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 表のフラッシュバック操作を実行する ###

1. 表のフラッシュバックを実行する

   ~~~sql
   FLASHBACK TABLE <表名> TO {TIMESTAMP <タイムスタンプ> | SCN <SCN番号>};

   SELECT timestamp_to_scn(systimestamp) FROM dual;
   FLASHBACK TABLE emp TO SCN 1898805;
   ALTER TABLE emp ENABLE ROW MOVEMENT;
   FLASHBACK TABLE emp TO SCN 1898805;
   ~~~

1. 表をごみ箱からリストアする

   ~~~sql
   SELECT OBJECT_NAME,ORIGINAL_NAME,TYPE FROM USER_RECYCLBIN;
   SHOW RECYCLEBIN;
   FLASHBACK TABLE T TO BEFORE DROP;

   ALTER SESSION SET RECYCLEBIN = OFF;
   SHOW PARAMETER RECYCLEBIN;
   ~~~

### フラッシュバック・データ・アーカイブを説明および使用する ###

1. フラッシュバック・データ・アーカイブを使用する

   ~~~sql
   SELECT * FROM v$parameter WHERE name like 'undo_management%';--AUTO

   CREATE TABLESPACE tbs_fda DATAFILE 'xxx' size 10M SEGMENT SPACE MANAGEMENT AUTO;
   CREATE FLASHBACK ARCHIVE fda1 TABLESPACE tbs_fda QUOTA 1M RETENTION 2 YEAR;
   CREATE FLASHBACK ARCHIVE DEFAULT fda2 TABLESPACE tbs_fda QUOTA 1M RETENTION 2 YEAR;

   CREATE TABLE ... FLASHBACK ARCHIVE [<フラッシュバックデータアーカイブ名>];
   ALTER TABLE emp1 FLASHBACK ARCHIVE fda1;
   ALTER TABLE <表名> NO FLASHBACK ARCHIVE;

   SELECT * FROM emp1 AS OF TIMESTAMP sysdate-2;

   ALTER FLASHBACK ARCHIVE <FDA名> MODIFY TABLESPACE <表領域名> QUOTA サイズ {K|M|G};
   ALTER FLASHBACK ARCHIVE <FDA名> MODIFY RETENTION <保存期間> {YEAR | MONTH | DAY};
   ALTER FLASHBACK ARCHIVE fda1 PURGE BEFORE TIMESTAMP (systimestamp - interval '1' day);

   DROP FLASHBACK ARCHIVE <FDA名>;
   SELECT * FROM dba_flashback_archive;
   SELECT * FROM dba_flashback_archive_tables;
   SELECT * FROM dba_flashback_archive_ts;
   ~~~

1. DBMS_FLASHBACK_ARCHIVE パッケージを使用する

   ~~~sql
   ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
   ALTER DATABASE ADD SUPPLEMENTAL LOG DATA(PRIMARY KEY) COLUMNS;
   GRANT EXECUTE ON DBMS_FLASHBACK TO <user>;
   GRANT SELECT ANY TRANSACTION TO <user>;

   SQL> connect scott/tigger
   SQL> SELECT sysdate,dbms_flashback.get_system_change_number() FROM dual;
   SQL> SET TRANSACTION NAME 'TXNAME1';
   SQL> UPDATE T SET a=2 WHERE id=1;
   SQL> UPDATE T SET a=3 WHERE id=2;
   SQL> commit;
   SQL> SET TRANSACTION NAME 'TXNAME2';
   SQL> UPDATE T SET a=2 WHERE id=2;
   SQL> commit;
   SQL> SELECT * FROM T;

   SQL> BEGIN
   2 DBMS_FLASHBACK.TRANSACTION_BACKOUT(
   3   numtxns => 1, --トランザクションの数を指定
   4   name => TXNAME_ARRAY('TXNAME1'), --トランザクション名,複数可（numtxnsとセット）
   5   options => DBMS_FLASHBACK.CASCADE, --NOCASCADE,CASCADE,NONCONFLICT_ONLY,NOCASCADE_FORCE
   6   scnhint => 1747656 --トランザクションの検索開始点SCN
   7   );
   8 END;
   9 /
   SQL> SELECT * FROM T;
   SQL> commit;
   ~~~

## 8. データの転送 ##

### トランスポータブル表領域およびデータベースの概念を説明および使用する ###

1. イメージ・コピーまたはバックアップ・セットを使用してデータベース間で表領域を転送する

   ~~~sql
   SQL> ALTER TABLESPACE ts01 READ ONLY;
   SQL> !expdb system/Password123 DIRECTORY=DATA_PUMP_DIR DUMPFILE=ts01.dmp
   SQL> SELECT directory_path FROM dba_directories WHERE directory_name='DATA_PUMP_DIR';
   SQL> !ls -ltr /u01/app/oracle/admin/orcl/dpdump/
   SQL> !cp /u01/app/oracle/admin/orcl/ts01.dbf /u01/app/oracle/oradata/c102/ts01.dbf
   SQL> ALTER TABLESPACE ts01 READ WRITE;
   SQL> !cp /u01/app/oracle/admin/orcl/ts01.dmp /u01/app/oracle/oradata/c102/ts01.dmp
   ~~~

   ~~~sql
   SQL> !impdp system/oracle DIRECTORY=DATA_PUMP_DIR DUMPFILE=ts01.dmp
   SQL> SELECT tablespace_name,plugged_in,status FROM DBA_TABLESPACES WHERE tablespace_name='TS01';
   SQL> ALTER TABLESPACE ts01 READ WRITE;
   SQL> SELECT tablespace_name,plugged_in,status FROM DBA_TABLESPACES WHERE tablespace_name='TS01';
   ~~~

1. データ・ファイルまたはバックアップ・セットを使用してデータベースを転送する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. プラットフォーム間でデータを転送する

   ~~~sql
   SQL> SELECT * FROM v$transportable_platform;
   SQL> SELECT t.endian_format,d.platform_id,d.platform_name FROM v$database d,v$transportable_platform t WHERE t.platform_id = d.platform_id;
   --ソース側で変換
   RMAN> CONVERT TABLESPACE users TO PLATFORM = 'Linux IA (32-bit)' DB_FILE_NAME_CONVERT '/data1','conv';
   --ターゲット側で変換
   RMAN> CONVERT DATAFILE '/tmp/data/*' FROM PLATFORM = 'Solaris[tm] OE (32-bit)' DB_FILE_NAME_CONVERT = '/tmp/data','oradata';

   --BACKUP
   RMAN> BACKUP
   2> FOR TRANSPORT TABLESPACE tbs01 FORMAT 'tmp/trans_ts3.bck'
   3> DATADUMP FORMAT '/tmp/trans_ts3_dmp.bck';
   --RESTORE
   RMAN> RESORE
   2> FROM PLATFORM 'Linux x86 64-bit'
   3> FOREIGN TABLESPACE tbs01 FORMAT '/u01/app/oracle/oradata/c102/%N-%f.dbf'
   4> FROM BACKUPSET '/tmp/trans_ts3.bck'
   5> DUMP FILE FROM BACKUPSET '/tmp/trans_ts3_dmp.bck';
   ~~~

## 9. RMAN の操作の監視と調整 ##

### RMAN のパフォーマンスを調整する ###

1. RMAN のエラー・スタックを解釈する

   ~~~sql
   RMAN-99999
   ORA-99999
   ORA-19511
   ~~~

1. パフォーマンスのボトルネックを診断する

   ~~~sql
   SELECT * FROM v$session_longops;--6秒(絶対時間)より長くかかる様々な操作の状態
   SELECT * FROM v$session_longops WHERE opname LIKE = 'RMAN%';
   --各チャネル:読み取り、コピー、書き込み
   ~~~

1. RMAN のバックアップ・パフォーマンスを調整する

   ~~~sql
   SELECT * FROM v$backup_sync_io;
   SELECT * FROM v$backup_async_io;

   --DBWR_IO_SLAVES 初期化パラメータ0以外
   --ラージプール構成が必要（バッファとして使用）

   export NLS_DATE_FORMAT='RR-MM-DD HH24:MI:SS'
   rman target /
   RMAN> BACKUP DATABASE;--OUTPUT：開始時間、終了時間
   ...
   RMAN> VALIDATE DATABASE;--OUTPUT：開始時間、終了時間
   ...
   ~~~

## 10. マルチテナント・コンテナ・データベースとプラガブル・データベースの作成 ##

### CDB を設定および作成する ###

   ~~~sql



   ~~~

### 異なる方法で PDB を作成する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### PDB を切断および削除する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 非 CDB データベースを PDB に移行する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 11. CDB と PDB の記憶域の管理 ##

### CDB と PDB で永続表領域と一時表領域を管理する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 12. 可用性の管理 ##

### CDB と PDB のバックアップを実行する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### PDB のデータ・ファイルの損失から PDB をリカバリする ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### データ・リカバリ・アドバイザを使用する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### RMAN を使用して PDB を複製する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 13. データ の移動、セキュリティ操作の実行、他の O racle 製品との統合 ##

### データ・ポンプを使用する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### SQL*Loader を使用する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 操作を監査する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 他の製品（Database Vault、Data Guard、LogMiner）とともに CDB および PDB を使用する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 14. 基本的なバックアップとリカバリの実行 ##

### NOARCHIVELOG データベースをバックアップおよびリカバリする ###

1. NOARCHIVELOG モードでバックアップおよびリカバリを実行する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. RMAN で SQL を使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 15. RMANリカバリ・カタログの使用 ##

### RMAN リカバリ・カタログを作成および使用する ###

1. リカバリ・カタログを設定する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. リカバリ・カタログにターゲット・データベースを登録する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. 追加のバックアップ・ファイルをカタログ化する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. リカバリ・カタログを再同期させる

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. RMAN ストアド・スクリプトを使用およびメンテナンスする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. リカバリ・カタログをアップグレードおよび削除する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### RMAN リカバリ・カタログを保護する ###

1. リカバリ・カタログをバックアップする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. リカバリ不能なリカバリ・カタログを再作成する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. リカバリ・カタログをエクスポートおよびインポートする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 16. バックアップの実行 ##

### 完全および増分バックアップを実行する ###

1. 完全および増分バックアップを作成する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. Oracle 推奨のバックアップ計画を使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### バックアップを管理する ###

1. ブロック変更トラッキング・ファイルを設定および監視する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. LIST、REPORT コマンドを使用してバックアップに関してレポートする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. CROSSCHECK、DELETE コマンドを使用してバックアップを管理する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 17. RMAN 暗号化バックアップの使用 ##

### RMAN 暗号化バックアップを作成する ###

1. 透過モードの暗号化を使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. パスワード・モードの暗号化を使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. デュアル・モードの暗号化を使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. 暗号化バックアップをリストアする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 18. リストアおよびリカバリ操作の実行 ##

### インスタンス・リカバリを説明および調整する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 完全リカバリと不完全リカバリを実行する ###

1. RMAN の RESTORE お よび RECOVER コマンドを使用する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. ASM ディスク・グループをリストアする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. メディアの障害からリカバリする

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. RMAN を使用して完全リカバリと不完全リカバリまたはポイント・イン・タイム・リカバリを実行する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 19. Oracle Secure Backup の使用 ##

### Oracle Secure Backup を設定および使用する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 20. フラッシュバック・データベースの使用 ##

### フラッシュバック・データベースを実行する ###

1. フラッシュバック・データベースを構成する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. フラッシュバック・データベースを実行する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 21. データベースの複製 ##

### データベースを複製するための手法を選択する ###

1. ターゲットおよび補助インスタンスに接続された、アクティブ・データベースから

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. ターゲットおよび補助インスタンスに接続された、バックアップから

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. 補助インスタンスに接続され、ターゲットに接続されていないが、リカバリ・カタログに接続されたバックアップから

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. 補助インスタンスに接続され、ターゲットおよびリカバリ・カタログに接続されていないバックアップから

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

1. RMAN を使用してデータベースを複製する

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### バックアップ・ベースの複製データベースを作成する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 実行中のインスタンスに基づいてデータベースを複製する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 22. マルチテナント・コンテナ・データベースとプラガブル・データベースのアーキテクチャ ##

### マルチテナント・コンテナ・データベースのアーキテクチャを説明する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### プラガブル・データベースのプロビジョニングを説明する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 23. CDB と PDB の管理 ##

### CDB/PDB に対する接続を確立する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### CDB を起動および停止する、PDBを開く、閉じる ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### パラメータ値の変更の影響を評価する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 24. CDB と PDB でのセキュリティの管理 ##

### 共通ユーザーとローカル・ユーザーを管理する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 共通権限とローカル権限を管理する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 共通ロールとローカル・ロールを管理する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### 共通ユーザーが特定の PDB のデータにアクセスできるようにする ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## 25. パフォーマンスの管理 ##

### CDB と PDB で操作とパフォーマンスを監視する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### PDB 間および PDB 内でのリソースの割当てを管理する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

### データベース・リプレイを実行する ###

   ~~~sql
   insert into "TEST"."T"("ID","SAL") values ('2','300');
   ~~~

## その他、分類が難しいもの ##

1. バックアップ方法の機能比較
   | 機能 | Recovery Manager | ユーザー管理 | データ・ポンプ・エクスポート |
   | --- | --- | --- | --- |
   | クローズ状態のデータベース・バックアップ            | 〇 | 〇 | x |
   | オープン状態のデータベース・バックアップ            | 〇 | 〇 | x |
   | 増分バックアップ                                  | 〇 | x | x |
   | 破損ブロックの検出                                | 〇 | x | 〇 |
   | バックアップに含めるファイルの自動指定              | 〇 | x | x |
   | バックアップ・リポジトリ                           | 〇 | x | x |
   | メディア・マネージャへのバックアップ                | 〇 | 〇 | x |
   | 初期化パラメータ・ファイルのバックアップ            | 〇 | 〇 | x |
   | パスワードおよびネットワーク・ファイルのバックアップ | x | 〇 | x |
   | プラットフォームに依存しないバックアップ用言語       | 〇 | x | 〇 |

1. RMAN構成要素
   * RMANクライアント
   * ターゲット・データベース
   * リカバリ・カタログ・データベース
   * リカバリ・カタログ・スキーマ
   * フィジカル・スタンバイ・データベース
   * 高速リカバリ領域
   * メディア管理ソフトウェア
   * メディア管理カタログ
   * Oracle Enterprise Manager

参考資料：

[Oracle Databaseオンライン・ドキュメント 12c リリース1 (12.1)](https://docs.oracle.com/cd/E57425_01/121/index.htm)

[Databaseバックアップおよびリカバリ・リファレンス](https://docs.oracle.com/cd/E57425_01/121/RCMRF/toc.htm)

[Databaseバックアップおよびリカバリ・ユーザーズ・ガイド](https://docs.oracle.com/cd/E57425_01/121/BRADV/toc.htm)
