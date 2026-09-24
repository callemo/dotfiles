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

_dotfiles_gb() {
	local d=$PWD head
	while [ -n "$d" ]; do
		if [ -f "$d/.git/HEAD" ]; then
			read -r head <"$d/.git/HEAD" || return
			case $head in
			'ref: refs/heads/'*) head=${head#ref: refs/heads/} ;;
			*) head=$(printf '%.7s' "$head") ;;
			esac
			printf ' (%s)' "$head"
			return
		fi
		d=${d%/*}
	done
}

_dotfiles_host=
if [ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]; then
	_dotfiles_host=$(uname -n)
	_dotfiles_host=${_dotfiles_host%%.*}
fi

# Starship switches its prompt character to # for uid 0; do the same
_dotfiles_root=
if [ "$(id -u)" -eq 0 ]; then
	_dotfiles_root=1
fi

DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
LYNX_CFG="$HOME/.lynx.cfg"; export LYNX_CFG
LYNX_LSS="$HOME/.lynx.lss"; export LYNX_LSS
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
	setopt prompt_subst
	if [ -n "$_dotfiles_host" ]; then
		PROMPT='%B%F{green}${_dotfiles_host}%f%b in %1~%B%F{magenta}$(_dotfiles_gb)%f%b %(!.%B%F{red}#%f%b.%B%F{blue}>%f%b) '
	else
		PROMPT='%1~%B%F{magenta}$(_dotfiles_gb)%f%b %(!.%B%F{red}#%f%b.%B%F{blue}>%f%b) '
	fi
	;;
bash)
	: "${HISTFILESIZE:=$HISTSIZE}"; export HISTFILESIZE
	if [ -n "$_dotfiles_root" ]; then
		_dotfiles_char=$(printf '\033[1;31m#\033[0m')
	else
		_dotfiles_char=$(printf '\033[1;34m>\033[0m')
	fi
	if [ -n "$_dotfiles_host" ]; then
		PS1='\[\e[1;2;32m\]${_dotfiles_host}\[\e[0m\] in \W\[\e[1;35m\]$(_dotfiles_gb)\[\e[0m\] \[${_dotfiles_char}\] '
	else
		PS1='\W\[\e[1;35m\]$(_dotfiles_gb)\[\e[0m\] \[${_dotfiles_char}\] '
	fi
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
