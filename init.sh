if [[ "$BASH_VERSION" ]]; then
    dir="$(cd "$(dirname "$BASH_SOURCE{0}")" && pwd)"
elif [[ "$ZSH_VERSION" ]]; then
    dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi

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
test_and_prepend_path "$HOME/.local/node/bin"
test_and_prepend_path "$HOME/.local/yarn/bin"
test_and_prepend_path "$PYTHONUSERBASE/bin"
test_and_prepend_path "$HOME/.local/bin"
test_and_prepend_path "$HOME/bin"
export PATH

# Prompt
test_and_source "$dir/git-prompt.sh"
if command -v __git_ps1 > /dev/null 2>&1; then
    if [[ "$BASH_VERSION" ]]; then
        PROMPT_COMMAND='__git_ps1 "\h:\W" "\\\$ "'
        export PROMPT_COMMAND
    fi
    if [[ "$ZSH_VERSION" ]]; then
        precmd () { __git_ps1 "%m:%1~" " %# "; }
    fi
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=1
fi

# Aliases
alias dco='docker-compose'
alias dps='docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"'
alias ga='git add'
alias gb='git branch'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -v -a -m'
alias gd='git diff'
alias glo="git log --pretty='format:%Cred%h%Creset [%ar] %an: %s%Cgreen%d%Creset' --graph"
alias gst='git status'

[[ "$winid" ]] && test_and_source "$dir/acme.sh"
