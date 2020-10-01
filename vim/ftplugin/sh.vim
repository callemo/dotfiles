setl sw=2 sts=2 et

inoremap <buffer> <C-x>= ${}<Left>
inoremap <buffer> <C-x>- $()<Left>
inoremap <buffer> <C-x>! #!/bin/sh<CR>set -eu<CR><ESC>

iabbr <buffer> case\ case  <C-o>mmin<CR>
      \PATTERN \| PATTERN)<CR>
      \COMMANDS<CR>
      \;;<CR>
      \*)<CR>
      \DEFAULT ;;<CR>
      \esac<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> for\ for <C-o>mm<CR>
      \do<CR>
      \done<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> if\ if <C-o>mm<CR>
      \then<CR>
      \fi<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> func\ (<C-o>mm) {<CR>
      \}<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> getopts\ aflag=<CR>
      \bflag=<CR>
      \while getopts a<C-o>mmb: opt<CR>
      \do<CR>
      \case $opt in<CR>
      \a) aflag=1 ;;<CR>
      \b) bflag="$OPTARG" ;;<CR>
      \?) echo "usage: $0 [-a] [-b value] args" >&2; exit 2 ;;<CR>
      \esac<CR>
      \done<CR>
      \shift $((OPTIND - 1))<Esc>`m<C-r>=dotfiles#EndAbbr()<CR>

