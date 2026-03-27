set nocompatible
set nomore
set shortmess+=I

let s:root = fnamemodify(expand('<sfile>:p'), ':h')
let $PATH = s:root . '/testdata:' . $PATH
execute 'source' fnameescape(s:root . '/dot.vimrc')
let s:term_outfile = ''

" Cycle 1: version guard -- vim9script loaded, nocompatible set
call assert_false(&compatible)

" Cycle 3: top-level variables
call assert_equal(' ', g:mapleader)
call assert_equal(1, g:loaded_netrw)
call assert_equal(1, g:loaded_netrwPlugin)

" FocusNext/FocusPrev exist; WinCycleNext/WinCyclePrev removed
call assert_true(exists('*FocusNext'))
call assert_true(exists('*FocusPrev'))
call assert_false(exists('*WinCycleNext'))
call assert_false(exists('*WinCyclePrev'))

" All public functions are def (compiled)
call assert_match('def ', execute('function Cmd'))
call assert_match('def ', execute('function DirToggle'))
call assert_match('def ', execute('function LoadVimGo'))

" Data extraction: GetVisualText and DirEntry are pure text extractors
call assert_true(exists('*GetVisualText'))
call assert_true(exists('*DirEntry'))

" Plumb attr: normal-mode maps pass word, visual maps pass visual
" (verified structurally below via SetVisualSearch; Plumb routing tested via OpenURL)

function! Cmd(cmd, range, line1, line2) abort
	let g:test_cmd = a:cmd
endfunction

let s:url = "https://example.com/a'b?x=1&y=2"
call OpenURL(s:url)
if has('mac') || executable('xdg-open')
	call assert_equal((has('mac') ? 'open ' : 'xdg-open ') . shellescape(s:url), get(g:, 'test_cmd', ''))
endif

let s:fts_tmpdir = tempname()
call mkdir(s:fts_tmpdir, 'p')
let s:fts_log = s:fts_tmpdir . '/args.log'
let s:fts_pwn = s:fts_tmpdir . '/pwn'
let s:had_fts_log = exists('$FTS_LOG')
if s:had_fts_log
	let s:old_fts_log = $FTS_LOG
endif
let $FTS_LOG = s:fts_log
call Fts('needle; touch ' . s:fts_pwn)
call assert_false(filereadable(s:fts_pwn))
call assert_equal('arg1=needle; touch ' . s:fts_pwn, get(readfile(s:fts_log), 0, ''))
if s:had_fts_log
	let $FTS_LOG = s:old_fts_log
else
	unlet $FTS_LOG
endif
call delete(s:fts_tmpdir, 'rf')

function! GetVisualText() abort
	return 'a[b]c'
endfunction
call SetVisualSearch()
call assert_equal('\m\Ca\[b\]c', @/)

if len(v:errors)
	if !empty(s:term_outfile)
		call delete(s:term_outfile)
	endif
	if exists('s:fts_tmpdir') && isdirectory(s:fts_tmpdir)
		call delete(s:fts_tmpdir, 'rf')
	endif
	for e in v:errors
		echo e
	endfor
	cquit 1
endif

if !empty(s:term_outfile)
	call delete(s:term_outfile)
endif
if exists('s:fts_tmpdir') && isdirectory(s:fts_tmpdir)
	call delete(s:fts_tmpdir, 'rf')
endif

qall!
