hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

hi Normal ctermbg=NONE

" Color 16 stays black when bold text promotes ANSI black to bright black.
hi StatusLine   cterm=bold ctermfg=16 ctermbg=4
hi StatusLineNC cterm=NONE ctermfg=244 ctermbg=235
hi TabLineSel   cterm=bold ctermfg=16 ctermbg=4
hi TabLine      cterm=NONE ctermfg=244 ctermbg=235
hi TabLineFill  cterm=NONE
hi VertSplit    cterm=NONE ctermfg=235 ctermbg=235

" Syntax — NONE overrides vim's built-in defaults after syntax reset
hi Comment    ctermfg=244
hi Constant   ctermfg=5
hi String     ctermfg=NONE
hi Statement  cterm=bold
hi Identifier ctermfg=NONE
hi Type       ctermfg=NONE
hi PreProc    ctermfg=NONE
hi Special    ctermfg=3

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
