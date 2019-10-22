autoload -U compaudit compinit

setopt auto_pushd pushd_ignore_dups pushdminus

unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
	hist_ignore_space hist_verify inc_append_history share_history

compinit

