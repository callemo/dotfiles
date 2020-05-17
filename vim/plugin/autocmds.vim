augroup dotfiles
  au!
  au BufReadPost * exe "silent! norm! g'\""
  au FileType c,cpp setl path+=/usr/include
  au FileType css,html,htmldjango,scss setl sw=2 sts=2 et iskeyword+=-
  au FileType java,javascript,json,vim,xml,yaml setl sw=2 sts=2 et
  au FileType netrw setl statusline=%F
  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
  au TerminalOpen * setl nonumber | noremap <buffer> <2-LeftMouse> :wincmd F<CR>
augroup END

