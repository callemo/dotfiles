set nocompatible

set autoread
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
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

setglobal commentstring=#\ %s
setglobal path=.,,

filetype plugin indent on
set autoindent
set textwidth=0

let g:netrw_banner = 0
let g:netrw_list_hide = '^\./$,^\.\./$'

let mapleader = ' '

nnoremap - :Explore<CR>
nnoremap <C-j> <C-w>w
nnoremap <C-k> <C-w>W

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

nnoremap <leader>D :Dump<CR>
nnoremap <leader>L :Load<CR>
nnoremap <leader>q :bwipeout<CR>
nnoremap <leader>T :Ctags<CR>

command! Ctags silent !ctags -R --languages=-vim,sql .
command! Dump mksession! Session.vim
command! Load source Session.vim
command! Trim let _s=@/ | %s/\s\+$//e | let @/=_s | nohl | unlet _s
command! Prettier call Fmt('prettier --write')
command! Black call Fmt('black')

function! Fmt(cmd) abort
	update
	execute '!' . a:cmd . expand(' %')
	edit
endfunction

function! PatchColors()
	let l:highlight_groups = [
				\'Comment', 'Constant', 'Delimiter', 'Function',
				\'Identifier', 'Special', 'Statement', 'Todo',
				\'Type', 'Visual'
				\]
	for i in highlight_groups
		exe 'hi! ' . i . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE'
	endfor

	hi! Comment	ctermfg=240			guifg=#586e75
	hi! Function	ctermfg=33			guifg=#268bd2
	hi! String	ctermfg=37			guifg=#2aa198
	hi! Todo	ctermfg=125			guifg=#d33682
	hi! Visual	ctermfg=240	ctermbg=234	guifg=#586e75	guibg=#002b36

	hi! link StatusLineTerm StatusLine
	hi! link StatusLineTermNC StatusLineNC
	hi! link VertSplit Normal
endfunction

syntax enable
colorscheme default
call PatchColors()

autocmd FileType c,cpp setlocal path+=/usr/include
autocmd FileType javascript,json setlocal shiftwidth=2 expandtab
autocmd FileType python,yaml setlocal shiftwidth=4 expandtab

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif

