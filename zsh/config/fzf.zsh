# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/shown/.oh-my-zsh/custom/plugins/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/shown/.oh-my-zsh/custom/plugins/fzf/bin"
fi

source <(fzf --zsh)
