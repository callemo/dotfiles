if exists("g:loaded_venv") || !has("python3")
  finish
endif
let g:loaded_venv = 1
let g:venv_is_enabled = 0

if !exists("g:venv_home")
  let g:venv_home = !empty($WORKON_HOME) ? $WORKON_HOME : expand("~/.virtualenvs")
endif

python3 <<EOF
import os
import site
import sys
import vim

venv_initial_os_path = os.environ["PATH"]
venv_initial_sys_path = sys.path[:]
venv_initial_os_venv = os.environ.get("VIRTUAL_ENV")
venv_is_enabled = False


def venv_set():
    global venv_is_enabled
    global venv_initial_os_path
    if venv_is_enabled:
        venv_reset()
    for child in os.scandir(os.path.join(os.environ["VIRTUAL_ENV"], "lib")):
        sitedir = os.path.join(child.path, "site-packages")
        if os.path.isdir(sitedir):
            site.addsitedir(sitedir)
            if not venv_is_enabled:
                venv_is_enabled = True
    if not venv_is_enabled:
        return
    os.environ["PATH"] = os.pathsep.join(
        (os.path.join(os.environ["VIRTUAL_ENV"], "bin"), os.environ["PATH"])
    )
    sys.prefix = os.environ["VIRTUAL_ENV"]
    vim.command("let g:venv_is_enabled = 1")
    print("venv: enabled: " + sys.prefix)


def venv_reset():
    global venv_is_enabled
    global venv_initial_os_path
    global venv_initial_os_venv
    if not venv_is_enabled:
        return
    if venv_initial_os_venv is None:
        del os.environ["VIRTUAL_ENV"]
        vim.command("unlet $VIRTUAL_ENV")
    else:
        os.environ["VIRTUAL_ENV"] = venv_initial_os_venv
        vim.command('let $VIRTUAL_ENV = "' + venv_initial_os_venv + '"')
    os.environ["PATH"] = venv_initial_os_path
    sys.path = venv_initial_sys_path[:]
    sys.prefix = sys.base_prefix
    venv_is_enabled = False
    vim.command("let g:venv_is_enabled = 0")
    print("venv: disabled")
EOF

function! Venv()
  if g:venv_is_enabled == 1
    python3 venv_reset()
    return
  endif

  if empty($VIRTUAL_ENV)
    let path = g:venv_home . "/" . fnamemodify(getcwd(), ":t")
    if !isdirectory(path)
      echoerr "venv: not found: " . path
      return
    endif
    let $VIRTUAL_ENV=path
    python3 os.environ["VIRTUAL_ENV"] = vim.eval("$VIRTUAL_ENV")
  endif

  python3 venv_set()
endfunction

command! Venv call Venv()

if !empty($VIRTUAL_ENV)
  call Venv()
endif

" vim: set sw=2 sts=2 et fdm=indent: 
