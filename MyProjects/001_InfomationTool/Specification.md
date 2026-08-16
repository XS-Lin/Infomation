# 情報収集用ツール #

RSS(Really Simple Syndication) ツール、登録したWebサイトの更新情報や新着記事を自動的に収集・一元化する。

## 要件 ##

- 登録したWebサイトの更新情報や新着記事を自動的に収集
  - qiita
  - zenn
  - 必要に応じて追加
- フィルタリング
  - タグで分類する
    - 技術
    - 趣味
    - ニュース
- 要約、保存
  - 気になった記事をブックマークとして保存
- 連携
  - SLACK

## 設計 ##

- RSS / atom
  - x
- LLM
  - Gemini
  - Gemma
- Storage
  - chromdb
  - postgres/pgvector
- [Slack Auto RSS App](https://api.slack.com/apps/A0BCSA5NBPG)

## テスト ##
