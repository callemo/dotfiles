#!/bin/bash

_merge_path() {
	case "$PATH" in
	$1:*)	;;
	*:$1:*) ;;
	*:$1)	;;
	*)		if [ -d "$1" ]; then PATH="$1:$PATH"; fi;;
	esac
}

DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
EDITOR=vim; export EDITOR

case "${SHELL##*/}" in
ksh)
	: "${HISTFILE:=$HOME/.ksh_history}"
	export HISTSIZE=10000
	export HISTCONTROL=ignoredups:ignorespace
	set -o emacs
	if command -v fzf >/dev/null
	then
		_hist() {
			local cmd
			cmd="$(fzf --tac --no-sort <"$HISTFILE")"
			if [ -n "$cmd" ]
			then
				eval "$cmd"
			fi
		}
		bind -m ^R=\ _hist^J
	fi
	;;
zsh)
	: "${HISTFILE:=$HOME/.zsh_history}"
	SAVEHIST=10000; export SAVEHIST
	bindkey -e
	bindkey \^U backward-kill-line
	if [ "$TERM_PROGRAM" = Alacritty ]
	then
		printf '\e]0;%s %s\b' "$SHELL" "$$"
	fi
	;;
bash)
	HISTFILESIZE=10000; export HISTFILESIZE
	;;
esac

_merge_path '/usr/local/node/bin'
_merge_path '/usr/local/go/bin'
_merge_path "$HOME/go/bin"
_merge_path "$HOME/dotfiles/bin"
_merge_path "$HOME/bin"
export PATH

unset _merge_path
