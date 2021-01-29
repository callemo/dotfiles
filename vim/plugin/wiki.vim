let g:vimwiki_url_maxsave = 0

augroup wiki
  au!
  au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
  au FileType vimwiki iabbr note\ Title: <CR>Date: <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<CR><CR>Tags:<ESC><Up><Up>
augroup END

command Wiki :call wiki#Open()
