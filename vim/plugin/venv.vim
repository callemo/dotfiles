if exists('g:loaded_venv') || !has('python3')
  finish
endif
let g:loaded_venv = 1

if !exists('g:venv_home')
  let g:venv_home = !empty($WORKON_HOME) ? $WORKON_HOME : expand('~/.virtualenvs')
endif

let g:venv_is_enabled = 0

python3 <<EOF
import os
import site
import sys
import vim


class Venv:
    def __init__(self):
        self.initial_os_path = os.environ["PATH"]
        self.initial_os_venv = os.environ.get("VIRTUAL_ENV")
        self.initial_sys_path = sys.path[:]
        self.is_enabled = False

    def set(self, path):
        if self.is_enabled:
            self.reset()

        for child in os.scandir(os.path.join(path, "lib")):
            sitedir = os.path.join(child.path, "site-packages")
            if os.path.isdir(sitedir):
                site.addsitedir(sitedir)
                if not self.is_enabled:
                    self.is_enabled = True

        if not self.is_enabled:
            return

        os.environ["PATH"] = os.pathsep.join(
            (os.path.join(path, "bin"), os.environ["PATH"])
        )
        sys.prefix = path
        vim.command("let g:venv_is_enabled = 1")
        print("venv: set: " + sys.prefix)

    def reset(self):
        if not self.is_enabled:
            return
        if self.initial_os_venv is None:
            del os.environ["VIRTUAL_ENV"]
            vim.command("unlet $VIRTUAL_ENV")
        else:
            os.environ["VIRTUAL_ENV"] = self.initial_os_venv
            vim.command('let $VIRTUAL_ENV = "' + self.initial_os_venv + '"')
        os.environ["PATH"] = self.initial_os_path
        sys.path = self.initial_sys_path[:]
        sys.prefix = sys.base_prefix
        self.is_enabled = False
        vim.command("let g:venv_is_enabled = 0")


venv = Venv()
EOF

function! s:venv(...)
  if a:0 == 0 && g:venv_is_enabled == 1
    python3 venv.reset()
    echomsg 'venv: reset'
    return
  endif

  if a:0 > 0
    let path = g:venv_home . '/' . a:1
  elseif !empty($VIRTUAL_ENV)
    let path = $VIRTUAL_ENV
  else
    let path = g:venv_home . '/' . fnamemodify(getcwd(), ':t')
  endif

  if !isdirectory(l:path)
    echohl ErrorMsg
    echomsg 'venv: not found: ' . l:path
    echohl NONE
    return
  endif

  python3 venv.set(vim.eval("l:path"))
endfunction

command! -nargs=? Venv call s:venv(<f-args>)

if !empty($VIRTUAL_ENV)
  if v:vim_did_enter
    call s:venv()
  else
    au VimEnter * call s:venv()
  endif
endif

