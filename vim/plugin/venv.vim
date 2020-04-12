if exists("g:loaded_venv")
  finish
endif
let g:loaded_venv = 1

function! Venv(path)
  if !has("python3")
    return 0
  endif

  if !isdirectory(expand(a:path))
    return 0
  endif

  let $VIRTUAL_ENV=(expand(a:path))
  python3 <<EOF
import os
import pathlib
import site
import sys
VIRTUAL_ENV = os.environ.get("VIRTUAL_ENV")
if VIRTUAL_ENV:
    venv_path = pathlib.Path(VIRTUAL_ENV)
    os.environ["PATH"] = str(venv_path / "bin") + os.pathsep + os.environ["PATH"]
    for child in (venv_path / "lib").iterdir():
        site_path = child / "site-packages"
        if site_path.is_dir():
            site.addsitedir(site_path)
    sys.prefix = VIRTUAL_ENV
EOF
  return 1
endfunction

" vim: set sw=2 sts=2 et fdm=indent: 
