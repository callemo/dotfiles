" ---------------------------------------------------------------------
" File: plan9.vim
" Description: A light color scheme inspired by Plan 9.
" ---------------------------------------------------------------------

hi clear
if exists('syntax_on')
  syntax reset
endif

set background=light
let g:colors_name = 'plan9'

" Reset: {{{
let s:highlight_groups = [
      \ 'ColorColumn', 'Comment', 'Conceal', 'Constant', 'CursorColumn',
      \ 'CursorLine', 'CursorLineNr', 'DiffAdd', 'DiffChange', 'DiffDelete',
      \ 'DiffText', 'Directory', 'Error', 'ErrorMsg', 'FoldColumn', 'Folded',
      \ 'Identifier', 'Ignore', 'IncSearch', 'LineNr', 'MatchParen',
      \ 'ModeMsg', 'MoreMsg', 'NonText', 'Pmenu', 'PmenuSbar', 'PmenuSel',
      \ 'PmenuThumb', 'PreProc', 'Question', 'Search', 'SignColumn',
      \ 'Special', 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare',
      \ 'Statement', 'StatusLine', 'StatusLineNC', 'TabLine', 'TabLineFill',
      \ 'TabLineSel', 'Title', 'Todo', 'Type', 'Underlined', 'VertSplit',
      \ 'Visual', 'VisualNOS', 'WarningMsg', 'WildMenu',
      \ ]
for s:g in s:highlight_groups
  exe 'hi! ' . s:g
        \ . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE'
        \ . ' gui=NONE guifg=NONE guibg=NONE'
endfor
" }}}
" Formats: {{{
let s:support_italics = ['rxvt', 'gnome-terminal', 'iTerm.app']
let s:has_italic = v:false
for term in s:support_italics
  if $TERM_PROGRAM =~# term
    let s:has_italic=1
    break
  endif
endfor

if has('gui_running')
  let s:has_italic=1
  let g:terminal_ansi_colors = [
        \ '#e5e5e5', '#d12f1b', '#3e8087', '#78492a', '#0f68a0', '#ad3da4',
        \ '#804fb8', '#262626', '#8a99a6', '#d12f1b', '#23575c', '#78492a',
        \ '#0b4f79', '#ad3da4', '#4b21b0', '#262626'
        \ ]
endif

let s:italic = s:has_italic ? ' gui=italic cterm=italic' : ' gui=NONE cterm=NONE'
" }}} Formats:
" Colors: {{{
let s:base03  = ' guibg=#002b36 ctermbg=234'
let s:base02  = ' guibg=#073642 ctermbg=235'
let s:base01  = ' guifg=#586e75 ctermfg=240'
let s:base00  = ' guifg=#657b83 ctermfg=241'
let s:base0   = ' guifg=#839496 ctermfg=244'
let s:base1   = ' guifg=#93a1a1 ctermfg=245'
let s:base2   = ' guibg=#eee8d5 ctermbg=254'
let s:base3   = ' guibg=#fdf6e3 ctermbg=230'
let s:yellow  = ' guifg=#b58900 ctermfg=136'
let s:orange  = ' guifg=#cb4b16 ctermfg=166'
let s:red     = ' guifg=#dc322f ctermfg=160'
let s:magenta = ' guifg=#d33682 ctermfg=125'
let s:violet  = ' guifg=#6c71c4 ctermfg=061'
let s:blue    = ' guifg=#268bd2 ctermfg=033'
let s:cyan    = ' guifg=#2aa198 ctermfg=037'
let s:green   = ' guifg=#859900 ctermfg=064'

let s:white   = ' guibg=#ffffff ctermbg=231'

let s:text       = ' guifg=Black ctermfg=Black'
let s:background = ' guibg=#ffffe0 ctermbg=230'

let s:primaryAnsi = '229'
let s:primaryRGB  = '#ededa6'
let s:primaryFg   = ' guifg=' . s:primaryRGB . ' ctermfg=' . s:primaryAnsi
let s:primaryBg   = ' guibg=' . s:primaryRGB . ' ctermbg=' . s:primaryAnsi

let s:primaryDarkAnsi = '101'
let s:primaryDarkRGB  = '#979758'
let s:primaryDarkFg   = ' guifg=' . s:primaryDarkRGB . ' ctermfg=' . s:primaryDarkAnsi
let s:primaryDarkBg   = ' guibg=' . s:primaryDarkRGB . ' ctermbg=' . s:primaryDarkAnsi

let s:secondaryAnsi = '195'
let s:secondaryRGB  = '#e9ffff'
let s:secondaryFg   = ' guifg=' . s:secondaryRGB . ' ctermfg=' . s:secondaryAnsi
let s:secondaryBg   = ' guibg=' . s:secondaryRGB . ' ctermbg=' . s:secondaryAnsi

