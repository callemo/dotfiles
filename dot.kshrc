# /etc/ksh.kshrc and PS1 escapes are OpenBSD ksh features;
# NetBSD ksh expands only parameters in PS1
case $(uname) in
OpenBSD)
	. /etc/ksh.kshrc
	;;
esac

: "${HISTSIZE:=10000}"
: "${HISTFILE:=$HOME/.ksh_history}"
HISTCONTROL=ignoredups:ignorespace
set -o emacs

# current git branch, or empty; reads .git/HEAD directly to
# avoid forking git on every prompt. Starship styles the branch
# bold purple; _dotfiles_gb_color holds the escape, wrapped in
# \[...\] so OpenBSD ksh excludes it from the prompt width. NetBSD
# ksh lacks \[...\] and counts every byte, so it stays colorless.
_dotfiles_gb() {
	local d=$PWD head
	while [ -n "$d" ]; do
		if [ -f "$d/.git/HEAD" ]; then
			head=$(cat "$d/.git/HEAD") || return
			case $head in
			'ref: refs/heads/'*) head=${head#ref: refs/heads/} ;;
			*) head=$(printf '%.7s' "$head") ;;
			esac
			printf ' %s(%s)%s' "$_dotfiles_gb_color" "$head" \
				"${_dotfiles_gb_color:+\\[\\e[0m\\]}"
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

case $(uname) in
OpenBSD)
	_dotfiles_gb_color='\[\e[1;35m\]'
	if [ -n "$_dotfiles_root" ]; then
		_dotfiles_char='\[\e[1;31m\]#\[\e[0m\]'
	else
		_dotfiles_char='\[\e[1;34m\]>\[\e[0m\]'
	fi
	if [ -n "$_dotfiles_host" ]; then
		PS1='\[\e[1;2;32m\]${_dotfiles_host}\[\e[0m\] in \W$(_dotfiles_gb) ${_dotfiles_char} '
	else
		PS1='\W$(_dotfiles_gb) ${_dotfiles_char} '
	fi
	;;
*)
	_dotfiles_gb_color=
	if [ -n "$_dotfiles_root" ]; then
		_dotfiles_char='#'
	else
		_dotfiles_char='>'
	fi
	if [ -n "$_dotfiles_host" ]; then
		PS1='${_dotfiles_host} in ${PWD##*/}$(_dotfiles_gb) ${_dotfiles_char} '
	else
		PS1='${PWD##*/}$(_dotfiles_gb) ${_dotfiles_char} '
	fi
	;;
esac
