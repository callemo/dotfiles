set nocompatible
set nomore

let s:root = fnamemodify(expand('<sfile>:p'), ':h')
let $PATH = s:root . '/testdata:' . $PATH
execute 'source' fnameescape(s:root . '/dot.vimrc')

" Force-load autoload modules so exists() works
runtime autoload/plumb.vim
runtime autoload/exec.vim
runtime autoload/view.vim
runtime autoload/plugins.vim

" Cycle 1: version guard -- vim9script loaded, nocompatible set
call assert_false(&compatible)

" Cycle 3: top-level variables
call assert_equal(' ', g:mapleader)
call assert_equal(1, g:loaded_netrw)
call assert_equal(1, g:loaded_netrwPlugin)

" Next/Prev exist in view autoload
call assert_true(exists('*view#Next'))
call assert_true(exists('*view#Prev'))
call assert_false(exists('*WinCycleNext'))
call assert_false(exists('*WinCyclePrev'))

" Functions moved from vimrc to autoload
call assert_true(exists('*view#TabLine'))
call assert_true(exists('*view#TabLabel'))
call assert_true(exists('*view#TermStatus'))
call assert_true(exists('*view#Selection'))
call assert_true(exists('*view#SearchSel'))
call assert_true(exists('*view#Trim'))
call assert_true(exists('*exec#Tmux'))
call assert_true(exists('*plugins#Go'))

" Terminal mappings trigger view navigation
let s:tj = maparg('<c-j>', 't', 0, 1)
let s:tk = maparg('<c-k>', 't', 0, 1)
call assert_match('view[#.]Next', s:tj.rhs)
call assert_match('view[#.]Prev', s:tk.rhs)

" All public functions are def (compiled)
call assert_match('def ', execute('function exec#Cmd'))
call assert_match('def ', execute('function view#Browse'))

" Plumb: url dispatches through Url() which logs via echom
let s:url = 'https://example.com/path?x=1'
messages clear
call plumb#Do('', {}, s:url)
call assert_match('url: https://example\.com/path?x=1', execute('messages'))

let s:fts_tmpdir = tempname()
call mkdir(s:fts_tmpdir, 'p')
let s:fts_log = s:fts_tmpdir . '/args.log'
let s:fts_pwn = s:fts_tmpdir . '/pwn'
let s:had_fts_log = exists('$FTS_LOG')
if s:had_fts_log
	let s:old_fts_log = $FTS_LOG
endif
let $FTS_LOG = s:fts_log
call exec#Fts('needle; touch ' . s:fts_pwn)
call assert_false(filereadable(s:fts_pwn))
call assert_equal('arg1=needle; touch ' . s:fts_pwn, get(readfile(s:fts_log), 0, ''))
if s:had_fts_log
	let $FTS_LOG = s:old_fts_log
else
	unlet $FTS_LOG
endif
call delete(s:fts_tmpdir, 'rf')

" Dir(): opens a directory buffer with ls output and correct mappings
let s:dir_tmpdir = tempname()
call mkdir(s:dir_tmpdir, 'p')
call writefile(['hello'], s:dir_tmpdir . '/afile.txt')
enew
call view#Dir(s:dir_tmpdir, v:true)
call assert_equal('dir', &filetype)
call assert_equal(s:dir_tmpdir . '/', b:dir)
call assert_match('afile\.txt', join(getline(1, '$'), "\n"))
" Verify buffer-local CR mapping uses plumb.Do
let s:cr_map = maparg('<CR>', 'n', 0, 1)
call assert_true(!empty(s:cr_map))
call assert_match('plumb\.Do', s:cr_map.rhs)
bwipeout
call delete(s:dir_tmpdir, 'rf')

" Selection and SearchSel live in view autoload;
" verified indirectly via the visual * mapping.

if len(v:errors)
	for e in v:errors
		echo e
	endfor
	cquit 1
endif

qall!
