iabbr <buffer> #! #!/bin/bash<CR>set -euo pipefail<CR>
iabbr <buffer> getopts` aflag=<CR>bflag=<CR><CR>while getopts ab: opt; do<CR>case $opt in<CR>a) aflag=1;;<CR>b) bflag="$OPTARG";;<CR>?) echo "usage: $0 [-a] [-b value] args"<CR>exit 2;;<CR><down><down><CR><CR>shift $((OPTIND - 1))<CR>
iabbr <buffer> for` for (( i = 0; i < count; i++ )); do<CR>
iabbr <buffer> scriptdir` readonly SCRIPTDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"<CR>
iabbr <buffer> tempdir` tempdir=$(mktemp -d)<CR>atexit() { rm -rf "$tempdir"; }<CR>trap atexit EXIT<CR>
