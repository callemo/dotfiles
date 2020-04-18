cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

nnoremap <silent> <C-l> :nohlsearch<CR>:syntax sync fromstart<CR>

nnoremap <leader>D :Dump<CR>
nnoremap <leader>e :tabedit <C-r>=expand('%:p:h')<CR>/
nnoremap <leader>l :ls<CR>
nnoremap <leader>o :browse
      \ filter /^<C-r>=escape(fnamemodify(getcwd(), ':~'), '~/\.')<CR>/ oldfiles<CR>
nnoremap <leader>r :registers<CR>
nnoremap <leader>t :tags<CR>
nnoremap <leader>. :lcd %:p:h<CR>
nnoremap <leader>q :if bufnr('$') == 1<CR>quit<CR>else<CR>bdelete<CR>endif<CR>
nnoremap <leader>w :silent write!<CR>

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

nnoremap yob :set background=<C-R>=&background == "dark" ?
      \ "light" : "dark"<CR><CR>
nnoremap yoh :setlocal invhlsearch<CR>
nnoremap yol :setlocal invlist<CR>
nnoremap yon :setlocal invnumber<CR>
nnoremap yop :setlocal invpaste<CR>
nnoremap yos :setlocal invspell<CR>
nnoremap yow :setlocal invwrap<CR>

nnoremap m<CR> :make<CR>
nnoremap m<Space> :make<Space>

nnoremap <silent> <C-j> :if winnr() == winnr('$')<CR>
      \ silent !tmux select-pane -t :.+<CR>
      \ else<CR>
      \ wincmd w<CR>
      \ endif<CR>
nnoremap <silent> <C-k> :if winnr() == 1<CR>
      \ silent !tmux select-pane -t :.-<CR>
      \ else<CR>
      \ wincmd W<CR>
      \ endif<CR>

vnoremap * :call dotfiles#SetVisualSearch()<CR>/<CR>
vnoremap # :call dotfiles#SetVisualSearch()<CR>?<CR>

if has('clipboard')
  vnoremap <C-c> "*y
endif
