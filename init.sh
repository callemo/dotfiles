# Variables
HISTSIZE=50000
PYTHONUSERBASE="$HOME/.local/python"
export HISTSIZE PYTHONUSERBASE

# Functions
test_and_source() {
    if [[ -r "$1" ]]; then
        # shellcheck source=/dev/null
        . "$1"
    fi
}

test_and_prepend_path() {
    if [[ -d "$1" ]]; then
        PATH="$1:$PATH"
    fi
}

# Paths
test_and_prepend_path "$PYTHONUSERBASE/bin"
test_and_prepend_path "$HOME/.local/node/bin"
test_and_prepend_path "$HOME/.local/yarn/bin"
test_and_prepend_path "$HOME/.local/bin"
test_and_prepend_path "$HOME/bin"
export PATH

# Aliases
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

if [[ "$BASH_VERSION" ]]; then
    dir="$(cd "$(dirname "$BASH_SOURCE{0}")" && pwd)"
elif [[ "$ZSH_VERSION" ]]; then
    dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
    test_and_source "$dir/zsh.sh"
fi

# Prompt
test_and_source "$dir/git-prompt.sh"
if command -v __git_ps1 > /dev/null 2>&1; then
    if [[ "$BASH_VERSION" ]]; then
        PROMPT_COMMAND='__git_ps1 "\h:\W" "\\\$ "'
        export PROMPT_COMMAND
    elif [[ "$ZSH_VERSION" ]]; then
        precmd () { __git_ps1 "%m:%1~" " %# "; }
    fi
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=1
fi

[[ "$winid" ]] && test_and_source "$dir/acme.sh"

