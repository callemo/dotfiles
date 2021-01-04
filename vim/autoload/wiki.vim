func! wiki#Load() abort
  if exists('g:loaded_wiki')
    return
  endif
  let g:loaded_wiki = 1

  let g:vimwiki_url_maxsave = 0

  augroup wiki
    au!
    au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
  augroup END

  packadd vimwiki
endfunc

func! wiki#Open() abort
  call wiki#Load()
  VimwikiUISelect
endfunc
