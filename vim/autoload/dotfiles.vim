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

function! dotfiles#ToggleBackground() abort
  if &background == 'dark'
    let &background = 'light'
  else
    let &background = 'dark'
  endif
endfunction

function! dotfiles#TrimTrailingSpaces() abort
  let cursor = getpos('.')
  let last_search = @/
  silent! %s/\s\+$//e
  let @/ = last_search
  call setpos('.', cursor)
endfunction

