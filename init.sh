# dotfiles/init.sh

readonly scriptroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables:
HISTSIZE=50000
PYTHONUSERBASE="$HOME/.local/python"
export HISTSIZE PYTHONUSERBASE
if [[ "$BASH" ]]; then
    PS1='\h:\W \\$ '
    export PS1
fi

# Functions:
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

# Paths:
test_and_prepend_path "$HOME/.local/node/bin"
test_and_prepend_path "$HOME/.local/yarn/bin"
test_and_prepend_path "$PYTHONUSERBASE/bin"
test_and_prepend_path "$HOME/.local/bin"
test_and_prepend_path "$HOME/bin"
export PATH

# Git prompt support
test_and_source "$scriptroot/git-prompt.sh"
if command -v __git_ps1 > /dev/null 2>&1; then
    PROMPT_COMMAND='__git_ps1 "\h:\W" "\\\$ "'
    export PROMPT_COMMAND
else
    unset PROMPT_COMMAND
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

[[ "$winid" ]] && test_and_source "$scriptroot/acme.sh"
