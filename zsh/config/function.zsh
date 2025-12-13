# Function Plugin config

# The fuck
# The fuck 需要 python 3.11
# https://github.com/nvbn/thefuck/issues/1434
# eval $(thefuck --alias fuck)

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