let s:secondaryDarkAnsi = '159'
let s:secondaryDarkRGB  = '#9ceeed'
let s:secondaryDarkFg   = ' guifg=' . s:secondaryDarkRGB . ' ctermfg=' . s:secondaryDarkAnsi
let s:secondaryDarkBg   = ' guibg=' . s:secondaryDarkRGB . ' ctermbg=' . s:secondaryDarkAnsi

let s:accentAnsi = '104'
let s:accentRGB  = '#8787c6'
let s:accentFg   = ' guifg=' . s:accentRGB . ' ctermfg=' . s:accentAnsi
let s:accentBg   = ' guibg=' . s:accentRGB . ' ctermbg=' . s:accentAnsi
" }}}
" Interface: {{{
exe 'hi! CursorLine'   . s:text          . s:primaryBg
exe 'hi! Folded'       . s:primaryDarkFg . s:background      . s:italic
exe 'hi! IncSearch'    . s:text          . s:primaryBg
exe 'hi! LineNr'       . s:primaryDarkFg . s:background
exe 'hi! MatchParen'   . s:accentFg      . s:background      . ' gui=bold,underline cterm=bold,underline'
exe 'hi! ModeMsg'                                            . ' gui=bold cterm=bold'
exe 'hi! MoreMsg'                                            . ' gui=bold cterm=bold'
exe 'hi! Normal'       . s:text          . s:white
exe 'hi! Pmenu'        . s:accentFg      . s:background      . ' gui=reverse cterm=reverse'
exe 'hi! PmenuSbar'    . s:text          . s:secondaryBg
exe 'hi! PmenuSel'     . s:text          . s:secondaryBg
exe 'hi! PmenuThumb'   . s:text          . s:background      . ' gui=reverse cterm=reverse'
exe 'hi! Search'       . s:text          . s:primaryBg
exe 'hi! StatusLineNC' . s:text          . s:secondaryBg
exe 'hi! StatusLine'   . s:text          . s:secondaryDarkBg . ' gui=bold cterm=bold'
exe 'hi! TabLineSel'   . s:text          . s:secondaryDarkBg . ' gui=bold cterm=bold'
exe 'hi! TabLine'      . s:text          . s:secondaryBg
exe 'hi! Visual'       . s:text          . s:primaryBg
exe 'hi! WildMenu'     . s:text          . s:background      . ' gui=reverse cterm=reverse'
hi! helpHyperTextJump gui=underline cterm=underline

hi! link SignColumn LineNr
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLineFill TabLine
" }}}
" Syntax: {{{
exe 'hi! Comment' . s:base01 . s:italic
hi! DiffAdd guibg=#edfff0 ctermbg=195
hi! DiffText guibg=#fdfae6 ctermbg=230
hi! DiffDelete guibg=#fef0f1 ctermbg=255 
hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
exe 'hi! Directory' . s:blue
exe 'hi! Error' . s:red . ' gui=bold cterm=bold'
exe 'hi! ErrorMsg' . s:red . ' gui=bold cterm=bold'
exe 'hi! PreProc' . s:orange
exe 'hi! SpellBad' . s:red . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellCap' . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellLocal' . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellRare' . ' gui=undercurl cterm=undercurl'
exe 'hi! String' . s:magenta
exe 'hi! Title' . ' gui=bold cterm=bold'
hi! link Todo Error
exe 'hi! Underlined' . ' gui=underline cterm=underline'
exe 'hi! WarningMsg' . s:yellow . ' gui=bold cterm=bold'
" }}}
" Plugins: {{{
hi! link ALEError SpellBad
hi! link ALEErrorSign Error

exe 'hi! CtrlPPrtCursor gui=underline cterm=underline'
hi! link CtrlPMatch IncSearch
hi! link CtrlPNoEntries Error
hi! link CtrlPTabExtra Normal
hi! link CtrlPTagKind Type

hi! link NERDTreeCWD ModeMsg
hi! link NERDTreeDir Directory
" }}}
" Filetypes: {{{
hi! link goDeclaration Statement
hi! link goDeclType Statement
hi! link goFormatSpecifier PreProc
hi! link goType Statement
exe 'hi! htmlArg' . s:italic
hi! link htmlEndTag Normal
exe 'hi! htmlItalic' . s:italic
hi! link htmlTag Normal
hi! link htmlTagN Statement
exe 'hi! htmlTagName' . s:violet
hi! link jsClassKeyword Statement
hi! link jsExtendsKeyword Statement
hi! link jsFunction Statement
hi! link jsObjectKey Identifier
hi! link jsonBraces Normal
hi! link jsonKeyword Identifier
hi! link jsonString String
hi! link jsTemplateString String
hi! link jsVariableDef Identifier
hi! link pythonBuiltin Statement
hi! link pythonConditional Statement
hi! link pythonImport PreProc
hi! link pythonRepeat Statement
hi! link xmlAttrib htmlArg
hi! link xmlEndTag Normal
hi! link xmlTag Normal
exe 'hi! xmlTagName' . s:violet
hi! link yamlKey Identifier
"}}}
