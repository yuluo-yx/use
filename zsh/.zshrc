export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="yz"

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

source ~/.${USER}_env/zsh/config/aliases.zsh
source ~/.${USER}_env/zsh/config/envs.zsh
source ~/.${USER}_env/zsh/config/function.zsh
source ~/.${USER}_env/zsh/config/ai_envs.zsh
source ~/.${USER}_env/zsh/config/fzf.zsh
