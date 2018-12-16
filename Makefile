# Makefile
SHELL = /bin/bash

dotfiles = \
	   .bashrc \
	   .gnupg/gpg.conf \
	   .tmux.conf

dotfiles     := $(patsubst .%,$(HOME)/.%,$(dotfiles))
excludesfile =  $(HOME)/.gitignore

.PHONY: dotfiles
dotfiles: $(dotfiles) $(excludesfile) ## Links dotfiles

$(dotfiles): $(HOME)/.%: .%
	ln -s $(realpath $<) $@

$(excludesfile): .gitignore
	ln -s $(realpath $<) $@
	git config --global core.excludesfile $@

.PHONY: help
help:  ## Prints help for targets with comments
	@echo 'Makefile targets:'
	@cat $(MAKEFILE_LIST) | perl -ne \
		'printf " %-16s%s\n", $$1, $$2 if /^([^\.\$$]\S+):.+##\s+(.+)/'
