# Claude Code 実践現場で使える自動化テクニック #

[Claude Code 実践自動化テクニック — サンプルコード集](github.com/forest6511/claude-code-automation-patterns)

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

## T11: Hooks の仕組みと17イベントを把握する ##

Hooksはセッション起動時にスナップショットとして取り込む。
セッション中にsettings.jsonを直接編集しても、変更はすぐ反映されない。
/hooksで確認が必要。
また、/hooksで追加・削除・確認をできる。

|exit code|意味|
|---|---|
|0|成功。stdoutのJSONを解析|
|2|ブロックエラー。stderrの内容がClaudeへのフィールドバックになる|
|その他|非ブロックエラー。verboseモード(Ctrl+O)でstderrを表示|

## T12: PreToolUseで危険コマンドをブロックする ##

Level1: シンプルな危険コマンドブロック

~~~bash
#!/bin/bash 
# block-dangerous.sh 

INPUT=$(cat) 
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty') 

# 危険なコマンドパターンを検出 

PATTERNS=( 
  "rm -rf /" 
  "rm -rf ~" 
  "git push --force" 
  "git push -f" 
  "chmod -R 777" 
  "DROP TABLE" 
  "> /dev/sda" 
) 
for pattern in "${PATTERNS[@]}"; do 
  if echo "$COMMAND" | grep -qF "$pattern"; then 
    echo "ブロック: '$pattern' は実行禁止コマンドです" >&2 
    exit 2 
  fi 
done 

exit 0
~~~

~~~json
{
  "hooks": {
    "PreToolUse": [ 
      { 
        "matcher": "Bash", 
        "hooks": [ 
          { 
            "type": "command", 
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous.sh" 
          } 
        ] 
      } 
    ] 
  } 
}
~~~

Level2: JSON形式での詳細制御(allow/deny/ask)

~~~bash
#!/bin/bash 
# block-with-json.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r 'tool_input.command // empty')

if echo "$COMMAND" | grep -qE "rm -rf|DROP TABLE"; then
  jq -n '{
    hookSpecificOutput {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "破壊的操作はブロックされています"
    }
  }'
  exit 0
fi

if echo "$COMMAND" | grep -qE "git push"; then
  jq -n '{
    hookSpecificOutput {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: "リモートへのプッシュは確認が必要です"
    }
  }'
  exit 0
fi
exit 0
~~~

- Alternative operator: //
  - 左側がfalseまたはnullの場合、右側を返す。
  - 左側がfalseまたはnull以外の場合、左側を返す。

Level3: ファイル操作のブロック（Edit/Writeへの適用）

~~~bash
#!/bin/bash 
# protect-files.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED=(
  ".env"
  ".env.local"
  "secrets/"
  "credential.json"
  ".git/"
)

for pattern in "${PROTECTED[@]}"; do
  if [[ "$FILE_PATH"==*"$pattern"* ]]; then
    echo "保護ファイルへの書き込みをブロック：$FILE_PATH">&2
    exit 2
  fi
done
exit 0
~~~

