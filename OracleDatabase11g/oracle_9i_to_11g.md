# Oracle9i から 11g へ移行メモ #

## 対象 ##

移行元:Oracle 9i

* host os = solaris 10
* database version = 9.2.0.5.0
* client version = 9.2.0.1.0

移行先:Oracle 11gR2

* host os = redhat linux 7.5
* database version = 11.2.0.1.0
* client version = 12.1.0.2.0

## 方式 ##

オリジナルのエクスポート/インポート・ユーティリティ(exp/imp)使用

* 理由
   1. Oracleのバージョン差によって、直接アップグレード不能
   1. OS変更あり

## 手順 ##

1. Oracle Databaseをアップグレードするための準備

   1. 現行DB情報収集 (info_all.sql)

   1. 新データベース計画(容量、配置先等)

   1. 試験データ取得のためexp実施

1. Oracle Databaseのアップグレード処理のテスト

   1. 試験環境構築

   1. 試験環境にimp実施

   1. impエラー等処置

1. アップグレードしたテスト用Oracle Databaseのテスト

   1. 情報取得し、現行と比較

   1. 現行アプリケーションテストDBに接続し、正常実行できる確認

   1. 問題処置し、本番用手順作成

1. 新しい本番Oracle Databaseのチューニングおよび調整

   1. 本番環境構築

   1. 本番環境にデータ投入

   1. チューニング