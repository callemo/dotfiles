setl foldmethod=indent
setl keywordprg=:Cmd\ pydoc3
setl sw=4 sts=4 et

iabbr <buffer> """ """"""<Esc>2hi<C-r>=dotfiles#EatBlank()<CR>
iabbr <buffer> #! #!/usr/bin/env python3<CR><C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> class\ class C:<Esc>Bmso
      \def __init__(self):<CR>
      \pass<CR>
      \<CR><Esc>`scw<C-r>=dotfiles#EatBlank()<CR>

iabbr <buffer> ifmain\ def main():<CR>
      \pass<Esc>Bmso<CR>
      \if __name__ == "__main__":
      \<CR>main()<CR>
      \<Esc>`scw<C-r>=dotfiles#EatBlank()<CR>
