iabbr <buffer> #! #!/bin/bash<CR>set -eu<CR>set -o pipefail<CR>
iabbr <buffer> getopts` aflag=<CR>bflag=<CR><CR>while getopts ab: opt; do<CR>case $opt in<CR>a) aflag=1;;<CR>b) bflag="$OPTARG";;<CR>?) echo "usage: $0: [-a] [-b value] args"<CR>exit 2;;<CR><down><down><CR><CR>shift $((OPTIND - 1))<CR>
