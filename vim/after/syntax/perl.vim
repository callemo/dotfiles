if exists('b:basic_perl_include')
	finish
endif
" Keep native qr recognition, but separate its quotes from literal-string quotes.
syntax clear perlQR
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\>\s*\z([^[:space:]#([{<'/]\)+ end=+\z1+ contains=@perlInterpMatch keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*/+ end=+/+ contains=@perlInterpSlash keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr#+ end=+#+ contains=@perlInterpMatch keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*'+ end=+'+ contains=@perlInterpSQ keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*(+ end=+)+ contains=@perlInterpMatch,perlParensDQ keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*{+ end=+}+ contains=@perlInterpMatch,perlBracesDQ,perlComment keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*<+ end=+>+ contains=@perlInterpMatch,perlAnglesDQ,perlComment keepend extend nextgroup=perlQRModifiers
syntax region perlQR matchgroup=perlMatchStartEnd start=+\<\%(::\|'\|->\)\@<!qr\s*\[+ end=+\]+ contains=@perlInterpMatch,perlBracketsDQ,perlComment keepend extend nextgroup=perlQRModifiers
" Shared escapes and nested delimiters inherit the enclosing string or regex style.
syntax clear perlSpecialString perlSpecialStringU perlSpecialStringU2
let s:char = exists('b:basic_perl_shell') ? "[^']" : '.'
let s:other = exists('b:basic_perl_shell') ? "[^cx']" : '[^cx]'
execute 'syntax match perlSpecialString transparent "\\\%(\o\{1,3}\|x\%({\x\+}\|\x\{1,2}\)\|c' . s:char . '\|' . s:other . '\)" contained contains=NONE extend'
execute 'syntax match perlSpecialStringU2 transparent "\\' . s:char . '" extend contained contains=NONE'
syntax match perlSpecialStringU transparent "\\\\" contained contains=NONE
syntax clear perlParensSQ perlBracketsSQ perlBracesSQ perlAnglesSQ
syntax clear perlParensDQ perlBracketsDQ perlBracesDQ perlAnglesDQ
let s:end = exists('b:basic_perl_shell') ? " end=+'\\@=+" : ''
for s:interp in ['SQ', 'DQ']
	for [s:name, s:open, s:close] in [
		\ ['Parens', '(', ')'], ['Brackets', '\[', '\]'],
		\ ['Braces', '{', '}'], ['Angles', '<', '>']]
		let s:group = 'perl' . s:name . s:interp
		execute 'syntax region ' . s:group . ' transparent start=+' . s:open .
			\ '+ end=+' . s:close . '+' . s:end . ' extend contained contains=' .
			\ s:group . ',@perlInterp' . s:interp . ' keepend'
	endfor
endfor
unlet s:char s:other s:end s:interp s:name s:open s:close s:group
