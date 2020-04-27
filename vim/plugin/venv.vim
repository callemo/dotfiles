if exists('g:loaded_venv') || !has('python3')
  finish
endif
let g:loaded_venv = 1

if !exists('g:venv_home')
  let g:venv_home = !empty($WORKON_HOME) ? $WORKON_HOME : expand('~/.virtualenvs')
endif


python3 <<EOF
import os
import site
import sys
import vim


class Venv:
    def __init__(self):
        self.dir = ""
        self.initial_os_path = os.environ["PATH"]
        self.initial_os_venv = os.environ.get("VIRTUAL_ENV")
        self.initial_sys_path = sys.path[:]
        self.is_active = False

    def activate(self, dir):
        if self.is_active:
            self.deactivate()

        for child in os.scandir(os.path.join(dir, "lib")):
            sitedir = os.path.join(child.path, "site-packages")
            if os.path.isdir(sitedir):
                site.addsitedir(sitedir)
                if not self.is_active:
                    self.is_active = True

        if not self.is_active:
            return

        os.environ["VIRTUAL_ENV"] = dir
        os.environ["PATH"] = os.pathsep.join(
            (os.path.join(dir, "bin"), os.environ["PATH"])
        )
        sys.prefix = self.dir = dir

    def deactivate(self):
        if not self.is_active:
            return
        if self.initial_os_venv is not None:
            os.environ["VIRTUAL_ENV"] = self.initial_os_venv
            vim.command('let $VIRTUAL_ENV = "' + self.initial_os_venv + '"')
        os.environ["PATH"] = self.initial_os_path
        sys.path = self.initial_sys_path[:]
        sys.prefix = sys.base_prefix
        self.dir = ""
        self.is_active = False


venv = Venv()
EOF

function! s:venv(...)
  if a:0 > 0
    if a:1 == "?"
      echomsg py3eval('venv.dir')
      return
    endif
    let path = g:venv_home . '/' . a:1
  elseif !empty($VIRTUAL_ENV) && $VIRTUAL_ENV !=# py3eval('venv.dir')
    let path = $VIRTUAL_ENV
  else
    let path = g:venv_home . '/' . getcwd()->fnamemodify(':t')
  endif

  if !isdirectory(l:path)
    echohl ErrorMsg
    echomsg 'Not found: ' . l:path
    echohl None
    return
  endif

  python3 venv.activate(vim.eval("l:path"))
  echomsg l:path
endfunction

function! s:complete(A, L, P) abort
  return glob(g:venv_home . '/' . a:A . '*', v:true, v:true, v:true)
        \ ->map("v:val->fnamemodify(':t')")
endfunction

command! -nargs=? -complete=customlist,<SID>complete Venv call <SID>venv(<f-args>)
command! NoVenv python3 venv.deactivate()

if !empty($VIRTUAL_ENV)
  if v:vim_did_enter
    call <SID>venv()
  else
    au VimEnter * call <SID>venv()
  endif
endif

