#!/bin/bash

_prepend_missing_path() {
  case "$PATH" in
  $1:*)
    ;;
  *:$1:*)
    ;;
  *:$1)
    ;;
  *)
    if [ -d "$1" ]
    then
      PATH="$1:$PATH";
    fi
    ;;
  esac
}

DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
EDITOR=vim; export EDITOR
HISTSIZE=100000; export HISTSIZE
PYTHONUSERBASE="$HOME/python"; export PYTHONUSERBASE

if [ -n "$ZSH_VERSION" ]
then
  SAVEHIST="$HISTSIZE"; export SAVEHIST
  : "${HISTFILE:=$HOME/.zsh_history}"
  bindkey -e  # implicitly changed with EDITOR=vim
else
  HISTFILESIZE="$HISTSIZE"; export HISTFILESIZE
fi

_prepend_missing_path '/usr/local/go/bin'
_prepend_missing_path '/usr/local/node/bin'
_prepend_missing_path "$PYTHONUSERBASE/bin"
_prepend_missing_path "$HOME/dotfiles/bin"
_prepend_missing_path "$HOME/bin"
export PATH

unset _prepend_missing_path
