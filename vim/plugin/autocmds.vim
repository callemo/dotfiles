augroup dotfiles
  au!
  au BufReadPost * exe "silent! normal! g'\""

  au FileType css,html,htmldjango,java,javascript,json,scss,sh,vim,xml,yaml
        \ setlocal sw=2 sts=2 et
  au FileType c,cpp setlocal path+=/usr/include
  au FileType netrw setlocal statusline=%F
  au Filetype markdown setlocal spell

  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
augroup END

