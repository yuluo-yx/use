# Function Plugin config

# Yazi
# 目前为止还没有用起来...
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
