set nocompatible

set autoindent
set autoread
set backspace=indent,eol,start
set cmdheight=2
set commentstring=#\ %s
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

if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

if has('unix')
  if executable('ag')
    set grepprg=ag\ --vimgrep
  else
    set grepprg=grep\ -EnRI\ --exclude-dir\ .git\ --exclude-dir\ node_modules\ $*\ /dev/null
  endif
endif

if has('mouse_sgr')
  set ttymouse=sgr
endif

filetype plugin indent on
syntax on

let g:netrw_banner = 0
let g:netrw_mousemaps = 0

iabbr date\ <C-r>=strftime('%Y-%m-%d')<CR><ESC>
iabbr datetime\ <C-r>=strftime('%Y-%m-%d %H:%M:%S')<CR><ESC>
iabbr modeline\ <C-r>=printf('vi: set sw=%d sts=%d et ft=%s :', &sw, &sts, &ft)<CR><ESC>

set rtp+=$DOTFILES/vim
set keywordprg=:Cmd\ PAGER=nobs\ man
colorscheme basic

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
