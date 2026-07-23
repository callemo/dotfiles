#!/bin/sh

# Move $1 to the front of PATH, deduplicating any existing occurrence.
pathfront() {
	[ -d "$1" ] || return
	local p='' t="${PATH}:" s
	while [ -n "$t" ]; do
		s="${t%%:*}"; t="${t#*:}"
		[ "$s" = "$1" ] || p="${p:+${p}:}${s}"
	done
	PATH="$1${p:+:${p}}"
	unset p t s
}

DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"; export RIPGREP_CONFIG_PATH

: "${HISTSIZE:=10000}"; export HISTSIZE

# Set EDITOR before any shell selects its line-editor mode: ksh derives the
# mode from EDITOR each time the value changes, so a later EDITOR=vi (e.g. in
# ~/.profile) would flip ksh out of emacs mode unless the value already matches.
: "${EDITOR:=vi}"; export EDITOR
: "${VISUAL:=$EDITOR}"; export VISUAL

case "${SHELL##*/}" in
ksh)
	ENV="$DOTFILES/init.sh"; export ENV
	: "${HISTFILE:=$HOME/.ksh_history}"
	export HISTCONTROL=ignoredups:ignorespace
	set -o emacs
	case $- in *i*) PS1='\[\e[36m\]\W\[\e[0m\] \[\e[1;36m\]>\[\e[0m\] ' ;; esac
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

pathfront '/usr/local/node/bin'
pathfront '/usr/local/go/bin'
pathfront "$HOME/go/bin"
pathfront "$HOME/.local/bin"
pathfront "$HOME/dotfiles/bin"
pathfront "$HOME/bin"
export PATH
unset pathfront
