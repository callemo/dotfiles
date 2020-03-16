if exists("g:loaded_virtualenv")
  finish
endif
let g:loaded_virtualenv = 1

if has('python3')
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
endif

" vim: set sw=2 sts=2 et fdm=indent: 
