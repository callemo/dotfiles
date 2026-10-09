if exists('b:current_syntax')
	finish
endif

syntax case match
syntax match perlKeyword /\%#=1\%(\i\|:\)\@4<!\%(use\|no\|require\|package\|sub\|my\|our\|local\|state\|if\|elsif\|else\|unless\|given\|when\|default\|while\|for\|foreach\|do\|until\|continue\|return\|last\|next\|redo\|goto\|BEGIN\|CHECK\|INIT\|END\|UNITCHECK\|print\|printf\|say\|open\|close\|read\|write\|sysread\|syswrite\|opendir\|readdir\|closedir\|chomp\|chop\|length\|substr\|index\|rindex\|split\|join\|push\|pop\|shift\|unshift\|splice\|map\|grep\|sort\|reverse\|keys\|values\|each\|exists\|delete\|die\|warn\|eval\|exit\|system\|exec\|fork\|wait\|sleep\|time\|sin\|cos\|sqrt\|abs\|int\|rand\|srand\|sprintf\|pack\|unpack\|chr\|ord\|lc\|uc\|scalar\|bless\|ref\)\%(\i\|:\)\@!/ display
syntax match perlNumber /\i\@4<!\d\%(_\?\d\)*\%(\.\d*\)\?\%([eE][-+]\?\d\%(_\?\d\)*\)\?\i\@!/ display
syntax match perlNumber /\i\@4<!0[xX]\x\%(_\?\x\)*\i\@!/ display
syntax match perlNumber /\i\@4<!0[bB][01]\%(_\?[01]\)*\i\@!/ display
syntax match perlNumber /\i\@4<!\.\d\+\%([eE][-+]\?\d\+\)\?\i\@!/ display
syntax match perlString /\i\@4<!\%(v\d\+\%(\.\d\+\)*\|\d\+\%(\.\d\+\)\{2,}\)\i\@!/ display
syntax match perlVarPlain /[$@%&*]\%([[:alpha:]_][[:alnum:]_:]*\|\d\+\|[!@#$?_/]\)/ nextgroup=perlVarMember display
syntax region perlVarBlock oneline transparent matchgroup=perlVarPlain start=+\%($#\|[$@%&*]\)\$*{+ end=+}+ contains=perlVarPlain,perlVarBlock,perlVarMember,perlHashKeyString display
syntax region perlVarMember contained oneline transparent matchgroup=perlVarPlain start=+{+ end=+}+ contains=perlVarPlain,perlVarMember,perlHashKeyString display
syntax match perlHashKeyString /\I\i*/ contained
syntax match perlHashKey /\i\@4<!-\?\I\i*\s*=>/ contains=perlHashKeyString display
syntax match perlEscape /\\./ contained transparent contains=NONE
syntax region perlString start=+"+ skip=+\\.+ end=+"+ oneline contains=perlVarPlain,perlVarBlock display
syntax region perlString start=+'+ skip=+\\.+ end=+'+ oneline contains=NONE display
syntax region perlString start=+`+ skip=+\\.+ end=+`+ oneline contains=perlVarPlain,perlVarBlock display
syntax region perlRegexClass contained start=/\[/ skip=/\\.\|\[:[^:]*:\]/ end=/\]/ oneline contains=NONE
syntax match perlComment /#.*$/ contains=NONE display

" Paired delimiters share a small balancing rule; quote operators stay on one line.
for [s:name, s:open, s:close] in [
	\ ['Parens', '(', ')'], ['Brackets', '\[', '\]'],
	\ ['Braces', '{', '}'], ['Angles', '<', '>']]
	for s:kind in ['Literal', 'Regex']
		let s:group = 'perl' . s:kind . s:name
		let s:contains = s:group . ',perlEscape'
		if s:kind ==# 'Regex'
			let s:contains .= ',perlRegexClass'
		endif
		execute 'syntax region ' . s:group . ' contained transparent oneline start=+' .
			\ s:open . '+ skip=+\\.+ end=+' . s:close . '+ contains=' . s:contains
	endfor
endfor
for [s:group, s:operator, s:kind, s:children, s:nextgroup, s:matchgroup] in [
	\ ['perlQ', '\%(q\|qw\)', 'Literal', 'perlEscape', '', 'perlStringStartEnd'],
	\ ['perlQQ', 'q[qx]', 'Literal', 'perlEscape,perlVarPlain,perlVarBlock', '', 'perlStringStartEnd'],
	\ ['perlMatch', '\%(m\|qr\)', 'Regex', 'perlEscape,perlRegexClass', '', 'perlMatchStartEnd'],
	\ ['perlSubPattern', '\%(s\|tr\|y\)', 'Regex', 'perlEscape,perlRegexClass', 'nextgroup=perlReplacement skipwhite', 'perlMatchStartEnd'],
	\ ['perlReplacement', '', 'Literal', 'perlEscape,perlVarPlain,perlVarBlock', '', 'perlMatchStartEnd']]
	for [s:open, s:close, s:name] in [
		\ ['\z([^[:space:]([{<]\)', '\z1', ''],
		\ ['(', ')', 'Parens'], ['\[', '\]', 'Brackets'],
		\ ['{', '}', 'Braces'], ['<', '>', 'Angles']]
		let s:contains = s:children
		if s:name !=# ''
			let s:contains .= ',perl' . s:kind . s:name
		endif
		let s:prefix = s:operator ==# '' ? '' : '\%#=1\%(\i\|:\)\@4<!\%(->\)\@2<!' . s:operator . '\i\@!\s*'
		let s:contained = s:operator ==# '' ? ' contained' : ''
		let s:offset = s:group ==# 'perlSubPattern' && s:name ==# '' ? 'me=e-1' : ''
		execute 'syntax region ' . s:group . s:contained . ' oneline display matchgroup=' . s:matchgroup .
			\ ' start=+' . s:prefix . s:open . '+ skip=+\\.+ end=+' . s:close . '+' .
			\ s:offset . ' contains=' . s:contains . ' ' . s:nextgroup
	endfor
endfor
unlet s:name s:open s:close s:kind s:group s:children s:operator s:nextgroup s:matchgroup s:contains s:prefix s:contained s:offset

syntax region perlMatch start=+\%#=1\%([=~(\[,!?:'&|]\s*\|\%(\i\|:\)\@4<!\%(if\|unless\|while\|split\|return\)\s\+\|^\s*\)\@<=/\ze[^/=]+ skip=+\\.+ end=+/+ oneline contains=perlEscape,perlRegexClass display
syntax region perlPOD start=/^=\%(cut\>\)\@![a-z]/ end=/^=cut\>/ keepend contains=NONE

highlight default link perlKeyword Statement
highlight default link perlNumber Number
highlight default link perlString String
highlight default link perlQ perlString
highlight default link perlQQ perlString
highlight default link perlReplacement perlString
highlight default link perlStringStartEnd perlString
highlight default link perlHashKey Normal
highlight default link perlHashKeyString perlString
highlight default link perlVarPlain Normal
highlight default link perlMatch Normal
highlight default link perlSubPattern Normal
highlight default link perlMatchStartEnd Normal
highlight default link perlRegexClass Normal
highlight default link perlComment Comment
highlight default link perlPOD Comment
if !exists('main_syntax')
	syntax sync fromstart
endif
let b:current_syntax = 'perl'
