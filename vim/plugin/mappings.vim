" Normal {{{
nmap + <c-w>+
nmap - <c-w>-
nmap <down> <c-d>
nmap <up> <c-u>
nnoremap <c-l> :noh \| syntax sync fromstart \| redraw!<cr>
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
nnoremap <leader>n :edit <c-r>=strftime('%Y%m%d%H%M')<cr>-
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
" Pairs {{{
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
" Visual {{{
vnoremap # :call dotfiles#SetVisualSearch()<cr>?<cr>
vnoremap * :call dotfiles#SetVisualSearch()<cr>/<cr>
vnoremap <leader>! :Cmd<space>
vnoremap <leader><cr> :Send<cr>
vnoremap <leader>p "*p
vnoremap <leader>x "*x
vnoremap <leader>y "*y
" }}}
" Insert {{{
inoremap <c-a> <home>
inoremap <c-e> <end>
" }}}
" Command {{{
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>
" }}}
" Terminal {{{
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

