#!/bin/sh

cd() { command cd "$@" && awd "$sysname"; }

case "${SHELL##*/}" in
zsh)
	unset zle_bracketed_paste
	;;
esac
