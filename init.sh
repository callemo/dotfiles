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
LYNX_CFG="$HOME/.lynx.cfg"; export LYNX_CFG
RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"; export RIPGREP_CONFIG_PATH

: "${HISTSIZE:=10000}"; export HISTSIZE

EDITOR=ed; export EDITOR
case $(uname) in
OpenBSD) VISUAL=vi ;;
*)       VISUAL=vim ;;
esac
export VISUAL

case "${SHELL##*/}" in
ksh)
	ENV="$HOME/.kshrc"; export ENV
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
