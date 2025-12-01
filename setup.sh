#!/bin/bash

# 一键配置 vim 和 zsh 的脚本
# 支持 macOS、Ubuntu、CentOS、Arch Linux
# 作者: Shown
# 日期: 2025-11-16

echo "开始配置 vim 和 zsh..."

# 获取当前脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME=$(whoami)

echo "脚本目录: $SCRIPT_DIR"
echo "当前用户: $USER_NAME"

# 检测操作系统类型
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command -v apt-get &> /dev/null; then
        echo "ubuntu"
    elif command -v yum &> /dev/null; then
        echo "centos"
    elif command -v pacman &> /dev/null; then
        echo "arch"
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)
echo "检测到的操作系统: $OS_TYPE"

# 根据不同操作系统安装软件包
install_package() {
    local package_name=$1
    case $OS_TYPE in
        "macos")
            if command -v brew &> /dev/null; then
                brew install $package_name
            else
                echo "请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
            ;;
        "ubuntu")
            sudo apt-get update && sudo apt-get install -y $package_name
            ;;
        "centos")
            sudo yum install -y $package_name
            ;;
        "arch")
            sudo pacman -S --noconfirm $package_name
            ;;
        *)
            echo "未知的操作系统，无法自动安装 $package_name"
            return 1
            ;;
    esac
}

# 检查并安装 git（如果未安装）
if ! command -v git &> /dev/null; then
    echo "未找到 git 命令，正在尝试安装..."
    if ! install_package git; then
        echo "git 安装失败，请手动安装 git"
        echo "macOS: brew install git 或从 https://git-scm.com/downloads 下载"
        echo "Ubuntu: sudo apt-get install git"
        echo "CentOS: sudo yum install git"
        echo "Arch Linux: sudo pacman -S git"
        exit 1
    fi
    echo "git 安装完成"
else
    echo "git 已安装"
fi

# 检查并安装 curl（如果未安装）
if ! command -v curl &> /dev/null; then
    echo "未找到 curl 命令，正在尝试安装..."
    if ! install_package curl; then
        echo "curl 安装失败，请手动安装 curl"
        echo "macOS: brew install curl"
        echo "Ubuntu: sudo apt-get install curl"
        echo "CentOS: sudo yum install curl"
        echo "Arch Linux: sudo pacman -S curl"
        exit 1
    fi
    echo "curl 安装完成"
else
    echo "curl 已安装"
fi

# 检查并安装 zsh（如果未安装）
if ! command -v zsh &> /dev/null; then
    echo "未找到 zsh 命令，正在尝试安装..."
    if ! install_package zsh; then
        echo "zsh 安装失败，请手动安装 zsh"
        echo "macOS: brew install zsh"
        echo "Ubuntu: sudo apt-get install zsh"
        echo "CentOS: sudo yum install zsh"
        echo "Arch Linux: sudo pacman -S zsh"
        exit 1
    fi
    echo "zsh 安装完成"
else
    echo "zsh 已安装"
fi

# 检查是否已安装 oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "正在安装 oh-my-zsh..."
    # 使用官方安装脚本安装 oh-my-zsh
    # 尝试多种方法安装
    INSTALL_SUCCESS=false

    # 方法1: 直接管道安装
    if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended; then
        INSTALL_SUCCESS=true
    fi

    # 如果方法1失败，尝试方法2: 下载后执行
    if [ "$INSTALL_SUCCESS" = false ]; then
        echo "尝试方法2安装..."
        if curl -fsSL -o /tmp/ohmyzsh-install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && bash /tmp/ohmyzsh-install.sh --unattended; then
            INSTALL_SUCCESS=true
            rm -f /tmp/ohmyzsh-install.sh
        fi
    fi

    # 如果方法2也失败，尝试方法3: 使用不同的SSL选项
    if [ "$INSTALL_SUCCESS" = false ]; then
        echo "尝试方法3安装..."
        if curl --tlsv1.2 -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended; then
            INSTALL_SUCCESS=true
        fi
    fi

    if [ "$INSTALL_SUCCESS" = false ]; then
        echo "oh-my-zsh 安装失败，请手动安装"
        echo "可以尝试手动运行以下命令:"
        echo "  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash"
        echo "或者访问 https://github.com/ohmyzsh/ohmyzsh 获取安装说明"
        # 不退出，继续执行其他步骤
    else
        echo "oh-my-zsh 安装完成"
    fi
else
    echo "oh-my-zsh 已安装"
fi

# 检查并安装 thefuck
if ! command -v thefuck &> /dev/null; then
    echo "未找到 thefuck 命令，正在尝试安装..."
    if ! install_package thefuck; then
        echo "thefuck 安装失败，请手动安装 thefuck"
        echo "macOS: brew install thefuck 或从 https://github.com/nvbn/thefuck 下载"
        echo "Ubuntu: sudo apt-get install thefuck"
        echo "CentOS: sudo yum install thefuck"
        echo "Arch Linux: sudo pacman -S thefuck"
        exit 1
    fi
    echo "thefuck 安装完成"
