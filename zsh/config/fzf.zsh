# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/${USER}/.oh-my-zsh/custom/plugins/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/${USER}/.oh-my-zsh/custom/plugins/fzf/bin"
fi

export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# 如果出现 unknown option --zsh，需要升级 fzf 版本
source <(fzf --zsh)
