" ---------------------------------------------------------------------
" File: basic.vim
" Description: A minimalist theme inspired by Plan 9 Acme editor
" Author: Based on basic theme with subtle, non-distractive colors
" ---------------------------------------------------------------------
"
" Color Philosophy:
" - Minimal syntax highlighting to reduce visual noise
" - Subtle contrast that's easy on the eyes
" - Plan 9 Acme-inspired purple for folded sections
" - Clean separation between UI and content
"
" Main Colors:
" Light: #ffffff bg, #000000 fg, #5d4e75 purple accents
" Dark:  #292a30 bg, #ffffff fg, #b8a9d1 purple accents
"
" =============================================================================
" Color Scheme Setup
" =============================================================================

hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

let s:highlight_groups = [
	\ 'Comment', 'Constant', 'CursorLine', 'CursorLineNr', 'Delimiter',
	\ 'DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText', 'Error', 'ErrorMsg',
	\ 'Folded', 'Function', 'Identifier', 'LineNr', 'MatchParen', 'NonText',
	\ 'PreProc', 'Search', 'Special', 'SpellBad', 'SpellCap', 'SpellLocal',
	\ 'SpellRare', 'Statement', 'StatusLine', 'StatusLineNC', 'StatusLineTerm',
	\ 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'TabLineSel', 'Title',
	\ 'Todo', 'Type', 'VertSplit', 'Visual', 'WarningMsg', 'WildMenu'
	\ ]
for s:g in s:highlight_groups
	exe 'hi! ' . s:g . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE'
endfor

" =============================================================================
" UI Element Overrides
" =============================================================================

hi ErrorMsg guifg=#000000 guibg=#f74a4a ctermfg=16 ctermbg=203
hi Pmenu ctermbg=DarkGray ctermfg=White
hi PmenuSel ctermbg=73 ctermfg=Black
hi SpellBad ctermbg=DarkRed ctermfg=White gui=undercurl
hi SpellCap ctermbg=DarkBlue ctermfg=White gui=undercurl
hi SpellLocal ctermbg=DarkCyan ctermfg=White gui=undercurl
hi SpellRare ctermbg=DarkMagenta ctermfg=White gui=undercurl
hi StatusLine ctermbg=73 ctermfg=Black guibg=#5f9ea0 guifg=#000000
hi TabLineSel ctermbg=73 ctermfg=Black
hi WarningMsg guifg=#000000 guibg=#efb759 ctermfg=16 ctermbg=215

" =============================================================================
" Light Background Colors
" =============================================================================

if &background ==# 'light'
	hi Comment guifg=#707f8b ctermfg=241
	" hi CursorLine guibg=#e8f2ff
	hi CursorLineNr guifg=#000000 ctermfg=16
	hi DiffAdd guibg=#e6ffee ctermbg=194
	hi DiffChange guifg=#000000 guibg=#dddddd ctermfg=16 ctermbg=188
	hi DiffDelete guibg=#ffeef0 ctermbg=225
	hi DiffText guifg=#000000 guibg=#d4edf4 ctermfg=16 ctermbg=195
	hi ErrorMsg guibg=#f74a4a ctermbg=203
	hi Folded guifg=#5d4e75 guibg=#f0e6ff ctermfg=60 ctermbg=189
	hi Function guifg=#077cae ctermfg=31
	hi Keyword guifg=#9b2393 ctermfg=90
	hi NonText guifg=#a6a6a6 ctermfg=145
	hi Normal guifg=#000000 guibg=#ffffff
	hi Number guifg=#1c00cf ctermfg=20
	hi PreProc guifg=#78492d ctermfg=94
	hi Search guifg=#262626 guibg=#e5e5e5 ctermfg=235 ctermbg=254
	hi StatusLineNC guifg=#a6a6a6 ctermfg=145 gui=reverse cterm=reverse
	hi String guifg=#d13121 ctermfg=124
	hi Visual guibg=#b2d7fd ctermbg=153
	hi helpHyperTextJump guifg=#0e38fa ctermfg=27
	" Modern vim highlight groups
	hi ColorColumn guibg=#f0f0f0 ctermbg=255
	hi CursorColumn guibg=#f5f5f5 ctermbg=255
	hi SignColumn guibg=#ffffff ctermbg=15
	hi Conceal guifg=#a0a0a0 ctermfg=145
	hi SpecialKey guifg=#cccccc ctermfg=252
	hi Directory guifg=#077cae ctermfg=31
	hi Question guifg=#078f00 ctermfg=28
	hi MoreMsg guifg=#078f00 ctermfg=28
	hi ModeMsg guifg=#000000 ctermfg=16

