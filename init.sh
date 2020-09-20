# Initializes the current shell. Meant to be sourced.

HISTSIZE=50000 export HISTSIZE
PYTHONUSERBASE="$HOME/python"; export PYTHONUSERBASE

progdir="$(dirname "$0")"

_source_if() { [ -r "$1" ] && . "$1"; }
_path_prepend_if() { [ -d "$1" ] && PATH="$1:$PATH"; }
_venv_prompt() { [ "$VIRTUAL_ENV" ] && echo "($(basename "$VIRTUAL_ENV")) "; }

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

alias dco='docker-compose'
alias dps='docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"'
alias ga='git add'
alias gca='git commit -v -a'
alias gcam='git commit -v -a -m'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gd='git diff'
alias gdtvim='git difftool --no-prompt --tool=vimdiff'
alias gdw='git diff --word-diff'
alias glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glo='git log --oneline --decorate'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat"
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gst='git status'
alias tsp='tmux split-window -l 12'

_path_prepend_if '/usr/local/go/bin'
_path_prepend_if '/usr/local/node/bin'
_path_prepend_if "$PYTHONUSERBASE/bin"
_path_prepend_if "$HOME/dotfiles/bin"
_path_prepend_if "$HOME/bin"
export PATH

[ -n "${ZSH_VERSION}" ] && _source_if "${progdir}/zsh.sh"

unset progdir _path_prepend_if _source_if
