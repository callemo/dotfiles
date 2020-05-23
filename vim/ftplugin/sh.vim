setl keywordprg=:Cmd\ PAGER=rmbs\ man
setl makeprg=shellcheck\ -f\ gcc\ %
setl sw=2 sts=2 et

iabbr <buffer> #! #!/bin/bash<CR>
      \set -euo pipefail<CR>
      \<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> case\ case  <C-o>mmin<CR>
      \PATTERN \| PATTERN)<CR>
      \COMMANDS<CR>
      \;;<CR>
      \*)<CR>
      \DEFAULT ;;<CR>
      \esac<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> for\ for ;<C-o>mm do<CR>
      \done<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> if\ if [[  <C-o>mm]]; then<CR>
      \fi<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> func\ (<C-o>mm) {<CR>
      \}<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> getopts\ aflag=<CR>
      \bflag=<CR>
      \while getopts a<C-o>mmb: opt; do<CR>
      \case ${opt} in<CR>
      \a) aflag=1 ;;<CR>
      \b) bflag="${OPTARG}" ;;<CR>
      \?) echo "usage: $0 [-a] [-b value] args" >&2; exit 2 ;;<CR>
      \esac<CR>
      \done<CR>
      \shift $((OPTIND - 1))<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> scriptdir\ readonly SCRIPTDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"<CR>
      \<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> tempdir\ tempdir=$(mktemp -d)<CR>
      \atexit() { rm -rf "${tempdir}"; }<CR>
      \trap atexit EXIT<CR>
      \<C-r>=dotfiles#EndAbbr()<CR>

inoremap <buffer> <C-x>= ${}<Left>
inoremap <buffer> <C-x>- $()<Left>
