export ZSH="$HOME/.oh-my-zsh"

# Custom Theme, can edit it.
ZSH_THEME="ys-custom"

source $ZSH/oh-my-zsh.sh
source ${HOME}/.config/zsh/aliases.zsh
source ${HOME}/.config/zsh/envs.zsh
source ${HOME}/.config/zsh/function.zsh
source ${HOME}/.config/zsh/mise.zsh
source ${HOME}/.config/zsh/fzf.zsh
source ${HOME}/.config/zsh/typo.zsh

plugins=(
    z
    eza
    extract
    # kubectl
    # git
    # docker
    copypath
    copybuffer
    web-search
    zsh-autosuggestions
    zsh-autosuggestions
    zsh-syntax-highlightingi
)
