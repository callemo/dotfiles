# Dotfiles
Configuration files.

## Vim extras

Example `~/.vimrc.local`:
```vim
" /usr/local/bin/python3 -m pip install --user --upgrade pynvim
let g:python3_host_prog = '/usr/local/bin/python3'
let g:deoplete#enable_at_startup = 1
let g:neosnippet#enable_snipmate_compatibility = 1
packadd nvim-yarp
packadd vim-hug-neovim-rpc
packadd deoplete.nvim
packadd deoplete-jedi
packadd neosnippet.vim
packadd neosnippet-snippets
packadd vim-snippets
imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
```
