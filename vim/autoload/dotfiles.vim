function! dotfiles#Format(command) abort
  update
  execute '!' . a:command . expand(' %')
  checktime
endfunction

function! dotfiles#SetVisualSearch() abort
  let reg = @"
  execute 'normal! vgvy'
  let pattern = escape(@", "\\/.*'$^~[]")
  let pattern = substitute(pattern, "\n$", '', '')
  let @/ = pattern
  let @" = reg
endfunction

function! dotfiles#TrimTrailingSpaces() abort
  let cursor = getpos('.')
  let last_search = @/
  silent! %s/\m\C\s\+$//e
  let @/ = l:last_search
  call setpos('.', l:cursor)
endfunction

function! dotfiles#TabLine() abort
  let s = ''
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= '%' . (i + 1) . 'T'
    let s .= ' %{dotfiles#TabLabel(' . (i + 1) . ')} '
  endfor
  let s .= '%#TabLineFill#%T'
  return s
endfunction

function! dotfiles#TabLabel(n) abort
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let bufnr = buflist[winnr - 1]
  let label = bufname(bufnr)
  let buftype = getbufvar(bufnr, '&buftype')
  if empty(label)
    if empty(buftype)
      return '[No Name]'
    endif
    return '[' . buftype . ']'
  endif
  if filereadable(label)
    let label = fnamemodify(label, ':p:t')
  elseif isdirectory(label)
    let label = fnamemodify(label, ':~:.') . '/'
  elseif label[-1:] == '/'
    let label = split(label, '/')[-1] . '/'
  else
    let label = split(label, '/')[-1]
  endif
  let modified = getbufvar(bufnr, '&modified')
  if modified
    let label = label .'+'
  endif
  return label
endfunction

