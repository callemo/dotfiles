#!/bin/bash

# Prepend $1 to PATH only if the directory exists and is not already present.
_pathinsert() {
	case ":${PATH}:" in
	*":$1:"*) ;;
	*) [ -d "$1" ] && PATH="$1:${PATH}" ;;
	esac
}

DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"; export RIPGREP_CONFIG_PATH

: "${HISTSIZE:=10000}"; export HISTSIZE

case "${SHELL##*/}" in
ksh)
	: "${HISTFILE:=$HOME/.ksh_history}"
	export HISTCONTROL=ignoredups:ignorespace
	set -o emacs
	;;
zsh)
	: "${HISTFILE:=$HOME/.zsh_history}"
	: "${SAVEHIST:=$HISTSIZE}"; export SAVEHIST
	bindkey -e
	bindkey '^U' backward-kill-line
	bindkey '^[[1;5D' backward-word
	bindkey '^[[1;5C' forward-word
	;;
bash)
	: "${HISTFILESIZE:=$HISTSIZE}"; export HISTFILESIZE
	;;
esac

_pathinsert '/usr/local/node/bin'
_pathinsert '/usr/local/go/bin'
_pathinsert "$HOME/go/bin"
_pathinsert "$HOME/.local/bin"
_pathinsert "$HOME/dotfiles/bin"
_pathinsert "$HOME/bin"
export PATH
unset _pathinsert
