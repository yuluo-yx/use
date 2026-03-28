# CLAUDE.md

本仓库是开发环境配置集合，不再包含 Go 安装器、构建产物或模板渲染逻辑。

## 目录结构

```text
use/
├── git/       # Git 配置
├── zsh/       # zsh 主配置、模块脚本和主题
├── vim/       # Vim 配置
├── ghostty/   # Ghostty 配置
├── raycast/   # Raycast 脚本
├── claude/    # Claude Code 配置
├── codex/     # Codex 配置说明
└── mac/       # macOS 使用笔记
```

## 仓库约定

- 配置通过复制或软链手动应用，不再提供统一 CLI。
- 修改 README、子目录说明和配置内容时，保持与仓库现状一致，不要重新引入 Go 入口、模板变量或二进制文件。
- `git/.gitconfig` 不包含用户姓名和邮箱，需由使用者自行通过 `git config` 设置。

## 配置提示

- `zsh/.zshrc` 会加载 `~/.config/zsh/` 下的模块脚本。
- `zsh` 相关配置依赖 `oh-my-zsh`、`zsh-autosuggestions`、`zsh-syntax-highlighting`、`eza` 和 `fzf`。
- `vim/.vimrc` 使用 `vim-plug` 管理插件，当前不再包含 Go 专属插件。
- 图片资源只用于展示效果，不参与任何自动安装逻辑。
