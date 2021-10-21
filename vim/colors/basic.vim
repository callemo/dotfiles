" ---------------------------------------------------------------------
" File: basic.vim
" Description: A basic theme.
" ---------------------------------------------------------------------

hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name = 'basic'

let s:highlight_groups = ['Comment', 'Constant', 'CursorLine', 'CursorLineNr', 'Delimiter', 'DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText', 'Error', 'ErrorMsg', 'Folded', 'Function', 'Identifier', 'LineNr', 'MatchParen', 'NonText', 'PreProc', 'Search', 'Special', 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare' , 'Statement', 'StatusLine', 'StatusLineNC', 'StatusLineTerm', 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'TabLineSel', 'Title', 'Todo', 'Type', 'VertSplit', 'Visual', 'WarningMsg', 'WildMenu']
for s:g in s:highlight_groups
	exe 'hi! ' . s:g . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE'
endfor

hi ErrorMsg guifg=#000000 guibg=#f74a4a ctermfg=16 ctermbg=203
hi SpellBad ctermbg=DarkRed ctermfg=White cterm=bold gui=undercurl
hi SpellCap ctermbg=DarkBlue ctermfg=White cterm=bold gui=undercurl
hi SpellLocal ctermbg=DarkCyan ctermfg=White cterm=bold gui=undercurl
hi SpellRare ctermbg=DarkMagenta ctermfg=White cterm=bold gui=undercurl
hi StatusLine gui=bold,reverse cterm=bold,reverse
hi TabLineSel gui=reverse,bold cterm=reverse,bold
hi Title gui=bold cterm=bold
hi WarningMsg guifg=#000000 guibg=#efb759 ctermfg=16 ctermbg=215
hi WildMenu gui=bold cterm=bold

if &background ==# 'light'
	hi Comment guifg=#707f8b ctermfg=241
	hi CursorLine guibg=#e8f2ff
	hi CursorLineNr guifg=#000000 ctermfg=16 gui=bold cterm=bold
	hi DiffAdd guibg=#e6ffee ctermbg=194
	hi DiffChange guifg=#000000 guibg=#dddddd ctermfg=16 ctermbg=188
	hi DiffDelete guibg=#ffeef0 ctermbg=225
	hi DiffText guifg=#000000 guibg=#d4edf4 ctermfg=16 ctermbg=195
	hi ErrorMsg guibg=#f74a4a ctermbg=203
	hi Folded guifg=#6c6c6c guibg=#d9d9d9 ctermfg=59 ctermbg=188
	hi Function guifg=#077cae ctermfg=31
	hi Keyword guifg=#9b2393 ctermfg=90 gui=bold cterm=bold
	hi NonText guifg=#a6a6a6 ctermfg=145
	hi Normal guifg=#000000 guibg=#ffffff
	hi Number guifg=#1c00cf ctermfg=20
	hi PreProc guifg=#78492d ctermfg=94
	hi Search guifg=#262626 guibg=#e5e5e5 ctermfg=235 ctermbg=254 gui=bold cterm=bold
	hi StatusLineNC guifg=#a6a6a6 ctermfg=145 gui=reverse cterm=reverse
	hi String guifg=#d13121 ctermfg=124
	hi Visual guibg=#b2d7fd ctermbg=153
	hi helpHyperTextJump guifg=#0e38fa ctermfg=27
else  " background is dark
	hi Comment guifg=#7f8c97 ctermfg=102
	hi CursorLine guibg=#2f3239
	hi CursorLineNr guifg=#ffffff gui=bold cterm=bold
	hi DiffAdd guibg=#113a1d ctermbg=22
	hi DiffChange guifg=#000000 guibg=#dddddd ctermfg=16 ctermbg=188
	hi DiffDelete guibg=#450c0f ctermbg=52
	hi DiffText guifg=#000000 guibg=#d4edf4 ctermfg=16 ctermbg=195
	hi Folded guifg=#a4a5a7 guibg=#494a4f ctermfg=145 ctermbg=59
	hi Function guifg=#4fb0ca ctermfg=74
	hi Keyword guifg=#fe7bb1 ctermfg=211 gui=bold cterm=bold
	hi NonText guifg=#747478 ctermfg=102
	hi Normal guifg=#ffffff guibg=#292a30
	hi Number guifg=#d9c981 ctermfg=186
	hi PreProc guifg=#ffa157 ctermfg=215
	hi Search guifg=#ffffff guibg=#545558 ctermfg=231 ctermbg=59 gui=bold cterm=bold
	hi StatusLineNC guifg=#747478 ctermfg=102 gui=reverse cterm=reverse
	hi String guifg=#ff8272 ctermfg=203
	hi Visual guibg=#646f82 ctermbg=60
	hi helpHyperTextJump guifg=#6699fb ctermfg=69
endif

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

if &background ==# 'light'
  let g:terminal_ansi_colors = ['#e5e5e5', '#d12f1b', '#3e8087', '#78492a', '#0f68a0', '#ad3da4', '#804fb8', '#262626', '#8a99a6', '#d12f1b', '#23575c', '#78492a', '#0b4f79', '#ad3da4', '#4b21b0', '#262626']
else  " &background ==# 'dark'
  let g:terminal_ansi_colors = ['#21222c', '#ff5555', '#50fa7b', '#f1fa8c', '#bd93f9', '#ff79c6', '#8be9fd', '#f8f8f2', '#6272a4', '#ff6e6e', '#69ff94', '#ffffa5', '#d6acff', '#ff92df', '#a4ffff', '#ffffff']
endif
