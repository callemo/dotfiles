set nocompatible
set nomore

let s:root = fnamemodify(expand('<sfile>:p'), ':h')
let $PATH = s:root . '/testdata:' . $PATH
execute 'source' fnameescape(s:root . '/dot.vimrc')
set noconfirm noautowrite noautowriteall

" Poll until Pred() returns true or timeout (50ms ticks, 5s max).
function! s:WaitFor(Pred) abort
	for i in range(100)
		if a:Pred()
			return 1
		endif
		sleep 50m
	endfor
	return 0
endfunction

" Force-load autoload modules so exists() works
runtime autoload/plumb.vim
runtime autoload/exec.vim
runtime autoload/view.vim
runtime autoload/plugins.vim
runtime autoload/text.vim

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
call assert_true(exists('*text#Selection'))
call assert_true(exists('*text#SearchSel'))
call assert_true(exists('*text#Trim'))
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

" Clipboard: OSC 52 only; tmux loadb removed (set-clipboard on handles forwarding)
call assert_equal('', &clipboard)
let s:yank_au = execute('autocmd dotfiles TextYankPost')
call assert_match('exec\.Yank(getreg(''"''))', s:yank_au)
call assert_false(s:yank_au =~# 'tmux loadb')
let s:path_y = maparg('<leader>y', 'n', 0, 1)
let s:path_Y = maparg('<leader>Y', 'n', 0, 1)
call assert_match("exec\\.Yank(fnamemodify(expand('%:p'), ':\\.'))", s:path_y.rhs)
call assert_match("exec\\.Yank(expand('%:p'))", s:path_Y.rhs)
" Old relative-path clipboard mapping was replaced by <leader>y / <leader>Y.
call assert_equal('', maparg('<leader>F', 'n'))

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
" Verify buffer-local CR mapping reuses the current window
let s:cr_map = maparg('<CR>', 'n', 0, 1)
call assert_true(!empty(s:cr_map))
call assert_match('Open(Entry())', s:cr_map.rhs)
bwipeout!
call delete(s:dir_tmpdir, 'rf')

" Selection and SearchSel live in view autoload;
" verified indirectly via the visual * mapping.

" Cmd(): no-range produces output
call exec#Cmd('echo cmd-test-ok', 0, 0, 0)
call s:WaitFor({-> getbufline(bufnr(getcwd() . '/+Errors'), 1, '$') != ['']})
let s:errbnr = bufnr(getcwd() . '/+Errors')
call assert_match('cmd-test-ok', join(getbufline(s:errbnr, 1, '$'), "\n"))
exe 'bwipeout!' s:errbnr

" Cmd(): ranged pipes buffer lines as stdin
enew
call setline(1, ['cherry', 'apple', 'banana'])
let s:tmpf = tempname()
call exec#Cmd('sort > ' . s:tmpf, 2, 1, 3)
call s:WaitFor({-> filereadable(s:tmpf) && readfile(s:tmpf) != []})
call assert_equal(['apple', 'banana', 'cherry'], readfile(s:tmpf))
call delete(s:tmpf)
bwipeout!
let s:errbnr = bufnr(getcwd() . '/+Errors')
if s:errbnr > 0 | exe 'bwipeout!' s:errbnr | endif

" Cmd(): shell syntax (pipes, redirects) works
let s:tmpf = tempname()
call exec#Cmd('echo hello world | tr a-z A-Z > ' . s:tmpf, 0, 0, 0)
call s:WaitFor({-> filereadable(s:tmpf) && readfile(s:tmpf) != []})
call assert_match('HELLO WORLD', join(readfile(s:tmpf), ''))
call delete(s:tmpf)
let s:errbnr = bufnr(getcwd() . '/+Errors')
if s:errbnr > 0 | exe 'bwipeout!' s:errbnr | endif

" Toc(): populates location list with heading lines
enew
call setline(1, ['# One', 'text', '## Two', 'more'])
call view#Toc()
let s:ll = getloclist(0)
call assert_equal(2, len(s:ll))
call assert_equal('# One', s:ll[0].text)
call assert_equal('## Two', s:ll[1].text)
lclose
bwipeout!

" Cmd(): runs in buffer's directory (Acme model)
let s:cmd_tmpdir = tempname()
call mkdir(s:cmd_tmpdir, 'p')
call writefile([], s:cmd_tmpdir . '/marker')
exe 'edit' fnameescape(s:cmd_tmpdir . '/marker')
let s:pwdf = tempname()
call exec#Cmd('pwd > ' . s:pwdf, 0, 0, 0)
call s:WaitFor({-> filereadable(s:pwdf) && readfile(s:pwdf) != []})
call assert_match(s:cmd_tmpdir, join(readfile(s:pwdf), ''))
call delete(s:pwdf)
" +Errors buffer belongs to the buffer's directory, not vim's cwd
call assert_true(bufexists(s:cmd_tmpdir . '/+Errors'))
bwipeout!
exe 'bwipeout!' bufnr(s:cmd_tmpdir . '/+Errors')
call delete(s:cmd_tmpdir, 'rf')

" Cmd(): concurrent jobs both appear in +Errors
call exec#Cmd('echo job-aaa', 0, 0, 0)
call exec#Cmd('echo job-bbb', 0, 0, 0)
let s:errbnr = bufnr(getcwd() . '/+Errors')
call s:WaitFor({-> join(getbufline(s:errbnr, 1, '$'), "\n") =~ 'job-aaa' && join(getbufline(s:errbnr, 1, '$'), "\n") =~ 'job-bbb'})
let s:errtxt = join(getbufline(s:errbnr, 1, '$'), "\n")
call assert_match('job-aaa', s:errtxt)
call assert_match('job-bbb', s:errtxt)
exe 'bwipeout!' s:errbnr

" Cmd(): multi-line output preserved
call exec#Cmd('printf "line1\nline2\nline3"', 0, 0, 0)
let s:errbnr = bufnr(getcwd() . '/+Errors')
call s:WaitFor({-> len(getbufline(s:errbnr, 1, '$')) >= 3})
let s:errtxt = join(getbufline(s:errbnr, 1, '$'), "\n")
call assert_match('line1', s:errtxt)
call assert_match('line3', s:errtxt)
exe 'bwipeout!' s:errbnr

" DblClick/Expand: functions exist and mappings are wired up
call assert_true(exists('*text#Expand'))
call assert_true(exists('*view#DblClick'))
let s:expand_map = maparg('<Space><Space>', 'n', 0, 1)
call assert_true(!empty(s:expand_map))
call assert_match('text[#.]Expand', s:expand_map.rhs)
let s:c2_map = maparg('<2-LeftMouse>', 'n', 0, 1)
call assert_true(!empty(s:c2_map))
call assert_match('view[#.]DblClick', s:c2_map.rhs)

" Dump/Load: functions exist and commands are defined
call assert_true(exists('*exec#Dump'))
call assert_true(exists('*exec#Load'))
call assert_true(exists(':Dump'))
call assert_true(exists(':Load'))
let s:dk_map = maparg('<leader>E', 'n', 0, 1)
call assert_true(!empty(s:dk_map))

" Dump/Load: round-trip preserves clean file
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
let s:test_file = s:dump_tmpdir . '/testfile.txt'
call writefile(['line1', 'line2'], s:test_file)
silent! tabonly!
silent! only!
exe 'edit' fnameescape(s:test_file)
call cursor(2, 3)
call exec#Dump(s:dump_file)
call assert_true(filereadable(s:dump_file))
let s:dump_lines = readfile(s:dump_file)
call assert_match('^f1\t', s:dump_lines[3])
call assert_match(s:test_file, join(s:dump_lines, "\n"))
" Load into fresh state
enew!
call exec#Load(s:dump_file)
call assert_equal(fnamemodify(s:test_file, ':p'), expand('%:p'))
call assert_equal(2, line('.'))
call delete(s:dump_tmpdir, 'rf')

" Dump/Load: dirty buffer embeds content
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
silent! tabonly!
silent! only!
enew
call setline(1, ['dirty1', 'dirty2', 'dirty3'])
setlocal modified
call cursor(2, 1)
call exec#Dump(s:dump_file)
let s:dump_lines = readfile(s:dump_file)
call assert_match('^F1\t', s:dump_lines[3])
call assert_match('dirty2', join(s:dump_lines, "\n"))
" Load and verify content restored
enew!
call exec#Load(s:dump_file)
call assert_equal(['dirty1', 'dirty2', 'dirty3'], getline(1, '$'))
call assert_true(&modified)
call delete(s:dump_tmpdir, 'rf')

if len(v:errors)
	for e in v:errors
		echo e
	endfor
	cquit 1
endif

qall!
