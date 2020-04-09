set nocompatible

set backspace=indent,eol,start
set cmdheight=2
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
set shortmess=at
set showcmd
set showtabline=2
set statusline=%n:%<%.99f\ %{PasteMode()}%y%h%w%m%r%=%-14.(%l,%c%V%)\ %P
set switchbuf=useopen,usetab,newtab
set title
set t_ut=
set updatetime=400
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime

set mouse=a
if has("mouse_sgr")
  set ttymouse=sgr
endif

setglobal commentstring=#\ %s
setglobal path=.,,

filetype plugin indent on
set autoindent
set textwidth=0

let g:netrw_banner = 0
let g:netrw_list_hide = "^\./$,^\.\./$"

let mapleader = " "

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

nnoremap yob :call ToggleBackground()<CR>
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
nnoremap <leader>e :tabedit <C-r>=expand("%:p:h")<CR>/
nnoremap <leader>l :ls<CR>
nnoremap <silent> <leader>q :if bufnr("$") == 1<Bar>quit<Bar>else<Bar>bdelete<Bar>endif<CR>
nnoremap <silent> <leader>w :silent write!<CR>

nnoremap <silent> <C-j> :if winnr() == winnr("$")<CR>silent !tmux select-pane -t :.+<CR>else<CR>wincmd w<CR>endif<CR>
nnoremap <silent> <C-k> :if winnr() == 1<CR>silent !tmux select-pane -t :.-<CR>else<CR>wincmd W<CR>endif<CR>

vnoremap * :call SetVisualSearch()<CR>/<CR>
vnoremap # :call SetVisualSearch()<CR>?<CR>

if has("clipboard")
  vnoremap <C-c> "*y
else
  if has("unix") && system("uname")[0:-2] ==# "Darwin"
    vnoremap <C-c> :write !pbcopy<CR>
  endif
endif

command! Black call Format("black")
command! -nargs=* -complete=dir Ctags belowright terminal ++norestore ++rows=12 ++close ++shell ctags -R <args>
command! Dump mksession! Session.vim
command! Load source Session.vim
command! Prettier call Format("prettier --write")
command! TrimTrailingSpaces call TrimTrailingSpaces()

function! PasteMode()
  if &paste
    return "[PASTE]"
  endif
  return ""
endfunction

function! ToggleBackground()
  if &background == "dark"
    let &background = "light"
  else
    let &background = "dark"
  endif
endfunction

function! TrimTrailingSpaces() abort
  let cursor = getpos(".")
  let last_search = @/
  silent! %s/\s\+$//e
  let @/ = last_search
  call setpos(".", cursor)
endfunction

function! SetVisualSearch()
  let reg = @"
  execute "normal! vgvy"
  let pattern = escape(@", "\\/.*'$^~[]")
  let pattern = substitute(pattern, "\n$", "", "")
  let @/ = pattern
  let @" = reg
endfunction

function! Format(command) abort
  update
  execute "!" . a:command . expand(" %")
  checktime
endfunction

augroup config
  autocmd BufReadPost * exe "silent! normal! g'\""
  autocmd BufWritePre *.txt,*.js,*.py,*.sh :call TrimTrailingSpaces()
  autocmd FileType c,cpp setlocal path+=/usr/include
  autocmd FileType css,html,htmldjango,java,javascript,json,scss,sh,vim,xml,yaml setlocal sw=2 sts=2 et
  autocmd FileType python setlocal sw=4 sts=4 et
augroup end

iabbr modeline` <C-r>=printf(&commentstring, printf(" vim: set sw=%d sts=%d et fdm=%s: ", &sw, &sts, &fdm))<CR><Esc>^3W

if isdirectory(expand("~/dotfiles/vim"))
  set rtp+=~/dotfiles/vim
endif

if isdirectory(expand("~/.fzf"))
  set rtp+=~/.fzf
  nnoremap <silent> <C-p> :call fzf#run(fzf#wrap({"options": "--reverse"}))<CR>
  nnoremap <silent> <leader>o :call fzf#run(fzf#wrap({
        \ "source": filter(copy(v:oldfiles), "filereadable(fnamemodify(v:val, ':p'))"),
        \ "options": "--reverse"
        \ }))<CR>
endif

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" vim: set sw=2 sts=2 et fdm=indent: 
