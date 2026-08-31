############################
# Ghostty Tab Title
############################
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ghostty_set_title() {
        local dir="${PWD/#$HOME/~}"
        printf '\033]2;%s\033\\' "$dir"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd ghostty_set_title
    add-zsh-hook precmd ghostty_set_title
    add-zsh-hook preexec ghostty_set_title
    ghostty_set_title
fi

############################
# Yazi Directory Switcher
############################
function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

############################
# Log Filter
############################
function logcat() {
    GREP_COLORS='mt=01;42' command grep -E 'ERROR|WARNING|INFO|DEBUG' --color=always "$1" | \
        GREP_COLORS='mt=01;46' command grep "$2" --color=always
}

############################
# Directory Creator
############################
function mkcd() {
    mkdir -p -- "$1" && builtin cd -- "$1"
}

############################
# Proxy Controller
############################
function proxy() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7898"
    echo "proxy on"
}

function noproxy() {
    unset http_proxy https_proxy all_proxy
    echo "proxy off"
}
