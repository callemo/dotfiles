if exists('b:current_syntax')
	finish
endif

source <sfile>:h/javascript.vim
syntax match tsKeyword /\%#=1\%(\i\|[$]\|[^\x00-\x7f]\)\@4<!\%(a\%(bstract\|s\%(serts\)\?\)\|declare\|enum\|i\%(mplements\|nfer\|nterface\|s\)\|keyof\|module\|namespace\|override\|p\%(rivate\|rotected\|ublic\)\|readonly\|s\%(atisfies\|tatic\)\|type\|unique\)\%(\i\|[$]\|[^\x00-\x7f]\)\@!\%(\s*:\)\@!/ display
syntax cluster tsCode contains=@jsCode,tsKeyword,tsTemplate,tsBraces
syntax region tsTemplate start=+`+ skip=+\\.+ end=+`+ end=+^\s*\%(const\|let\|var\|export\|function\|class\|interface\|type\|import\)\>+me=s-1 contains=jsEscape,tsInterpolation
syntax region tsInterpolation contained matchgroup=jsDelimiter start=+${+ end=+}+ end=+^\s*\%(const\|let\|var\|export\|function\|class\|interface\|type\|import\)\>+me=s-1 contains=@tsCode
syntax region tsBraces contained transparent matchgroup=jsDelimiter start=+{+ end=+}+ contains=@tsCode
highlight default link tsKeyword Statement
highlight default link tsTemplate jsString
let b:current_syntax = 'typescript'
