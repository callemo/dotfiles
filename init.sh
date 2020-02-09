#
# Shell initialization script
#
# Variables {{{
HISTSIZE=50000
export HISTSIZE

PYTHONUSERBASE="${HOME}/.local/python"
export PYTHONUSERBASE

if [[ -n "${ZSH_VERSION}" ]]; then
  _script_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# }}}
# Functions {{{
_source_if() { [[ -r "${1}" ]] && . "${1}"; }
_path_prepend_if() { [[ -d "${1}" ]] && PATH="${1}:${PATH}"; }

_venv_prompt() {
  [[ "${VIRTUAL_ENV}" ]] && echo -n "($(basename "${VIRTUAL_ENV}")) "
}

venv () {
  local e
  e="${1:-$(basename "$(pwd)")}"
  if [[ ! -d "${VENV_HOME:=${HOME}/.virtualenvs}/${e}" ]]; then
    echo "venv not found: ${e}" >&2
    return 1
  fi
  [[ -n "${VIRTUAL_ENV}" ]] && deactivate
  . "${VENV_HOME}/${e}/bin/activate"
}

# Update current branch from master
gupm () {
  local branch master
  master="${1:-master}"
  branch="$(git branch | awk '/^\*/ { print $2 }')"
  if [[ -z "${branch}" ]] || [[ "${branch}" = "${master}" ]]; then
    echo "bad branch: ${branch}" >&2
    return 1
  fi
  git checkout "${master}" \
    && git pull \
    && git checkout "${branch}" \
    && git merge --no-ff -m "Merge ${master}"
}

# Find all repos and update
gupr () {
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
# Prompt {{{
. "${_script_dir}/git-prompt.sh"
if [[ -n "${ZSH_VERSION}" ]]; then
  precmd () { __git_ps1 "$(_venv_prompt)%m:%1~" " %# "; }
else
  PROMPT_COMMAND='__git_ps1 "$(_venv_prompt)\h:\W" "\\\$ "'
  export PROMPT_COMMAND
fi
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1
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
# PATH {{{
_path_prepend_if "$PYTHONUSERBASE/bin"
_path_prepend_if "$HOME/.local/node/bin"
_path_prepend_if "$HOME/.local/yarn/bin"
_path_prepend_if "$HOME/.local/bin"
_path_prepend_if "$HOME/bin"
export PATH

# }}}

[[ -n "${ZSH_VERSION}" ]] && _source_if "${_script_dir}/zsh.sh"
unset _script_dir _path_prepend_if _source_if
# vim: set sw=2 sts=2 et fdm=marker:
