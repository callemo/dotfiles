sources = .alacritty.yml .ctags .pylintrc .tmux.conf .vimrc
targets = $(sources:.%=$(HOME)/.%)

.PHONY: all check dotfiles vim tmux fzf scipy

all: dotfiles vim tmux fzf

check:
	./test

dotfiles: $(targets) $(HOME)/.gitignore

fzf: $(HOME)/.fzf

$(targets): $(HOME)/%: $(CURDIR)/%
	ln -s $< $@

$(HOME)/.gitignore: $(CURDIR)/.gitignore
	ln -s $< $@
	git config --global core.excludesfile $@

vim:
	bin/vimget https://github.com/tpope/vim-commentary
	bin/vimget https://github.com/tpope/vim-dispatch
	bin/vimget https://github.com/tpope/vim-eunuch
	bin/vimget https://github.com/tpope/vim-fugitive
	bin/vimget https://github.com/tpope/vim-ragtag
	bin/vimget https://github.com/tpope/vim-repeat
	bin/vimget https://github.com/tpope/vim-surround
	bin/vimget https://github.com/tpope/vim-tbone
	bin/vimget -o https://github.com/tpope/vim-projectionist
	bin/vimget -o https://github.com/tpope/vim-scriptease
	bin/vimget -o https://github.com/vimwiki/vimwiki

tmux:
	@if [ -d ~/.tmux/plugins/tmux-resurrect ]; then \
		git -C ~/.tmux/plugins/tmux-resurrect pull; \
	else \
		git clone https://github.com/tmux-plugins/tmux-resurrect.git \
			~/.tmux/plugins/tmux-resurrect; \
	fi

$(HOME)/.fzf:
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --all

scipy: $(HOME)/.virtualenvs/scipy
	$</bin/python3 -m pip install --upgrade \
		numpy scipy matplotlib ipython jupyter pandas sympy nose jupyterlab

$(HOME)/.virtualenvs/scipy:
	python3 -m venv $@
