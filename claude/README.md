# Claude 配置

## 配置文件

```bash
mkdir -p ~/.claude
cp claude/settings.json ~/.claude/settings.json
cp claude/system-prompt.txt ~/.claude/system-prompt.txt
```

## Alias

`alias cc='claude --dangerously-skip-permissions`

## Raycast

- [raycast/cc.sh](../raycast/cl.sh) `cc` 脚本默认通过 Ghostty 登录 shell 并启动 Claude Code。
