set nocompatible

let mapleader = ' '
let g:netrw_banner = 0
let g:netrw_list_hide = netrw_gitignore#Hide() . '^\./$,^\.\./$'

" Settings {{{
set backspace=indent,eol,start
set cmdheight=2
set complete-=i
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
set shortmess=atI
set showcmd
set showtabline=2
set statusline=%n:%<%.99f\ %{PasteMode()}%y%h%w%m%r%=[cwd:%{getcwd()}]\ %-14.(%l,%c%V%)\ %P
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

if exists('+macmeta')
  set macmeta
endif

set commentstring=#\ %s
set path=.,,

filetype plugin indent on
setglobal autoindent
setglobal textwidth=0
"Settings }}}
" Mappings {{{
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

nnoremap <leader>. :Lwd<CR>
nnoremap <leader>D :Dump<CR>
nnoremap <leader>e :tabedit <C-r>=expand('%:p:h')<CR>/
nnoremap <leader>l :ls<CR>
nnoremap <leader>o :browse filter /^<C-r>=escape(fnamemodify(getcwd(), ':~'), '~/\.')<CR>/ oldfiles<CR>
nnoremap <leader>r :registers<CR>
nnoremap <leader>t :tags<CR>
nnoremap <silent> <leader>q :if bufnr('$') == 1<Bar>quit<Bar>else<Bar>bdelete<Bar>endif<CR>
nnoremap <silent> <leader>w :silent write!<CR>

nnoremap <silent> <C-j> :if winnr() == winnr('$')<CR>silent !tmux select-pane -t :.+<CR>else<CR>wincmd w<CR>endif<CR>
nnoremap <silent> <C-k> :if winnr() == 1<CR>silent !tmux select-pane -t :.-<CR>else<CR>wincmd W<CR>endif<CR>

vnoremap * :call SetVisualSearch()<CR>/<CR>
vnoremap # :call SetVisualSearch()<CR>?<CR>

if has('clipboard')
  vnoremap <C-c> "*y
endif
" Mappings }}}
" Commands {{{
command! Dump mksession! ~/Session.vim
command! Load source ~/Session.vim
command! Lwd lcd %:p:h

command! Black call Format('black')
command! Prettier call Format('prettier --write')
command! TrimTrailingSpaces call TrimTrailingSpaces()

if has('terminal')
  command! -nargs=* -complete=file Win belowright terminal ++noclose ++kill=term ++shell ++rows=10 <args>
  command! -nargs=1 -range Send call term_sendkeys(<args>, join(getline(<line1>, <line2>), "\n") . "\n")
endif
" Commands }}}
" Functions {{{
function! PasteMode() abort
  if &paste
    return '[PASTE]'
  endif
  return ''
endfunction

function! ToggleBackground() abort
  if &background == 'dark'
    let &background = 'light'
  else
    let &background = 'dark'
  endif
endfunction

function! TrimTrailingSpaces() abort
  let cursor = getpos('.')
  let last_search = @/
  silent! %s/\s\+$//e
  let @/ = last_search
  call setpos('.', cursor)
endfunction

function! SetVisualSearch() abort
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

" Functions }}}
augroup config
  autocmd BufReadPost * exe "silent! normal! g'\""
  autocmd BufWritePre *.txt,*.js,*.py,*.sh :call TrimTrailingSpaces()
  autocmd FileType c,cpp setlocal path+=/usr/include
  autocmd FileType css,html,htmldjango,java,javascript,json,scss,sh,vim,xml,yaml setlocal sw=2 sts=2 et
  autocmd FileType python setlocal sw=4 sts=4 et
augroup end

iabbr modeline` <C-r>=printf(&commentstring, printf('vim: set sw=%d sts=%d et fdm=%s:', &sw, &sts, &fdm))<CR><Esc>^2W

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

" vim: set sw=2 sts=2 et fdm=marker:
