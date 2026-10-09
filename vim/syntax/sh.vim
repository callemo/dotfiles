if exists('b:current_syntax')
	finish
endif

syntax include @shAwkScript <sfile>:h/awk.vim
unlet b:current_syntax
syntax include @shPerlScript <sfile>:h/perl.vim
unlet b:current_syntax
syntax case match
syntax cluster shCode contains=shLoop,shNumber,shAssignment,shEscape,shSingleQuote,shDoubleQuote,shComment,shParameter,shCommandSub,shBacktick,shParen,shAwk,shPerl,shHereDoc
syntax match shLoop /\%#=1\%(\i\|[-./]\)\@4<!\%(if\|then\|elif\|else\|fi\|for\|in\|do\|done\|while\|until\|case\|esac\|select\|function\)\%(\i\|[-]\)\@!/ display
syntax match shNumber /\%(\w\|[$./-]\)\@4<!-\?\%(\d\+\%(\.\d*\)\?\|\.\d\+\)\w\@!/ display
syntax match shAssignment /\<\h\w*=/ contains=NONE display
syntax match shEscape /\\./ contains=NONE
syntax region shSingleQuote start=+'+ end=+'+ contains=NONE
syntax region shDoubleQuote start=+"+ skip=+\\.+ end=+"+ contains=shEscape,shParameter,shCommandSub,shBacktick
syntax region shParameter start=+${+ end=+}+ contains=shParameter,shCommandSub
syntax region shCommandSub transparent matchgroup=Normal start=+\$(+ end=+)+ contains=@shCode
syntax region shParen contained transparent matchgroup=Normal start=+(+ end=+)+ contains=@shCode
syntax region shBacktick transparent matchgroup=Normal start=+`+ skip=+\\.+ end=+`+ contains=@shCode
syntax match shComment /\%(^\|[[:space:];|&()]\)\@<=#.*$/ contains=NONE
syntax region shHereDoc matchgroup=Normal start=+<<-\?\s*['"]\?\z(\h\w*\)['"]\?\s*$+ end=+^\t*\z1$+ keepend contains=NONE

" Shell quotes bound the embedded program, including incomplete child literals.
syntax region shAwk matchgroup=shSingleQuote start=+\%(\i\|[-.]\)\@4<![gmn]\?awk\%(\i\|[-]\)\@!\s\+'+ end=+'+ keepend contains=@shAwkScript
syntax region shPerl matchgroup=shSingleQuote start=+\%(\i\|[-.]\)\@4<!perl\%(\i\|[-]\)\@!\s\+\%(-[[:alnum:]][^[:space:]'"\\;|&<>()`]*\s\+\)*-[[:alpha:]]*[eE]\s\+'+ end=+'+ keepend contains=@shPerlScript

highlight default link shLoop Statement
highlight default link shNumber Number
highlight default link shAssignment Normal
highlight default link shEscape Normal
highlight default link shSingleQuote Normal
highlight default link shDoubleQuote Normal
highlight default link shParameter Normal
highlight default link shHereDoc Normal
highlight default link shComment Comment
if !exists('main_syntax')
	syntax sync fromstart
endif
let b:current_syntax = 'sh'
