let s:syntax = b:current_syntax
let s:isk = trim(execute('syntax iskeyword'))
unlet b:current_syntax
syntax include @shAwkScript syntax/awk.vim
" The included syntax changes buffer-wide keyword and sync settings.
execute s:isk ==# 'syntax iskeyword not set' ? 'syntax iskeyword clear' : s:isk
syntax sync fromstart
" Shell keyword characters include '-', so AWK numbers need their own boundaries.
syntax match awkNumber contained display "\w\@<!\%(\d\+\%(\.\d*\)\?\|\.\d\+\)\%([eE][+-]\?\d\+\)\?\w\@!"
" Shell quotes must end the region, even inside AWK strings or comments.
syntax region shAwk matchgroup=shSingleQuote start=+\<[gmn]\?awk\>\s\+'+ end=+'+ keepend contains=@shAwkScript
syntax cluster shCommandSubList add=shAwk
let b:current_syntax = s:syntax
unlet s:syntax s:isk
