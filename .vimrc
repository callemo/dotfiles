set nocompatible

set autoread
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set exrc
set guioptions=
set hidden
set history=1000
set hlsearch
set lazyredraw
set listchars=eol:$,tab:>\ 
set mouse=a
set number
set ruler
set scrolloff=1
set secure
set sidescrolloff=2
set title
set visualbell
set wildmenu

set laststatus=2
set showtabline=2
set statusline=[%n]\ %<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %P

set notimeout
set nottimeout

set nobackup
set noswapfile
set nowritebackup

filetype plugin indent on
set autoindent
set textwidth=0

let g:netrw_banner = 0
let g:netrw_list_hide = '^\./$,^\.\./$'

command! Dump mksession! Session.vim
command! Load source Session.vim
command! Ctags silent !ctags -R --languages=-vim,sql .

let mapleader = ' '

nnoremap - :Explore<CR>

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

nnoremap <c-l> :nohlsearch<CR>

nnoremap <leader>T :Ctags<CR>

nnoremap m<CR> :make<CR>
nnoremap m<Space> :make<Space>

function! ResetSyntaxHighlight()
	let l:highlight_groups = ['Constant', 'Delimiter', 'Function', 'Identifier', 'PreProc', 'Special', 'Statement', 'Type']
	for i in highlight_groups
		exe 'hi! ' . i . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE'
	endfor
	hi! Comment ctermfg=008 guifg=#808080
endfunction

syntax enable
call ResetSyntaxHighlight()

if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif

