command Dump mksession! ~/vim.dump
command Load source ~/vim.dump
command -nargs=?
      \ Format call dotfiles#FormatFile(<f-args>)
command Bonly call dotfiles#BufferOnly()
command Trim call dotfiles#TrimTrailingSpaces()
command -nargs=1 -range -complete=customlist,dotfiles#VisualChangeCaseComplete
      \ Case :call dotfiles#VisualChangeCase(<f-args>)
if has('terminal')
  command -nargs=? -range
        \ Send call dotfiles#SendTerminalKeys(<line1>, <line2>, <args>)
  command -nargs=* -complete=file
        \ Win belowright terminal ++noclose ++kill=term ++shell ++rows=10 <args>
endif


