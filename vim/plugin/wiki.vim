let g:vimwiki_url_maxsave = 0

augroup wiki
  au!
  au FileType vimwiki cnorea <buffer> Go VimwikiGoto
  au FileType vimwiki cnorea <buffer> Note edit
    \ <c-r>=expand('%:p:h') . '/' . strftime('%Y%m%d%H%M')<cr>
  au FileType vimwiki iabbr <buffer> head] Title: <CR>
    \Date: <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<CR><CR>
    \Tags:<ESC><Up><Up>
  au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
augroup END

command Wiki :call wiki#Open()
