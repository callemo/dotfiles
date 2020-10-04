func! wiki#Load() abort
  if exists('g:loaded_wiki')
    return
  endif
  let g:loaded_wiki = 1

  augroup wiki
    au!
    au FileType vimwiki setl ts=4 sw=4 sts=4 iskeyword+=-
  augroup END

  if !exists('g:vimwiki_list')
    let g:vimwiki_list = [{
          \ 'path': '~/wiki',
          \ 'path_html': '~/wiki/html',
          \ 'template_ext': '.html',
          \ 'template_path': '~/wiki/templates',
          \ 'css_name': 'style/style.css'
          \ }]
  endif

  packadd vimwiki
endfunc

func! wiki#Open() abort
  call wiki#Load()
  VimwikiIndex
endfunc
