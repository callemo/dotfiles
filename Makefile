sources = .pylintrc .tmux.conf .vimrc .gvimrc
targets = $(sources:.%=$(HOME)/.%)

.PHONY: all check dotfiles vim tmux lab

all: dotfiles

check:
	./test

dotfiles: $(targets) $(HOME)/.gitignore

$(targets): $(HOME)/%: $(CURDIR)/%
	ln -s $< $@

$(HOME)/.gitignore: $(CURDIR)/.gitignore
	ln -s $< $@
	git config --global core.excludesfile $@

vim: tmux
	vim/get https://github.com/preservim/nerdtree
	vim/get https://github.com/tpope/vim-commentary
	vim/get https://github.com/tpope/vim-fugitive
	vim/get https://github.com/tpope/vim-obsession
	vim/get https://github.com/tpope/vim-repeat
	vim/get https://github.com/tpope/vim-surround
	vim/get https://github.com/tpope/vim-dispatch

tmux:
	@if [ -d ~/.tmux/plugins/tmux-resurrect ]; then git -C ~/.tmux/plugins/tmux-resurrect pull; \
	else git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.tmux/plugins/tmux-resurrect; \
	fi

lab: $(HOME)/.virtualenvs/lab
	$</bin/python3 -m pip install --upgrade \
		numpy scipy matplotlib ipython jupyterlab pandas sympy nose scikit-learn

$(HOME)/.virtualenvs/lab:
	python3 -m venv $@
