# Claude 配置

## 配置文件

```bash
mkdir -p ~/.claude
cp claude/settings.json ~/.claude/settings.json
cp claude/system-prompt.txt ~/.claude/system-prompt.txt
```

## Alias

`alias cl='claude --dangerously-skip-permissions --append-system-prompt "$(cat ~/.claude/system-prompt.txt)"'`

## Raycast

- [raycast/cl.sh](../raycast/cl.sh) 使用与 alias 相同的 `~/.claude/system-prompt.txt` 路径。
- `cl` 脚本默认通过 Ghostty 以登录 shell 方式启动 Claude Code。
