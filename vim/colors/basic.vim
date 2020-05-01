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
      \ 'Comment', 'Constant', 'Delimiter', 'Function', 'DiffAdd',
      \ 'DiffChange', 'DiffDelete', 'DiffText', 'Identifier', 'Special',
      \ 'Statement', 'Search', 'MatchParen', 'PreProc', 'TabLine',
      \ 'TabLineFill', 'TabLineSel', 'Todo', 'Type', 'Visual'
      \]

for s:g in s:highlight_groups
  exe 'hi! ' . s:g
        \ . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE'
        \ . ' gui=NONE guifg=NONE guibg=NONE'
endfor

hi helpHyperTextJump gui=underline cterm=underline
hi TabLineSel gui=reverse,bold cterm=reverse,bold
hi Todo ctermfg=125 guifg=#d33682
hi WildMenu ctermfg=016 ctermbg=159 guifg=#000000 guibg=#9ceeed cterm=bold gui=bold

if &background ==# 'light'
  hi Comment guifg=#8a99a6 ctermfg=245
  hi DiffAdd guibg=#edfff0 ctermbg=195
  hi DiffDelete guibg=#fef0f1 ctermbg=255
  hi DiffText guibg=#fdfae6 ctermbg=230
  hi Function ctermfg=97 guifg=#804fb8
  hi Search ctermfg=235 ctermbg=254 guifg=#262626 guibg=#e5e5e5
  hi String ctermfg=160 guifg=#d12f1b
  hi Visual ctermbg=153 guibg=#b4d8fd
else
  hi Comment guifg=#8a99a6 ctermfg=246
  hi DiffAdd ctermfg=159 ctermbg=235 guifg=#b1faeb guibg=#1e2a28
  hi DiffChange ctermfg=215 guifg=#ffa14f
  hi DiffDelete ctermfg=210 ctermbg=235 guifg=#ff8a7a guibg=#2f2625
  hi DiffText ctermfg=215 ctermbg=235 guifg=#ffa14f guibg=#2e2622 cterm=reverse gui=reverse
  hi Function ctermfg=141 guifg=#b281eb
  hi Search ctermfg=254 ctermbg=238 guifg=#dfdfe0 guibg=#414453
  hi String ctermfg=210 guifg=#ff8170
  hi Visual ctermbg=238 guibg=#414453
endif

hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link VertSplit Normal
