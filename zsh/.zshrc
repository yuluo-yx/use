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
    eza
)

source $ZSH/oh-my-zsh.sh

source ${HOME}/.${USER}_env/zsh/aliases.zsh
source ${HOME}/.${USER}_env/zsh/envs.zsh
source ${HOME}/.${USER}_env/zsh/function.zsh
source ${HOME}/.${USER}_env/zsh/fzf.zsh
