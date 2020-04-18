cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

nnoremap <silent> <C-l> :nohlsearch<CR>:syntax sync fromstart<CR>

nnoremap <silent> <leader>D :Dump<CR>
nnoremap <silent> <leader>e :tabedit <C-r>=expand('%:p:h')<CR>/
nnoremap <silent> <leader>l :ls<CR>
nnoremap <silent> <leader>o :browse filter 
      \ /^<C-r>=escape(fnamemodify(getcwd(), ':~'), '~/\.')<CR>/ oldfiles<CR>
nnoremap <silent> <leader>r :registers<CR>
nnoremap <silent> <leader>t :tags<CR>
nnoremap <silent> <leader>. :lcd %:p:h<CR>
nnoremap <silent> <leader>q :exe bufnr('$') == 1 ? 'quit' : 'bdelete'<CR>
nnoremap <silent> <leader>w :silent write!<CR>

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