~~~json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous.sh"
          }
        ]
      },
      {
        "matcher":"Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
~~~

- 注意点
  - スクリプトに実行権限付与(chmod +x .claude/hooks/*.sh)
  - jqが必要
  - matcherは正規表現

## T14: Stopでセッション終了時の品質ゲートを設ける ##

基本パターン：未コミット変更の警告

~~~bash
#!/bin/bash
# quality-gate.sh
INPUT=$(cat)
# 無限ループ防止：stop_hookがすでに動作中なら終了
STOP_HOOK_ACTIVE=$(echo "$INPUT"|jq -r '.stop_hook_active')
if [ "$STOP_HOOK_ACTIVE"="true" ]; then
  exit 0
fi
ISSUES=()
# 未コミット変更チェック
UNCOMMITED=$(git diff --name-only 2>/dev/null)
STAGED=$(git diff --name-only --cached 2>/dev/null)
if [ -n "$UNCOMMITED" ] || [ -n "$STAGED" ]; then
  ISSUES+=("未コミットの変更があります")
fi
# TODO コミットの残数チェック
TODO_COUNT=$(grep -rn "TODO\|FIXME" src/ 2>/dev/null | wc -l | tr -d '')
if [ "$TODO_COUNT" -gt 0 ]; then
  ISSUES+=("TODO マーカーが${TODO_COUNT}件残っています")
fi
if [ ${#ISSUES[@]} -gt 0 ]; then
  jq -n --arg reason "$(printf'%s\n' "${ISSUES[@]}" | awk '{print NR"."$0}')" '"decision":"block", "reason":$reason}'
fi
~~~

~~~json
{
  "hooks": {
    "PreToolUse": [ 
      { 
        "matcher": "Bash", 
        "hooks": [ 
          { 
            "type": "command", 
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/quality-gate.sh" 
          } 
        ] 
      } 
    ] 
  } 
}
~~~

サイドエフェクトのみパターン（ブロックせず記録だけ）

~~~bash
#!/bin/bash
# session-logger.sh
INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT"|jq -r '.stop_hook_active')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

LOG_FILE=".claude/session-log.md"
DATE=$(date '+%Y-%m-%d %H:%M')
LAST_MSG=$(echo "$INPUT"|jq -r '.last_assistant_message'|head -c 200)

echo "## ${DATE}">>"$LOG_FILE"
echo "${LAST_MSG}...">>"$LOG_FILE"
echo "">>"$LOG_FILE"

exit 0
~~~

- 重要
  - Stop Hook はClaudeが応答を終えた直後に発火します。decision:"block"をJSONで返すと、Claudeは停止せずにreasonの内容を次の指示として受取、作業継続。stop_hook_active:true が返ってくる場合はすでにHookによって継続中のセッションなので、二度目のブロックは避けてください。この確認を怠るとClaudeが無限ループに陥る。

~~~txt
Claude応答終了
-> Stop Hook 発火(stop_hook_active:false)
-> issues 発見 -> decision: "block"
-> Claude が問題を修正して再応答
-> Stop Hook 再発火 (stop_hook_active:true)
-> 即 exit 0 (ループ停止)
~~~

- 注意点
  - last_assistant_message フィールドでClaudeの最終メッセージを取得できる。stop_hook_activeと合わせて、内容に応じた条件分岐も可能
  - Stop Hook は interrupt(Ctrl+C)では発火しない

## T15: SessionStartでセッション状態を復元する ##

~~~json
{
  "hooks": {
    "SessionStart": [ 
      { 
        "matcher": "compact", 
        "hooks": [ 
          { 
            "type": "command", 
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/restore-context.sh" 
          } 
        ]
      } 
    ]
  }
}
~~~

~~~bash
#!/bin/bash 
# restore-context.sh 
# 圧縮後のセッション用コンテキスト注入
BRANCH=$(git branch --show-current 2>/dev/null)
RECENT=$(git log --oneline -3 2>/dev/null)
UNCOMMITTED=$(git status --short 2>/dev/null | head -10)
SESSION_STATE=".claude/session-state.md"

echo "## 復元されたセッションコンテキスト"
echo ""
echo "### ブランチ：${BRANCH}"
echo ""
echo "### 直近のコミット"
echo "$RECENT"
echo ""

if [ -n "$UNCOMMITTED" ]; then
  echo "### 未コミットの変更"
  echo "$UNCOMMITTED"
  echo ""
fi

# 前回セッションの保存状態があれば追記
if [ -f "$SESSION_STATE" ]; then
  echo "### 前回セッション状態"
  echo "$SESSION_STATE"
fi
~~~

~~~bash
#!/bin/bash
# session-init.sh
INPUT=$(cat)
SOURCE=$(echo "$INPUT"|jq -r '.source')

case "$SOURCE" in
  startup)
    echo "## 新規セッション開始"
    echo "プロジェクト: $(basename $PWD)"
    echo "ブランチ: $(git branch --show-current 2>/dev/null)"
    ;;
  compact)
    echo "## コンテキスト圧縮後の復元"
    cat .claude/session-state.md 2>/dev/null || \
      echo "セッション状態ファイルがありません"
    ;;
  resume)
    echo "## セッション再開"
    echo "前回の作業を継続します"
    ;;
esac
exit 0
~~~

- 動作説明
  - SessionStart Hook の stdout は通常の Hook と異なり、Claudeのコンテキストに直接追加(verboseモードではなくても有効)
  - async:false がデフォルトの挙動で、Hook完了までClaudeの処理を待機。起動時の状態復元には同期実行が適切
- 注意点
  - stdoutの内容はClaudeが読むテキストになる。
  - SessionStart は exit 2 を返してもブロックできない。
  - ファイル注入との使い分け

## T16: PreCompactで圧縮前にセッション状態を保存する ##

- 注意点
  - session-state.mdは.gitignoreに追加
  - PreCompact Hook の custom_instructions フィールドには /compact で渡した内容が入る。

## T19: prompt HooksでLLM判断をイベントに組み込む ##

- 動作説明
  1. イベント発火
  1. Claude Codeが$ARGUMENTSをHooks入力JSONで置換
  1. 展開されてプロンプトをClaudeモデル（デフォルト：高速モデル）に送信
  1. モデルが{"ok":true/false, "reason":"..."}を返す
  1. ok:false の場合、reasonがClaudeへのフィードバックになる
  1. ok:true の場合、通常通り処理が続く

- 注意点
  - prompt Hooks は追加のトークンを消費
  - デフォルトタイムアウトは30秒
  - stop_hook_active:true の場合でも prompt Hooks は呼ばれる

## T22: Hooks のデバックとトラブルシューティングを行う ##

- Step1: verboseモードでHookの実行を確認
  - Ctrl+O
- Step2: スクリプトをローカルで直接テストする
- Step3: よくあるエラーと対処法
  - Hook が発火しない
    - 実行権限がない
    - matcher が一致しない
    - stdoutに余分なテキストがある
  - 無限ループになる
    - stop_hook_active チェック漏れ
  - 設定変更が反映されない
    - スナップショットが古い
  - jq:not found
    - jqがインストールされていない
- Step4: JSON出力の検証

~~~bash
#!/bin/bash
# debug-hook.sh
INPUT=$(cat)
echo "===$(date)===">>/tmp/claude-hook-debug.log
echo "EVENT:$(echo "$INPUT"|jq -r '.hook_event_name')">>/tmp/claude-hook-debug.log
echo "INPUT:">>/tmp/claude-hook-debug.log
echo "$INPUT"|jq '.'>>/tmp/claude-hook-debug.log
echo "">>/tmp/claude-hook-debug.log

exit 0
~~~

## T23: 組み込みSub-agent（Explore/Plan/General-purpose）を理解する ##

[カスタムサブエージェントの作成](https://code.claude.com/docs/ja/sub-agents#other)

## T25: Agentの合理化行動を封殺する ##

|合理化|実際の意味|取るべき行動|
|---|---|---|
|ファイルが大きすぎます|読むのが面倒|必要な範囲だけReadで読む|
|テストが複雑です|テスト修正が手間|テストを先に修正してから実装する|
|既存コードと互換性がありません|変更に自信がない|変更を加えて互換性問題を別途報告する|
|スコープ外の変更が必要です|追加作業を避けたい|指示範囲を実行し、追加作業を明示する|
|副作用が心配です|変更を避けたい|変更を最小化し、副作用を文書化する|
|ドキュメントが不足しています|不確かなので進めたくない|利用可能な情報で判断して進める|
|別の方法のほうが優れています|指示を変えたい|指示通り実行し、代替案を末尾に提案する|
|時間がかかりすぎます|途中で締めたい|段階的に進め、完了した部分を報告する|
|エラーが発生しました|中断を正当化したい|エラーを分析し、解決策を試みてから報告する|
|フォーマットが不明確です|開始を先送りしたい|最も合理的な解釈で進め、仮定を明示する|
|品質が落ちる可能性があります|指示に従いたくない|指示通り実行し、品質懸念を最後に報告する|
|承認が必要なはずです|権限移譲を避けたい|自分の権限範囲で実行し、必要なら確認する|

## T50: Strategic Compact でコンテキストを戦略的に圧縮する ##

- compactの実行タイミングの目安
  - ファイル大量読み取り後
    - 10ファイル以上読み取った後
  - 長時間の実装作業後
    - 50ツール呼出しを超えたあたり
  - フェーズ切り替え時
    - 実行完了->レビュー開始のタイミング
  - コンテキスト使用率確認後
    - /contextで80%を超えた場合

- 注意点
  - compactは不可逆的な操作。圧縮前の復元はできない。別途記録しておくことを推奨。

## T55: /contextコマンドで消費量をモニタリング ##

|使用率|推奨アクション|
|---|---|
|0-50%|通常通り作業を継続|
|50-80%|近いうちに/compactを実行する準備|
|80-90%|/compactを実行してコンテキスト圧縮|
|90%以上|即座に/compactを実行、または新セッションを開始|

## T57: 7ステージ開発ワークフローを構築する ##

- Brainstorming
  - 要件整理・スコープ確定
  - /brainstorm
- Worktree
  - 作業ブランチ・隔離環境
  - git worktree add
- Plan
  - 設計・実装前チェック
  - /plan,/confidence-check
- Subagent
  - 並列実装・調査移譲
  - Taskツール
- TDD
  - テスト駆動実装
  - /tdd
- Review
  - コードレビュー・品質検証
  - /review
- Completion
  - コミット・クリーンアップ
  - /session-end

## T58: /orchestrateコマンドで4種ワークフローを切り替える ##

[orchestrate Skill](https://github.com/forest6511/claude-code-automation-patterns/blob/main/part7-workflows/skills/orchestrate/SKILL.md)

|種別|起点|最重要チェック|完了条件|
|---|---|---|---|
|feature|要件定義|設計レビュー|AC全通過|
|bugfix|再現確認|根本原因特定|回帰テスト追加|
|refactor|既存テスト|挙動不変確認|カバレッジ維持|
|security|影響範囲調査|脆弱性検証|CVEクローズ|

- 使用例
  - /orchestrate feature ユーザ認証追加
