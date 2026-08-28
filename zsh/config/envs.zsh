# 环境变量配置

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=30

export LANG=en_US.UTF-8

# zsh 相关的工具会放在家目录下，因此将家目录加入到 PATH 中
export PATH=${HOME}/.local/bin:$PATH

# fzf
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# AI envs
export AI_DASHSCOPE_API_KEY="xxxx"

# eza envs
export FPATH="$HOME/.oh-my-zsh/custom/plugins/ezacompletions/zsh:$FPATH"

# PATH env
export PATH="$HOME/.local/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
