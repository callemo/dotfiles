" ---------------------------------------------------------------------
" File: basic.vim
" Description: Basic theme based on the default.
" ---------------------------------------------------------------------

hi clear
if exists('syntax_on')
  syntax reset
endif

runtime colors/default.vim

let g:colors_name = 'basic'

let s:highlight_groups = [
      \ 'Comment', 'Constant', 'Delimiter', 'Function', 'DiffAdd',
      \ 'DiffChange', 'DiffDelete', 'DiffText', 'Identifier', 'Special',
      \ 'Statement', 'Search', 'MatchParen', 'TabLine', 'TabLineFill',
      \ 'TabLineSel', 'Todo', 'Type', 'Visual'
      \]

for s:g in s:highlight_groups
  exe 'hi! ' . s:g
        \ . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE'
        \ . ' gui=NONE guifg=NONE guibg=NONE'
endfor

hi! Comment ctermfg=240 guifg=#586e75
hi! DiffAdd guibg=#edfff0 ctermbg=195
hi! DiffDelete guibg=#fef0f1 ctermbg=255 
hi! DiffText guibg=#fdfae6 ctermbg=230
hi! Function ctermfg=33 guifg=#268bd2
hi! helpHyperTextJump gui=underline cterm=underline
hi! Search ctermfg=016 ctermbg=229 guifg=#000000 guibg=#ededa6
hi! String ctermfg=37 guifg=#2aa198
hi! TabLineSel gui=reverse,bold cterm=reverse,bold
hi! Todo ctermfg=125 guifg=#d33682
hi! Visual ctermfg=240 ctermbg=234 guifg=#586e75 guibg=#002b36
hi! WildMenu ctermfg=016 ctermbg=159 guifg=#000000 guibg=#9ceeed cterm=bold gui=bold

hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link VertSplit Normal
