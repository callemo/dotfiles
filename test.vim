set nocompatible
set nomore
set shortmess+=I

let s:root = fnamemodify(expand('<sfile>:p'), ':h')
let $PATH = s:root . '/testdata:' . $PATH
execute 'source' fnameescape(s:root . '/dot.vimrc')
let s:term_outfile = ''

call assert_true(TmuxSend('%7', "hello\nworld\n"))

new
call setline(1, ['one', 'two', 'three'])

call Send(1, 1, 2, 'T:%1')
call assert_equal('T:%1', w:send_terminal_buf)

if has('terminal') && exists('*term_start')
	let s:term_outfile = tempname()
	let s:termcmd = ['sh', '-c', 'cat > ' . shellescape(s:term_outfile)]
	let s:termbuf = term_start(s:termcmd)
	if type(s:termbuf) == v:t_number && s:termbuf > 0
		call assert_true(TermSend(s:termbuf, "two"))
		call term_sendkeys(s:termbuf, "\<C-d>")
		call term_wait(s:termbuf, 200)
		if filereadable(s:term_outfile)
			call assert_equal('two', join(readfile(s:term_outfile), "\n"))
		endif
	endif
endif

call assert_match('v:count1', maparg('<leader>;', 'n'))

function! TmuxSend(target, text) abort
	let g:test_send_tmux_target = a:target
	let g:test_send_tmux_text = a:text
	return v:true
endfunction

function! TermSend(target, text) abort
	let g:test_send_term_target = a:target
	let g:test_send_term_text = a:text
	return v:true
endfunction

unlet! w:send_terminal_buf
execute 'Send T:0'
call assert_equal('T:0', w:send_terminal_buf)
call assert_equal('0', get(g:, 'test_send_tmux_target', ''))

unlet! g:test_send_tmux_target g:test_send_tmux_text
unlet! g:test_send_term_target g:test_send_term_text
execute 'Send'
call assert_equal('0', get(g:, 'test_send_tmux_target', ''))
call assert_false(exists('g:test_send_term_target'))
call assert_equal('T:0', w:send_terminal_buf)

only
enew
call setline(1, ['alpha'])
unlet! w:send_terminal_buf
unlet! g:test_send_tmux_target g:test_send_tmux_text
unlet! g:test_send_term_target g:test_send_term_text
execute 'Send'
call assert_false(exists('w:send_terminal_buf'))
call assert_false(exists('g:test_send_tmux_target'))
call assert_false(exists('g:test_send_term_target'))

execute 'Send 12'
call assert_equal(12, get(g:, 'test_send_term_target', -1))
call assert_false(exists('g:test_send_tmux_target'))
call assert_equal(12, w:send_terminal_buf)

only
enew
call setline(1, ['one'])
unlet! g:test_send_tmux_target g:test_send_tmux_text
unlet! g:test_send_term_target g:test_send_term_text
execute 'Send T:7'
call assert_equal('7', get(g:, 'test_send_tmux_target', ''))
new
call setline(1, ['two'])
unlet! g:test_send_tmux_target g:test_send_tmux_text
unlet! g:test_send_term_target g:test_send_term_text
execute 'Send'
call assert_false(exists('w:send_terminal_buf'))
call assert_false(exists('g:test_send_tmux_target'))
call assert_false(exists('g:test_send_term_target'))
wincmd p
call assert_equal('T:7', w:send_terminal_buf)

function! Cmd(cmd, range, line1, line2) abort
	let g:test_cmd = a:cmd
endfunction

let s:url = "https://example.com/a'b?x=1&y=2"
call OpenURL(s:url)
call assert_equal((has('mac') ? 'open ' : 'xdg-open ') . shellescape(s:url), get(g:, 'test_cmd', ''))

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
