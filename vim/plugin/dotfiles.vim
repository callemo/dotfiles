" Autocmds: {{{
augroup dotfiles
  au!
  au BufReadPost * exe "silent! norm! g'\""
  au BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | endif
  au FileType c,cpp setl sw=2 sts=2 et path+=/usr/include
  au FileType css,html,htmldjango,scss setl sw=2 sts=2 et iskeyword+=-
  au FileType gitcommit setl spell fdm=syntax fdl=1 iskeyword+=.,-
  au FileType java,javascript,json,typescript,vim,xml,yaml setl sw=2 sts=2 et
  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
  au InsertEnter,WinLeave * setl nocursorline
  au InsertLeave,WinEnter * setl cursorline
  au OptionSet * if &diff | setl nocursorline | endif

  if v:version > 800 && has('terminal')
    au TerminalOpen * setl nonumber | noremap <buffer> q i
  endif
augroup END
" }}}
" Commands: {{{
command -nargs=+ -complete=file -range Cmd
  \ call dotfiles#Cmd(<range>, <line1>, <line2>, <q-args>)

command -nargs=1 TabLabel let t:label = '<args>'

if has('terminal')
  command -nargs=? -range Send
    \ call dotfiles#Send(<range>, <line1>, <line2>, <args>)
endif

command -nargs=1 Dash exe 'silent !open dash://<args>' | redraw!
command Lint call dotfiles#LintFile()
command -nargs=? Fmt call dotfiles#FormatFile(<f-args>)
command Trim call dotfiles#TrimTrailingBlanks()
command -nargs=* Rg call dotfiles#Rg(<q-args>)
command -nargs=+ Bx call dotfiles#Bx(<f-args>)
command -nargs=+ By call dotfiles#By(<f-args>)
" }}}
" Maps: normal {{{
nnoremap <c-w>+ :exe 'resize ' . (winheight(0) * 3/2)<cr>
nnoremap <c-w>- :exe 'resize ' . (winheight(0) * 2/3)<cr>

nmap <down> <c-e>
nmap <up> <c-y>

nnoremap <c-l> :nohlsearch \|
  \ diffupdate \|
  \ syntax sync fromstart<cr><c-l>

nnoremap <leader>! :Cmd<space>
nnoremap <leader>. :lcd %:p:h<cr>
nnoremap <leader><cr> :Send<cr>
nnoremap <leader>F :Fmt<cr>
nnoremap <leader>L :Lint<cr>
nnoremap <leader>b :buffers<cr>
nnoremap <leader>cc :cclose<cr>
nnoremap <leader>co :copen \| wincmd p<cr>
nnoremap <leader>e :edit <c-r>=expand('%:h')<cr>/
nnoremap <leader>f :let @"=expand('%:p') \| let @*=@"<cr>
nnoremap <leader>gf :edit <cfile><cr>
nnoremap <leader>p "*p
nnoremap <leader>r :registers<cr>
nnoremap <leader>y "*y

if has('macunix')
  nnoremap gx :silent !open '<cfile>'<cr>
elseif has('unix')
  nnoremap gx :silent !xdg-open '<cfile>'<cr>
endif

if !empty($TMUX)
  nnoremap <expr> <silent> <c-j> winnr() == winnr('$') ?
        \ ':silent !tmux selectp -t :.+<cr>' : ':wincmd w<cr>'
  nnoremap <expr> <silent> <c-k> winnr() == 1 ?
        \ ':silent !tmux selectp -t :.-<cr>' : ':wincmd W<cr>'
else
  nnoremap <silent> <c-j> :wincmd w<cr>
  nnoremap <silent> <c-k> :wincmd W<cr>
endif
" }}}
" Maps: pairs {{{
nnoremap ]a :next<cr>
nnoremap [a :previous<cr>
nnoremap ]b :bnext<cr>
nnoremap [b :bprevious<cr>
nnoremap ]l :lnext<cr>
nnoremap [l :lprevious<cr>
nnoremap ]q :cnext<cr>
nnoremap [q :cprevious<cr>
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprevious<cr>
nnoremap yob :set background=<c-r>=&background == 'light' ? 'dark' : 'light'<cr><cr>
nnoremap yoc :setl invcursorline<cr>
nnoremap yoh :setl invhlsearch<cr>
nnoremap yol :setl invlist<cr>
nnoremap yon :setl invnumber<cr>
nnoremap yop :setl invpaste<cr>
nnoremap yor :setl invrelativenumber<cr>
nnoremap yos :setl invspell<cr>
nnoremap yow :setl invwrap<cr>
" }}}
" Maps: visual {{{
vnoremap * :call dotfiles#SetVisualSearch()<cr>/<cr>
vnoremap <leader>! :<c-u>call dotfiles#CmdVisual()<cr>
vnoremap <leader><cr> :Send<cr>
vnoremap <leader>p "*p
vnoremap <leader>x "*x
vnoremap <leader>y "*y
" }}}
" Maps: insert {{{
inoremap <c-a> <home>
inoremap <c-e> <end>
" }}}
" Maps: command {{{
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>
" }}}
" Maps: terminal {{{
if has('terminal')
  tnoremap <c-r><c-r> <c-r>
  tnoremap <c-w>+ <c-w>:exe 'resize ' . (winheight(0) * 3/2)<cr>
  tnoremap <c-w>- <c-w>:exe 'resize ' . (winheight(0) * 2/3)<cr>
  tnoremap <c-w><c-w> <c-w>.
  tnoremap <c-w>[ <c-\><c-n>
  tnoremap <scrollwheelup> <c-\><c-n>
  tnoremap <expr> <c-r> '<c-w>"' . nr2char(getchar())
  if !empty($TMUX)
    tnoremap <expr> <silent> <c-j> winnr() == winnr('$') ?
          \ '<c-w>:silent !tmux selectp -t :.+<cr>' : '<c-w>:wincmd w<cr>'
    tnoremap <expr> <silent> <c-k> winnr() == 1 ?
          \ '<c-w>:silent !tmux selectp -t :.-<cr>' : '<c-w>:wincmd W<cr>'
  else
    tnoremap <silent> <c-j> <c-w>:wincmd w<cr>
    tnoremap <silent> <c-k> <c-w>:wincmd W<cr>
  endif
endif
" }}}
" Maps: mouse {{{
"
" MacVim interprets ctrl-click as right-click. To disable this type:
"   defaults write org.vim.MacVim MMTranslateCtrlClick 0
"
nnoremap <c-leftmouse> <leftmouse>gF
nnoremap <c-rightmouse> <c-o>
nnoremap <middlemouse> <leftmouse>:Cmd <c-r><c-w><cr>
nnoremap <rightmouse> <leftmouse>*

nmap <c-a-leftmouse> <middlemouse>

vmap <c-a-leftmouse> <leader>!
vmap <middlemouse> <leader>!
vmap <rightmouse> *
" }}}
" vi: set sw=2 sts=2 et fdm=marker :
