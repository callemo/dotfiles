if exists('b:current_syntax')
	finish
endif

syntax case match
syntax cluster yamlValue contains=yamlPlainScalar,yamlString,yamlNumber,yamlConstant,yamlFlow,yamlComment
syntax match yamlValueStart /^ */ nextgroup=@yamlValue,yamlKey,yamlQuotedKey skipwhite
syntax match yamlSequence /^ *-\ze\%(\s\|$\)/ nextgroup=@yamlValue,yamlKey,yamlQuotedKey skipwhite
syntax match yamlPlainScalar /[^][{},#"' \t]\%([^][{},#]\|\S\@<=#\)*/ contained
syntax region yamlString contained start=+"+ skip=+\\\\\|\\"+ end=+"+ oneline contains=NONE
syntax region yamlString contained start=+'+ skip=+''+ end=+'+ oneline contains=NONE
syntax region yamlFlow transparent contained start=/\[/ end=/\]/ contains=@yamlValue,yamlKey,yamlQuotedKey
syntax region yamlFlow transparent contained start=/{/ end=/}/ contains=@yamlValue,yamlKey,yamlQuotedKey
syntax match yamlKey /[^][{},:#"' \t][^][{},:#"']*:\ze\%(\s\|$\)/ contained nextgroup=@yamlValue skipwhite
syntax match yamlQuotedKey /"\%([^"\\]\|\\.\)*"\s*:/ contained nextgroup=@yamlValue skipwhite
syntax match yamlQuotedKey /'\%([^']\|''\)*'\s*:/ contained nextgroup=@yamlValue skipwhite
syntax match yamlNumber /[-+]\?\%(\d\+\%(\.\d*\)\?\%([eE][-+]\?\d\+\)\?\|\.\d\+\%([eE][-+]\?\d\+\)\?\|0[xX]\x\+\|0o[0-7]\+\|\.\%(inf\|Inf\|INF\|nan\|NaN\|NAN\)\)\ze\s*\%($\|[,}\]]\|#\)/ contained display
syntax match yamlConstant /\%(true\|True\|TRUE\|false\|False\|FALSE\|null\|Null\|NULL\|\~\)\ze\s*\%($\|[,}\]]\|#\)/ contained display
syntax match yamlComment /\%(^\|\s\)\@<=#.*$/ contains=NONE

" Header comments remain comments; indentation bounds the literal body.
syntax region yamlBlockScalarRegion transparent matchgroup=yamlKey start=+^\z( *\)\%(- \+\)\?\%([^#]*: \+\)\?[|>]\%([+-]\=[1-9]\|[1-9]\=[+-]\)\=\ze\s*\%(#.*\)\?$+ end=+^\%(\z1 \|\s*$\)\@!+ keepend contains=yamlComment,yamlBlockScalar
syntax region yamlBlockScalar contained start=+^+ end=+\%$+ contains=NONE

highlight default link yamlString String
highlight default link yamlPlainScalar yamlString
highlight default link yamlBlockScalar yamlString
highlight default link yamlKey Normal
highlight default link yamlQuotedKey yamlKey
highlight default link yamlSequence Normal
highlight default link yamlNumber Number
highlight default link yamlConstant Constant
highlight default link yamlComment Comment
let b:current_syntax = 'yaml'
