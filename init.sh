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
HISTSIZE=100000; export HISTSIZE

if [ -n "$ZSH_VERSION" ]
then
	SAVEHIST="$HISTSIZE"; export SAVEHIST
	: "${HISTFILE:=$HOME/.zsh_history}"
	bindkey -e	# implicitly changed with EDITOR=vim
	bindkey \^U backward-kill-line
else
	HISTFILESIZE="$HISTSIZE"; export HISTFILESIZE
fi

_merge_path '/usr/local/node/bin'
_merge_path '/usr/local/go/bin'
_merge_path "$HOME/go/bin"
_merge_path "$HOME/dotfiles/bin"
_merge_path "$HOME/bin"
export PATH

unset _merge_path
