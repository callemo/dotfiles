function! dotfiles#BufferOnly() abort
  let l:keep = bufnr()
  silent bufdo if bufnr() != l:keep | exec 'bdelete ' . bufnr() | endif
endfunction

function! dotfiles#Camelize(term) abort
  return a:term->substitute('[^A-Za-z0-9]\+\([A-Za-z0-9]\)', '\u\1', 'g')
endfunction

function! dotfiles#Underscore(term) abort
  return a:term->substitute('\([a-z]\)\([A-Z]\)', '\1_\l\2', 'g')->tolower()
endfunction

function! dotfiles#Dasherize(term) abort
  return dotfiles#Underscore(a:term)->tr('_', '-')
endfunction

function! dotfiles#FormatFile(...) abort
  let l:fallback = 'prettier --write --print-width 88'
  let l:formatters = {
        \ 'python': 'black',
        \ }
  let l:cmd = a:0 > 0 ? a:1 : l:formatters->get(&filetype, l:fallback)

  update

  let l:out = system(l:cmd . ' ' . expand('%:S'))
  if v:shell_error != 0
    echo out
  endif

  checktime
endfunction

function! dotfiles#SendTerminalKeys(start, end, ...) abort
  if a:0 > 0
    let l:buf = a:1
  elseif exists('w:send_terminal_buf')
    let l:buf = w:send_terminal_buf
  else
    echohl ErrorMsg
    echo 'No terminal link'
    echohl None
    return
  endif

  let l:keys = getline(a:start, a:end)->join(" \n")
  call term_sendkeys(l:buf, l:keys . "\n")
  let w:send_terminal_buf = l:buf
endfunction

function! dotfiles#SetVisualSearch() abort
  let l:reg = @"
  exe 'normal! vgvy'
  let @/ = '\m\C' . escape(@", "\\/.*'$^~[]")->substitute("\n$", '', '')
  let @" = l:reg
endfunction

function! dotfiles#TrimTrailingSpaces() abort
  let l:cursor = getpos('.')
  let l:last_search = @/
  silent! %s/\m\C\s\+$//e
  let @/ = l:last_search
  call setpos('.', l:cursor)
endfunction

function! dotfiles#TabLine() abort
  let l:s = ''
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      let l:s .= '%#TabLineSel#'
    else
      let l:s .= '%#TabLine#'
    endif
    let l:s .= '%' . (i + 1) . 'T'
    let l:s .= ' %{dotfiles#TabLabel(' . (i + 1) . ')} '
  endfor
  let l:s .= '%#TabLineFill#%T'
  return l:s
endfunction

function! dotfiles#TabLabel(n) abort
  let l:buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let l:bufnr = l:buflist[l:winnr - 1]
  let l:label = bufname(l:bufnr)

  if empty(l:label)
    let buftype = getbufvar(l:bufnr, '&buftype')
    if empty(buftype)
      return '[No Name]'
    endif
    return '[' . buftype . ']'
  endif

  if filereadable(l:label)
    let l:label = fnamemodify(l:label, ':p:t')
  elseif isdirectory(l:label)
    let l:label = fnamemodify(l:label, ':p:~')
  elseif l:label[-1:] == '/'
    let l:label = split(l:label, '/')[-1] . '/'
  else
    let l:label = split(l:label, '/')[-1]
  endif

  if getbufvar(l:bufnr, '&modified')
    return l:label .'+'
  endif
  return l:label
endfunction

