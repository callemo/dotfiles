command Dump mksession! ~/vim.dump
command Load source ~/vim.dump

command -nargs=? Format call dotfiles#FormatFile(<f-args>)
command Only call dotfiles#BufferOnly()
command Trim call dotfiles#TrimTrailingSpaces()
command -range CamelCase :call dotfiles#ChangeVisualCamelCase()
command -range KebabCase :call dotfiles#ChangeVisualKebabCase()
command -range SnakeCase :call dotfiles#ChangeVisualSnakeCase()

if has('terminal')
  command -nargs=? -range Send call dotfiles#SendTerminalKeys(<line1>, <line2>, <args>)
  command -nargs=* -complete=file Win belowright terminal
        \ ++noclose ++kill=term ++shell ++rows=10 <args>
endif


