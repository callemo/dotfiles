#!/bin/sh

cd() { command cd "$@" && awd "$sysname"; }

case "${SHELL##*/}" in
zsh)
	unset zle_bracketed_paste
	;;
bash)
	if alias ls >/dev/null 2>&1
	then
		unalias ls
	fi
esac
