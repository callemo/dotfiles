augroup dotfiles
  au!
  au BufReadPost * exe "silent! norm! g'\""
  au FileType c,cpp setl sw=2 sts=2 et path+=/usr/include
  au FileType css,html,htmldjango,scss setl sw=2 sts=2 et iskeyword+=-
  au FileType gitcommit setl spell fdm=syntax fdl=1 iskeyword+=.,-
  au FileType java,javascript,json,vim,xml,yaml setl sw=2 sts=2 et
  au FileType netrw setl statusline=%F
  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
  au OptionSet * if &diff | setl nocursorline | endif
  au TerminalOpen * setl nonumber | noremap <buffer> <2-LeftMouse> :wincmd F<CR>
augroup END

