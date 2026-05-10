# Claude Code #

## 設定 ##

- 機密情報禁止

~~~json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  },
}
~~~

## メモ ##

[Skills](https://github.com/anthropics/skills)

[claude-code](https://github.com/anthropics/claude-code)

[claude-cookbooks](https://github.com/anthropics/claude-cookbooks)

[claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python)
