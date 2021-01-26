let g:vimwiki_url_maxsave = 0

augroup wiki
  au!
  au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
augroup END

command Wiki :call wiki#Open()
