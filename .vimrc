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
set foldmethod=marker
set foldnestmax=3
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set mouse=a
set mousemodel=extend
set nobackup
set nofoldenable
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set number
set path=.,,
set ruler
set sessionoptions=buffers,folds,help,tabpages,terminal,winpos,winsize
set shortmess=atI
set showcmd
set showtabline=2
set switchbuf=useopen,split
set tabline=%!dotfiles#TabLine()
set textwidth=0
set title
set updatetime=300
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

set statusline=%n:%<%.99f\ %y%h%w%m
set statusline+=%{&paste\ ?\ '[PASTE]'\ :\ ''}
set statusline+=%r%=[dir:%{getcwd()}]\ %-14.(%l,%c%V%)\ %P

if has('unix')
  set grepprg=grep\ -rnE\ $*\ /dev/null
endif

if has('mouse_sgr')
  set ttymouse=sgr
endif

let mapleader = "\<Space>"

filetype plugin indent on
syntax on

let g:netrw_banner = 0
let g:netrw_list_hide = netrw_gitignore#Hide() . ',^\./$,^\.\./$'
let g:ragtag_global_maps = 1

iabbr modeline` <C-r>=printf(
      \ &commentstring,
      \ printf('vim: set sw=%d sts=%d et fdm=%s:', &sw, &sts, &fdm))
      \ <CR><Esc>^2W

if isdirectory(expand('~/dotfiles/vim'))
  set rtp+=~/dotfiles/vim
  colorscheme basic
endif

if isdirectory(expand('~/.fzf'))
  set rtp+=~/.fzf
  nnoremap <silent> <C-p> :call fzf#run(fzf#wrap({'options': '--reverse'}))<CR>
endif

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
