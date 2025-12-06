# Function Plugin config

# The fuck
eval $(thefuck --alias fuck)

# Yazi
# 目前为止还没有用起来...
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# fzf
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# logcat
function logcat() {

}
