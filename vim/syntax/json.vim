if exists('b:current_syntax')
	finish
endif

syntax case match
syntax match jsonNumber /-\?\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\?\%([eE][-+]\?\d\+\)\?/ display
syntax keyword jsonBoolean true false null
let s:conceal = has('conceal') && get(g:, 'vim_json_conceal', 1) == 1 ? ' concealends' : ''
execute 'syntax region jsonString oneline matchgroup=jsonString start=+"+ skip=+\\.+ end=+"+ contains=NONE' . s:conceal
execute 'syntax region jsonKeyword contained oneline matchgroup=jsonQuote start=+"+ skip=+\\.+ end=+"+ contains=NONE' . s:conceal
syntax match jsonKeywordMatch /"\%([^"\\]\|\\.\)*"\_s*:/ contains=jsonKeyword
unlet s:conceal

highlight default link jsonNumber Number
highlight default link jsonBoolean Constant
highlight default link jsonString String
highlight default link jsonKeyword Identifier
highlight default link jsonQuote jsonKeyword
let b:current_syntax = 'json'
