func! wiki#Load() abort
  if exists('g:loaded_wiki')
    finish
  endif
  let g:loaded_wiki = 1

  augroup wiki
    au!
    au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
  augroup END

  packadd vimwiki
endfunc

func! wiki#Open() abort
  call wiki#Load()
  VimwikiIndex
endfunc