" =============================================================================
" Dark Background Colors
" =============================================================================

else  " background is dark
	hi Comment guifg=#7f8c97 ctermfg=102
	" hi CursorLine guibg=#2f3239
	hi CursorLineNr guifg=#ffffff
	hi DiffAdd guibg=#113a1d ctermbg=22
	hi DiffChange guifg=#000000 guibg=#dddddd ctermfg=16 ctermbg=188
	hi DiffDelete guibg=#450c0f ctermbg=52
	hi DiffText guifg=#000000 guibg=#d4edf4 ctermfg=16 ctermbg=195
	hi Folded guifg=#b8a9d1 guibg=#3d3447 ctermfg=146 ctermbg=60
	hi Function guifg=#4fb0ca ctermfg=74
	hi Keyword guifg=#fe7bb1 ctermfg=211
	hi NonText guifg=#747478 ctermfg=102
	hi Normal guifg=#ffffff guibg=#292a30
	hi Number guifg=#d9c981 ctermfg=186
	hi PreProc guifg=#ffa157 ctermfg=215
	hi Search guifg=#ffffff guibg=#545558 ctermfg=231 ctermbg=59
	hi StatusLineNC guifg=#747478 ctermfg=102 gui=reverse cterm=reverse
	hi String guifg=#ff8272 ctermfg=203
	hi Visual guibg=#646f82 ctermbg=60
	hi helpHyperTextJump guifg=#6699fb ctermfg=69
	" Modern vim highlight groups
	hi ColorColumn guibg=#3a3a3a ctermbg=59
	hi CursorColumn guibg=#35363c ctermbg=59
	hi SignColumn guibg=#292a30 ctermbg=235
	hi Conceal guifg=#6a6a6a ctermfg=242
	hi SpecialKey guifg=#505050 ctermfg=239
	hi Directory guifg=#4fb0ca ctermfg=74
	hi Question guifg=#50c878 ctermfg=78
	hi MoreMsg guifg=#50c878 ctermfg=78
	hi ModeMsg guifg=#ffffff ctermfg=231
endif

" =============================================================================
" Highlight Group Links
" =============================================================================

hi link diffAdded DiffAdd
hi link diffRemoved DiffDelete
hi link LineNr NonText
hi link MatchParen Search
hi link pythonBuiltin Keyword
hi link pythonStatement Keyword
hi link rubyDefine Keyword
hi link rubyStringDelimiter String
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC
hi link Todo Title
hi link VertSplit StatusLineNC
hi link vimOption Keyword

" =============================================================================
" Terminal Colors
" =============================================================================

if &background ==# 'light'
  " Light theme terminal colors - muted and harmonious with GUI theme
  let g:terminal_ansi_colors = ['#e5e5e5', '#d13121', '#078f00', '#78492d', '#077cae', '#9b2393', '#5f9ea0', '#262626', '#8a99a6', '#d13121', '#078f00', '#78492d', '#077cae', '#9b2393', '#5f9ea0', '#000000']
else  " &background ==# 'dark'
  " Dark theme terminal colors - aligned with GUI theme palette
  let g:terminal_ansi_colors = ['#292a30', '#ff8272', '#50c878', '#ffa157', '#4fb0ca', '#fe7bb1', '#5f9ea0', '#ffffff', '#747478', '#ff8272', '#50c878', '#ffa157', '#4fb0ca', '#fe7bb1', '#5f9ea0', '#ffffff']
endif
