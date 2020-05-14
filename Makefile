SHELL = /bin/bash

sources = .vimrc .gvimrc .tmux.conf .ctags
targets = $(sources:.%=$(HOME)/.%)

.PHONY: all dotfiles vim tmux fzf help

all: dotfiles vim tmux fzf

dotfiles: $(targets) $(HOME)/.gitignore

$(targets): $(HOME)/%: $(CURDIR)/%
	ln -s $< $@

$(HOME)/.gitignore: $(CURDIR)/.gitignore
	ln -s $< $@
	git config --global core.excludesfile $@

vim:
	./vimget https://github.com/tpope/vim-commentary.git
	./vimget https://github.com/tpope/vim-dispatch.git
	./vimget https://github.com/tpope/vim-eunuch.git
	./vimget https://github.com/tpope/vim-fugitive.git
	./vimget https://github.com/tpope/vim-repeat.git
	./vimget https://github.com/tpope/vim-surround.git
	./vimget -o https://github.com/tpope/vim-projectionist.git
	./vimget -o https://github.com/tpope/vim-ragtag.git
	./vimget -o https://github.com/tpope/vim-scriptease.git
tmux:
	if [[ -d ~/.tmux/plugins/tmux-resurrect ]]; then git -C ~/.tmux/plugins/tmux-resurrect pull; \
	else git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.tmux/plugins/tmux-resurrect; \
	fi

fzf:
	if [[ -d ~/.fzf ]]; then git -C ~/.fzf pull; \
	else git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --all; \
	fi

