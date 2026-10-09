if exists('b:current_syntax')
	finish
endif

syntax case match
syntax region cssStringQQ start=+"+ skip=+\\.+ end=+"+ oneline contains=NONE
syntax region cssStringQ start=+'+ skip=+\\.+ end=+'+ oneline contains=NONE
" These group families are also consumed by bundled HTML, Sass, and LESS syntax.
syntax region cssBlock transparent start=/{/ end=/}/ contains=cssBlock,cssProp,cssStringQ,cssStringQQ,cssComment
syntax region cssProp contained transparent matchgroup=Normal start=/[-_[:alpha:]][-_[:alnum:]]*\s*:/ end=/\ze[;}]/ contains=cssBlock,cssStringQ,cssStringQQ,cssValueLength,cssValueAttr,cssColor,cssURL,cssImportant,cssComment
syntax match cssValueLength /\%(\w\|\\\)\@4<![-+]\?\%(\d\+\%(\.\d*\)\?\|\.\d\+\)\%([eE][-+]\?\d\+\)\?\%([[:alpha:]%]\+\)\?/ contained display
syntax match cssColor /#\x\{3,8}\>/ contained display
syntax match cssValueAttr /\%#=1\c[-[:alnum:]_]\@4<!\%(auto\|none\|inherit\|initial\|unset\|revert\|block\|inline\|inline-block\|flex\|inline-flex\|grid\|inline-grid\|contents\|hidden\|visible\|solid\|dashed\|dotted\|transparent\|currentcolor\|normal\|bold\|italic\|serif\|sans-serif\|monospace\|red\|green\|blue\|black\|white\)[-[:alnum:]_]\@!/ contained display
syntax region cssURL contained start=/\c\<url(/ end=/)/ oneline contains=cssStringQ,cssStringQQ
syntax match cssImportant /!\s*important\>/ contained display
syntax region cssComment start=+/\*+ end=+\*/+ contains=NONE

highlight default link cssStringQ String
highlight default link cssStringQQ String
highlight default link cssValueLength Number
highlight default link cssValueAttr Constant
highlight default link cssColor Constant
highlight default link cssURL Normal
highlight default link cssImportant Normal
highlight default link cssComment Comment
if !exists('main_syntax')
	syntax sync ccomment cssComment minlines=20 maxlines=200
endif
let b:current_syntax = 'css'
