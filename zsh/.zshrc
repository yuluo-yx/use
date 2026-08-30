export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ys"

############################
# Mise
############################
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

############################
# Oh My Zsh Plugins
############################
plugins=(
    z
    web-search
    zsh-autosuggestions
    copypath
    copybuffer
    eza
    extract
)

############################
# Shell History
############################
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

############################
# Shell Behavior
############################
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

############################
# Oh My Zsh
############################
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

############################
# Modular Configuration
############################
typeset -a zsh_config_files=(
    aliases.zsh
    toolchains.zsh
    custom_vars.zsh
    functions.zsh
    fzf.zsh
    wine.zsh
    blog_algoia.zsh
    custom_vars.local.zsh
)

for zsh_config_file in "${zsh_config_files[@]}"; do
    zsh_config_path="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/$zsh_config_file"
    [[ -r "$zsh_config_path" ]] && source "$zsh_config_path"
done
unset zsh_config_file zsh_config_files zsh_config_path

############################
# Typo
############################
if command -v typo >/dev/null 2>&1; then
    eval "$(typo init zsh)"
fi

############################
# Syntax Highlighting
############################
zsh_highlighting="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$zsh_highlighting" ]] && source "$zsh_highlighting"
unset zsh_highlighting
