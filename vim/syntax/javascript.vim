if exists('b:current_syntax')
	finish
endif

syntax case match
syntax cluster jsCode contains=jsKeyword,jsConstant,jsNumber,jsString,jsTemplate,jsRegexp,jsComment,jsLineComment,jsKey,jsBraces
" Bound look-behind to one UTF-8 character; group keyword prefixes to cut retries.
syntax match jsKeyword /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!\%(a\%(sync\|wait\)\|break\|c\%(ase\|atch\|lass\|onst\|ontinue\)\|d\%(ebugger\|efault\|elete\|o\)\|e\%(lse\|xport\|xtends\)\|f\%(inally\|or\|unction\)\|i\%(f\|mport\|n\%(stanceof\)\?\)\|let\|new\|of\|return\|s\%(uper\|witch\)\|t\%(his\|hrow\|ry\|ypeof\)\|v\%(ar\|oid\)\|w\%(hile\|ith\)\|yield\)\%(\i\|[$]\|[^\x00-\x7f]\)\@!\%(\s*:\)\@!/ display
syntax match jsConstant /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!\%(true\|false\|null\|undefined\)\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax match jsNumber /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!\d\%(_\?\d\)*\%(\.\%(\d\%(_\?\d\)*\)\?\)\?\%([eE][-+]\?\d\%(_\?\d\)*\)\?n\?\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax match jsNumber /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!0[xX]\x\%(_\?\x\)*n\?\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax match jsNumber /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!0[bB][01]\%(_\?[01]\)*n\?\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax match jsNumber /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!0[oO][0-7]\%(_\?[0-7]\)*n\?\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax match jsNumber /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!\.\d\%(_\?\d\)*\%([eE][-+]\?\d\%(_\?\d\)*\)\?\%(\i\|[$]\|[^\x00-\x7f]\)\@!/ display
syntax region jsString start=+"+ skip=+\\.+ end=+"+ oneline contains=NONE
syntax region jsString start=+'+ skip=+\\.+ end=+'+ oneline contains=NONE

" Brace balancing is only needed inside template expressions.
syntax match jsEscape /\\./ contained
syntax region jsTemplate start=+`+ skip=+\\.+ end=+`+ end=+^\s*\%(const\|let\|var\|export\|function\|class\|interface\|type\|import\)\>+me=s-1 contains=jsEscape,jsInterpolation
syntax region jsInterpolation contained matchgroup=jsDelimiter start=+${+ end=+}+ end=+^\s*\%(const\|let\|var\|export\|function\|class\|interface\|type\|import\)\>+me=s-1 contains=@jsCode
syntax region jsBraces contained transparent matchgroup=jsDelimiter start=+{+ end=+}+ contains=@jsCode

" Recognize regexes in common expression positions, not a full JS grammar.
syntax region jsRegexp start=+\%#=1\%([=(:,\[!&|?;{}<>]\s*\|\<\%(return\|throw\|case\|yield\)\s\+\|^\s*\)\@<=/\ze[^/*]+ skip=+\\.\|\[\%([^]\\]\|\\.\)*\]+ end=+/[dgimsuvy]*+ oneline contains=NONE
syntax match jsKey /\%#=1\%([{,]\s*\|^\s*\)\@<="\%([^"\\]\|\\.\)*"\s*:/ contains=NONE display
syntax match jsKey /\%#=1\%([{,]\s*\|^\s*\)\@<='\%([^'\\]\|\\.\)*'\s*:/ contains=NONE display
syntax match jsKey /\%#=1\%([{,]\s*\|^\s*\)\@<=\d\+\s*:/ contains=NONE display
syntax match jsKey /\%#=1\%([{,]\s*\|^\s*\)\@<=\%(true\|false\|null\|undefined\)\s*:/ contains=NONE display
syntax match jsKey /\.\s*[$[:alpha:]_][$[:alnum:]_]*/ contains=NONE display
syntax region jsComment start=+/\*+ end=+\*/+ contains=NONE
syntax match jsLineComment +//.*$+ contains=NONE
syntax match jsLineComment /\%^#!.*$/ contains=NONE

highlight default link jsKeyword Statement
highlight default link jsConstant Constant
highlight default link jsNumber Number
highlight default link jsString String
highlight default link jsTemplate jsString
highlight default link jsEscape jsString
highlight default link jsKey Normal
highlight default link jsDelimiter Normal
highlight default link jsRegexp Normal
highlight default link jsComment Comment
highlight default link jsLineComment Comment

if !exists('main_syntax')
	syntax sync fromstart
endif
let b:current_syntax = 'javascript'
