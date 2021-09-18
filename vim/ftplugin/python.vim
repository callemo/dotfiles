setl foldmethod=indent
setl sw=4 sts=4 et

if has('unix') && has('terminal')
  setl keywordprg=:terminal\ python3\ -m\ pydoc
endif

inoremap <buffer> <c-x>= {}<left>
inoremap <buffer> <c-x>" """"""<left><left><left>
inoremap <buffer> <c-x>! #!/usr/bin/env python3<cr>
imap <buffer> <c-x>' <c-x>"

iabbrev <buffer> class] class :<c-o>mm<cr>
  \<c-t>def __init__(self):<cr>
  \<c-t>pass<cr>
  \<esc>`mi

iabbrev <buffer> main] def main():<cr>
  \<c-o>mm<cr>
  \<c-d><cr>
  \if __name__ == "__main__":<cr>
  \<c-t>main()<esc>`mi<c-t>

iabbrev <buffer> argparse] parser = argparse.ArgumentParser()<cr>
  \parser.add_argument(""<c-o>mm)<cr>
  \args = parser.parse_args()<esc>`mi

iabbrev <buffer> filter] <c-x>!"""Command-line filter."""<cr>
  \import argparse<cr>
  \import fileinput<cr>
  \import os<cr>
  \import sys<cr>
  \<cr><cr>
  \def main():<cr>
  \<c-o>:normal a<c-t>argparse]<cr><right>files<right>, nargs="*"<esc>jo
  \with fileinput.input(files=args.files) as f:<cr>
  \<c-t>for line in f:<cr>
  \<c-t>print(line<c-o>mm, end="")<cr>
  \<c-d><c-d><c-d>
  \<cr><cr>
  \try:<cr>
  \<c-t>main()<cr>
  \sys.stdout.flush()<cr>
  \<c-d>except (BrokenPipeError, KeyboardInterrupt):<cr>
  \<c-t>os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())<esc>`ma
