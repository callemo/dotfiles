" ---------------------------------------------------------------------
" File: acme.vim
" Description: A light color scheme inspired by Acme and Solarized.
" ---------------------------------------------------------------------

hi clear
syntax reset

set background=light
let g:colors_name = 'acme'

if !exists('g:acme_syntax')
  let g:acme_syntax = 0
endif

" Formats: {{{
let s:support_italics=['rxvt', 'gnome-terminal', 'iTerm.app']
let s:has_italic=0
for term in s:support_italics
  if $TERM_PROGRAM =~ term
    let s:has_italic=1
    break
  endif
endfor

if has('gui_running') || $COLORTERM == 'truecolor'
  let s:has_italic=1
endif

let s:i= ''
if s:has_italic == 1
  let s:i= ',italic'
endif

let s:bold        = ' gui=bold cterm=bold'
let s:italic      = ' gui=NONE'.s:i.' cterm=NONE'.s:i
let s:bold_italic = ' gui=bold'.s:i.' cterm=bold'.s:i
" }}} Formats:
" Reset: {{{
hi! ColorColumn  term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Comment      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Conceal      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Constant     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! CursorColumn term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! CursorLine   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! CursorLineNr term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! DiffAdd      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! DiffChange   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! DiffDelete   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! DiffText     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Directory    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Error        term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! ErrorMsg     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! FoldColumn   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Folded       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Identifier   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Ignore       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! IncSearch    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! LineNr       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! MatchParen   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! ModeMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! MoreMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! NonText      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Pmenu        term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! PmenuSbar    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! PmenuSel     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! PmenuThumb   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! PreProc      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Question     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Search       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! SignColumn   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Special      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! SpellBad     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! SpellCap     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! SpellLocal   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! SpellRare    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Statement    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! StatusLine   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! StatusLineNC term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! TabLine      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! TabLineFill  term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! TabLineSel   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Title        term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Todo         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Type         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Underlined   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! VertSplit    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! Visual       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! VisualNOS    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! WarningMsg   term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
hi! WildMenu     term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
" }}}
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

let s:text       = ' guifg=#000000 ctermfg=016'
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
exe 'hi! LineNr'       . s:primaryDarkFg . s:background      . s:italic
exe 'hi! MatchParen'   . s:accentFg      . s:background      . ' gui=bold,underline cterm=bold,underline'
exe 'hi! ModeMsg'                                            . ' gui=bold cterm=bold'
exe 'hi! MoreMsg'                                            . ' gui=bold cterm=bold'
exe 'hi! Normal'       . s:text          . s:background
exe 'hi! Pmenu'        . s:accentFg      . s:background      . ' gui=reverse cterm=reverse'
exe 'hi! PmenuSbar'    . s:text          . s:secondaryBg
exe 'hi! PmenuSel'     . s:text          . s:secondaryBg
exe 'hi! PmenuThumb'   . s:text          . s:background      . ' gui=reverse cterm=reverse'
exe 'hi! Search'       . s:text          . s:primaryBg
exe 'hi! StatusLineNC' . s:text          . s:secondaryBg
exe 'hi! StatusLine'   . s:text          . s:secondaryDarkBg
exe 'hi! TabLineSel'   . s:text          . s:secondaryDarkBg
exe 'hi! TabLine'      . s:text          . s:secondaryBg
exe 'hi! Visual'       . s:text          . s:primaryBg
exe 'hi! WildMenu'     . s:text          . s:background      . ' gui=reverse cterm=reverse'

hi! link SignColumn LineNr
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLineFill TabLine
" }}}
" Syntax: {{{
exe 'hi! Comment'    . s:base01          . s:italic
exe 'hi! DiffAdd'    . s:green . s:base2
exe 'hi! DiffChange' . s:base1 . s:base2
exe 'hi! DiffDelete' . s:red   . s:base2
exe 'hi! DiffText'   . s:blue  . s:base2
exe 'hi! Directory'  . s:blue
exe 'hi! ErrorMsg'   . s:red             . ' gui=bold cterm=bold'
exe 'hi! Error'      . s:red             . ' gui=bold cterm=bold'
exe 'hi! PreProc'    . s:orange
exe 'hi! Special'    . s:blue
exe 'hi! SpellBad'   . s:red             . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellCap'                       . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellLocal'                     . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellRare'                      . ' gui=undercurl cterm=undercurl'
exe 'hi! String'     . s:magenta
exe 'hi! Title'                          . ' gui=bold cterm=bold'
exe 'hi! Underlined'                     . ' gui=underline cterm=underline'
exe 'hi! WarningMsg' . s:yellow          . ' gui=bold cterm=bold'
hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
hi! link Todo Error
if (g:acme_syntax == 1)
  exe 'hi! Identifier' . s:cyan
  exe 'hi! Statement'  . s:violet
  exe 'hi! Type'       . s:violet
endif
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
exe 'hi! htmlArg'                . s:italic
exe 'hi! htmlItalic'             . s:italic
exe 'hi! htmlTagName' . s:violet
hi! link htmlEndTag Normal
hi! link htmlTag Normal
hi! link htmlTagN Statement
exe 'hi! xmlTagName' . s:violet
hi! link xmlTag Normal
hi! link xmlEndTag Normal
hi! link xmlAttrib htmlArg
hi! link yamlKey Identifier
hi! link jsonKeyword Identifier
hi! link jsonString String
hi! link jsonBraces Normal
hi! link jsClassKeyword Statement
hi! link jsExtendsKeyword Statement
hi! link jsFunction Statement
hi! link jsTemplateString String
hi! link jsVariableDef Identifier
hi! link jsObjectKey Identifier
hi! link pythonImport PreProc
hi! link pythonBuiltin Statement
hi! link pythonRepeat Statement
hi! link pythonConditional Statement
hi! link goDeclaration Statement
hi! link goDeclType Statement
hi! link goType Statement
hi! link goFormatSpecifier PreProc
"}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker:
