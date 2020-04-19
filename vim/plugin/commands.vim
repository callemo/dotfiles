command Dump mksession! ~/vim.dump
command Load source ~/vim.dump

command -nargs=? Format call dotfiles#FormatFile(<f-args>)
command Trim call dotfiles#TrimTrailingSpaces()

if has('terminal')
  command -nargs=1 -range Send call term_sendkeys(
        \ <args>, join(getline(<line1>, <line2>), "\n") . "\n")
  command -nargs=* -complete=file Win belowright terminal
        \ ++noclose ++kill=term ++shell ++rows=10 <args>
endif


