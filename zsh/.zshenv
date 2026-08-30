############################
# XDG Configuration
############################
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

############################
# Executable Path
############################
typeset -U path PATH
path=("$HOME/.local/bin" $path)

############################
# Default Editor
############################
export EDITOR="vim"
export VISUAL="vim"

############################
# Manual Pager
############################
if command -v bat >/dev/null 2>&1; then
    export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
    export MANPAGER="batcat -l man -p"
fi
