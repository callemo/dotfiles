nnoremap <Leader>! :Cmd
nnoremap <Leader>!! :Cmd<Space><C-r><C-l>
nnoremap <silent> <Leader>. :lcd %:p:h<CR>
nnoremap <Leader>b :buffers<CR>
nnoremap <Leader>D :Dump<CR>
nnoremap <silent> <Leader>d :bdelete<CR>
nnoremap <Leader>e :tabedit <C-r>=expand('%:p:h')<CR>/
nnoremap <Leader>p "*p
nnoremap <Leader>r :registers<CR>
nnoremap <Leader>s :Send<CR>
nnoremap <silent> <Leader>w :silent write!<CR>

vnoremap <Leader>! :Cmd<Space>
vnoremap <Leader><S-`> :<C-u>ChangeCase<Space>
vnoremap <Leader>p "*p
vnoremap <Leader>x "*x
vnoremap <Leader>y "*y

nmap <Up> <C-U>
nmap <Down> <C-D>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-Enter> <C-o>o
inoremap <C-j> <Down>
inoremap <C-k> <Up>

tnoremap <C-w><C-b> <C-w>N<C-b>

vnoremap # :call dotfiles#SetVisualSearch()<cr>?<cr>
vnoremap * :call dotfiles#SetVisualSearch()<CR>/<CR>

nnoremap <silent> <C-l> :noh \| syntax sync fromstart<CR>

if empty(maparg('m<CR>'))
  nnoremap m<CR> :Win make<CR>
  nnoremap m<Space> :Win make<Space>
endif

if !empty($TMUX)
  nnoremap <expr> <silent> <C-j> winnr() == winnr('$') ? ':silent !tmux selectp -t :.+<CR>' : ':wincmd w<CR>'
  nnoremap <expr> <silent> <C-k> winnr() == 1 ? ':silent !tmux selectp -t :.-<CR>' : ':wincmd W<CR>'
else
  nnoremap <silent> <C-j> :wincmd w<CR>
  nnoremap <silent> <C-k> :wincmd W<CR>
endif

nnoremap - :Explore<CR>

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

