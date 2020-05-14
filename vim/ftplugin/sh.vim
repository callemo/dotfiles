iabbr <buffer> #! #!/bin/bash
      \<CR>set -euo pipefail
      \<CR><C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> case\ case  <C-o>mmin
      \<CR>PATTERN \| PATTERN)
      \<CR>COMMANDS
      \<CR>;;
      \<CR>*)
      \<CR>DEFAULT ;;
      \<CR>esac<C-o>`m<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> for\ for ;<C-o>mm do
      \<CR>done<C-o>`m<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> if\ if [[  <C-o>mm]]; then
      \<CR>fi<C-o>`m<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> getopts\ aflag=
      \<CR>bflag=
      \<CR>while getopts a<C-o>mmb: opt; do
      \<CR>case ${opt} in
      \<CR>a) aflag=1 ;;
      \<CR>b) bflag="${OPTARG}" ;;
      \<CR>?) echo "usage: $0 [-a] [-b value] args" >&2; exit 2 ;;
      \<CR>esac
      \<CR>done
      \<CR>shift $((OPTIND - 1))<C-o>`m<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> scriptdir\ readonly SCRIPTDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
      \<CR><C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> tempdir\ tempdir=$(mktemp -d)
      \<CR>atexit() { rm -rf "${tempdir}"; }
      \<CR>trap atexit EXIT
      \<CR><C-r>=dotfiles#EatBlank()<CR>
