hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

hi Normal ctermbg=NONE

" Status bar
hi StatusLine   cterm=bold ctermfg=0 ctermbg=4
hi StatusLineNC cterm=NONE ctermfg=250 ctermbg=238
hi TabLineSel   cterm=bold ctermfg=0 ctermbg=4
hi TabLine      cterm=NONE ctermfg=250 ctermbg=238
hi TabLineFill  cterm=NONE
hi VertSplit    cterm=NONE ctermfg=238 ctermbg=238

" Syntax — NONE overrides vim's built-in defaults after syntax reset
hi Comment    ctermfg=8
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
hi Visual         ctermfg=0 ctermbg=4
hi Search         cterm=NONE ctermfg=0 ctermbg=3
hi CurSearch      cterm=bold ctermfg=0 ctermbg=11
hi LineNr         ctermfg=8
hi CursorLineNr   cterm=reverse ctermfg=0 ctermbg=3
hi NonText        ctermfg=8
hi Folded         ctermfg=5
hi MatchParen     ctermbg=8 ctermfg=15

" Errors & diffs
hi ErrorMsg   ctermfg=0 ctermbg=1
hi WarningMsg ctermfg=0 ctermbg=3
hi DiffAdd    ctermfg=2 ctermbg=NONE
hi DiffDelete ctermfg=1 ctermbg=NONE
hi DiffChange ctermfg=3 ctermbg=NONE
hi DiffText   ctermfg=0 ctermbg=3

" Spell
hi SpellBad   ctermfg=0
hi SpellCap   ctermfg=0
hi SpellLocal ctermfg=0
hi SpellRare  ctermfg=0

hi link diffAdded DiffAdd
hi link diffRemoved DiffDelete
hi link Pmenu StatusLineNC
hi link PmenuSel StatusLine
