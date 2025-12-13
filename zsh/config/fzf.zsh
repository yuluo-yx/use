# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/${USER}/.oh-my-zsh/custom/plugins/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/${USER}/.oh-my-zsh/custom/plugins/fzf/bin"
fi

export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
