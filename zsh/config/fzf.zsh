############################
# Fzf Availability
############################

if ! command -v fzf >/dev/null 2>&1; then
  return
fi

############################
# File Discovery
############################
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
fi

############################
# Ctrl T Search
############################
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

############################
# Interface
############################
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

############################
# File Preview
############################
if command -v bat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
else
  export _FZF_PREVIEW_CMD='sed -n "1,500p" {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

############################
# Shell Integration
############################
if [[ -o interactive ]]; then
  source <(fzf --zsh)
fi

############################
# Ctrl F Search
############################
_fzf_file_no_hidden() {
  local result
  if command -v fd >/dev/null 2>&1; then
    result=$(command fd --type f --strip-cwd-prefix --exclude .git | command fzf --preview "$_FZF_PREVIEW_CMD") || return
  else
    result=$(command find . -type f | command fzf --preview "$_FZF_PREVIEW_CMD") || return
  fi
  LBUFFER+="${(q)result}"
  zle reset-prompt
}

if [[ -o interactive ]]; then
  zle -N _fzf_file_no_hidden
  bindkey '^F' _fzf_file_no_hidden
fi
