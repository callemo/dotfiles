" Reduce syntax noise without flattening the editor UI.
" Keep identifiers, operators, types, and shell commands plain.
" Comments are gray; constants and numbers are greenish teal.
" Keywords are muted purple and bold; colored strings are rose-magenta.
" Normal, keywords, strings, numbers, and links have similar reference xterm contrast.
" String values in Python, Go, C, and our lexers use LiteralString.
" Keys stay plain, including quoted JSON/YAML keys; regexes stay plain.
" JavaScript templates share the string accent; expressions keep their own roles.
" Markdown headings use the keyword accent; links are blue and inline code bold.
" Unlisted languages keep strings plain.
" TODO follows comments rather than adding a separate warning color.
"
" Preserve the existing UI colors for bars, search, selection, and diagnostics.
" Do not replace those definitions with aliases that change GUI attributes.
" Normal has a neutral foreground; the background remains the terminal's default.
" Exact contrast still depends on the terminal's palette and background.
" Tests use reference black/white backgrounds: at least 4.5:1 contrast,
" with no more than a 20% spread among the five primary text roles.
" vim/syntax owns small lexers for JavaScript, TypeScript, JSON, YAML, HTML,
" CSS, AWK, Perl, sh, and Markdown. Other languages use their existing syntax.
" These are practical lexers, not full grammars; unsupported constructs stay plain.
" Forced links prevent inherited syntax colors or bold attributes from leaking.
" HTML embeds our CSS and JavaScript; Markdown reuses those imports.
" YAML replaces the old conf fallback without loading the heavy bundled grammar.
" JSON preserves g:vim_json_conceal; Markdown uses fixed fence-language defaults.
" sh embeds single-quoted awk/gawk/mawk/nawk programs immediately after the command,
" and perl -e/-E programs, including combined short flags such as -ne.
" Separate option arguments and concatenated shell quotes are outside these rules.
" Perl quote-like operators stay on one line; shell quotes bound embedded programs.
" JS/TS, Perl, sh, and Markdown synchronize from the start for long regions.
" Cold jumps can cost more than bounded synchronization; subsequent queries are cached.
" dot.vimrc puts vim/ before the standard runtime, with vim/after last.
" Restart Vim after changing syntax files to discard already-loaded definitions.
" tests/vim.vim covers language roles, backgrounds, reloads, and embedded programs.
" Run from the repository root:
" DOTFILES="$PWD" vim -Nu NONE -n -i NONE -es -S tests/vim.vim

hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

" Color 16 stays black when bold text promotes ANSI black to bright black.
hi StatusLine   cterm=bold ctermfg=16 ctermbg=4
hi StatusLineNC cterm=NONE ctermfg=236 ctermbg=242
hi TabLineSel   cterm=bold ctermfg=16 ctermbg=4
hi TabLine      cterm=NONE ctermfg=236 ctermbg=242
hi TabLineFill  cterm=NONE
hi VertSplit    cterm=NONE ctermfg=235 ctermbg=235

hi! link String Normal
hi! link Identifier Normal
hi! link Type Normal
hi! link PreProc Normal
hi! link Special Normal
hi! link Todo Comment
hi! link Operator Normal
hi! link Label Normal

if &background ==# 'dark'
	hi Normal        cterm=NONE ctermfg=251 ctermbg=NONE
	hi Comment       cterm=NONE ctermfg=246 ctermbg=NONE
	hi Constant      cterm=NONE ctermfg=115 ctermbg=NONE
	hi Statement     cterm=bold ctermfg=183 ctermbg=NONE
	hi LiteralString cterm=NONE ctermfg=218 ctermbg=NONE
	hi markdownHeadingItalic cterm=bold,italic ctermfg=183 ctermbg=NONE gui=bold,italic
	let s:link_color = 117
else
	hi Normal        cterm=NONE ctermfg=239 ctermbg=NONE
	hi Comment       cterm=NONE ctermfg=240 ctermbg=NONE
	hi Constant      cterm=NONE ctermfg=23 ctermbg=NONE
	hi Statement     cterm=bold ctermfg=91 ctermbg=NONE
	hi LiteralString cterm=NONE ctermfg=125 ctermbg=NONE
	hi markdownHeadingItalic cterm=bold,italic ctermfg=91 ctermbg=NONE gui=bold,italic
	let s:link_color = 24
endif
hi! link Number Constant
hi! link Float Number

" Shell syntax routes commands and punctuation through keyword groups.
hi! link shStatement Normal
hi! link shSet Normal
hi! link shRepeat Normal
hi! link shForPP Normal
hi! link shLoop Statement
hi! link shFunctionKey Statement
hi! link shTestOpr Normal
hi! link shCaseBar Normal
hi! link shCaseStart Normal
hi! link shSnglCase Normal

hi! link pythonString LiteralString
hi! link pythonRawString pythonString
hi! link pythonQuotes pythonString
hi! link pythonEscape pythonString
hi! link pythonInclude Statement
hi! link pythonOperator Statement

