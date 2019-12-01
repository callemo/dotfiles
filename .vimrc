set nocompatible

set autoread
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set foldmethod=indent
set foldnestmax=3
set guioptions=
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set nobackup
set nofoldenable
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set number
set ruler
set scrolloff=1
set shortmess+=I
set showtabline=2
set sidescrolloff=2
set statusline=#%{winnr()}\ %<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %P
set title
set visualbell
set wildmenu

set mouse=a
if has('mouse_sgr')
	set ttymouse=sgr
endif

setglobal commentstring=#\ %s
setglobal path=.,,

filetype plugin indent on
set autoindent
set textwidth=0

let g:netrw_banner = 0
let g:netrw_list_hide = '^\./$,^\.\./$'

let mapleader = ' '

nnoremap <c-j> <c-w>w
nnoremap <c-k> <c-w>W

nnoremap - :Explore<CR>
nnoremap <c-n> :25Lex<CR>
autocmd FileType netrw setlocal statusline=#%{winnr()}\ %F

cnoremap <c-n> <down>
cnoremap <c-p> <up>

nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprevious<CR>

nnoremap yoh :setlocal hlsearch!<CR>
nnoremap yol :setlocal list!<CR>
nnoremap yon :setlocal number!<CR>
nnoremap yop :setlocal paste!<CR>
nnoremap yos :setlocal spell!<CR>
nnoremap yow :setlocal wrap!<CR>

nnoremap m<CR> :make<CR>
nnoremap m<Space> :make<Space>

nnoremap <c-l> :nohlsearch<CR>
if has('clipboard')
	vnoremap <c-c> :y *<CR>
else
	if has('unix') && system('uname -s') == "Darwin\n"
		vnoremap <c-c> :write !pbcopy<CR><CR>
	endif
endif

nnoremap <leader>D :Dump<CR>
nnoremap <leader>T :Ctags<CR>
nnoremap <leader>W :bwipeout<CR>
nnoremap <leader>w :write<CR>

command! Ctags silent !ctags -R --languages=-vim,sql .
command! Dump mksession! Session.vim
command! Load source Session.vim
command! TrimTrailingSpaces call TrimTrailingSpaces()
command! Prettier call Format('prettier --write')
command! Black call Format('black')

function! TrimTrailingSpaces() abort
	let l:s=@/
	%s/\s\+$//e
	let @/=s
	nohlsearch
endfunction

function! Format(command) abort
	update
	execute '!' . a:command . expand(' %')
	edit
endfunction

if isdirectory(expand('~/dotfiles/vim'))
	set rtp+=~/dotfiles/vim
endif

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
	nnoremap <c-p> :FZF<CR>
endif

syntax enable
colorscheme monokai

autocmd FileType c,cpp setlocal path+=/usr/include
autocmd FileType javascript,json setlocal shiftwidth=2 expandtab
autocmd FileType python,yaml setlocal shiftwidth=4 expandtab

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif

