# Options:

# Variables:
GIT_PS1_SHOWDIRTYSTATE=1
HISTSIZE=50000
PYTHONUSERBASE="$HOME/.local/python"
GOPATH="$HOME/go"
PS1='\h:\W \\$ '
# Exports:
# > awk -F '=' 'BEGIN {printf("export")} {printf(" %s", $1)} END{printf("\n")}'
export GIT_PS1_SHOWDIRTYSTATE HISTSIZE PYTHONUSERBASE GOPATH PS1

# Functions:
test_and_source() { if [[ -r "$1" ]]; then . "$1"; fi }
test_and_prepend_path() { if [[ -d "$1" ]]; then PATH="$1:$PATH"; fi }

# Paths:
test_and_prepend_path /usr/local/bin
test_and_prepend_path /usr/local/sbin
test_and_prepend_path "$PYTHONUSERBASE/bin"
test_and_prepend_path "$HOME/.pyenv/bin"
test_and_prepend_path "$HOME/.rbenv/bin"
test_and_prepend_path "$GOPATH/bin"
test_and_prepend_path "$HOME/.local/bin"
test_and_prepend_path "$HOME/bin"
export PATH

# Git prompt support
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
if command -v __git_ps1 > /dev/null 2>&1; then
     PROMPT_COMMAND='__git_ps1 "\h:\W" "\\\$ "'
     export PROMPT_COMMAND
fi

# pyenv:
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  PYTHONHOME="$(python-config --prefix)"
  export PYTHONHOME
fi

# nvm:
if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
    test_and_source "$HOME/.nvm/nvm.sh"
    test_and_source "$HOME/.nvm/bash_completion"
fi

# rbenv:
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# Go:
if command -v go > /dev/null 2>&1; then
    GOROOT="$(go env GOROOT)"
    export GOROOT
fi

# Aliases:
alias dco='docker-compose'
alias dps='docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"'
alias ga='git add'
alias gba='git branch -a'
alias gca='git commit -a -m'
alias gd='git diff'
alias gl="git log --pretty='format:%Cred%h%Creset [%ar] %an: %s%Cgreen%d%Creset' --graph"
alias gst='git status'
alias ls='ls -1A'

test_and_source "$HOME/.bashrc.local"
