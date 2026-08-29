. /etc/ksh.kshrc

: "${HISTSIZE:=10000}"
: "${HISTFILE:=$HOME/.ksh_history}"
HISTCONTROL=ignoredups:ignorespace
set -o emacs
PS1='\W \[\e[1;34m\]❯\[\e[0m\] '
