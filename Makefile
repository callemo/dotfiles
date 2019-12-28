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
vim: ## Install vim plugins
	./vimget https://github.com/sheerun/vim-polyglot.git
	./vimget https://github.com/tpope/vim-commentary.git
	./vimget https://github.com/tpope/vim-eunuch.git
	./vimget https://github.com/tpope/vim-fugitive.git
	./vimget https://github.com/tpope/vim-repeat.git
	./vimget https://github.com/tpope/vim-surround.git
	./vimget https://github.com/tpope/vim-tbone.git
	./vimget -o https://github.com/honza/vim-snippets.git
	./vimget -o https://github.com/sirver/UltiSnips.git
	./vimget -o -r https://github.com/davidhalter/jedi-vim.git

.PHONY: tmux
tmux: ## Install tmux plugins
	if [[ -d ~/.tmux/plugins/resurrect ]]; then \
		git -C ~/.tmux/plugins/resurrect pull; \
	else \
		git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.tmux/plugins/resurrect; \
	fi

.PHONY: fzf
fzf: ## Installs fzf
	if [[ -d ~/.fzf ]]; then \
		git -C ~/.fzf pull; \
	else \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
	fi
	~/.fzf/install --all

.PHONY: help
help:  ## Prints help for targets with comments
	@echo 'Makefile targets:'
	@cat $(MAKEFILE_LIST) \
		| egrep '^[a-zA-Z_-]+:.*?## .*$$' \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "%-24s %s\n", $$1, $$2 }'

