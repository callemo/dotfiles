if exists('b:current_syntax')
	finish
endif

let s:main = !exists('main_syntax')
if s:main
	let main_syntax = 'markdown'
endif
" Load only our HTML lexer, not every HTML syntax on the runtime path.
source <sfile>:h/html.vim
unlet b:current_syntax
syntax case match
syntax spell toplevel
syntax cluster markdownInline contains=markdownItalic,markdownBold,markdownBoldItalic,markdownStrike,markdownCode,markdownCodeLiteral,markdownEscape,markdownLinkText,markdownWikiLink,markdownAutomaticLink,@Spell
syntax cluster markdownHeadingInline contains=markdownHeadingItalic,markdownHeadingBold,markdownHeadingBoldItalic,markdownHeadingCode,markdownHeadingCodeLiteral,markdownHeadingEscape,markdownHeadingLinkText,markdownHeadingWikiLink,markdownHeadingAutomaticLink,@Spell

for s:level in range(1, 6)
	execute 'syntax match markdownH' . s:level . ' /^ \{0,3}' .
		\ repeat('#', s:level) . '\%(\s\|$\).*$/ contains=@markdownHeadingInline'
	execute 'highlight default link markdownH' . s:level . ' Statement'
endfor
syntax match markdownH1 /^.\+\n=\+$/ contains=@markdownHeadingInline,markdownHeadingRule
syntax match markdownH2 /^.\+\n-\+$/ contains=@markdownHeadingInline,markdownHeadingRule
syntax match markdownHeadingRule /^[=-]\+$/ contained
syntax match markdownListMarker /^ \{0,3}[-*+]\ze\s/
syntax match markdownOrderedListMarker /^ \{0,3}\d\+[.)]\ze\s/
syntax match markdownBlockquote /^ \{0,3}>\ze\%(\s\|$\)/
syntax match markdownRule /^ \{0,3}\%(\*\s*\)\{3,}$\|^ \{0,3}\%(-\s*\)\{3,}$\|^ \{0,3}\%(_\s*\)\{3,}$/

let s:concealends = has('conceal') && get(g:, 'markdown_syntax_conceal', 1) == 1 ? ' concealends' : ''
for [s:prefix, s:contained] in [
	\ ['markdown', ''], ['markdownHeading', ' contained'],
	\ ['markdownLink', ' contained'], ['markdownHeadingLink', ' contained']]
	let s:emphasis_options = s:contained ==# '' ? '' : s:contained . ' oneline'
	execute 'syntax region ' . s:prefix . 'Italic' . s:emphasis_options . ' matchgroup=' . s:prefix . 'ItalicDelimiter start=/\*\ze\S/ skip=/\\./ end=/\S\@1<=\*\|^$/ contains=@Spell' . s:concealends
	execute 'syntax region ' . s:prefix . 'Italic' . s:emphasis_options . ' matchgroup=' . s:prefix . 'ItalicDelimiter start=/\w\@4<!_\ze\S/ skip=/\\./ end=/\S\@1<=_\w\@!\|^$/ contains=@Spell' . s:concealends
	execute 'syntax region ' . s:prefix . 'Bold' . s:emphasis_options . ' matchgroup=' . s:prefix . 'BoldDelimiter start=/\*\*\ze\S/ skip=/\\./ end=/\S\@1<=\*\*\|^$/ contains=' . s:prefix . 'Italic,@Spell' . s:concealends
	execute 'syntax region ' . s:prefix . 'Bold' . s:emphasis_options . ' matchgroup=' . s:prefix . 'BoldDelimiter start=/\w\@4<!__\ze\S/ skip=/\\./ end=/\S\@1<=__\w\@!\|^$/ contains=' . s:prefix . 'Italic,@Spell' . s:concealends
	execute 'syntax region ' . s:prefix . 'BoldItalic' . s:emphasis_options . ' matchgroup=' . s:prefix . 'BoldItalicDelimiter start=/\*\*\*\ze\S/ skip=/\\./ end=/\S\@1<=\*\*\*\|^$/ contains=@Spell' . s:concealends
	execute 'syntax region ' . s:prefix . 'CodeLiteral' . s:contained . ' matchgroup=markdownCodeDelimiter start=/\z(`\{2,}\)/ end=/\z1/ oneline keepend contains=NONE'
	execute 'syntax region ' . s:prefix . 'Code' . s:contained . ' matchgroup=markdownCodeDelimiter start=/`\ze[^`]/ end=/`/ oneline keepend contains=NONE'
