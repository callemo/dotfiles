func! wiki#Load() abort
  if exists('g:loaded_wiki')
    return
  endif
  let g:loaded_wiki = 1

  packadd vimwiki
endfunc

func! wiki#Open() abort
  call wiki#Load()
  VimwikiUISelect
endfunc
