setl foldmethod=indent
setl keywordprg=:Cmd\ pydoc3
" setl makeprg=pylint\ %
setl sw=4 sts=4 et

iabbr <buffer> #! #!/usr/bin/env python3<CR>
      \<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> class\ class :<C-o>mm<CR>
      \def __init__(self):<CR>
      \pass<CR>
      \<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> ifmain\ def main():<CR>
      \pass<C-o>mm<CR><CR>
      \if __name__ == "__main__":<CR>
      \main()<Esc>`mcc<C-r>=dotfiles#EndAbbr()<CR>

iabbr <buffer> argparse\ parser = argparse.ArgumentParser()<CR>
      \parser.add_argument(""<C-o>mm)<CR>
      \args = parser.parse_args()<C-o>`m<C-r>=dotfiles#EndAbbr()<CR>

inoremap <buffer> <C-x>= {}<Left>
inoremap <buffer> <C-x>" """"""<Left><Left><Left>
imap <buffer> <C-x>' <C-x>"
