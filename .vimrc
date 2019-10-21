set nocompatible

set autoread
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set exrc
set foldmethod=marker
set guioptions=
set hidden
set history=1000
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ 
set mouse=nic
set nomodeline
set number
set ruler
set scrolloff=1
set secure
set sidescrolloff=2
set title
set visualbell
set wildmenu

set notimeout
set nottimeout

set nobackup
set noswapfile
set nowritebackup

filetype plugin indent on
set autoindent
set shiftwidth=4
set textwidth=0

let g:netrw_banner = 0
let g:netrw_list_hide = '^\./$,^\.\./$'

function! PatchColors()
	highlight! Comment term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Directory term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Identifier term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! LineNr term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! MatchParen term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! PreProc term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! QuickFixLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Search term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Special term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Statement term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! TabLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! TabLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! TabLineFill term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Title term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
	highlight! Type term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE

	highlight! Comment          	ctermfg=008 guifg=#808080
	highlight! helpHyperTextJump	ctermfg=004 guifg=#268bd2 term=underline cterm=underline gui=underline
	highlight! LineNr           	ctermfg=008 guifg=#808080 term=reverse   cterm=reverse   gui=reverse
	highlight! QuickFixLine     	ctermfg=008 guifg=#808080 term=reverse   cterm=reverse   gui=reverse
	highlight! Search           	ctermfg=008 guifg=#808080 term=reverse   cterm=reverse   gui=reverse
	highlight! TabLine          	ctermfg=008 guifg=#808080 term=reverse   cterm=reverse   gui=reverse
	highlight! TabLineFill      	ctermfg=008 guifg=#808080 term=reverse   cterm=reverse   gui=reverse
endfunction

command! Dump mksession! Session.vim
command! Load source Session.vim
command! Ctags silent !ctags -R --languages=-vim,sql .

let mapleader = ' '

nnoremap - :Explore<CR>

cnoremap <c-n> <down>
cnoremap <c-p> <up>

nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>

nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>

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

syntax enable
colorscheme desert
call PatchColors()

if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif

