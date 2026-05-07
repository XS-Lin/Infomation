# Claude Code 実践現場で使える自動化テクニック #

## T04: Skills の description トラップを回避する ##

disable-model-invocation:true は副作用のあるSkillsに必須、自動Skill実行を防ぐため。

- descriptionに書くべき内容
  - トリガー条件
  - 自然な言葉のキーワード
  - 自動実行の有無
- descriptionに書いてはいけない内容
  - 手順のステップ
    - 本文を読まずに実行される
  - コマンドの具体例
    - 本文の内容が無視される
  - 詳細な説明
    - コンテキストを無駄に消費する

## T05: Claude Search Optimization でSkills発見率を上げる ##

Skillsが除外されていないかを確認する方法: /context

## T06: invocation制御で「誰が呼ぶか」を設計する ##

|フロントマター設定|ユーザが/nameで呼べる|Claudeが自動呼出しできる|descriptionの扱い|
|---|---|---|---|
|(デフォルト)                  |Yes|Yes|常にコンテキストに含まれる|
|disable-model-invocation:true|Yes|No |コンテキストに含まれない|
|user-invocable:false         |No |Yes|常にコンテキストに含まれる|

実践的な使い分けの判断基準:
Yes -> disable-model-invocation:true
No  -> 続けて確認
ユーザーが/nameで直接呼ぶ意味がある？
No  -> user-invocable:false
Yes -> デフォルト(両方可)

## T07: SkillsをSubagentとして実行する ##

context:forkでSkillsをSubagentとして実行すると、Skillsは独立したコンテキストで動作し、結果のみがメインセッションに返す

- agentフィールドで実行するSubagent
  - Explore
    - 読み取り専用ツール、コードベース探索に最適化
    - セキュリティ監査、コード分析
  - Plan
    - 計画立案に特化、変更を加えない
    - 実装計画の作成、設計検討
  - general-purpose
    - すべてのツールにアクセス可能
    - 汎用タスク
  - カスタム名
    - .claude/
    - プロジェクト固有の専門Skills

## T08: Skillsに動的コンテキストを注入する ##

~~~txt

## 現在のブランチ情報 
- ブランチ: !`git branch --show-current` 
- ベースブランチからの差分: !`git diff origin/main --stat` 
- コミット履歴: !`git log origin/main..HEAD --oneline` 
- 未コミット変更: !`git diff --stat` 

## 環境情報
- 現在のディレクトリ: !`pwd` 
- 環境変数: !`env | grep NODE_ENV`
~~~

## T09: Compact Instructionsでコンテキスト圧縮を制御する ##

|手段|タイミング|保持方法|
|---|---|---|
|Compact Instructions|圧縮処理中|圧縮後の要約に含める|
|PreCompact Hook|圧縮前|外部ファイルに保存(圧縮とは独立)|

- 注意点
  - Compact InstructionsはCLAUDE.mdの末尾に書くのが推奨
  - PreCompact Hookのmatcher:"manual"を使うと、/compactコマンド実行時のみHookが発動
  - セッション状態ファイルは.gitignoreに追加

## T10: プロジェクト別CLAUDE.mdテンプレートを整備する ##

Page 64 of 286
