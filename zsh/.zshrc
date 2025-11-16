export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="ys"

# 设置自定义主题目录
USER_NAME=$(whoami)
ZSH_CUSTOM="$HOME/.${USER_NAME}_env/theme/zsh"

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

source ~/.${USER_NAME}_env/config/zsh/aliases.zsh
source ~/.${USER_NAME}_env/config/zsh/envs.zsh
source ~/.${USER_NAME}_env/config/zsh/function.zsh
source ~/.${USER_NAME}_env/config/zsh/ai_envs.zsh
source ~/.${USER_NAME}_env/config/zsh/fzf.zsh
