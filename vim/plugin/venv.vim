if exists("g:loaded_venv") || !has("python3")
  finish
endif
let g:loaded_venv = 1

if !exists("g:venv_home")
  let g:venv_home = !empty($WORKON_HOME) ? $WORKON_HOME : expand("~/.virtualenvs")
endif

function! Venv()
  if empty($VIRTUAL_ENV)
    let path = g:venv_home . "/" . fnamemodify(getcwd(), ":t")
    if !isdirectory(path)
      echoerr "Can not find virtualenv: " . path
      return
    endif
    let $VIRTUAL_ENV=path
  endif

  python3 <<EOF
import os
import pathlib
import site
import sys
venv_path = pathlib.Path(os.environ["VIRTUAL_ENV"])
os.environ["PATH"] = str(venv_path / "bin") + os.pathsep + os.environ["PATH"]
for child in (venv_path / "lib").iterdir():
    site_path = child / "site-packages"
    if site_path.is_dir():
        site.addsitedir(site_path)
sys.prefix = os.environ["VIRTUAL_ENV"]
EOF

  echomsg "Enabled virtualenv: " . fnamemodify($VIRTUAL_ENV, ":t")
endfunction

command! Venv call Venv()

" vim: set sw=2 sts=2 et fdm=indent: 
