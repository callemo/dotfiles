iabbr <buffer> #! #!/bin/bash<CR>set -euo pipefail<CR>
iabbr <buffer> case` case WORD in<CR>PATTERN \| PATTERN)<CR>COMMANDS ;;<CR>*)<CR>DEFAULT ;;<CR><Esc>5k^w
iabbr <buffer> flock` [[ "${FLOCKER}" != "${0}" ]] \<CR>&& exec env FLOCKER="${0}" flock -en "${0}" "${0}" "${@}" \|\| :<CR><Esc>
iabbr <buffer> getopts` aflag=<CR>bflag=<CR><CR>while getopts ab: opt; do<CR>case $opt in<CR>a) aflag=1 ;;<CR>b) bflag="$OPTARG" ;;<CR>?) echo "usage: $0 [-a] [-b value] args"<CR>exit 2<CR>;;<CR><down><down><CR><CR>shift $((OPTIND - 1))<CR>
iabbr <buffer> if` if [[  ]]; then<CR><Esc>k^2f[a<Space>
iabbr <buffer> scriptdir` readonly SCRIPTDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"<CR>
iabbr <buffer> tempdir` tempdir=$(mktemp -d)<CR>atexit() { rm -rf "$tempdir"; }<CR>trap atexit EXIT<CR>
