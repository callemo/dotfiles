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
      \esac<ESC>`m

iabbr <buffer> for\ for i in *<C-o>mm<CR>
      \do<CR>
      \done<ESC>`m

iabbr <buffer> if\ if [  <C-o>mm]<CR>
      \then<CR>
      \fi<ESC>`m

iabbr <buffer> func\ (<C-o>mm) {<CR>
      \}<ESC>`m

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
      \shift $((OPTIND - 1))<ESC>`m
