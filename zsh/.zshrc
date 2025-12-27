export ZSH="$HOME/.oh-my-zsh"

# Custom Theme, can edit it.
ZSH_THEME="use-custom"

plugins=(
    z
    kubectl
    thefuck
    copypath
    copybuffer
    web-search
    extract
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

source ${HOME}/.${USER}_env/zsh/aliases.zsh
source ${HOME}/.${USER}_env/zsh/envs.zsh
source ${HOME}/.${USER}_env/zsh/function.zsh
source ${HOME}/.${USER}_env/zsh/fzf.zsh
