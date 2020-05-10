command -nargs=1
      \ Dash silent exe '!open dash://' . <q-args>
command Dump mksession! ~/vim.dump
command Load source ~/vim.dump
command -nargs=?
      \ Fmt call dotfiles#FormatFile(<f-args>)
command Bonly call dotfiles#BufferOnly()
command Trim call dotfiles#TrimTrailingBlanks()
command -nargs=1 -complete=customlist,dotfiles#VisualSwitchCaseComplete
      \ SwitchCase :call dotfiles#VisualSwitchCase(<f-args>)
command -nargs=+ -complete=file -range
      \ Cmd call dotfiles#RunShellCommand(<range>, <line1>, <line2>, <q-args>)
if has('terminal')
  command -nargs=? -range
        \ Send call dotfiles#SendTerminalKeys(<line1>, <line2>, <args>)
  command -nargs=* -complete=file
        \ Win botright terminal ++noclose ++shell ++kill=term <args>
endif

