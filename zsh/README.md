# Zsh 配置与安装指南

本目录保存 macOS 使用的通用 Zsh 配置。配置基于 Oh My Zsh，命令行工具优先由 mise 管理。mise 无法管理的组件使用 Homebrew 或项目官方安装方式。

## 目录结构

```text
zsh/
├── .zshenv                  # 所有 Zsh 进程使用的基础环境变量
├── .zshrc                   # 交互式 Shell 与插件加载入口
└── config/
    ├── aliases.zsh          # 命令别名
    ├── functions.zsh        # Ghostty、Yazi、日志与代理函数
    ├── fzf.zsh              # fzf 搜索与快捷键
    └── toolchains.zsh       # 可公开的工具链环境变量
```

`.zshenv` 只设置所有 Zsh 进程都需要的变量。mise、Typo、fzf 和 Oh My Zsh 等交互功能统一在 `.zshrc` 中加载，避免影响非交互脚本。

## 安装基础组件

### 安装 Homebrew 软件

Zsh、Git 和 mise 使用 Homebrew 安装：

```shell
brew install zsh git mise
```

`mk` 别名依赖 `make`。macOS 可通过 Xcode Command Line Tools 安装：

```shell
xcode-select --install
```

Ghostty 标题钩子会把当前目录显示在标签页标题中。Ghostty 使用 Homebrew Cask 安装：

```shell
brew install --cask ghostty
```

### 使用 mise 安装命令行工具

以下工具都在 mise registry 中。一个命令即可安装并写入全局配置：

```shell
mise use --global \
  bat@latest \
  claude@latest \
  eza@latest \
  fastfetch@latest \
  fd@latest \
  fzf@latest \
  kubectl@latest \
  python@latest \
  ripgrep@latest \
  yazi@latest
```

| 工具 | 命令 | 配置用途 |
| --- | --- | --- |
| bat | `bat` | 为 fzf 提供带行号和语法高亮的文件预览 |
| Claude Code | `claude` | 提供 `cc` 别名 |
| eza | `eza` | 提供 `ls`、`ll`、`la` 和 `tree` 别名 |
| fastfetch | `fastfetch` | 提供 `sf` 系统信息别名 |
| fd | `fd` | 为 fzf 提供快速文件检索 |
| fzf | `fzf` | 提供历史、文件和分支模糊搜索 |
| kubectl | `kubectl` | 提供 `k`、`kg`、`ka` 等别名 |
| Python | `python3`、`pip3` | 提供 `py`、`pi` 和虚拟环境操作 |
| ripgrep | `rg` | 替代交互式 Shell 中的 `grep` |
| Yazi | `yazi` | 提供退出后保留目录位置的 `y` 函数 |

Typo 不在 mise 的简写 registry 中，但提供标准 GitHub Release。使用 GitHub backend 安装：

```shell
mise use --global 'ubi:yuluo-yx/typo[exe=typo]'
```

如需使用 `toolchains.zsh` 中的开发工具链变量，可继续交给 mise 管理：

```shell
mise use --global \
  bun@latest \
  flutter@latest \
  go@latest \
  java@temurin-21 \
  rust@latest
```

### 安装容器运行时

`d` 别名和 Docker 命令需要容器运行时。macOS 使用 OrbStack：

```shell
brew install --cask orbstack
```

OrbStack 启动后会提供 `docker` 命令和 Docker API。

## 安装 Oh My Zsh 与插件

### 安装 Oh My Zsh

使用 Oh My Zsh 官方安装脚本：

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

配置使用以下 Oh My Zsh 内置插件，无需额外安装：

- `z`：按历史访问频率快速跳转目录。
- `web-search`：从终端调用搜索引擎。
- `copypath`：复制当前路径。
- `copybuffer`：复制当前命令行缓冲区。
- `eza`：加载 eza 补全与别名支持。
- `extract`：统一解压常见压缩格式。

### 安装第三方插件

自动建议和语法高亮插件使用 Git 安装到 Oh My Zsh 自定义插件目录：

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
```

`.zshrc` 会在所有自定义 ZLE 组件加载后再加载语法高亮，确保它最后注册钩子。

## 同步配置

在 `use` 仓库根目录执行：

```shell
mkdir -p "$HOME/.config/zsh"
cp zsh/.zshenv "$HOME/.zshenv"
cp zsh/.zshrc "$HOME/.zshrc"
cp zsh/config/aliases.zsh "$HOME/.config/zsh/aliases.zsh"
cp zsh/config/functions.zsh "$HOME/.config/zsh/functions.zsh"
cp zsh/config/fzf.zsh "$HOME/.config/zsh/fzf.zsh"
cp zsh/config/toolchains.zsh "$HOME/.config/zsh/toolchains.zsh"
```

同步命令不会修改以下本地文件：

- `~/.config/zsh/custom_vars.zsh`
- `~/.config/zsh/custom_vars.local.zsh`
- `~/.config/zsh/blog_algoia.zsh`
- `~/.config/zsh/wine.zsh`

私有凭据使用三行区块注释保存在 `custom_vars.zsh` 或 `custom_vars.local.zsh`：

```zsh
############################
# Private Credentials
############################
export SERVICE_API_KEY="replace-with-your-value"
```

建议将私有变量文件设置为仅当前用户可读：

```shell
chmod 600 "$HOME/.config/zsh/custom_vars.zsh"
chmod 600 "$HOME/.config/zsh/custom_vars.local.zsh"
```

## 快捷键与常用命令

- `Ctrl-R`：使用 fzf 搜索历史命令。
- `Ctrl-T`：使用 fzf 搜索文件，包括隐藏文件。
- `Ctrl-F`：使用 fzf 搜索文件，不包括隐藏文件。
- `ff`：选择文件并使用 bat 预览。
- `gco`：模糊选择并切换 Git 分支。
- `sv`：激活当前目录的 `.venv` Python 虚拟环境。
- `proxy`、`noproxy`：启用或关闭本地代理变量。

## 验证配置

先执行静态语法检查：

```shell
zsh -n zsh/.zshenv zsh/.zshrc zsh/config/*.zsh
```

完成同步后，启动新的登录 Shell：

```shell
exec zsh -l
```

检查关键命令：

```shell
command -v mise typo fzf fd bat eza rg yazi
echo "$EDITOR"
```

`EDITOR` 和 `VISUAL` 使用 macOS 自带的 `vim`。

## 参考资料

- [mise 安装与工具管理](https://mise.jdx.dev/getting-started.html)
- [mise registry](https://mise.jdx.dev/registry)
- [Oh My Zsh 官方安装说明](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Oh My Zsh 插件列表](https://github.com/ohmyzsh/ohmyzsh/wiki/plugins)
- [zsh-autosuggestions 安装说明](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
- [zsh-syntax-highlighting 安装说明](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)
- [Ghostty Homebrew Cask](https://formulae.brew.sh/cask/ghostty)
- [OrbStack Homebrew Cask](https://formulae.brew.sh/cask/orbstack)
- [Typo Releases](https://github.com/yuluo-yx/typo/releases)