endfor
unlet s:prefix s:contained s:emphasis_options
execute 'syntax region markdownStrike matchgroup=markdownStrikeDelimiter start=/\~\~\ze\S/ end=/\S\@1<=\~\~\|^$/ contains=@Spell' . s:concealends
syntax match markdownHeadingEscape /\\[][\\`*_{}()<>#+.!-]/ contained
syntax region markdownCodeBlock start=/^\%( \{4,}\| \{0,3}\t\)[ \t]*\S/ end=/^\ze \{0,3}\S/ keepend contains=NONE
syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start=/^ \{0,3}\z(`\{3,\}\).*$/ end=/^ \{0,3}\z1`*\s*$/ keepend contains=NONE
syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start=/^ \{0,3}\z(\~\{3,\}\).*$/ end=/^ \{0,3}\z1\~*\s*$/ keepend contains=NONE
for [s:prefix, s:contained] in [['markdown', ''], ['markdownHeading', ' contained']]
	execute 'syntax cluster ' . s:prefix . 'LinkInline contains=' . s:prefix .
		\ 'LinkItalic,' . s:prefix . 'LinkBold,' . s:prefix . 'LinkBoldItalic,' .
		\ s:prefix . 'LinkCode,' . s:prefix . 'LinkCodeLiteral,@Spell'
	let s:delimiter = s:prefix . 'LinkDelimiter'
	execute 'syntax region ' . s:prefix . 'LinkText' . s:contained . ' matchgroup=' .
		\ s:delimiter . ' start=/!\?\[\ze[^][]*\]\s*[([]/ end=/\]/ oneline keepend nextgroup=' .
		\ s:prefix . 'Link,' . s:prefix . 'Id skipwhite contains=@' . s:prefix . 'LinkInline'
	execute 'syntax region ' . s:prefix . 'Link contained matchgroup=' . s:delimiter .
		\ ' start=/(/ end=/)/ oneline keepend contains=' . s:prefix . 'Url,markdownUrlTitle'
	execute 'syntax region ' . s:prefix . 'Id contained matchgroup=' . s:delimiter .
		\ ' start=/\[/ end=/\]/ oneline keepend contains=NONE'
	execute 'syntax match ' . s:prefix . 'Url /[^[:space:]()"'']\+/ contained'
	execute 'syntax region ' . s:prefix . 'WikiLink' . s:contained . ' matchgroup=' .
		\ s:delimiter . ' start=/!\?\[\[/ end=/\]\]/ oneline keepend contains=NONE'
	execute 'syntax region ' . s:prefix . 'AutomaticLink' . s:contained . ' matchgroup=' .
		\ s:delimiter . ' start=/<\ze\%(\w\+:\|[[:alnum:]_+-]\+@\)/ end=/>/ oneline keepend contains=NONE'
endfor
unlet s:prefix s:contained s:delimiter
syntax region markdownIdDeclaration matchgroup=markdownLinkDelimiter start=/^ \{0,3}\[\ze[^][]*\]:/ end=/\]:/ oneline keepend nextgroup=markdownUrl skipwhite contains=NONE
syntax region markdownUrlTitle contained start=/"/ end=/"/ oneline contains=NONE
syntax region markdownUrlTitle contained start=/'/ end=/'/ oneline contains=NONE
syntax match markdownEscape /\\[][\\`*_{}()<>#+.!-]/

" Aliases share owned lexers; unknown fences remain opaque.
let s:included = {'html': 'htmlCode', 'javascript': 'htmlJavaScript', 'css': 'htmlCss'}
let s:iskeyword = &l:iskeyword
let s:dir = expand('<sfile>:p:h')
for s:spec in [
	\ 'javascript', 'js=javascript', 'typescript', 'ts=typescript',
	\ 'json', 'yaml', 'yml=yaml', 'html', 'css', 'awk', 'perl', 'sh', 'bash=sh']
	let s:label = matchstr(s:spec, '^[^=]*')
	let s:language = matchstr(s:spec, '[^=]*$')
	let s:cluster = 'markdownHighlight_' . s:language
	if !has_key(s:included, s:language)
		execute 'syntax include @' . s:cluster . ' ' . fnameescape(s:dir . '/' . s:language . '.vim')
		unlet! b:current_syntax
		let s:included[s:language] = s:cluster
	endif
	for s:fence in ['`', '\~']
		execute 'syntax region ' . s:cluster . ' matchgroup=markdownCodeDelimiter start=/^ \{0,3}\z(' .
			\ s:fence . '\{3,\}\)\s*\%({[^}]*\.\)\?' . s:label . '}\?\%(\s\|$\).*$/ end=/^ \{0,3}\z1' .
			\ s:fence . '*\s*$/ keepend contains=@' . s:included[s:language] . s:concealends
	endfor
