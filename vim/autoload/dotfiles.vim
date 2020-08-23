func! dotfiles#BufferOnly() abort
  let l:current = bufnr()
  for b in getbufinfo({'buflisted': v:true})
    if b.bufnr != l:current
      exe 'bdelete ' . b.bufnr
    endif
  endfor
endfunc

func! dotfiles#VisualSwitchCase(style) abort
  if a:style ==# 'camel'
    s/\m\C\%V.*\%V./\L&/ge
    s/\m\C\%V[^A-Za-z0-9]\+\([A-Za-z0-9]\)\%V/\u\1/ge
  elseif a:style ==# 'snake'
    s/\m\C\%V[^A-Za-z0-9_]\%V/_/ge
    s/\m\C\%V\([a-z]\)\([A-Z]\)\%V/\1_\l\2/ge
  elseif a:style ==# 'kebab'
    s/\m\C\%V[^A-Za-z0-9-]\%V/-/ge
    s/\m\C\%V\([a-z]\)\([A-Z]\)\%V/\1-\l\2/ge
  else
    echohl ErrorMsg | echo 'Unknown case style: ' . a:style | echohl None
  endif
  norm! `<
endfunc

func! dotfiles#VisualSwitchCaseComplete(A, L, P) abort
  return ['camel', 'snake', 'kebab']->filter('v:val =~ ("^" . a:A)' )
endfunc

func! dotfiles#LintFile() abort
  let l:linters = {
        \ 'css': 'stylelint',
        \ 'python': 'pylint',
        \ 'scss': 'stylelint',
        \ 'sh': 'shellcheck -f gcc',
        \ }
  let l:cmd = l:linters->get(&filetype, v:null)
  if l:cmd == v:null
    echohl ErrorMsg | echo 'No linter for ' . &filetype | echohl None
    return
  endif
  update
  let l:out = systemlist(l:cmd . ' ' . expand('%:S'))
  call setqflist([], 'r', {'title': l:cmd, 'lines': out})
  cwindow
  checktime
endfunc

func! dotfiles#FormatFile(...) abort
  let l:fallback = 'prettier --write --print-width 88'
  let l:formatters = {
        \ 'c': 'clang-format -i',
        \ 'cpp': 'clang-format -i',
        \ 'java': 'clang-format -i',
        \ 'python': 'black',
        \ }
  let l:cmd = a:0 > 0 ? a:1 : l:formatters->get(&filetype, l:fallback)
  update
  let l:out = system(l:cmd . ' ' . expand('%:S'))
  if v:shell_error != 0
    echo out
  endif
  checktime
endfunc

func! dotfiles#RunShellCommand(range, lnum, end, cmd) abort
  let l:input = a:range > 0 ? getline(a:lnum, a:end) : []
  let l:bufname = getcwd() . '/+Output'
  let l:winnr = bufwinnr('\m\C^' . l:bufname . '$')
  if l:winnr < 0
    exe 'botright new ' . l:bufname
    setl buftype=nofile nobuflisted noswapfile nonumber
    noremap <buffer> <2-LeftMouse> :wincmd F<CR>
  else
    exe l:winnr . 'wincmd w'
  endif
  silent let l:err = a:cmd->systemlist(l:input)->append(line('$') - 1)
  call line('$')->cursor('.')
endfunc

func! dotfiles#SendTerminalKeys(start, end, ...) abort
  if a:0 > 0
    let l:buf = a:1
  elseif exists('w:send_terminal_buf')
    let l:buf = w:send_terminal_buf
  else
    echohl ErrorMsg | echo 'No terminal link' | echohl None
    return
  endif

  let l:keys = getline(a:start, a:end)->join(" \n")
  call term_sendkeys(l:buf, l:keys . "\n")
  let w:send_terminal_buf = l:buf
endfunc

func! dotfiles#SetVisualSearch() abort
  let l:reg = @"
  exe 'normal! vgvy'
  let @/ = '\V\C' . escape(@", '\')->substitute("\n$", '', '')
  let @" = l:reg
endfunc

func! dotfiles#TrimTrailingBlanks() abort
  let l:last_pos = getcurpos()
  let l:last_search = @/
  silent! %s/\m\C\s\+$//e
  let @/ = l:last_search
  call setpos('.', l:last_pos)
endfunc

func! dotfiles#TabLine() abort
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
endfunc

func! dotfiles#TabLabel(n) abort
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
endfunc

" Consumes the space typed after an abbreviation.
func! dotfiles#EndAbbr() abort
  let l:ch = nr2char(getchar(0))
  return (ch =~# '\s') ? '' : ch
endfunc

