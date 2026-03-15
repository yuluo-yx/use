# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

开发环境配置仓库，用于管理 Mac/Linux 开发环境。核心是一个 Go 程序（main.go），使用 embed 将配置文件嵌入二进制中。

## 核心结构

```
use/
├── main.go               # 安装程序源码
├── bin/use               # 编译后的二进制
├── zsh/                  # zsh 配置（embed 嵌入）
├── vim/                  # vim 配置（embed 嵌入）
├── git/.gitconfig        # git 配置模板
└── claude/               # Claude Code 配置
```

## 构建与运行

```bash
# 构建
go build -o bin/use main.go

# 安装所有配置
./bin/use --all

# 安装指定模块
./bin/use --zsh --git --vim

# 预览模式（不实际执行）
./bin/use --all --dry-run

# 强制覆盖已存在文件
./bin/use --all -f

# 配置 git 并指定用户信息
./bin/use --git --git-name "YourName" --git-email "your@email.com"

# 安装语言版本管理器
./bin/use --gvm    # Go
./bin/use --java   # Java (SDKMAN)
./bin/use --rust   # Rust
```

## 架构说明

### 安装流程

main.go 定义了安装流程：检查工具 → 安装缺失工具 → 应用配置。

**工具安装方式**：
- 包管理器：git, zsh, thefuck
- 脚本安装：oh-my-zsh, gvm, sdkman, rustup
- 二进制下载：fzf, bat, eza（从 GitHub releases 下载）

**配置文件处理**：
- 使用 `//go:embed` 嵌入配置文件
- `envs.zsh` 和 `.gitconfig` 使用 Go 模板，根据参数动态生成

### zsh 配置

- 依赖 oh-my-zsh 框架
- 插件：z, eza, extract, thefuck, zsh-autosuggestions, zsh-syntax-highlighting
- 遇到 `unknown option --zsh` 错误时需升级 fzf

### 配置文件位置

安装后配置位于：
- `~/.zshrc` - zsh 主配置
- `~/.${USER}_env/zsh/` - zsh 模块化配置（aliases.zsh, envs.zsh, function.zsh, fzf.zsh）
- `~/.gitconfig` - git 配置
- `~/.vimrc` - vim 配置

## 常用别名

```bash
cl='claude --dangerously-skip-permissions'  # Claude
ff='fzf --preview "bat --color=always {}"'  # 带预览的模糊搜索
k='kubectl'                                  # kubectl 缩写
ls='eza'                                     # 替代 ls
```

## Linux 注意事项

- 安装需要 sudo 权限
- eza 在 CentOS 上不支持 yum 直接安装
- 安装前确保系统已换源
