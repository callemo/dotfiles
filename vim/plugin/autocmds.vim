augroup dotfiles
  au!
  au BufReadPost * exe "silent! norm! g'\""
  au BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | endif
  au FileType c,cpp setl sw=2 sts=2 et path+=/usr/include
  au FileType css,html,htmldjango,scss setl sw=2 sts=2 et iskeyword+=-
  au FileType gitcommit setl spell fdm=syntax fdl=1 iskeyword+=.,-
  au FileType java,javascript,json,typescript,vim,xml,yaml setl sw=2 sts=2 et
  au FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
  au OptionSet * if &diff | setl nocursorline | endif

  if v:version > 800 && has('terminal')
    au TerminalOpen * setl nonumber | noremap <buffer> <2-LeftMouse> :wincmd F<CR>
  endif
augroup END

