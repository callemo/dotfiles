# Initializes the current shell. Meant to be sourced.
_source_if() { [ -r "$1" ] && . "$1"; }
_path_prepend_if() { [ -d "$1" ] && PATH="$1:$PATH"; }
_venv_prompt() { [ "$VIRTUAL_ENV" ] && echo "($(basename "$VIRTUAL_ENV")) "; }

progdir="$(dirname "$0")"

HISTSIZE=50000 export HISTSIZE
PYTHONUSERBASE="$HOME/python"; export PYTHONUSERBASE

_path_prepend_if '/usr/local/go/bin'
_path_prepend_if '/usr/local/node/bin'
_path_prepend_if "$PYTHONUSERBASE/bin"
_path_prepend_if "$HOME/dotfiles/bin"
_path_prepend_if "$HOME/bin"
export PATH

. "$progdir/git-prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

if [ -n "$ZSH_VERSION" ]; then
  precmd () { __git_ps1 "$(_venv_prompt)%m:%1~" " %# "; }
else
  PROMPT_COMMAND='__git_ps1 "$(_venv_prompt)\h:\W" "\\\$ "'; export PROMPT_COMMAND
fi

. "$progdir/aliases.sh"

[ -n "${ZSH_VERSION}" ] && . "$progdir/zsh.sh"

unset progdir _path_prepend_if _source_if
