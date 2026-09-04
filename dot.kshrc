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

case $(uname) in
OpenBSD)
	_dotfiles_gb_color='\[\e[1;35m\]'
	PS1='\W$(_dotfiles_gb) \[\e[1;34m\]>\[\e[0m\] '
	;;
*)
	_dotfiles_gb_color=
	PS1='${PWD##*/}$(_dotfiles_gb) > '
	;;
esac
