DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"; export DOTFILES
EDITOR=vim; export EDITOR
PYTHONUSERBASE="$HOME/python"; export PYTHONUSERBASE
HISTSIZE=100000; export HISTSIZE
HISTFILESIZE="$HISTSIZE"; export HISTFILESIZE
SAVEHIST="$HISTSIZE"; export SAVEHIST

_path_prepend_if() { [ -d "$1" ] && PATH="$1:$PATH"; }

_path_prepend_if '/usr/local/go/bin'
_path_prepend_if '/usr/local/node/bin'
_path_prepend_if "$PYTHONUSERBASE/bin"
_path_prepend_if "$HOME/dotfiles/bin"
_path_prepend_if "$HOME/bin"
export PATH

unset _path_prepend_if
