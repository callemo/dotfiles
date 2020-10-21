setl foldmethod=indent
setl keywordprg=:Cmd\ pydoc3
setl sw=4 sts=4 et

inoremap <buffer> <C-x>= {}<Left>
inoremap <buffer> <C-x>" """"""<Left><Left><Left>
inoremap <buffer> <C-x>! #!/usr/bin/env python3<CR><ESC>

imap <buffer> <C-x>' <C-x>"

iabbr <buffer> class\ class :<C-o>mm<CR>
      \def __init__(self):<CR>
      \pass<CR>
      \<ESC>`m

iabbr <buffer> ifmain\ def main():<CR>
      \pass<C-o>mm<CR><CR>
      \if __name__ == "__main__":<CR>
      \main()<ESC>`m

iabbr <buffer> argparse\ parser = argparse.ArgumentParser()<CR>
      \parser.add_argument(""<C-o>mm)<CR>
      \args = parser.parse_args()<ESC>`m
