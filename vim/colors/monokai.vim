" --------------------------------------------------------------------
" File: monokai.vim
" Description: A dark color scheme inspired by Monokai.
" --------------------------------------------------------------------

hi clear
if exists('syntax_on')
  syntax reset
endif

set background=dark
let g:colors_name = 'monokai'

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
      \ 'Visual', 'VisualNOS', 'WarningMsg', 'WildMenu'
      \ ]
for s:g in s:highlight_groups
  exe 'hi! ' . s:g
        \ . ' term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE'
        \ . ' gui=NONE guifg=NONE guibg=NONE'
endfor
" }}}
" Formats: {{{
let s:support_italics=['rxvt', 'gnome-terminal', 'iTerm.app']
let s:has_italic=0
for term in s:support_italics
  if $TERM_PROGRAM =~ term
    let s:has_italic=1
    break
  endif
endfor

if has('gui_running')
  let s:has_italic=1
  let g:terminal_ansi_colors = ['#393b44', '#ff8170', '#78c2b3', '#d9c97c',
        \ '#4eb0cc', '#ff7ab2', '#b281eb', '#dfdfe0', '#7f8c98', '#ff8170',
        \ '#acf2e4', '#ffa14f', '#6bdfff', '#ff7ab2', '#dabaff', '#dfdfe0']
endif

let s:i= ''
if s:has_italic == 1
  let s:i= ',italic'
endif

let s:italic = ' gui=NONE'.s:i.' cterm=NONE'.s:i
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

let s:activeGuide        = ' guifg=#9D550F ctermfg=130'
let s:background         = ' guibg=#000000 ctermbg=016'
let s:bracketsForeground = ' guifg=#f8f8f2 ctermfg=231'
let s:findHighlight      = ' guibg=#ffe792 ctermbg=222'
let s:findHighlightText  = ' guifg=#000000 ctermfg=016'
let s:guide              = ' guifg=#90908a ctermfg=102'
let s:identifier         = ' guifg=#a6e22e ctermfg=148'
let s:keyword            = ' guifg=#f92672 ctermfg=197'
let s:lineHighlight      = ' guibg=#3e3d32 ctermbg=059'
let s:misspelling        = ' guifg=#F92672 ctermfg=197'
let s:number             = ' guifg=#ae81ff ctermfg=141'
let s:selection          = ' guibg=#49483e ctermbg=059'
let s:string             = ' guifg=#e6db74 ctermfg=186'
let s:text               = ' guifg=#f8f8f2 ctermfg=231'
let s:textBackground     = ' guibg=#272822 ctermbg=235'
let s:textComment        = ' guifg=#75715e ctermfg=242'
let s:type               = ' guifg=#66d9ef ctermfg=81'
" }}}
" Interface: {{{
exe 'hi! CursorLine' . s:text . s:lineHighlight
exe 'hi! Folded' . s:guide . s:textBackground . s:italic
exe 'hi! IncSearch' . s:findHighlightText . s:findHighlight
exe 'hi! LineNr' . s:guide . s:textBackground
exe 'hi! MatchParen' . s:bracketsForeground . s:textBackground . ' gui=bold,underline cterm=bold,underline'
exe 'hi! MoreMsg' . ' gui=bold cterm=bold'
exe 'hi! Normal' . s:text . s:textBackground
exe 'hi! Pmenu' . s:guide . s:background . ' gui=reverse cterm=reverse'
exe 'hi! PmenuSbar' . s:text . s:lineHighlight
exe 'hi! PmenuSel' . s:text . s:lineHighlight
exe 'hi! PmenuThumb' . s:guide . s:background . ' gui=reverse cterm=reverse'
exe 'hi! Search' . s:findHighlightText . s:findHighlight
exe 'hi! StatusLine' . s:text . s:background . ' gui=bold cterm=bold'
exe 'hi! StatusLineNC' . s:text . s:background
exe 'hi! TabLine' . s:guide . s:background
exe 'hi! TabLineSel' . s:text . s:textBackground . ' gui=bold cterm=bold'
exe 'hi! Visual' . s:text . s:selection
exe 'hi! WarningMsg' . s:activeGuide . ' gui=bold cterm=bold'
exe 'hi! WildMenu' . s:text . s:lineHighlight . ' gui=reverse cterm=reverse'

hi! helpHyperTextJump gui=underline cterm=underline

hi! link ErrorMsg Error
hi! link FoldColumn Folded
hi! link ModeMsg WarningMsg
hi! link NonText LineNr
hi! link SignColumn LineNr
hi! link SpecialKey LineNr
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLineFill TabLine
" }}}
" Syntax: {{{
exe 'hi! Comment' . s:textComment . s:italic
exe 'hi! Constant' . s:number
hi DiffAdd ctermfg=159 ctermbg=235 guifg=#b1faeb guibg=#1e2a28
hi DiffChange ctermfg=215 guifg=#ffa14f
hi DiffDelete ctermfg=210 ctermbg=235 guifg=#ff8a7a guibg=#2f2625
hi DiffText ctermfg=215 ctermbg=235 guifg=#ffa14f guibg=#2e2622 cterm=reverse gui=reverse
hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
exe 'hi! Error' . s:misspelling . ' gui=bold cterm=bold'
exe 'hi! Function' . s:type
exe 'hi! Number' . s:number
exe 'hi! PreProc' . s:keyword
exe 'hi! SpellBad' . s:misspelling . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellCap' . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellLocal' . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellRare' . ' gui=undercurl cterm=undercurl'
exe 'hi! String' . s:string
exe 'hi! Title' . ' gui=bold cterm=bold'
hi! link Todo Error
exe 'hi! Underlined' . ' gui=underline cterm=underline'
" }}}
" Plugins: {{{
hi! link CtrlPMatch IncSearch
hi! link CtrlPNoEntries Error
hi! CtrlPPrtCursor gui=underline cterm=underline
hi! link CtrlPTabExtra Normal
exe 'hi! CtrlPTagKind' . s:type
hi! link NERDTreeCWD ModeMsg
hi! link NERDTreeDir Directory
hi! link NERDTreeDirSlash LineNr
" }}}
" Filetypes: {{{
hi! link cssBraces Normal
hi! link cssInclude Normal
hi! link goDeclaration Statement
hi! link goDeclType Statement
hi! link goFormatSpecifier PreProc
hi! link goType Statement
exe 'hi! htmlArg' . s:identifier . s:italic
hi! link htmlEndTag Normal
exe 'hi! htmlItalic' . s:italic
hi! link htmlTag Normal
hi! link htmlTagN Statement
exe 'hi! htmlTagName' . s:keyword
hi! link jsClassKeyword Statement
hi! link jsExtendsKeyword Statement
hi! link jsFunction Statement
hi! link jsGlobalNodeObjects Type
hi! link jsGlobalObjects Type
hi! link jsObjectKey Identifier
hi! link jsonBraces Normal
hi! link jsonKeyword Identifier
hi! link jsonString String
hi! link jsTemplateString String
hi! link jsVariableDef Normal
hi! link phpClass Identifier
hi! link phpDocTags Statement
hi! link phpParent Normal
hi! link phpUseClass Identifier
hi! link pythonBuiltin Statement
hi! link pythonConditional Statement
hi! link pythonImport PreProc
hi! link pythonRepeat Statement
hi! link scssAttribute cssAttr
hi! link scssProperty cssProp
hi! link xmlAttrib htmlArg
hi! link xmlEndTag Normal
hi! link xmlTag Normal
exe 'hi! xmlTagName' . s:keyword
hi! link yamlKey Identifier
"}}}
