command -nargs=+ -complete=file -range
      \ Cmd call dotfiles#RunShellCommand(<range>, <line1>, <line2>, <q-args>)
command -nargs=1
      \ TabLabel let t:label = '<args>'

if has('terminal')
  command -nargs=? -range
        \ Send call dotfiles#SendTerminalKeys(<line1>, <line2>, <range>, <args>)
endif

command -nargs=1
      \ Dash exe 'silent !open dash://<args>' | redr!
command Lint call dotfiles#LintFile()
command -nargs=?
      \ Fmt call dotfiles#FormatFile(<f-args>)
command Bonly call dotfiles#BufferOnly()
command Trim call dotfiles#TrimTrailingBlanks()

command Wiki :call wiki#Open()
