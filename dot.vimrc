if !has('vim9script') | set nocompatible | finish | endif
vim9script

var root = exists('$DOTFILES') ? $DOTFILES : isdirectory(expand('~/dotfiles')) ? expand('~/dotfiles') : ''
if root != ''
	&rtp ..= ',' .. root .. '/vim'
	$PATH = root .. '/acme:' .. $PATH
endif

import autoload 'exec.vim'
import autoload 'plugins.vim'
import autoload 'plumb.vim'
import autoload 'view.vim'

# ── Options ──────────────────────────────────────────────
set autoindent
set autoread
set backspace=indent,eol,start
set commentstring=#%s
set confirm
set cursorline
set dictionary+=/usr/share/dict/words
set fillchars=vert:\ ,fold:-
set hidden
set history=1000
set hlsearch
set incsearch
set laststatus=2
set listchars=eol:$,tab:>\ ,space:.
set mouse=nv
if has('mouse_sgr')
	set ttymouse=sgr
endif
set nobackup
set noequalalways
set winminheight=0
set noexpandtab
set nofoldenable
set nojoinspaces
set noswapfile
set nowritebackup
set complete-=i
set nrformats-=octal
set nonumber
set path=.,,
set shiftwidth=4
set shortmess=atI
set showcmd
set showtabline=2
set softtabstop=4
set splitbelow
set splitright
set statusline=\ %{fnamemodify(getcwd(),':t')}\ ›\ %f\ %=%l:%c\ %y\ %{&bt==#'nofile'?'':&modified?'[+]':''}%R
set switchbuf=useopen,split
set tabline=%!view#TabLine()
set tabstop=4
set updatetime=300
set notimeout
set ttimeout
set ttimeoutlen=50
set viewoptions-=options
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu
set wildmode=longest,list

# ── Runtime ──────────────────────────────────────────────
packadd! matchit

runtime! ftplugin/man.vim
filetype plugin on
syntax on

g:mapleader = ' '
g:loaded_netrw = 1
g:loaded_netrwPlugin = 1

def! g:Err(msg: string)
	echohl ErrorMsg
	echo msg
	echohl None
enddef

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
endif

augroup lazy_plugins
	autocmd!
	autocmd BufRead,BufNewFile *.go ++once call plugins.Go()
augroup END

# ── Autocommands ─────────────────────────────────────────
augroup dotfiles
	autocmd!
	autocmd TextYankPost * if v:event.operator ==# 'y' | call exec.Yank(getreg('"')) | endif
	autocmd BufReadPost * exe 'silent! normal! g`"'
	autocmd BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | setl nowrap | endif
	autocmd BufWritePre * call view.Trim()
	autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
	autocmd InsertEnter,WinLeave * setl nocursorline
	autocmd InsertLeave,WinEnter * setl cursorline
	autocmd OptionSet diff if &diff | setl nocursorline | endif

	autocmd TerminalWinOpen *
		\ setl nonumber
		\ | setl statusline=%{%view#TermStatus()%}
		\ | nnoremap <buffer> q i
	autocmd VimEnter * if argc() == 0 && empty(bufname()) | call view.Dir('', true) | endif
	# BufReadCmd matches trailing / (dir buffer names); BufEnter catches :e .
	autocmd BufReadCmd */ call view.Dir(expand('<afile>:p'), true)
	autocmd BufEnter * if isdirectory(expand('<afile>:p')) | call view.Dir(expand('<afile>:p'), true) | endif
augroup END

augroup filetypes
	autocmd!
	autocmd BufNewFile,BufRead *.tidal    setfiletype haskell
	autocmd FileType c,cpp                setl path+=/usr/include
	autocmd FileType css,html,htmldjango,scss setl iskeyword+=-
	autocmd FileType gitcommit            setl spell fdm=syntax fdl=1 iskeyword+=.,-
	autocmd FileType groff                setl commentstring=.\\\"\ %s
	autocmd FileType javascript,json      setl sw=4 sts=4 et
	autocmd FileType lilypond             setl et sw=2 ts=2 sts=2 ai fdm=indent fdl=0 fdc=2 cms=%\ %s
	autocmd FileType markdown,python      setl sw=4 sts=4 et
	autocmd FileType perl                 setl et keywordprg=:terminal\ perldoc\ -f
	autocmd FileType python               setl keywordprg=:terminal\ pydoc3
	autocmd FileType sh                   setl noet sw=0 sts=0
	autocmd FileType typescript           setl sw=4 sts=4 et syn=javascript  # too buggy
	autocmd FileType yaml                 setl ts=2 sw=2 sts=2 et syn=conf   # too buggy
augroup END

# ── Commands ─────────────────────────────────────────────
command! -nargs=? -complete=file -range
	\ Cmd call exec.Cmd(<q-args>, <range>, <line1>, <line2>)

command! -nargs=? Lint call exec.Lint(<f-args>)
command! -nargs=? -range=% Fmt call exec.Fmt(<line1>, <line2>, <f-args>)
command! -nargs=* Fts call exec.Fts(<q-args>)
command! -nargs=? Toc call view.Toc(<f-args>)

command!          Sort call view.Sort()
command! -nargs=1 B    call view.Bufmatch(<q-args>)

command! -nargs=? -complete=file Dump call exec.Dump(<q-args>)
command! -nargs=? -complete=file Load call exec.Load(<q-args>)

command! -range -nargs=? Send call exec.Tmux(<line1>, <line2>, <q-args>)

# ── Leader ───────────────────────────────────────────────
nnoremap <silent> <leader>! <ScriptCmd>exec.Cmd('', 0, 0, 0)<CR>
nnoremap <leader>. <cmd>lcd %:p:h<CR>
nnoremap <silent> <leader>; <cmd>Send<CR>
nnoremap <silent> <leader><CR> <ScriptCmd>plumb.Do(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
nnoremap <silent> <leader>B <ScriptCmd>view.Browse()<CR>
nnoremap <silent> <leader>y <ScriptCmd>exec.Yank(fnamemodify(expand('%:p'), ':.'))<CR>
nnoremap <silent> <leader>Y <ScriptCmd>exec.Yank(expand('%:p'))<CR>
nnoremap <leader>N :new <c-r>=expand('%:h')<CR>/
nnoremap <silent> <leader>D <cmd>Dump<CR>
nnoremap <silent> <leader>E <cmd>Dump<CR><cmd>qall<CR>
nnoremap <leader>Q <ScriptCmd>view.Close('!')<CR>
nnoremap <leader>f <cmd>Fmt<CR>
nnoremap <leader>l <cmd>Lint<CR>
nnoremap <leader>q <ScriptCmd>view.Close('')<CR>
nnoremap <leader>z <cmd>resize<CR>
nnoremap <silent> <leader><leader> <ScriptCmd>view.Expand()<CR>

# ── Brackets ─────────────────────────────────────────────
nnoremap ]a <cmd>next<CR>
nnoremap [a <cmd>previous<CR>
nnoremap ]b <cmd>bnext<CR>
nnoremap [b <cmd>bprevious<CR>
nnoremap ]l <cmd>lnext<CR>
nnoremap [l <cmd>lprevious<CR>
nnoremap ]q <cmd>cnext<CR>
nnoremap [q <cmd>cprevious<CR>
nnoremap ]t <cmd>tabnext<CR>
nnoremap [t <cmd>tabprevious<CR>

# ── Toggles ──────────────────────────────────────────────
nnoremap yob :set background=<c-r>=&bg == 'light' ? 'dark' : 'light'<CR><CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yoi :setl invignorecase<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>

# ── Ctrl ─────────────────────────────────────────────────
nnoremap <silent> <c-j> <ScriptCmd>view.Next()<CR>
nnoremap <silent> <c-k> <ScriptCmd>view.Prev()<CR>
nnoremap <c-l> <cmd>nohlsearch \| call clearmatches() \| diffupdate \| syntax sync fromstart<CR><c-l>
nnoremap <c-p> <cmd>FZF<CR>
nnoremap <silent> + <ScriptCmd>execute('resize ' .. (winheight(0) + max([5, winheight(0) / 2])))<CR>
nnoremap <down> <c-e>
nnoremap <up> <c-y>

# ── Visual ───────────────────────────────────────────────
xnoremap <silent> <leader>! <ScriptCmd>exec.Cmd(view.Selection(), 0, 0, 0)<CR><Esc>
xnoremap <silent> <leader>; <cmd>Send<CR><Esc>
xnoremap <silent> <leader><CR> <ScriptCmd>plumb.Do(expand('%:h'), {'visual': 1}, view.Selection())<CR><Esc>
xnoremap * <ScriptCmd>view.SearchSel()<CR>/<CR>

# ── Insert / cmdline ─────────────────────────────────────
inoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
inoremap <C-x>w <C-r>=strftime("%YW%V")<CR>
inoremap <c-a> <home>
inoremap <c-e> <end>
inoremap <down> <c-o><c-e>
inoremap <up> <c-o><c-y>
cnoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
cnoremap <C-x>w <C-r>=strftime("%YW%V")<CR>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

# ── Terminal ─────────────────────────────────────────────
tnoremap <silent> <c-j> <ScriptCmd>view.Next()<CR>
tnoremap <silent> <c-k> <ScriptCmd>view.Prev()<CR>
tnoremap <c-w>[ <c-\><c-n>
tnoremap <c-w>] <c-w>""

tnoremap <leader>z <cmd>resize<CR>
tnoremap <scrollwheelup> <c-\><c-n>

# ── Mouse ────────────────────────────────────────────────
nnoremap <silent> <LeftMouse> <ScriptCmd>view.Click()<CR>
nnoremap <silent> <2-LeftMouse> <ScriptCmd>view.DblClick()<CR>
nnoremap <silent> <C-LeftMouse> <ScriptCmd>view.Zoom()<CR>
nnoremap <silent> <middlemouse> <leftmouse><ScriptCmd>view.MidClick()<CR>
nnoremap <silent> <rightmouse> <leftmouse><ScriptCmd>plumb.Do(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
xnoremap <silent> <middlemouse> <ScriptCmd>exec.Cmd(view.Selection(), 0, 0, 0)<CR><Esc>
xnoremap <silent> <rightmouse> <ScriptCmd>plumb.Do(expand('%:h'), {'visual': 1}, view.Selection())<CR><Esc>

# ── Colorscheme ──────────────────────────────────────────
if root != ''
	colorscheme basic
endif

# ── Local ────────────────────────────────────────────────
if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
