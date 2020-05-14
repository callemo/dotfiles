setl foldmethod=indent
setl keywordprg=:Cmd\ pydoc3
setl sw=4 sts=4 et

iabbr <buffer> #! #!/usr/bin/env python3<CR>
      \<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> """ """"""<Esc>2hi<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> class\ class :<C-o>mm<CR>
      \def __init__(self):<CR>
      \pass<CR>
      \<C-o>`m<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> ifmain\ def main():<CR>
      \pass<C-o>mm<CR><CR>
      \if __name__ == "__main__":<CR>
      \main()<Esc>`mcc<C-r>=dotfiles#EatBlank()<CR>
