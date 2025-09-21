export ZSH="/Users/shown/.oh-my-zsh"

ZSH_THEME="ys"

plugins=(
    thefuck
    z
    web-search
    zsh-syntax-highlighting
    zsh-autosuggestions
    copypath
    copybuffer
    kubectl
)

source $ZSH/oh-my-zsh.sh

source ~/.shown_env/zsh/aliases.zsh
source ~/.shown_env/zsh/envs.zsh
source ~/.shown_env/zsh/function.zsh
source ~/.shown_env/zsh/ai_envs.zsh
source ~/.shown_env/zsh/fzf.zsh
