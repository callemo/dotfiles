set nocompatible

set autoread
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set guioptions=
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set mouse=a
set nobackup
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set number
set ruler
set scrolloff=1
set showtabline=2
set sidescrolloff=2
set statusline=#%{winnr()}\ %<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %P
set title
set visualbell
set wildmenu

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

nnoremap <leader>D :Dump<CR>
nnoremap <leader>L :Load<CR>
nnoremap <leader>w :bwipeout<CR>
nnoremap <leader>T :Ctags<CR>

command! Ctags silent !ctags -R --languages=-vim,sql .
command! Dump mksession! Session.vim
command! Load source Session.vim
command! Trim call TrimTrailingSpaces()
command! Prettier call Fmt('prettier --write')
command! Black call Fmt('black')

function! TrimTrailingSpaces() abort
	let _s=@/
	%s/\s\+$//e
	let @/=_s
	nohl
	unlet _s
endfunction

function! Fmt(cmd) abort
	update
	execute '!' . a:cmd . expand(' %')
	edit
endfunction

if isdirectory(expand('~/dotfiles/vim'))
	set rtp+=~/dotfiles/vim
endif

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
	nnoremap <c-p> :FZF<CR>
endif

function! PatchColors()
	let l:highlight_groups = [
				\'Comment',	'Constant',	'Delimiter',	'Function',
				\'DiffAdd',	'DiffChange',	'DiffDelete',	'DiffText',
				\'Identifier',	'Special',	'Statement',	'Search',
				\'MatchParen',	'TabLine',	'TabLineFill',	'TabLineSel',
				\'Todo',	'Type',		'Visual'
				\]

	for group in highlight_groups
		exe 'hi! ' . group . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE'
	endfor

	hi! Comment	ctermfg=240			guifg=#586e75
	hi! DiffAdd	ctermfg=064	ctermbg=235	guifg=#859900	guibg=#073642
	hi! DiffChange	ctermfg=231	ctermbg=235	guifg=#f8f8f2	guibg=#073642
	hi! DiffDelete	ctermfg=160	ctermbg=235	guifg=#dc322f	guibg=#073642
	hi! DiffText	ctermfg=166	ctermbg=235	guifg=#cb4b16	guibg=#073642
	hi! Function	ctermfg=33			guifg=#268bd2
	hi! Search	ctermfg=016	ctermbg=229	guifg=#000000	guibg=#ededa6
	hi! String	ctermfg=37			guifg=#2aa198
	hi! Todo	ctermfg=125			guifg=#d33682
	hi! Visual	ctermfg=240	ctermbg=234	guifg=#586e75	guibg=#002b36
	hi! WildMenu	ctermfg=016	ctermbg=159	guifg=#000000	guibg=#9ceeed	cterm=bold	gui=bold

	hi! link diffAdded DiffAdd
	hi! link diffRemoved DiffDelete
	hi! link StatusLineTermNC StatusLineNC
	hi! link StatusLineTerm StatusLine
	hi! link VertSplit Normal
endfunction

syntax enable
colorscheme monokai

autocmd FileType c,cpp setlocal path+=/usr/include
autocmd FileType javascript,json setlocal shiftwidth=2 expandtab
autocmd FileType python,yaml setlocal shiftwidth=4 expandtab

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif

