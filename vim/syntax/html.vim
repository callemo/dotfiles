if exists('b:current_syntax')
	finish
endif

let s:main = !exists('main_syntax')
if s:main
	let main_syntax = 'html'
endif
syntax include @htmlCss <sfile>:h/css.vim
unlet b:current_syntax
syntax include @htmlJavaScript <sfile>:h/javascript.vim
unlet b:current_syntax

syntax region htmlTag start=+<\/\?\ze[[:alpha:]]+ end=+>+ contains=htmlTagName,htmlString,htmlValue
syntax match htmlTagName +<\/\?\zs[[:alpha:]][[:alnum:]:-]*+ contained
syntax region htmlString contained start=+"+ skip=+\\.+ end=+"+ oneline contains=NONE
syntax region htmlString contained start=+'+ skip=+\\.+ end=+'+ oneline contains=NONE
syntax match htmlValue +=\s*\zs[^"' \t>][^ \t>]*+ contained
syntax match htmlStyleTag +\c<style\>[^>]*>+ contained contains=htmlTagName,htmlString,htmlValue
syntax match htmlScriptTag +\c<script\>[^>]*>+ contained contains=htmlTagName,htmlString,htmlValue
syntax region cssStyle transparent start=+\c<style\>[^>]*>+ end=+\c\ze</style\s*>+ keepend contains=htmlStyleTag,@htmlCss
syntax region javaScript transparent start=+\c<script\>[^>]*>+ end=+\c\ze</script\s*>+ keepend contains=htmlScriptTag,@htmlJavaScript
syntax region htmlComment start=+<!--+ end=+-->+ contains=NONE
syntax cluster htmlCode contains=htmlTag,cssStyle,javaScript,htmlComment

highlight default link htmlTag Normal
highlight default link htmlTagName Statement
highlight default link htmlString String
highlight default link htmlValue htmlString
highlight default link htmlComment Comment
if s:main
	syntax sync minlines=40 maxlines=200
	syntax sync match htmlSync grouphere NONE +\c</\%(script\|style\)\s*>+
	unlet main_syntax
endif
unlet s:main
let b:current_syntax = 'html'
