# Function Plugin config

# The fuck
eval $(thefuck --alias fuck)

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# autojump plugin config
[[ -s /Users/shown/.autojump/etc/profile.d/autojump.sh ]] && source /Users/shown/.autojump/etc/profile.d/autojump.sh

# fzf
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
