# .bashrc
source_if() { if [[ -f "$1" ]]; then . "$1"; fi }
insert_path_if() { if [[ -d $1 ]]; then PATH="$1:$PATH"; fi }

source_if "$HOME/.bashrc.base"
source_if /usr/local/etc/bash_completion

# =============
# = Variables =
# =============
export CLICOLOR=1
export EDITOR=vim
export HISTSIZE=50000

# ===========
# = Aliases =
# ===========
alias dco='docker-compose'
alias dps='docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"'
alias flush='sudo killall -HUP mDNSResponder'
alias ga='git add'
alias gba='git branch -a'
alias gca='git commit -a -m'
alias gd='git diff'
alias gl="git log --pretty='format:%Cred%h%Creset [%ar] %an: %s%Cgreen%d%Creset' --graph"
alias gst='git status'
alias ll='ls -l'
alias ls='ls -1A'
alias tsp='tmux split'

# ========
# = Path =
# ========
PATH="/usr/local/bin:/usr/local/sbin:$PATH"
insert_path_if "$HOME/bin"
insert_path_if "$HOME/.local/bin"

# ==========
# = Python =
# ==========
export PYTHONUSERBASE="$HOME/.local/python"
export PYENV_ROOT="$HOME/.pyenv"
insert_path_if "$PYTHONUSERBASE/bin"
insert_path_if "$PYENV_ROOT/bin"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  PYTHONHOME="$(python-config --prefix)"
  export PYTHONHOME
fi

# ========
# = Ruby =
# ========
insert_path_if "$HOME/.rbenv/bin"
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# ===========
# = Nodejs =
# ===========
if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source_if "$NVM_DIR/nvm.sh"
    source_if "$NVM_DIR/bash_completion"
fi

# ======
# = Go =
# ======
if command -v go > /dev/null 2>&1; then
    GOROOT="$(go env GOROOT)"
    export GOROOT
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$PATH
fi

export PATH

# ==========
# = Prompt =
# ==========
if [ "$PS1" ]; then
    if [ "$(command -v __git_ps1)" ]; then
        export PS1="\[\e[36m\]\W\[\e[m\]\[\e[31m\]\`__git_ps1\`\[\e[m\] \\$ "
    else
        export PS1="\[\e[36m\]\W\[\e[m\] \\$ "
    fi
fi

source_if "$HOME/.fzf.bash"
source_if "$HOME/.bashrc.local"
