set nocompatible

set autoindent
set autoread
set backspace=indent,eol,start
set cmdheight=2
set commentstring=#%s
set complete-=i
set completeopt-=preview
set confirm
set cursorline
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set fillchars=vert:\ ,fold:-
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set mouse=nvi
set nobackup
set noequalalways
set nofoldenable
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set nrformats-=octal
set number
set path=.,,
set ruler
set sessionoptions-=options
set shortmess=atI
set showcmd
set showtabline=2
set switchbuf=useopen,split
set tabline=%!dotfiles#TabLine()
set textwidth=0
set title
set updatetime=300
set viewoptions-=options
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

set statusline=\ %n\ %<%.56f\ %Y%H%W%R%M%=%{fnamemodify(getcwd(),':t')}\ %l,%c\ %P\ 

let mapleader = "\<Space>"

if has('syntax') && has('eval')
  packadd! matchit
endif

if has('mouse_sgr')
  set ttymouse=sgr
endif

runtime! ftplugin/man.vim
if exists(':Man')
  set keywordprg=:Man
endif

filetype plugin on
syntax on

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let NERDTreeShowHidden=1
cnoreabbrev Show NERDTreeFind

iabbr date] <C-r>=strftime('%Y-%m-%d')<CR><ESC>
iabbr datet] <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<CR><ESC>
iabbr datew] <C-r>=strftime('%G-W%V')<CR><ESC>
iabbr modeline] <C-r>=printf(&cms, printf('vi: set sw=%d sts=%d%s ft=%s fdm=%s:',
  \ &sw, &sts, &et ? ' et' : '', &ft, &fdm))<CR><ESC>

if $DOTFILES
  set rtp+=$DOTFILES/vim
else
  set rtp+=~/dotfiles/vim
endif

colorscheme basic

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
