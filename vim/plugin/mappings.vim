" Normal {{{
nmap <Up> <C-U>
nmap <Down> <C-D>
nnoremap <silent> <C-l> :noh \| syntax sync fromstart<CR>
nnoremap - :Explore<CR>
nnoremap <Leader>! :Cmd<Space>
nnoremap <silent> <Leader>. :lcd %:p:h<CR>
nnoremap <Leader>D :Dump<CR>
nnoremap <Leader>K :Dash <C-r>=expand('<cword>')<CR><CR>
nnoremap <Leader>b :buffers<CR>
nnoremap <Leader>c :Chk<CR>
nnoremap <silent> <Leader>d :bdelete<CR>
nnoremap <Leader>e :split <C-r>=expand('%:p:h')<CR>/
nnoremap <Leader>f :Fmt<CR>
nnoremap <Leader>p "*p
nnoremap <Leader>r :registers<CR>
nnoremap <Leader>s :Send<CR>
nnoremap <silent> <Leader>w :silent write!<CR>
nnoremap <Leader>y "*yy

if empty(maparg('m<CR>'))
  nnoremap m<CR> :Win make<CR>
  nnoremap m<Space> :Win make<Space>
endif

if !empty($TMUX)
  nnoremap <expr> <silent> <C-j> winnr() == winnr('$') ?
        \ ':silent !tmux selectp -t :.+<CR>' : ':wincmd w<CR>'
  nnoremap <expr> <silent> <C-k> winnr() == 1 ?
        \ ':silent !tmux selectp -t :.-<CR>' : ':wincmd W<CR>'
else
  nnoremap <silent> <C-j> :wincmd w<CR>
  nnoremap <silent> <C-k> :wincmd W<CR>
endif
" }}}
" Pairs {{{
nnoremap ]a :next<CR>
nnoremap [a :previous<CR>
nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprevious<CR>
nnoremap yob :set background=<C-R>=&background == 'light' ? 'dark' : 'light'<CR><CR>
nnoremap yoc :setl invcursorline<CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>
" }}}
" Visual {{{
vnoremap # :call dotfiles#SetVisualSearch()<cr>?<cr>
vnoremap * :call dotfiles#SetVisualSearch()<CR>/<CR>
vnoremap <Leader>! :Cmd<Space>
vnoremap <Leader>~ :<C-u>SwitchCase<Space>
vnoremap <Leader>p "*p
vnoremap <Leader>s :Send<CR>
vnoremap <Leader>x "*x
vnoremap <Leader>y "*y
" }}}
" Insert {{{
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-Enter> <C-o>o
inoremap <C-j> <Down>
inoremap <C-k> <Up>
" }}}
" Command {{{
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
" }}}
" Terminal {{{
tnoremap <expr> <C-r> '<C-w>"' . nr2char(getchar())
tnoremap <C-r><C-r> <C-r>
tnoremap <C-w><C-b> <C-\><C-n><C-b>
tnoremap <C-w><C-w> <C-w>.
tnoremap <ScrollWheelUp> <C-\><C-n>
if !empty($TMUX)
  tnoremap <expr> <silent> <C-j> winnr() == winnr('$') ?
        \ '<C-w>:silent !tmux selectp -t :.+<CR>' : '<C-w>:wincmd w<CR>'
  tnoremap <expr> <silent> <C-k> winnr() == 1 ?
        \ '<C-w>:silent !tmux selectp -t :.-<CR>' : '<C-w>:wincmd W<CR>'
else
  tnoremap <silent> <C-j> <C-w>:wincmd w<CR>
  tnoremap <silent> <C-k> <C-w>:wincmd W<CR>
endif
" }}}