hi! link perlString LiteralString
hi! link perlStringStartEnd perlString
hi! link perlSpecialString perlString
hi! link perlSpecialStringU perlString
hi! link perlSpecialMatch Normal
hi! link perlMatchStartEnd Normal
hi! link perlMatch Normal
hi! link perlQR Normal
hi! link perlQRModifiers Normal
hi! link perlInclude Statement
hi! link perlControl Statement

hi! link awkString LiteralString
hi! link awkSearch Normal
hi! link awkSpecialPrintf awkString
hi! link awkSpecialCharacter awkString
hi! link awkRegExp Normal
hi! link awkNestRegExp Normal
hi! link awkPatterns Statement

hi! link goString LiteralString
hi! link goRawString goString
hi! link goImportString goString
hi! link goSpecialString goString
hi! link goCharacter goString

hi! link cString LiteralString
hi! link cSpecial cString
hi! link cCharacter cString

hi! link javaScriptStringS LiteralString
hi! link javaScriptStringD LiteralString
hi! link javaScriptStringT LiteralString
hi! link javaScriptSpecial LiteralString
hi! link jsString LiteralString
hi! link jsTemplate jsString

hi! link htmlString LiteralString
hi! link htmlValue htmlString

hi! link cssStringQ LiteralString
hi! link cssStringQQ LiteralString
hi! link cssSpecialCharQ cssStringQ
hi! link cssSpecialCharQQ cssStringQQ

hi! link jsonString LiteralString
hi! link jsonEscape jsonString
hi! link jsonKeyword Normal
hi! link jsonQuote Normal
hi! link jsonNull Constant

hi! link yamlString LiteralString
hi! link yamlPlainScalar yamlString
hi! link yamlEscape yamlString
hi! link yamlSingleEscape yamlString
hi! link yamlQuotedKey Normal
hi! link yamlKey Normal
hi! link yamlSequence Normal
hi! link yamlNumber Number
hi! link yamlConstant Constant
hi! link yamlBlockScalar yamlString

" Markdown keeps titles bold and blue links distinct without bright contrast jumps.
for s:level in range(1, 6)
	execute 'hi! link markdownH' . s:level . ' Statement'
endfor
unlet s:level
hi markdownBold       term=bold cterm=bold gui=bold
hi markdownItalic     term=italic cterm=italic gui=italic
hi markdownBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
hi markdownStrike     term=strikethrough cterm=strikethrough gui=strikethrough
for [s:group, s:attributes] in [
	\ ['markdownLinkText', 'underline'], ['markdownLinkBold', 'bold,underline'],
	\ ['markdownLinkItalic', 'italic,underline'], ['markdownLinkBoldItalic', 'bold,italic,underline']]
	execute 'hi ' . s:group . ' term=' . s:attributes . ' cterm=' . s:attributes .
		\ ' ctermfg=' . s:link_color . ' ctermbg=NONE gui=' . s:attributes
endfor
unlet s:group s:attributes s:link_color
hi! link markdownUrl markdownLinkText
hi! link markdownAutomaticLink markdownLinkText
hi! link markdownId markdownLinkText
hi! link markdownIdDeclaration markdownLinkText
hi! link markdownWikiLink markdownLinkText
hi! link markdownHeadingLinkText markdownLinkBold
hi! link markdownHeadingWikiLink markdownLinkBold
hi! link markdownHeadingAutomaticLink markdownLinkBold
hi! link markdownHeadingUrl markdownLinkBold
hi! link markdownHeadingId markdownLinkBold
hi! link markdownCode markdownBold
hi! link markdownCodeDelimiter Normal

" UI
if &background ==# 'dark'
	hi CursorLine cterm=NONE ctermbg=235
else
	hi CursorLine cterm=NONE ctermbg=254
endif
hi Visual         cterm=NONE ctermfg=15 ctermbg=8
hi Search         cterm=NONE ctermfg=16 ctermbg=3
hi CurSearch      cterm=bold ctermfg=16 ctermbg=11
hi LineNr         ctermfg=244
hi CursorLineNr   cterm=reverse ctermfg=16 ctermbg=3
hi NonText        ctermfg=244
hi Folded         ctermfg=5
hi MatchParen     ctermbg=8 ctermfg=16

" Errors & diffs
hi ErrorMsg   ctermfg=16 ctermbg=1
hi WarningMsg ctermfg=16 ctermbg=3
hi DiffAdd    ctermfg=2 ctermbg=NONE
hi DiffDelete ctermfg=1 ctermbg=NONE
hi DiffChange ctermfg=3 ctermbg=NONE
hi DiffText   cterm=NONE ctermfg=16 ctermbg=3

" Spell
hi SpellBad   cterm=underline ctermfg=1 ctermbg=NONE
hi SpellCap   cterm=underline ctermfg=4 ctermbg=NONE
hi SpellLocal cterm=underline ctermfg=6 ctermbg=NONE
hi SpellRare  cterm=underline ctermfg=5 ctermbg=NONE

hi link diffAdded DiffAdd
hi link diffRemoved DiffDelete
hi link Pmenu StatusLineNC
hi! link PmenuSel Visual
