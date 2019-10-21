EDITOR=E
PAGER=nobs
home="$HOME"
user="$USER"
export EDITOR PAGER home user
unalias cd 2>/dev/null
cd () { builtin cd "$1" && awd "$sysname" ; }
unalias ls 2>/dev/null
ls () { 9 ls "$@" ; }
