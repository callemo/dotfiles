if exists('b:current_syntax')
	finish
endif

syntax case match
syntax match awkKeyword /\%#=1\w\@4<!\%(BEGIN\|END\|BEGINFILE\|ENDFILE\|if\|else\|while\|for\|do\|break\|continue\|next\|nextfile\|exit\|return\|function\|delete\|in\|print\|printf\|getline\|close\|system\|length\|substr\|index\|split\|sub\|gsub\|match\|sprintf\|tolower\|toupper\|int\|sqrt\|exp\|log\|sin\|cos\|atan2\|rand\|srand\)\w\@!/ display
syntax match awkNumber /\%(\w\|[$]\)\@4<!\%(\d\+\%(\.\d*\)\?\|\.\d\+\)\%([eE][-+]\?\d\+\)\?\w\@!/ display
syntax region awkString start=+"+ skip=+\\.+ end=+"+ oneline contains=NONE display
syntax region awkRegexClass contained start=/\[/ skip=/\\.\|\[:[^:]*:\]/ end=/\]/ oneline contains=NONE
syntax region awkSearch start=+\%#=1\%([~=(,!:?'&|]\s*\|\<\%(if\|while\|print\|return\)\s\+\|^\s*\)\@<=/\ze[^/=]+ skip=+\\.+ end=+/+ oneline contains=awkRegexClass display
syntax match awkComment /#.*$/ contains=NONE display

highlight default link awkKeyword Statement
highlight default link awkNumber Number
highlight default link awkString String
highlight default link awkSearch Normal
highlight default link awkRegexClass awkSearch
highlight default link awkComment Comment
let b:current_syntax = 'awk'
