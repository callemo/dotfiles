#
# Shell initialization script
#
# Variables {{{
HISTSIZE=50000
export HISTSIZE

PYTHONUSERBASE="$HOME/.local/python"
export PYTHONUSERBASE

if [[ "${BASH_VERSION}" ]]; then
  _shell_name=bash
  _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ "${ZSH_VERSION}" ]]; then
  _shell_name=zsh
  _script_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi

# }}}
# Functions {{{
_source_if() { [[ -r "${1}" ]] && . "${1}"; }
_path_prepend_if() { [[ -d "${1}" ]] && PATH="${1}:${PATH}"; }

_venv_prompt() {
  [[ "${VIRTUAL_ENV}" ]] && echo -n "($(basename "${VIRTUAL_ENV}")) "
}

gupr () {
  set -o pipefail
  if [[ $# -lt 1 ]]; then
    echo "usage: $0 path [args]" >&2
    return 1
  fi
  p="$1"
  shift
  find "$p" -name .git \
    | sed 's/.git$//' \
    | xargs -n 1 -I % git -C "%" pull --rebase "$@"
}

# }}}
# PATH {{{
_path_prepend_if "$PYTHONUSERBASE/bin"
_path_prepend_if "$HOME/.local/node/bin"
_path_prepend_if "$HOME/.local/yarn/bin"
_path_prepend_if "$HOME/.local/bin"
_path_prepend_if "$HOME/bin"
export PATH

# }}}
# Aliases {{{
alias dco='docker-compose'
alias dps='docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"'
alias ga='git add'
alias gb='git branch'
alias gca='git commit -v -a'
alias gcam='git commit -v -a -m'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gd='git diff'
alias gdw='git diff --word-diff'
alias glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glo='git log --oneline --decorate'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat"
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gst='git status'
alias gupav='git pull --rebase --autostash -v'
alias gup='git pull --rebase'
# }}}
# Prompt {{{
. "${_script_dir}/git-prompt.sh"
if [[ "${_shell_name}" = "bash" ]]; then
  PROMPT_COMMAND='__git_ps1 "$(_venv_prompt)\h:\W" "\\\$ "'
  export PROMPT_COMMAND
elif [[ "${_shell_name}" = "zsh" ]]; then
  precmd () { __git_ps1 "$(_venv_prompt)%m:%1~" " %# "; }
fi
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1
# }}}

[[ "${_shell_name}" = "zsh" ]] && _source_if "${_script_dir}/zsh.sh"
unset _script_dir _shell_name _path_prepend_if _source_if
# vim: set sw=2 sts=2 et fdm=marker:
