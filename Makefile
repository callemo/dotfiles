# Makefile
SHELL        =  /bin/bash
dotfiles     =  .vimrc .tmux.conf
dotfiles     := $(patsubst .%,$(HOME)/.%,$(dotfiles))
excludesfile =  $(HOME)/.gitignore

.PHONY: dotfiles
dotfiles: $(dotfiles) $(excludesfile) ## Link dotfiles

$(dotfiles): $(HOME)/.%: .%
	ln -s $(realpath $<) $@

$(excludesfile): .gitignore
	ln -s $(realpath $<) $@
	git config --global core.excludesfile $@

.PHONY: vim
vim: ## Get vim plugins
	./vimget https://github.com/sheerun/vim-polyglot.git
	./vimget https://github.com/tpope/vim-commentary.git
	./vimget https://github.com/tpope/vim-fugitive.git
	./vimget https://github.com/tpope/vim-repeat.git
	./vimget https://github.com/tpope/vim-surround.git

.PHONY: tmux
tmux: ## Get tmux plugins
	git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.tmux/plugins/resurrect

.PHONY: help
help:  ## Prints help for targets with comments
	@echo 'Makefile targets:'
	@cat $(MAKEFILE_LIST) | perl -ne \
		'printf " %-16s%s\n", $$1, $$2 if /^([^\.\$$]\S+):.+##\s+(.+)/'
