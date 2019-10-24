autoload -U compaudit compinit

setopt auto_pushd pushd_ignore_dups pushdminus

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -10
  fi
}
compdef _dirs d

alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
	hist_ignore_space hist_verify inc_append_history share_history

compinit

