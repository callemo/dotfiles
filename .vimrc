set nocompatible

set autoindent
set autoread
set backspace=indent,eol,start
set cmdheight=2
set commentstring=#\ %s
set complete-=i
set completeopt-=preview
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set foldmethod=indent
set foldnestmax=3
set grepprg=grep\ -rnE\ $*\ /dev/null
set guioptions=
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set mouse=a
set nobackup
set nofoldenable
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set number
set path=.,,
set ruler
set shortmess=atI
set showcmd
set showtabline=2
set statusline=%n:%<%.99f\ %y%h%w%m
set statusline+=%r%=[cwd:%{getcwd()}]\ %-14.(%l,%c%V%)\ %P
set switchbuf=useopen,usetab,newtab
set textwidth=0
set title
set updatetime=400
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

if has('mouse_sgr')
  set ttymouse=sgr
endif

if exists('+macmeta')
  set macmeta
endif

filetype plugin indent on
let mapleader = ' '
let g:netrw_banner = 0
let g:netrw_list_hide = netrw_gitignore#Hide() . '^\./$,^\.\./$'

iabbr modeline` <C-r>=printf(
      \ &commentstring,
      \ printf('vim: set sw=%d sts=%d et fdm=%s:', &sw, &sts, &fdm))
      \ <CR><Esc>^2W

if isdirectory(expand('~/dotfiles/vim'))
  set rtp+=~/dotfiles/vim
endif

if isdirectory(expand('~/.fzf'))
  set rtp+=~/.fzf
  nnoremap <silent> <C-p> :call fzf#run(fzf#wrap({'options': '--reverse'}))<CR>
endif

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
