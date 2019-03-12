# dotfiles/acme.sh
EDITOR=E
PAGER=nobs
home=$HOME
user=$USER
export EDITOR PAGER home user
cd () { builtin cd "$1" && awd "$sysname"; }
