func! dotfiles#GetVisualText() abort
  let l:reg = @"
  exe 'normal! vgvy'
  let l:text = @"
  let @" = l:reg
  return l:text
endfunc

func! dotfiles#BufferOnly() abort
  let l:current = bufnr()
  for b in getbufinfo({'buflisted': v:true})
    if b.bufnr != l:current
      exe 'bdelete ' . b.bufnr
    endif
  endfor
endfunc

func! dotfiles#LintFile() abort
  let l:linters = {
        \ 'css': 'stylelint',
        \ 'python': 'pylint',
        \ 'scss': 'stylelint',
        \ 'sh': 'shellcheck -f gcc',
        \ }
  let l:cmd = get(l:linters, &filetype, v:null)
  if l:cmd == v:null
    echohl ErrorMsg | echo 'No linter for ' . &filetype | echohl None
    return
  endif
  update
  let l:out = systemlist(l:cmd . ' ' . expand('%:S'))
  call setqflist([], 'r', {'title': l:cmd, 'lines': out})
  botright cwindow
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
  let l:cmd = a:0 > 0 ? a:1 : get(l:formatters, &filetype, l:fallback)
  update
  let l:out = system(l:cmd . ' ' . expand('%:S'))
  if v:shell_error != 0
    echo out
  endif
  checktime
endfunc

func! dotfiles#Cmd(range, line1, line2, cmd) abort
  let l:bufnr = bufnr()
  let l:bufname = getcwd() . '/+Errors'
  let l:winnr = bufwinnr('\m\C^' . l:bufname . '$')
  if l:winnr < 0
    exe 'new ' . l:bufname
    setl buftype=nofile noswapfile nonumber
  else
    exe l:winnr . 'wincmd w'
  endif

  if has('job') && has('channel')
    " FIXME:
    " - print return code (e.g. "progname: exit 126")
    let l:opts ={ 'in_io': 'null', 'mode': 'raw',
      \ 'out_io': 'buffer', 'out_name': l:bufname,
      \ 'err_io': 'buffer', 'err_name': l:bufname }
    if a:range > 0
      let l:opts.in_io = 'buffer'
      let l:opts.in_buf = l:bufnr
      let l:opts.in_top = a:line1
      let l:opts.in_bot = a:line2
    endif
    let l:job = job_start([&sh, &shcf, a:cmd], l:opts)
  else
    let l:input = a:range > 0 ? getline(a:line1, a:line2) : []
    silent let l:err = append(line('$') - 1, systemlist(a:cmd, l:input))
    call cursor(line('$'), '.')
  endif
endfunc

func! dotfiles#CmdVisual()
  call dotfiles#Cmd(0, v:null, v:null, escape(dotfiles#GetVisualText(), '%#'))
endfunc

func! dotfiles#Send(range, start, end, ...) abort
  if a:0 > 0
    let l:buf = a:1
  elseif exists('w:send_terminal_buf')
    let l:buf = w:send_terminal_buf
  else
    echohl ErrorMsg | echo 'No terminal link' | echohl None
    return
  endif

  let l:keys = join(getline(a:start, a:end), "\n")
  call term_sendkeys(l:buf, l:keys)
  if a:range
    call term_sendkeys(l:buf, "\n")
  endif
  let w:send_terminal_buf = l:buf
endfunc

func! dotfiles#SetVisualSearch() abort
  let @/ = substitute('\V\C' . escape(dotfiles#GetVisualText(), '\'), "\n$", '', '')
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
  for i in range(1, tabpagenr('$'))
    if i == tabpagenr()
      let l:s .= '%#TabLineSel#'
    else
      let l:s .= '%#TabLine#'
    endif
    let l:s .= '%' . i . 'T'
    let l:s .= ' %{dotfiles#TabLabel(' . i . ')} '
  endfor
  let l:s .= '%#TabLineFill#%T'
  return l:s
endfunc

" TabLabel returns the a label string for the given tab number a:n. If t:label
" exists then returns it instead.
func! dotfiles#TabLabel(n) abort
  let l:tabl = gettabvar(a:n, 'label')
  if !empty(l:tabl)
    return a:n . ':' . l:tabl
  endif

  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:bufnr = l:buflist[l:winnr - 1]

  let l:label = bufname(l:bufnr)
  if empty(l:label)
    let buftype = getbufvar(l:bufnr, '&buftype')
    if empty(buftype)
      return a:n . ':' . '[No Name]'
    endif
    return a:n . ':' . '[' . buftype . ']'
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

  let l:label = a:n . ':' . l:label
  if getbufvar(l:bufnr, '&modified')
    return l:label .'+'
  endif
  return l:label
endfunc

func! dotfiles#Rg(args) abort
  let l:oprg = &grepprg
  let &grepprg = 'rg --vimgrep'
  exec 'grep' a:args
  let &grepprg = l:oprg
  botright cwindow
endfunc
