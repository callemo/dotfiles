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

.PHONY: vimget
vimget: ## Get vim plugins
	./bin/vimget https://github.com/tpope/vim-surround.git
	./bin/vimget https://github.com/sheerun/vim-polyglot.git
	./bin/vimget https://github.com/tpope/vim-commentary.git

.PHONY: help
help:  ## Prints help for targets with comments
	@echo 'Makefile targets:'
	@cat $(MAKEFILE_LIST) | perl -ne \
		'printf " %-16s%s\n", $$1, $$2 if /^([^\.\$$]\S+):.+##\s+(.+)/'
