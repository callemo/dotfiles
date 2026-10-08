" Reduce syntax noise without flattening the editor UI.
" Keep identifiers, operators, types, and shell commands plain.
" Comments are gray; constants and numbers are greenish teal.
" Keywords are muted purple and bold; colored strings are rose-magenta.
" Python, Perl, and AWK strings use LiteralString, separate from numeric constants.
" Perl and AWK patterns share the string accent; other languages keep strings plain.
" TODO follows comments rather than adding a separate warning color.
"
" Preserve the existing UI colors for bars, search, selection, and diagnostics.
" Do not replace those definitions with aliases that change GUI attributes.
" Normal uses the terminal's colors; contrast depends on its palette.
" Native syntax files decide which tokens match; this file only changes styling.
" Forced links prevent inherited syntax colors or bold attributes from leaking.
"
" vim/after/syntax/sh/awk.vim embeds native AWK syntax without changing shell filetypes.
" It handles single-quoted programs immediately after awk, gawk, mawk, or nawk.
" Options before the program and concatenated shell quotes are outside this rule.
" The extension preserves shell keyword characters and the native shell syntax marker.
" Its numeric rule fixes subtraction boundaries.
" Synchronization starts at the file's beginning to keep long AWK blocks correct.
" This trades more parsing in large shell files for correct highlighting.
" dot.vimrc adds vim/after to the runtime path after the standard syntax files.
" Restart Vim after changing the runtime path.
" tests/vim.vim covers language roles, both backgrounds, reloads, and bin/fivenum.
" Run from the repository root:
" DOTFILES="$PWD" vim -Nu NONE -n -i NONE -es -S tests/vim.vim

hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

hi Normal cterm=NONE ctermfg=NONE ctermbg=NONE

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
	hi Comment       cterm=NONE ctermfg=246 ctermbg=NONE
	hi Constant      cterm=NONE ctermfg=109 ctermbg=NONE
	hi Statement     cterm=bold ctermfg=139 ctermbg=NONE
	hi LiteralString cterm=NONE ctermfg=175 ctermbg=NONE
else
	hi Comment       cterm=NONE ctermfg=240 ctermbg=NONE
	hi Constant      cterm=NONE ctermfg=23 ctermbg=NONE
	hi Statement     cterm=bold ctermfg=60 ctermbg=NONE
	hi LiteralString cterm=NONE ctermfg=89 ctermbg=NONE
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
hi! link perlSpecialMatch perlString
hi! link perlMatchStartEnd perlString
hi! link perlInclude Statement
hi! link perlControl Statement

hi! link awkString LiteralString
hi! link awkSearch awkString
hi! link awkSpecialPrintf awkString
hi! link awkSpecialCharacter awkString
hi! link awkRegExp awkString
hi! link awkNestRegExp awkString
hi! link awkPatterns Statement

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
