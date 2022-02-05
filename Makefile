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

vim:
	bin/vimget https://github.com/preservim/nerdtree
	bin/vimget https://github.com/tpope/vim-commentary
	bin/vimget https://github.com/tpope/vim-fugitive
	bin/vimget https://github.com/tpope/vim-obsession
	bin/vimget https://github.com/tpope/vim-repeat
	bin/vimget https://github.com/tpope/vim-surround
	bin/vimget https://github.com/tpope/vim-dispatch

tmux:
	@if [ -d ~/.tmux/plugins/tmux-resurrect ]; then \
		git -C ~/.tmux/plugins/tmux-resurrect pull; \
	else \
		git clone https://github.com/tmux-plugins/tmux-resurrect.git \
			~/.tmux/plugins/tmux-resurrect; \
	fi

lab: $(HOME)/.virtualenvs/lab
	$</bin/python3 -m pip install --upgrade \
		numpy scipy matplotlib ipython jupyterlab pandas sympy nose scikit-learn

$(HOME)/.virtualenvs/lab:
	python3 -m venv $@
