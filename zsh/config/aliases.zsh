# alias config

alias clr="clear"
alias mk="make"

# Kubectl alias
alias k="kubectl"
alias kg="kubectl get"
alias ka="kubectl apply"
alias kcf="kubectl create -f"
alias kd="kubectl describe"
alias klf="kubectl logs -f"

# Docker alias
alias d="docker"

# python
alias py="python3"
alias pi="pip3 install"
alias sv="source .venv/bin/active"

# git
alias gg="git clone"

# Yazi
alias y="yazi"

# neofetch
alias sf="fastfetch"

# fzf
alias f="fzf"
alias ff='fzf --preview "bat --color=always {}"'
alias gco="git branch | fzf | xargs git checkout"

# Better ls
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# grep/egrep
alias grep="grep --color=auto"

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# alias cd
alias "--"="cd .."
alias "---"="cd ../.."
alias "----"="cd ../../.."

# claude
alias cc='claude --dangerously-skip-permissions'

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
