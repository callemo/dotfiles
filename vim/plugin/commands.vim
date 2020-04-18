command Dump mksession! ~/Session.vim
command Load source ~/Session.vim

command Black call dotfiles#Format('black')
command Prettier call dotfiles#Format('prettier --write')

command Trim call dotfiles#TrimTrailingSpaces()

if has('terminal')
  command -nargs=1 -range Send call term_sendkeys(
        \ <args>, join(getline(<line1>, <line2>), "\n") . "\n")
  command -nargs=* -complete=file Win belowright terminal
        \ ++noclose ++kill=term ++shell ++rows=10 <args>
endif


