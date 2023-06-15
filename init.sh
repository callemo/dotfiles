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
	HISTSIZE=10000; export HISTSIZE
	set -o emacs
	;;
zsh)
	: "${HISTFILE:=$HOME/.zsh_history}"
	SAVEHIST=10000; export SAVEHIST
	bindkey -e
	bindkey \^U backward-kill-line
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
