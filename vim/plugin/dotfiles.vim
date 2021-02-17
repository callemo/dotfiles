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
  au OptionSet * if &diff | setl nocursorline | endif

  if v:version > 800 && has('terminal')
    au TerminalOpen * setl nonumber | noremap <buffer> q i
  endif
augroup END
" }}}
" Commands: {{{
command -nargs=+ -complete=file -range
      \ Cmd call dotfiles#RunShellCommand(<range>, <line1>, <line2>, <q-args>)
command -nargs=1
      \ TabLabel let t:label = '<args>'

if has('terminal')
  command -nargs=? -range
        \ Send call dotfiles#SendTerminalKeys(<line1>, <line2>, <range>, <args>)
endif

command -nargs=1
      \ Dash exe 'silent !open dash://<args>' | redr!
command Lint call dotfiles#LintFile()
command -nargs=?
      \ Fmt call dotfiles#FormatFile(<f-args>)
command Bonly call dotfiles#BufferOnly()
command Trim call dotfiles#TrimTrailingBlanks()
" }}}
" Mappings: normal {{{
nmap + <c-w>+
nmap - <c-w>-
nmap <down> <c-e>
nmap <up> <c-y>
nnoremap <c-l> :noh<c-r>=has('diff')?'<bar>diffupdate':''<cr> \| syntax sync fromstart \| redraw!<cr>
nnoremap <c-w>+ :exe 'resize ' . (winheight(0) * 3/2)<cr>
nnoremap <c-w>- :exe 'resize ' . (winheight(0) * 2/3)<cr>
nnoremap <leader>! :Cmd<space>
nnoremap <leader>. :lcd %:p:h<cr>
nnoremap <leader><cr> :Send<cr>
nnoremap <leader>F :Fmt<cr>
nnoremap <leader>L :Lint<cr>
nnoremap <leader>b :buffers<cr>
nnoremap <leader>c :cclose<cr>
nnoremap <leader>e :split <c-r>=expand('%:p:h')<cr>/
nnoremap <leader>f :let @"=expand('%:p') \| let @*=@"<cr>
nnoremap <leader>p "*p
nnoremap <leader>r :registers<cr>
nnoremap <leader>y "*y

if empty(maparg('m<cr>'))
  if has('terminal')
    nnoremap m<cr> :terminal make<cr>
    nnoremap m<space> :terminal make<space>
  else
    nnoremap m<cr> make<cr>
    nnoremap m<space> make<space>
  endif
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
" Mappings: pairs {{{
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
" Mappings: visual {{{
vnoremap # :call dotfiles#SetVisualSearch()<cr>?<cr>
vnoremap * :call dotfiles#SetVisualSearch()<cr>/<cr>
vnoremap <leader>! :Cmd<space>
vnoremap <leader><cr> :Send<cr>
vnoremap <leader>p "*p
vnoremap <leader>x "*x
vnoremap <leader>y "*y
" }}}
" Mappings: insert {{{
inoremap <c-a> <home>
inoremap <c-e> <end>
" }}}
" Mappings: command {{{
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>
" }}}
" Mappings: terminal {{{
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
