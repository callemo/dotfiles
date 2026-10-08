" Reduce syntax noise without flattening the editor UI.
" Keep identifiers, operators, types, and shell commands plain.
" Comments are gray; constants and numbers are greenish teal.
" Keywords are muted purple and bold; colored strings are rose-magenta.
" Normal, keywords, strings, and numbers have similar reference xterm contrast.
" Python, Perl, and AWK strings use LiteralString, separate from numeric constants.
" Perl and AWK regexes stay plain; other languages keep strings plain.
" TODO follows comments rather than adding a separate warning color.
"
" Preserve the existing UI colors for bars, search, selection, and diagnostics.
" Do not replace those definitions with aliases that change GUI attributes.
" Normal has a neutral foreground; the background remains the terminal's default.
" Exact contrast still depends on the terminal's palette and background.
" Tests use reference black/white backgrounds: at least 4.5:1 contrast,
" with no more than a 20% spread among the four primary text roles.
" Native syntax files decide which tokens match; this file only changes styling.
" Forced links prevent inherited syntax colors or bold attributes from leaking.
" vim/after/syntax/awk.vim separates regex escapes from the shared string-escape group.
" vim/after/syntax/perl.vim separates regex escapes, nested delimiters, and qr quotes.
" The shell extension defers those replacements until after including native Perl.
" Clears are ignored inside syntax includes; redefining there duplicates nesting rules.
"
" vim/after/syntax/sh/awk.vim embeds native AWK syntax without changing shell filetypes.
" It handles single-quoted programs immediately after awk, gawk, mawk, or nawk.
" Options before the program and concatenated shell quotes are outside this rule.
" The extension preserves shell keyword characters and the native shell syntax marker.
" Its numeric rule fixes subtraction boundaries.
" vim/after/syntax/sh/perl.vim embeds single-quoted perl -e and -E programs.
" Combined short flags and preceding unquoted option words work, including -ne and -I.
" Options with separate arguments and concatenated shell quotes are outside this rule.
" Both embeddings preserve the shell syntax marker and keyword characters.
" The Perl extension also handles quote-like operators immediately after the shell quote.
" Escapes, nested strings, interpolation, and POD stop before the closing shell quote.
" Native keyword and number matches avoid the shell's '-' boundaries.
" Keywords retain Perl's ':' boundaries for qualified names and labels.
" Those boundary overrides mirror the native Perl rules and need review after runtime updates.
" Synchronization starts at the file's beginning to keep long embedded blocks correct.
" This trades more parsing in large shell files for correct highlighting.
" dot.vimrc adds vim/after to the runtime path after the standard syntax files.
" Restart Vim after changing the runtime path.
" tests/vim.vim covers language roles, backgrounds, reloads, bin/fivenum, and acme/afmt.
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
else
	hi Normal        cterm=NONE ctermfg=239 ctermbg=NONE
	hi Comment       cterm=NONE ctermfg=240 ctermbg=NONE
	hi Constant      cterm=NONE ctermfg=23 ctermbg=NONE
	hi Statement     cterm=bold ctermfg=91 ctermbg=NONE
	hi LiteralString cterm=NONE ctermfg=125 ctermbg=NONE
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