else
    echo "thefuck 已安装"
fi

# 检查并安装 zsh-syntax-highlighting 插件
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "正在安装 zsh-syntax-highlighting 插件..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || {
        echo "zsh-syntax-highlighting 插件安装失败"
        echo "可以稍后手动安装:"
        echo "  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    }
else
    echo "zsh-syntax-highlighting 插件已安装"
fi

# 检查并安装 zsh-autosuggestions 插件
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "正在安装 zsh-autosuggestions 插件..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || {
        echo "zsh-autosuggestions 插件安装失败"
        echo "可以稍后手动安装:"
        echo "  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    }
else
    echo "zsh-autosuggestions 插件已安装"
fi

# 创建必要的目录结构
echo "创建目录结构..."
mkdir -p ~/.${USER_NAME}_env/zsh/config
mkdir -p ~/.${USER_NAME}_env/zsh/theme

# 复制 zsh 配置文件
echo "复制 zsh 配置文件..."
cp -r "$SCRIPT_DIR/zsh/config/"* ~/.${USER_NAME}_env/zsh/config/ 2>/dev/null || true

# 复制 zsh 主题文件到 oh-my-zsh 标准主题目录
echo "复制 zsh 主题文件..."
# 首先检查项目中是否有 theme 目录（单数形式）
if [ -d "$SCRIPT_DIR/zsh/theme" ]; then
    cp -r "$SCRIPT_DIR/zsh/theme/"* ~/.oh-my-zsh/themes/ 2>/dev/null || true
    echo "从项目复制主题文件到 oh-my-zsh"
else
    # 如果项目中没有主题目录，从 oh-my-zsh 中复制 ys 主题
    if [ -f "$HOME/.oh-my-zsh/themes/ys.zsh-theme" ]; then
        echo "使用 oh-my-zsh 默认的 ys 主题"
    fi
fi

# 复制 .zshrc 文件
echo "配置 .zshrc 文件..."
if [ -f ~/.zshrc ]; then
    echo "备份现有的 .zshrc 文件为 ~/.zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup
fi

cp "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc

# 配置 vim
echo "配置 vim..."

# 检查并安装 vim（如果未安装）
if ! command -v vim &> /dev/null; then
    echo "未找到 vim 命令，正在尝试安装..."
    if ! install_package vim; then
        echo "vim 安装失败，请手动安装 vim"
        echo "macOS: brew install vim"
        echo "Ubuntu: sudo apt-get install vim"
        echo "CentOS: sudo yum install vim"
        echo "Arch Linux: sudo pacman -S vim"
        # 不退出，继续执行其他步骤
    else
        echo "vim 安装完成"
    fi
else
    echo "vim 已安装"
fi

# 检查并安装 vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "正在安装 vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || {
        echo "vim-plug 安装失败"
        echo "可以稍后手动安装:"
        echo "  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        # 不退出，继续执行其他步骤
    }
    echo "vim-plug 安装完成"
else
    echo "vim-plug 已安装"
fi

# 复制 vim 配置文件
if [ -f ~/.vimrc ]; then
    echo "备份现有的 .vimrc 文件为 ~/.vimrc.backup"
    cp ~/.vimrc ~/.vimrc.backup
fi

cp "$SCRIPT_DIR/vim/.vimrc" ~/.vimrc

# 安装 vim 插件 (只有在 vim-plug 安装成功后才尝试)
if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "安装 vim 插件..."
    # 检查 vim 是否可用
    if command -v vim &> /dev/null; then
        # 根据操作系统选择合适的超时命令
        if command -v timeout &> /dev/null; then
            timeout 60 vim -c ":PlugInstall" -c ":qa" || {
                echo "vim 插件安装失败，请手动运行 :PlugInstall 命令"
                echo "打开 vim 后输入 :PlugInstall"
            }
        elif command -v gtimeout &> /dev/null; then
            # macOS 上可能需要通过 brew install coreutils 安装
            gtimeout 60 vim -c ":PlugInstall" -c ":qa" || {
                echo "vim 插件安装失败，请手动运行 :PlugInstall 命令"
                echo "打开 vim 后输入 :PlugInstall"
            }
        else
            # 没有超时命令，直接运行（可能会卡住）
            vim -c ":PlugInstall" -c ":qa" || {
                echo "vim 插件安装失败，请手动运行 :PlugInstall 命令"
                echo "打开 vim 后输入 :PlugInstall"
            }
        fi
    else
        echo "未找到 vim 命令，请安装 vim 后手动运行 :PlugInstall"
    fi
else
    echo "vim-plug 未安装，跳过插件安装步骤"
fi

echo "配置完成！"
echo ""
echo "请执行以下命令来应用配置："
echo "  source ~/.zshrc"
echo ""
echo "或者重新打开终端窗口"