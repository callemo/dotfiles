set nocompatible

set backspace=indent,eol,start
set completeopt-=preview
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set foldmethod=indent
set foldnestmax=3
set grepprg=grep\ -E\ -n\ -s\ $*\ /dev/null
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
set shortmess+=I
set showtabline=2
set statusline=%n:%<%.99f\ %{PasteMode()}%y%h%w%m%r%=%-14.(%l,%c%V%)\ %P
set switchbuf=useopen,usetab,newtab
set title
set updatetime=400
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime

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

nnoremap - :Explore<CR>
autocmd FileType netrw setlocal statusline=%F

cnoremap <C-a> <Home>
cnoremap <C-e> <End>

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

nnoremap <silent> <C-l> :nohlsearch<CR>:syntax sync fromstart<CR>

nnoremap <leader>D :Dump<CR>
nnoremap <leader>T :Ctags<CR>
nnoremap <leader>c :close<CR>
nnoremap <leader>d :bdelete<CR>
nnoremap <leader>e :tabedit <C-r>=expand("%:p:h")<CR>/
nnoremap <leader>l :ls<CR>
nnoremap <silent> <leader>w :silent write!<CR>

nnoremap <silent> <C-j> :if winnr() == winnr('$')<CR>silent !tmux select-pane -t :.+<CR>else<CR>wincmd w<CR>endif<CR>
nnoremap <silent> <C-k> :if winnr() == 1<CR>silent !tmux select-pane -t :.-<CR>else<CR>wincmd W<CR>endif<CR>

vnoremap * :call SetVisualSearch()<CR>/<CR>
vnoremap # :call SetVisualSearch()<CR>?<CR>

if has('clipboard')
	vnoremap <C-c> "*y
else
	if has('unix') && system('uname')[0:-2] ==# "Darwin"
		vnoremap <C-c> :write !pbcopy<CR>
	endif
endif

command! Black call Format('black')
command! Ctags silent !ctags -R --languages=-vim,sql .
command! Dump mksession! Session.vim
command! Load source Session.vim
command! Prettier call Format('prettier --write')
command! TrimTrailingSpaces call TrimTrailingSpaces()

function! PasteMode()
	if &paste
		return '[PASTE]'
	endif
	return ''
endfunction

function TabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		let s .= '%' . (i + 1) . 'T'
		let s .= ' %{TabLabel(' . (i + 1) . ')} '
	endfor
	let s .= '%#TabLineFill#%T'
	return s
endfunction

function TabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let bufnr = buflist[winnr - 1]
	let label = bufname(bufnr)
	let buftype = getbufvar(bufnr, '&buftype')
	if label == ''
		if buftype == ''
			return '[No Name]'
		endif
		return '[' . buftype . ']'
	endif
	let label = fnamemodify(label, ':p:t')
	let modified = getbufvar(bufnr, "&modified")
	if modified
		let label = label .'*'
	endif
	return label
endfunction

set tabline=%!TabLine()

function! TrimTrailingSpaces() abort
	let cursor = getpos(".")
	let last_search = @/
	silent! %s/\s\+$//e
	let @/ = last_search
	call setpos('.', cursor)
endfunction

function! SetVisualSearch()
	let reg = @"
	execute 'normal! vgvy'
	let pattern = escape(@", "\\/.*'$^~[]")
	let pattern = substitute(pattern, "\n$", '', '')
	let @/ = pattern
	let @" = reg
endfunction

function! Format(command) abort
	update
	execute '!' . a:command . expand(' %')
	checktime
endfunction

if isdirectory(expand('~/dotfiles/vim'))
	set rtp+=~/dotfiles/vim
endif

autocmd BufReadPost * exe "normal! g'\""
autocmd BufWritePre *.txt,*.js,*.py,*.sh :call TrimTrailingSpaces()
autocmd FileType c,cpp setlocal path+=/usr/include
autocmd FileType javascript,json,html,css,scss setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType python,yaml setlocal expandtab shiftwidth=4 softtabstop=4

let g:projectionist_heuristics = {
			\ "manage.py": {
			\   "*": {
			\     "console": "./manage.py shell",
			\     "dispatch": "./manage.py test",
			\     "start": "./manage.py runserver",
			\   },
			\   "*.html": {"type": "template"},
			\   "*/models.py": {"type": "models", "alternate": "{}/views.py"},
			\   "*/urls.py": {"type": "urls"},
			\   "*/views.py": {"type": "views", "alternate": "{}/models.py"},
			\ }}

if has('python3')
let g:UltiSnipsListSnippets = "<S-Tab>"
silent! packadd! UltiSnips
silent! packadd! vim-snippets

python3 <<EOF
import os
import site
import sys
from pathlib import Path

VIRTUAL_ENV = os.environ.get("VIRTUAL_ENV")
if VIRTUAL_ENV:
    venv_path = Path(VIRTUAL_ENV)
    os.environ["PATH"] = str(venv_path / "bin") + os.pathsep + os.environ["PATH"]
    for child in (venv_path / "lib").iterdir():
        site_path = child / "site-packages"
        if site_path.is_dir():
            site.addsitedir(site_path)
    sys.prefix = VIRTUAL_ENV
EOF

let g:jedi#completions_command = ""
let g:jedi#goto_command = "<F12>"
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
let g:jedi#rename_command = "<F2>"
let g:jedi#show_call_signatures = 0
let g:jedi#use_tabs_not_buffers = 1
endif

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
	nnoremap <silent> <C-p> :call fzf#run(fzf#wrap({'options': '--reverse'}))<CR>
	nnoremap <silent> <leader>o :call fzf#run(fzf#wrap({
				\'source': filter(copy(v:oldfiles), "filereadable(fnamemodify(v:val, ':p'))"),
				\'options': '--reverse'
				\}))<CR>
endif

syntax enable
colorscheme monokai

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif

