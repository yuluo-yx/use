# Raycast Script 合集

这些脚本默认通过 Ghostty 打开登录 shell，并交给 Raycast 的 Script Commands 使用。

## 脚本说明

- `cl.sh`：启动 Claude Code，读取 `~/.claude/system-prompt.txt`。
- `codex.sh`：启动 Codex。
- `ssh.sh`：SSH 模板脚本，使用前需要把 `user@host` 改成你自己的目标主机。

## 使用前提

- 已安装 Ghostty。
- Raycast 已开启 Script Commands。
- `cl.sh` 依赖本地存在 `~/.claude/system-prompt.txt`。
