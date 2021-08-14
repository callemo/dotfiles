function! dotfiles#GetVisualText() abort " {{{
  let reg = @"
  exe 'normal! vgvy'
  let text = @"
  let @" = reg
  return text
endfunction

" }}}
function! dotfiles#LintFile() abort " {{{
  let linters = {
        \ 'css': 'stylelint',
        \ 'python': 'pylint',
        \ 'scss': 'stylelint',
        \ 'sh': 'shellcheck -f gcc',
        \ }
  let cmd = get(linters, &filetype, v:null)
  if cmd == v:null
    echohl ErrorMsg | echo 'No linter for ' . &filetype | echohl None
    return
  endif
  update
  let out = systemlist(cmd . ' ' . expand('%:S'))
  call setqflist([], 'r', {'title': cmd, 'lines': out})
  checktime
  botright cwindow
  silent! cfirst
endfunction

" }}}
function! dotfiles#FormatFile(...) abort " {{{
  let fallback = 'prettier --write --print-width 88'
  let formatters = {
        \ 'c': 'clang-format -i',
        \ 'cpp': 'clang-format -i',
        \ 'go': 'gofmt -w',
        \ 'java': 'clang-format -i',
        \ 'python': 'black',
        \ }
  let cmd = a:0 > 0 ? a:1 : get(formatters, &filetype, fallback)
  update
  let out = system(cmd . ' ' . expand('%:S'))
  if v:shell_error != 0
    echo out
  endif
  checktime
endfunction

" }}}
function! dotfiles#Cmd(range, line1, line2, cmd) abort " {{{
  let bufnr = bufnr()
  let bufname = getcwd() . '/+Errors'
  let winnr = bufwinnr('\m\C^' . bufname . '$')
  if winnr < 0
    exe 'new ' . bufname
    setl buftype=nofile noswapfile nonumber
  else
    exe winnr . 'wincmd w'
  endif

  if has('job') && has('channel')
    let opts = { 'in_io': 'null', 'mode': 'raw',
      \ 'out_io': 'buffer', 'out_name': bufname,
      \ 'err_io': 'buffer', 'err_name': bufname,
      \ 'exit_cb': 'dotfiles#HandleCmdExit' }
    if a:range > 0
      let opts.in_io = 'buffer'
      let opts.in_buf = bufnr
      let opts.in_top = a:line1
      let opts.in_bot = a:line2
    endif
    call job_start([&sh, &shcf, a:cmd], opts)
  else
    let input = a:range > 0 ? getline(a:line1, a:line2) : []
    silent let err = append(line('$') - 1, systemlist(a:cmd, input))
    call cursor(line('$'), '.')
  endif
endfunction

" }}}
function! dotfiles#HandleCmdExit(job, code) abort " {{{
  let prog = split(job_info(a:job).cmd[2])[0]
  let msg = prog . ': exit ' . a:code
  if a:code > 0
    echohl ErrorMsg | echom msg | echohl None
  else
    echom msg
  endif
endfunction

" }}}
function! dotfiles#CmdVisual() " {{{
  call dotfiles#Cmd(0, v:null, v:null, escape(dotfiles#GetVisualText(), '%#'))
endfunction

" }}}
function! dotfiles#Send(range, start, end, ...) abort " {{{
  if a:0 > 0
    let buf = a:1
  elseif exists('w:send_terminal_buf')
    let buf = w:send_terminal_buf
  else
    echohl ErrorMsg | echo 'No terminal link' | echohl None
    return
  endif

  let keys = join(getline(a:start, a:end), "\n")
  call term_sendkeys(buf, keys)
  if a:range
    call term_sendkeys(buf, "\n")
  endif
  let w:send_terminal_buf = buf
endfunction

" }}}
function! dotfiles#SetVisualSearch() abort " {{{
  let @/ = substitute('\V\C' . escape(dotfiles#GetVisualText(), '\'), "\n$", '', '')
endfunction

function! dotfiles#TrimTrailingBlanks() abort
  let last_pos = getcurpos()
  let last_search = @/
  silent! %s/\m\C\s\+$//e
  let @/ = last_search
  call setpos('.', last_pos)
endfunction

function! dotfiles#TabLine() abort
  let s = ''
  for i in range(1, tabpagenr('$'))
    if i == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= '%' . i . 'T'
    let s .= ' %{dotfiles#TabLabel(' . i . ')} '
  endfor
  let s .= '%#TabLineFill#%T'
  return s
endfunction

" }}}
" TabLabel returns the a label string for the given tab number a:n. If t:label
" exists then returns it instead.
function! dotfiles#TabLabel(n) abort " {{{
  let tabl = gettabvar(a:n, 'label')
  if !empty(tabl)
    return a:n . ':' . tabl
  endif

  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let bufnr = buflist[winnr - 1]

  let label = bufname(bufnr)
  if empty(label)
    let buftype = getbufvar(bufnr, '&buftype')
    if empty(buftype)
      return a:n . ':' . '[No Name]'
    endif
    return a:n . ':' . '[' . buftype . ']'
  endif

  if filereadable(label)
    let label = fnamemodify(label, ':p:t')
  elseif isdirectory(label)
    let label = fnamemodify(label, ':p:~')
  elseif label[-1:] == '/'
    let label = split(label, '/')[-1] . '/'
  else
    let label = split(label, '/')[-1]
  endif

  let label = a:n . ':' . label
  if getbufvar(bufnr, '&modified')
    return label .'+'
  endif
  return label
endfunction

" }}}
function! dotfiles#Rg(args) abort " {{{
  let oprg = &grepprg
  let &grepprg = 'rg --vimgrep'
  exec 'grep' a:args
  let &grepprg = oprg
  botright cwindow
  silent! cfirst
endfunction

" }}}
function! dotfiles#Bx(regexp, command) " {{{
  let prev = bufnr('%')
  for b in getbufinfo({'buflisted': 1})
    if b.name =~# a:regexp
      exe 'buffer' b.bufnr
      exe a:command
    endif
  endfor
  exe buflisted(prev) ? 'buffer ' . prev : 'bfirst'
endfunction

" }}}
function! dotfiles#By(regexp, command) abort " {{{
  let prev = bufnr('%')
  for b in getbufinfo({'buflisted': 1})
    if b.name !~# a:regexp
      exe 'buffer' b.bufnr
      exe a:command
    endif
  endfor
  exe buflisted(prev) ? 'buffer ' . prev : 'bfirst'
endfunction

" }}}
" vi: set sw=2 sts=2 et ft=vim fdm=marker:
