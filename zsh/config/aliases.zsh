############################
# General Aliases
############################

alias clr="clear"
alias mk="make"

############################
# Kubectl Aliases
############################
alias k="kubectl"
alias kg="kubectl get"
alias ka="kubectl apply"
alias kcf="kubectl create -f"
alias kd="kubectl describe"
alias klf="kubectl logs -f"

############################
# Docker Aliases
############################
alias d="docker"

############################
# Python Aliases
############################
alias py="python3"
alias pi="pip3 install"
alias sv="source .venv/bin/activate"

############################
# Git Aliases
############################
alias gg="git clone"

############################
# System Information
############################
alias sf="fastfetch"

############################
# Fzf Aliases
############################
alias f="fzf"
alias ff='fzf --preview "bat --color=always {}"'
alias gco="git branch | fzf | xargs git checkout"

############################
# Directory Listing
############################
alias ls='eza --icons'

alias ll='eza -lh --icons --git'

alias la='eza -lah --icons --git'

alias tree='eza --tree --icons'

compdef eza=ls

alias cat='bat'

############################
# Directory Shortcuts
############################
alias -- --='cd ..'
alias -- ---='cd ../..'
alias -- ----='cd ../../..'

############################
# Claude Code
############################
alias cc='claude --dangerously-skip-permissions'

############################
# Command Replacements
############################
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
