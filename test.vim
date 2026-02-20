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

if len(v:errors)
	if !empty(s:term_outfile)
		call delete(s:term_outfile)
	endif
	for e in v:errors
		echo e
	endfor
	cquit 1
endif

if !empty(s:term_outfile)
	call delete(s:term_outfile)
endif

qall!
