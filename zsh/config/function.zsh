# Function Plugin config

# Ghostty 标题栏配置
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ghostty_set_title() {
        # 将 HOME 替换为 ~，保持标题更短
        local dir="${PWD/#$HOME/~}"
        # Ghostty 支持 OSC 2 设置窗口标题
        printf '\033]2;%s\033\\' "$dir"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd ghostty_set_title
    add-zsh-hook precmd ghostty_set_title
    add-zsh-hook preexec ghostty_set_title
    ghostty_set_title
fi

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# logcat
function logcat() {
    cat "$1" | \
    GREP_COLORS='mt=01;42' grep -E 'ERROR|WARNING|INFO|DEBUG' --color=always | \
    GREP_COLORS='mt=01;46' grep "$2" --color=always
}

# mkdr 创建目录并进入
function mkcd() {
	mkdir -p "$1" && cd "$1"
}

# bun completions
[ -s "/Users/shown/.bun/_bun" ] && source "/Users/shown/.bun/_bun"

function proxy(){
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7898"
    echo "proxy on..."
}

function noproxy() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo "proxy off..."
}
