setl foldmethod=indent
setl sw=4 sts=4 et

if has('unix') && has('terminal')
  setl keywordprg=:terminal\ python3\ -m\ pydoc
endif

inoremap <buffer> <C-x>= {}<Left>
inoremap <buffer> <C-x>" """"""<Left><Left><Left>
inoremap <buffer> <C-x>! #!/usr/bin/env python3<CR>
imap <buffer> <C-x>' <C-x>"

iabbrev <buffer> class] class :<C-o>mm<CR>
  \<c-t>def __init__(self):<CR>
  \<c-t>pass<CR>
  \<ESC>`mi

iabbrev <buffer> main] def main():<CR>
  \<C-o>mm<CR>
  \<c-d><CR>
  \if __name__ == "__main__":<CR>
  \<c-t>main()<ESC>`mi<c-t>

iabbrev <buffer> argparse] parser = argparse.ArgumentParser()<CR>
  \parser.add_argument(""<C-o>mm)<CR>
  \args = parser.parse_args()<ESC>`mi

iabbrev <buffer> cmd] <c-x>!"""Command line utility."""<cr>
  \import argparse<cr>
  \import fileinput<cr><cr>
  \<c-o>:normal amain]<cr>
  \<c-o>:normal aargparse]<cr><right>files<right>, nargs="*"<esc>jo
  \with fileinput.input(files=args.files) as f:<cr>
  \<c-t>for line in f:<cr>
  \<c-t>print(line, end="")<cr>
