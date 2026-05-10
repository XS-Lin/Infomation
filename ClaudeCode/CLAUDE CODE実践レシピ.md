# CLAUDE CODE実践レシピ:SKILLSxMCPxSUB-AGENTSで開発を10倍加速する #

## 初期化 ##

~~~powershell
irm https://claude.ai/install.ps1 | iex
claude --version
# PATH 追加
$env:Path = [System.Environment]::GetEnvironment("Path","User")+";"
~~~
