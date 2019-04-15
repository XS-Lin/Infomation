# Oracle12c バックアップとリカバリ (ORACLE MASTER Gold Oracle Database 12c 1Z0-063対応) #

この記事は、オラクルデータベースが障害の時に、バックアップとリカバリの机上訓練を中心としています。
知識の詳細は以下の資料をご利用ください。

参考資料：

ORACLE MASTER Gold Oracle Database 12c資格(試験 1Z0-063)の[試験内容 チェックリスト](https://education.oracle.com/ja/oracle-database-12c-advanced-administration/pexam_1Z0-063)

[バックアップおよびリカバリ・ユーザーズ・ガイド](https://docs.oracle.com/cd/E82638_01/bradv/index.html)

[Oracle Databaseの概要](https://docs.oracle.com/cd/E82638_01/cncpt/introduction-to-oracle-database.html#GUID-A42A6EF0-20F8-4F4B-AFF7-09C100AE581E)

## DBAの介入が必要な障害種類 ##

* メディア障害
  
  データベースの実行に必要なディスク・ファイルの読取りまたは書込みの障害を発生させる、ディスクでの物理的な問題のことです。

* ユーザー・エラー

  誤りによって、データベース内のデータが誤って変更または削除によって、データがなくなることです。

* アプリケーション・エラー

  ソフトウェアの障害によってデータ・ブロックが破損のことです。

## メディア障害 ##

* データファイル
  * SYSTEM表領域
  * SYSAUX表領域
  * UNDO表領域
  * 一時表領域
* 制御ファイル
* オンラインREDOログ・ファイル

### Data Files ###

* データベースが完全消滅　=> 練習1
* データファイルすべて損失 => 練習2
* SYSTEM表領域故障 => 練習3
* SYSAUX表領域故障 => 練習4
* 一時表領域故障 => 練習5
* UNDO表領域故障  => 練習6
* ユーザ表領域故障 => 練習7
  * 読み取り専用表領域
  * Offline
  * ReadOnly
  * ReadWrite
  * インデックス専用表領域

### Control Files ###

* 部分損失 => 練習8
* すべて損失 => 練習9

### SP File ###

* SPファイル損失 => 練習10

### Online Redo Log ###

* ACTIVEグループ内一部損失 => 練習11
* ACTIVEグループまるごと損失
* CURRENTグループ内一部損失 => 練習12
* CURRENTグループまるごと損失
* INACTIVEグループ内一部損失 => 練習13
* INACTIVEグループまるごと損失

### Archived Redo Log ###

* アーカイブREDOログ・ファイル一部損失 => 練習14
* アーカイブREDOログ・ファイル全部損失

### Flashback Log ###

* フラッシュバック・ログ一部損失 => 練習15

## データロス ##

### Delete or update row ###

* UPDATE => 練習16
* DELETE

### Drop or alter table ###

* DROP TABLE => 練習17
* ALTER TABLE

## ロジック故障 ##

### Not recognize the block ###

* データブロック破損 => 練習18
