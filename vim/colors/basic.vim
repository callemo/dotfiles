" ---------------------------------------------------------------------
" File: basic.vim
" Description: A minimalist theme that trusts the terminal palette
" ---------------------------------------------------------------------

hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

" 1. Trust the terminal background
hi Normal ctermbg=NONE guibg=NONE

" 2. Status Bar (accent)
" Active: ctermbg=4 (Blue), ctermfg=0 (Black)
hi StatusLine   cterm=bold ctermfg=0 ctermbg=4 gui=bold guifg=Black guibg=Blue
" Inactive: ctermbg=238 (Dark Grey), ctermfg=250 (Light Grey)
hi StatusLineNC cterm=NONE ctermfg=250 ctermbg=238 gui=NONE guifg=#bcbcbc guibg=#444444
" TabLines: match the StatusLines
hi TabLineSel   cterm=bold ctermfg=0 ctermbg=4 gui=bold guifg=Black guibg=Blue
hi TabLine      cterm=NONE ctermfg=250 ctermbg=238 gui=NONE guifg=#bcbcbc guibg=#444444
hi TabLineFill  cterm=NONE ctermfg=NONE ctermbg=NONE
hi VertSplit    cterm=NONE ctermfg=238 ctermbg=238 guifg=#444444 guibg=#444444

" 3. Minimal Syntax (ANSI-indexed)
hi Comment    ctermfg=8  guifg=Grey
hi Constant   ctermfg=1  guifg=Red
hi String     ctermfg=1  guifg=Red
hi Statement  cterm=bold ctermfg=NONE gui=bold
hi Identifier ctermfg=NONE
hi Type       ctermfg=NONE
hi PreProc    ctermfg=NONE
hi Special    ctermfg=3  guifg=Yellow

" 4. UI & Selection
if &background ==# 'dark'
	hi CursorLine cterm=NONE ctermbg=235 gui=NONE guibg=#262626
else
	hi CursorLine cterm=NONE ctermbg=254 gui=NONE guibg=#e4e4e4
endif
hi Visual     ctermfg=0 ctermbg=6 guifg=Black guibg=Cyan
hi Search     ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi LineNr     ctermfg=8 guifg=Grey
hi NonText    ctermfg=8 guifg=Grey
hi Folded     ctermfg=5 ctermbg=NONE guifg=Magenta guibg=NONE
hi MatchParen ctermbg=8 ctermfg=15

" 5. Errors & Diffs
hi ErrorMsg   ctermfg=7 ctermbg=1 guifg=White guibg=Red
hi WarningMsg ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi DiffAdd    ctermfg=2 ctermbg=NONE guifg=Green
hi DiffDelete ctermfg=1 ctermbg=NONE guifg=Red
hi DiffChange ctermfg=3 ctermbg=NONE guifg=Yellow
hi DiffText   ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow

" Link modern groups
hi link diffAdded DiffAdd
hi link diffRemoved DiffDelete
hi link Pmenu StatusLineNC
hi link PmenuSel StatusLine
