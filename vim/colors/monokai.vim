" --------------------------------------------------------------------
" File: monokai.vim
" Description: A dark color scheme inspired by Sublime Text's Monokai.
" --------------------------------------------------------------------

hi clear
syntax reset

set background=dark
let g:colors_name = 'monokai'

if !exists('g:monokai_syntax')
  let g:monokai_syntax = 0
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

let s:italic = ' gui=NONE'.s:i.' cterm=NONE'.s:i
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

let s:activeGuide        = ' guifg=#9D550F ctermfg=130'
let s:background         = ' guibg=#272822 ctermbg=016'
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
let s:textComment        = ' guifg=#75715e ctermfg=095'
let s:type               = ' guifg=#66d9ef ctermfg=81'
" }}}
" Interface: {{{
exe 'hi! CursorLine'   . s:text                 . s:lineHighlight
exe 'hi! Folded'       . s:guide                . s:background     . s:italic
exe 'hi! IncSearch'    . s:findHighlightText    . s:findHighlight
exe 'hi! LineNr'       . s:guide                . s:background     . s:italic
exe 'hi! MatchParen'   . s:bracketsForeground   . s:background     . ' gui=bold,underline cterm=bold,underline'
exe 'hi! MoreMsg'                                                  . ' gui=bold cterm=bold'
exe 'hi! Normal'       . s:text                 . s:background
exe 'hi! PmenuSbar'    . s:text                 . s:lineHighlight
exe 'hi! PmenuSel'     . s:text                 . s:lineHighlight
exe 'hi! Pmenu'        . s:guide                . s:background     . ' gui=reverse cterm=reverse'
exe 'hi! PmenuThumb'   . s:guide                . s:background     . ' gui=reverse cterm=reverse'
exe 'hi! Search'       . s:findHighlightText    . s:findHighlight
exe 'hi! StatusLineNC' . s:text                 . s:lineHighlight
exe 'hi! StatusLine'   . s:text                 . s:lineHighlight  . ' gui=bold cterm=bold'
exe 'hi! TabLineSel'   . s:text                 . s:lineHighlight  . ' gui=bold cterm=bold'
exe 'hi! TabLine'      . s:guide                . s:background
exe 'hi! Visual'       . s:text                 . s:selection
exe 'hi! WarningMsg'   . s:activeGuide                             . ' gui=bold cterm=bold'
exe 'hi! WildMenu'     . s:text                 . s:lineHighlight  . ' gui=reverse cterm=reverse'

hi! link ErrorMsg Error
hi! link FoldColumn Folded
hi! link ModeMsg WarningMsg
hi! link SignColumn LineNr
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLineFill TabLine
" }}}
" Syntax: {{{
exe 'hi! Comment'    . s:textComment              . s:italic
exe 'hi! Constant'   . s:number
exe 'hi! DiffAdd'    . s:green        . s:base02
exe 'hi! DiffChange' . s:yellow       . s:base02
exe 'hi! DiffDelete' . s:red          . s:base02
exe 'hi! DiffText'   . s:orange       . s:base02
exe 'hi! Error'      . s:misspelling              . ' gui=bold cterm=bold'
exe 'hi! Number'     . s:number
exe 'hi! PreProc'    . s:text
exe 'hi! Special'    . s:activeGuide
exe 'hi! SpellBad'   . s:misspelling              . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellCap'                                . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellLocal'                              . ' gui=undercurl cterm=undercurl'
exe 'hi! SpellRare'                               . ' gui=undercurl cterm=undercurl'
exe 'hi! String'     . s:string
exe 'hi! Title'                                   . ' gui=bold cterm=bold'
exe 'hi! Underlined'                              . ' gui=underline cterm=underline'
hi! link diffAdded DiffAdd
hi! link diffRemoved DiffDelete
hi! link Todo Error
if (g:monokai_syntax == 1)
  exe 'hi! Identifier' . s:identifier
  exe 'hi! Statement'  . s:keyword
  exe 'hi! Type'       . s:type
endif
" }}}
" Plugins: {{{
exe 'hi! CtrlPPrtCursor gui=underline cterm=underline'
exe 'hi! CtrlPTagKind' . s:type
hi! link CtrlPMatch IncSearch
hi! link CtrlPNoEntries Error
hi! link CtrlPTabExtra Normal
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
exe 'hi! htmlArg'     . s:identifier . s:italic
exe 'hi! htmlItalic'                 . s:italic
exe 'hi! htmlTagName' . s:keyword
hi! link htmlEndTag Normal
hi! link htmlTag Normal
hi! link htmlTagN Statement
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
exe 'hi! xmlTagName' . s:keyword
hi! link xmlAttrib htmlArg
hi! link xmlEndTag Normal
hi! link xmlTag Normal
hi! link yamlKey Identifier
"}}}

