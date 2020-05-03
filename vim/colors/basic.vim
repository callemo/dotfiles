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

hi ErrorMsg guifg=#ffffff guibg=#f74a4a ctermfg=231 ctermbg=203
hi TabLineSel gui=reverse,bold cterm=reverse,bold
hi Todo guifg=#ffffff guibg=#efb759 ctermfg=231 ctermbg=215
hi WildMenu cterm=bold gui=bold

if &background ==# 'light'
  hi Comment guifg=#5d6c79 ctermfg=60
  hi CursorLine guibg=#e8f2ff cterm=NONE term=NONE
  hi CursorLineNr guifg=#000000 ctermfg=16 cterm=NONE term=NONE
  hi DiffAdd guibg=#edfff0 ctermbg=195
  hi DiffChange guifg=#000000 guibg=#8e8e8e ctermfg=16 ctermbg=102
  hi DiffDelete guibg=#fef0f1 ctermbg=255
  hi DiffText guifg=#000000 guibg=#e8f2ff ctermfg=16 ctermbg=195
  hi ErrorMsg guibg=#f74a4a ctermbg=203
  hi Function guifg=#326d74 ctermfg=60
  hi helpHyperTextJump guifg=#0e0eff ctermfg=21
  hi Keyword guifg=#9b2393 ctermfg=90
  hi LineNr guifg=#cdcdcd ctermfg=252
  hi MatchParen guifg=#262626 guibg=#fef869 ctermfg=235 ctermbg=227
  hi Normal guifg=#000000 guibg=#ffffff
  hi Number guifg=#1c00cf ctermfg=20
  hi PreProc guifg=#643820 ctermfg=58
  hi Search guifg=#262626 guibg=#e5e5e5 ctermfg=235 ctermbg=254
  hi String guifg=#c41a16 ctermfg=160
  hi Visual guibg=#a4cdff ctermbg=153
else  " &background ==# 'dark'
  hi Comment guifg=#6c7986 ctermfg=66
  hi CursorLine guibg=#23252b cterm=NONE term=NONE
  hi CursorLineNr guifg=#ffffff cterm=NONE term=NONE
  hi DiffChange guifg=#ffffff guibg=#8e8e8e ctermfg=231 ctermbg=102
  hi DiffDelete ctermfg=210 ctermbg=235 guifg=#ff8a7a guibg=#2f2625
  hi DiffText guifg=#ffffff guibg=#23252b ctermfg=231 ctermbg=16
  hi Function guifg=#67b7a4 ctermfg=73
  hi helpHyperTextJump guifg=#5482ff ctermfg=69
  hi Keyword guifg=#fc5fa3 ctermfg=205
  hi LineNr guifg=#53606e ctermfg=59
  hi MatchParen guifg=#292a30 guibg=#fef937 ctermfg=235 ctermbg=226
  hi Normal guifg=#ffffff guibg=#1f1f24
  hi Number guifg=#d0bf69 ctermfg=179
  hi PreProc guifg=#fd8f3f ctermfg=209
  hi Search ctermfg=254 ctermbg=238 guifg=#dfdfe0 guibg=#414453
  hi String guifg=#fc6a5d ctermfg=203
  hi Visual guibg=#515b70 ctermbg=59
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