endfor
let &l:iskeyword = s:iskeyword
if get(b:, 'markdown_yaml_head', get(g:, 'markdown_yaml_head', s:main))
	if has_key(s:included, 'yaml')
		execute 'syntax cluster markdownYamlTop contains=@' . s:included.yaml
	else
		syntax include @markdownYamlTop <sfile>:h/yaml.vim
		unlet b:current_syntax
	endif
	syntax region markdownYamlHead start=/\%^---$/ end=/^\%(---\|\.\.\.\)\s*$/ keepend contains=@markdownYamlTop
endif
syntax case match

highlight default link markdownHeadingRule Normal
highlight default link markdownListMarker Statement
highlight default link markdownOrderedListMarker markdownListMarker
highlight default link markdownBlockquote Comment
highlight default link markdownRule Normal
highlight default markdownBold term=bold cterm=bold gui=bold
highlight default markdownItalic term=italic cterm=italic gui=italic
highlight default markdownBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
highlight default markdownStrike term=strikethrough cterm=strikethrough gui=strikethrough
highlight default link markdownBoldDelimiter markdownBold
highlight default link markdownItalicDelimiter markdownItalic
highlight default link markdownBoldItalicDelimiter markdownBoldItalic
highlight default link markdownStrikeDelimiter markdownStrike
highlight default link markdownHeadingBold Statement
highlight default markdownHeadingItalic term=bold,italic cterm=bold,italic gui=bold,italic
highlight default link markdownHeadingBoldItalic markdownHeadingItalic
highlight default link markdownHeadingBoldDelimiter markdownHeadingBold
highlight default link markdownHeadingItalicDelimiter markdownHeadingItalic
highlight default link markdownHeadingBoldItalicDelimiter markdownHeadingBoldItalic
highlight default link markdownHeadingCode Statement
highlight default link markdownHeadingCodeLiteral Statement
highlight default link markdownHeadingEscape Statement
highlight default link markdownLinkText Underlined
highlight default markdownLinkBold term=bold,underline cterm=bold,underline gui=bold,underline
highlight default markdownLinkItalic term=italic,underline cterm=italic,underline gui=italic,underline
highlight default markdownLinkBoldItalic term=bold,italic,underline cterm=bold,italic,underline gui=bold,italic,underline
highlight default link markdownLinkBoldDelimiter markdownLinkBold
highlight default link markdownLinkItalicDelimiter markdownLinkItalic
highlight default link markdownLinkBoldItalicDelimiter markdownLinkBoldItalic
highlight default link markdownLinkCode markdownLinkBold
highlight default link markdownLinkCodeLiteral markdownLinkText
highlight default link markdownHeadingLinkText markdownLinkBold
highlight default link markdownHeadingLinkBold markdownLinkBold
highlight default link markdownHeadingLinkItalic markdownLinkBoldItalic
highlight default link markdownHeadingLinkBoldItalic markdownLinkBoldItalic
highlight default link markdownHeadingLinkBoldDelimiter markdownHeadingLinkBold
highlight default link markdownHeadingLinkItalicDelimiter markdownHeadingLinkItalic
highlight default link markdownHeadingLinkBoldItalicDelimiter markdownHeadingLinkBoldItalic
highlight default link markdownHeadingLinkCode markdownLinkBold
highlight default link markdownHeadingLinkCodeLiteral markdownLinkBold
highlight default link markdownHeadingLinkDelimiter Statement
highlight default link markdownHeadingWikiLink markdownLinkBold
highlight default link markdownHeadingAutomaticLink markdownLinkBold
highlight default link markdownHeadingUrl markdownLinkBold
highlight default link markdownHeadingId markdownLinkBold
highlight default link markdownUrl markdownLinkText
highlight default link markdownUrlTitle String
highlight default link markdownAutomaticLink markdownUrl
highlight default link markdownWikiLink markdownLinkText
highlight default link markdownIdDeclaration markdownLinkText
highlight default link markdownLinkDelimiter Normal
highlight default link markdownId markdownLinkText
highlight default link markdownCode markdownBold
highlight default link markdownCodeLiteral Normal
highlight default link markdownCodeBlock Normal
highlight default link markdownCodeDelimiter Normal
highlight default link markdownEscape Normal
if s:main
	if exists('g:markdown_minlines')
		execute 'syntax sync minlines=' . g:markdown_minlines
	else
		syntax sync fromstart
	endif
	unlet main_syntax
endif
let b:current_syntax = 'markdown'
