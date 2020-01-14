# Makefile
SHELL        =  /bin/bash
dotfiles     =  .vimrc .tmux.conf
dotfiles     := $(patsubst .%,$(HOME)/.%,$(dotfiles))
excludesfile =  $(HOME)/.gitignore

.PHONY: all
all: dotfiles vim tmux fzf

.PHONY: dotfiles
dotfiles: $(dotfiles) $(excludesfile) ## Link dotfiles

$(dotfiles): $(HOME)/.%: .%
	ln -s $(realpath $<) $@

$(excludesfile): .gitignore
	ln -s $(realpath $<) $@
	git config --global core.excludesfile $@

.PHONY: vim
vim: ## Install vim plugins
	./vimget https://github.com/tpope/vim-commentary.git
	./vimget https://github.com/tpope/vim-dispatch.git
	./vimget https://github.com/tpope/vim-eunuch.git
	./vimget https://github.com/tpope/vim-fugitive.git
	./vimget https://github.com/tpope/vim-projectionist.git
	./vimget https://github.com/tpope/vim-repeat.git
	./vimget https://github.com/tpope/vim-surround.git
	./vimget https://github.com/tpope/vim-tbone.git

.PHONY: vim-extras
vim-extras: ## Install vim optional plugins
	./vimget -o https://github.com/roxma/nvim-yarp.git
	./vimget -o https://github.com/roxma/vim-hug-neovim-rpc.git
	./vimget -o https://github.com/Shougo/deoplete.nvim.git
	./vimget -o -r https://github.com/deoplete-plugins/deoplete-jedi.git
	./vimget -o https://github.com/Shougo/neosnippet.vim.git
	./vimget -o https://github.com/Shougo/neosnippet-snippets.git
	./vimget -o https://github.com/honza/vim-snippets.git

.PHONY: tmux
tmux: ## Install tmux plugins
	if [[ -d ~/.tmux/plugins/resurrect ]]; then \
		git -C ~/.tmux/plugins/resurrect pull; \
	else \
		git clone https://github.com/tmux-plugins/tmux-resurrect.git \
			~/.tmux/plugins/resurrect; \
	fi

.PHONY: fzf
fzf: ## Installs fzf
	if [[ -d ~/.fzf ]]; then \
		git -C ~/.fzf pull; \
	else \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
		~/.fzf/install --all; \
	fi

.PHONY: help
help:  ## Prints help for targets with comments
	@echo 'Makefile targets:'
	@cat $(MAKEFILE_LIST) \
		| grep -E '^[a-zA-Z_-]+:.*?## .*$$' \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "%-24s %s\n", $$1, $$2 }'

