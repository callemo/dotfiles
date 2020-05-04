" ---------------------------------------------------------------------
" File: basic.vim
" Description: A basic theme.
" ---------------------------------------------------------------------

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'basic'

let s:highlight_groups = [
      \ 'Comment', 'CursorLine', 'CursorLineNr', 'Constant',
      \ 'Delimiter', 'Function', 'DiffAdd', 'DiffChange', 'DiffDelete',
      \ 'DiffText', 'Error', 'ErrorMsg', 'Identifier', 'Special', 'Statement', 'Search',
      \ 'MatchParen', 'PreProc', 'TabLine', 'TabLineFill', 'TabLineSel',
      \ 'Todo', 'Type', 'Visual', 'WildMenu'
      \]

for s:g in s:highlight_groups
  exe 'hi! ' . s:g
        \ . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE'
        \ . ' gui=NONE guifg=NONE guibg=NONE'
endfor

hi ErrorMsg guifg=#000000 guibg=#f74a4a ctermfg=16 ctermbg=203
hi TabLineSel gui=reverse,bold cterm=reverse,bold
hi Todo guifg=#000000 guibg=#efb759 ctermfg=16 ctermbg=215
hi WildMenu cterm=bold gui=bold

if &background ==# 'light'
  hi Comment guifg=#707f8b ctermfg=241
  hi CursorLine guibg=#e8f2ff cterm=NONE term=NONE
  hi CursorLineNr guifg=#000000 ctermfg=16 cterm=NONE term=NONE
  hi DiffAdd guibg=#edfff0 ctermbg=195
  hi DiffChange guifg=#000000 guibg=#8e8e8e ctermfg=16 ctermbg=102
  hi DiffDelete guibg=#fef0f1 ctermbg=255
  hi DiffText guifg=#000000 guibg=#e8f2ff ctermfg=16 ctermbg=195
  hi ErrorMsg guibg=#f74a4a ctermbg=203
  hi Function guifg=#077cae ctermfg=31
  hi helpHyperTextJump guifg=#0e38fa ctermfg=27
  hi Keyword guifg=#9b2393 ctermfg=90
  hi LineNr guifg=#a6a6a6 ctermfg=145
  hi MatchParen guifg=#262626 guibg=#fef869 ctermfg=235 ctermbg=227
  hi Normal guifg=#000000 guibg=#ffffff
  hi Number guifg=#1c00cf ctermfg=20
  hi PreProc guifg=#78492d ctermfg=94
  hi Search guifg=#262626 guibg=#e5e5e5 ctermfg=235 ctermbg=254
  hi String guifg=#d13121 ctermfg=160
  hi Visual guibg=#b2d7fd ctermbg=153
else  " &background ==# 'dark'
  hi Comment guifg=#7f8c97 ctermfg=102
  hi CursorLine guibg=#2f3239 cterm=NONE term=NONE
  hi CursorLineNr guifg=#ffffff cterm=NONE term=NONE
  hi DiffChange guifg=#ffffff guibg=#8e8e8e ctermfg=231 ctermbg=102
  hi DiffDelete ctermfg=210 ctermbg=235 guifg=#ff8a7a guibg=#2f2625
  hi DiffText guifg=#ffffff guibg=#23252b ctermfg=231 ctermbg=16
  hi Function guifg=#4fb0ca ctermfg=74
  hi helpHyperTextJump guifg=#6699fb ctermfg=69
  hi Keyword guifg=#fc5fa3 ctermfg=205
  hi LineNr guifg=#747478 ctermfg=102
  hi MatchParen guifg=#000000 guibg=#fffb3b ctermfg=16 ctermbg=227
  hi Normal guifg=#ffffff guibg=#292a30
  hi Number guifg=#d9c981 ctermfg=186
  hi PreProc guifg=#ffa157 ctermfg=215
  hi Search guibg=#545558 ctermbg=59 gui=bold cterm=bold
  hi String guifg=#ff8272 ctermfg=209
  hi Visual guibg=#646f82 ctermbg=60
endif

hi link diffAdded DiffAdd
hi link diffRemoved DiffDelete
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC
hi link VertSplit Normal
hi link vimOption Function
hi link CursorLineNr Normal

if has('gui_running') || (has('termguicolors') && &termguicolors)
  if &background ==# 'light'
    let g:terminal_ansi_colors = [
          \ '#e5e5e5', '#d12f1b', '#3e8087', '#78492a', '#0f68a0', '#ad3da4',
          \ '#804fb8', '#262626', '#8a99a6', '#d12f1b', '#23575c', '#78492a',
          \ '#0b4f79', '#ad3da4', '#4b21b0', '#262626'
          \ ]
  else  " &background ==# 'dark'
    let g:terminal_ansi_colors = [
          \ '#393b44', '#ff8170', '#78c2b3', '#d9c97c', '#4eb0cc', '#ff7ab2',
          \ '#b281eb', '#dfdfe0', '#7f8c98', '#ff8170', '#acf2e4', '#ffa14f',
          \ '#6bdfff', '#ff7ab2', '#dabaff', '#dfdfe0'
          \ ]

  endif
endif
