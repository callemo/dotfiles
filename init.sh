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
RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"; export RIPGREP_CONFIG_PATH

case "${SHELL##*/}" in
ksh)
	: "${HISTFILE:=$HOME/.ksh_history}"
	export HISTSIZE=10000
	export HISTCONTROL=ignoredups:ignorespace
	set -o emacs
	cd() { command cd "$@" && printf '\033]0;%s\007' "$PWD - ksh"; }
	;;
zsh)
	: "${HISTFILE:=$HOME/.zsh_history}"
	export HISTSIZE=10000
	export SAVEHIST=10000
	export PS1='%n@%m:%~$ '
	bindkey -e
	bindkey '^U' backward-kill-line
	bindkey '^[[1;5D' backward-word
	bindkey '^[[1;5C' forward-word
	print -Pn '\033]0;%n@%m: %~\007'
	cd() { builtin cd "$@" && print -Pn '\033]0;%n@%m: %~\007'; }
	;;
bash)
	export HISTFILESIZE=10000
	;;
esac

_merge_path '/usr/local/node/bin'
_merge_path '/usr/local/go/bin'
_merge_path "$HOME/go/bin"
_merge_path "$HOME/dotfiles/bin"
_merge_path "$HOME/bin"
export PATH

unset _merge_path
