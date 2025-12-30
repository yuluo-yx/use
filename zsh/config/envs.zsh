# env config

{{if .Gvm}}
# Go
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
{{end}}

{{if .Java}}
# Java
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
{{end}}

{{if .Rust}}
# Rust
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
export CARGO_UNSTABLE_SPARSE_REGISTRY=true
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
{{end}}

# AI envs
export AI_DASHSCOPE_API_KEY="sk-xxxx"

# zsh 相关的工具会放在家目录下，因此将家目录加入到 PATH 中
export PATH=${HOME}/.local/bin:$PATH

# fzf
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# AI envs
export AI_DASHSCOPE_API_KEY="xxxx"

# eza envs
export FPATH="/Users/${USER}/.oh-my-zsh/custom/plugins/ezacompletions/zsh:$FPATH"
