augroup dotfiles
  au!
  au BufReadPost * exe "silent! normal! g'\""

  au FileType java,javascript,json,sh,vim,xml,yaml setlocal sw=2 sts=2 et
  au FileType css,html,htmldjango,scss setlocal sw=2 sts=2 et iskeyword+=-
  au FileType c,cpp setlocal path+=/usr/include
  au FileType netrw setlocal statusline=%F

  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
augroup END

