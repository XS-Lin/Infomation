# Claude Code 実践レシピ100本 #

[Claude Code 実践レシピ100本](https://github.com/forest6511/claude-code-recipes-v2)

## 1 CALUDE.md & 設定の最適化 ##

- /memoryで編集、ロード状況検証
- CLAUDE.md はWHY・WHAT・HOWで記載
- Hooksは決定論的な実行保証、CLAUDE.mdは助言
- @importでrule分割
- /initコマンドで初期作成
- 一部md除外
  - settings.local.json に claudeMdExcludes
- ブロックレベルコメントでメンテナーメモ
  - <!-- ルール変更 -->
  - コンテキスト注入の時に除外される
- glob記法は使える
- .claude/rules 以下のmdファイルは再帰的に発見される
- InstructionLoaded Hookで発火状況を検証
- working directoryでロード範囲を制御する
- スコープ優先順位
  - Managed > CLI引数 > Local > project > User
- /config /status で現在の設定確認
- 6つのpermission mode
  - default
  - acceptEdits
    - ファイル編集は自動承認
  - plan
    - Read only
  - auto
    - バックグラウンドの安全性付き自動承認
  - dontAsk
    - 事前許可されたツール以外は自動拒否
  - bypassPermissions
    - 確認プロンプトを全スキップ
- パスパターン
  - 絶対パス
  - ホーム ~
  - プロジェクト相対 「/」1個
  - カレントディレクトリ相対
  - Windows
    - C:\users\x は /c/Users/x に正規化され、全ドライブ横断は //**/.env
- allow / ask / deny

## 2 コンテキスト管理 & コスト最適化 ##

- /contextで監視
- /compact + PostConpact Hooks で圧縮後ログ出力等
- /model で切り替え、/statusで現状確認
- 軌道修正と巻き戻し
  - Escで即停止、コンテキスト維持
  - Esc2回または/rewindで会話・コード・両方のどれを戻すかを選ぶ
- CLIツールをMCPサーバに優先
- /cost で、APIキーの場合は推定金額、サブスクリプションの場合は使用量比を表示
- /usage で、プラン使用枠とレート制限確認
- /stats で使用状況確認
- Remote Controlでリモート確認可
- claude -c 直前セッション再開、claude --resume で特定セッション再開
- claude -n "session_name"

## 3 GitHub & Web 検索連携 ##

- レビュー観点をまとめる REVIEW.md 作成
- Git操作について、安全ものを許可、情報損失リスクがあるものを拒否

~~~json
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git branch:*)",
      "Bash(git checkout:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git pull:*)",
      "Bash(gh pr view:*)",
      "Bash(gh pr create:*)"
    ],
    "deny": [
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(git reset --hard:*)",
      "Bash(git clean -fd:*)",
      "Bash(git branch -D:*)",
      "Bash(git checkout --:*)"
    ]
  }
}
~~~

## 7 Skills設計と基本 ##

- Skills の価値は名前よりdescriptionとwhen_to_useの品質できまる
- disable-model-invocation:true 明確に実行する（モデルの自動実行を禁止）
- user-invocable:false Claude Codeだけ参照用（ユーザから利用不可）
- Windowsについて、CLAUDE_CODE_USE_POWERSHELL_TOOL=1で!`command`をPowershellで評価できる
- 引数について
  - $ARGUMENTS で全引数
  - $0 で位置引数
  - $name で名前付き引数
  - ${CLAUDE_SESSION_ID},${CLAUDE_SKILL_DIR} でセッション引数
  - !`command` で外部コマンド、Skill読み込み時に実行される前処理（プロンプト送出前）
- context
  - fork
- agent
  - Explore
  - Plan
  - general-purpose (default)

## 10 サブエージェントの基礎と設計 ##

- agent
  - Explore
    - Read Only + Haiku
  - Plan
    - Read Only + メイン会話モデル継承
  - general-purpose (default)
    - 全ツール + メイン会話モデル継承
- flowchart
  - タスクの性質
    - 単発の調査/検索のみ
      - トークン量が多い（大規模grep/長いログ） -> Explore
      - 推論制度必要（設計レビュー/依存分析） -> Plan(planモード経由)
    - 探索 + 編集 + コマンドじっくが混在
      - 標準ケース -> genaral-purpose
      - 現在の会話を引き継ぎたい -> fork(CLAUDE_CODE_FORK_SUBAGENT=1)
    - 同じパターンを繰り返している -> カスタムサブエージェント

## 12 Agent Teams && 設計パターン ##

- デフォルトで無効、環境変数 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

~~~json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS":"1"
  },
  "teammateMode": "in-process"
}
~~~

- prompt はリーダーに伝える
- チームメート直接操作(in-process)
  - Shift+Down: 次に切り替え
  - Enter: そのチームメートのセッションに入り出力を読む
  - Excape: 現在のターンを中断
  - Ctrl+T: 共有タスクリスト表示
- クリックで操作(split panes)
