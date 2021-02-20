setl sw=2 sts=2 et

inoremap <buffer> <c-x>= ${}<left>
inoremap <buffer> <c-x>- $()<left>
inoremap <buffer> <c-x>! #!/bin/sh<cr>

iabbrev <buffer> progdir] readonly progdir="$(cd "$(dirname "$0")" && pwd)"

iabbrev <buffer> case] case  <c-o>mmin<cr>
  \PATTERN1\|PATTERN2)<cr>
  \<c-t>COMMAND_LIST<cr>
  \;;<cr>
  \<c-d>*)<cr>
  \<c-t>DEFAULT ;;<cr>
  \<c-d>esac<esc>`mi

iabbrev <buffer> for] for i in <c-o>mm<cr>
  \do<cr>
  \done<esc>`ma

iabbrev <buffer> if] if [  <c-o>mm]<cr>
  \then<cr>
  \fi<esc>`mi

iabbrev <buffer> func] (<c-o>mm) {<cr>
  \}<esc>`mi

iabbrev <buffer> getopts] aflag=<cr>
  \bflag=<cr>
  \while getopts ab:<c-o>mm i<cr>
  \do<cr>
  \<c-t>case $i in<cr>
  \a) aflag=1 ;;<cr>
  \b) bflag="$OPTARG" ;;<cr>
  \?) echo "usage: $0 [-a] [-b value] args" >&2; exit 2 ;;<cr>
  \esac<cr>
  \<c-d>done<cr>
  \shift $((OPTIND - 1))<esc>`ma
