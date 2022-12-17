# Git #

## cheat sheet ##

### シナリオ: 一般 ###

~~~bash
# 現在のブランチ確認
git branch

# ブランチ切り替え、新ブランチ作成
git switch -c feature/XXXXXX
git checkout -b feature/XXXXXX

# 差分確認
git diff

# 変更をステージング
git add <filename> 

# 状態確認
git status
git status -s

# 差分確認
git diff --cached

# コミット
git commit
git commit -m "[add] refs #XXXXXX new file"

# 差分確認
git diff HEAD^..HEAD

# サーバに反映
git push
~~~

### シナリオ: ローカルコミット取消 ###

~~~bash
git reset HEAD
git reset HEAD <file name>
~~~

~~~bash
git ls-remote origin HEAD
git log -1 HEAD
git log -1 origin/HEAD

git remote show origin # local out of date

# --soft ディレクトリの内容はそのままでコミットを消す
# --hard ディレクトリの内容を戻してコミットを消す
# HEAD^
# HEAD~{n}
git reset --soft HEAD^

git status

git restore --staged <file name>
~~~

### シナリオ: マージ ###

~~~bash
git status

git restore <file name> # 差分があれば

git merge <branch name>

git push
~~~
