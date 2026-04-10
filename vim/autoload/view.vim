vim9script

import autoload 'plumb.vim'
import autoload 'exec.vim'

# Scratch creates a scratch buffer with the given suffix returning its name.
export def Scratch(suffix: string): string
	var bufname = suffix[0] == '/' ? suffix : getcwd() .. suffix
	if !bufexists(bufname)
		var bnr = bufnr(bufname, 1)
		setbufvar(bnr, '&buflisted', 1)
		setbufvar(bnr, '&buftype', 'nofile')
		setbufvar(bnr, '&number', 0)
		setbufvar(bnr, '&swapfile', 0)
	endif
	return bufname
enddef

# Close: quit if last window, else wipeout the buffer.
export def Close(bang: string)
	if winnr('$') == 1
		exe 'quit' .. bang
	else
		exe 'bwipeout' .. bang
	endif
enddef

# Next/Prev: cycle focus across vim windows and tmux panes.
export def Next()
	if !empty($TMUX) && winnr() == winnr('$')
		system("tmux selectp -t :.+")
	else
		wincmd w
	endif
enddef

export def Prev()
	if !empty($TMUX) && winnr() == 1
		system("tmux selectp -t :.-")
	else
		wincmd W
	endif
enddef

# Click2: double-click statusline closes window, body selects structural block or word.
export def Click2()
	var m = getmousepos()
	var w = m.winid
	if w == 0
		return
	endif
	if m.winrow > winheight(win_id2win(w))
		win_execute(w, 'call view#Close("")')
		return
	endif

	win_gotoid(w)
	cursor(m.line, m.column)

	var ln = getline('.')
	var ci = charcol('.')
	var c = ln->slice(ci - 1, ci)
	var cb = ci > 1 ? ln->slice(ci - 2, ci - 1) : ''
	var pat = '[(){}\[\]<>"''`]'
	var obj = {
		'(': 'b', ')': 'b',
		'{': 'B', '}': 'B',
		'[': '[', ']': '[',
		'<': '<', '>': '>',
		'"': '"', "'": "'", '`': '`'
	}

	if c =~ pat
	elseif cb =~ pat
		c = cb
		exe 'normal! h'
	else
		exe "normal! \<Esc>viw"
		return
	endif

	exe "normal! \<Esc>va" .. obj[c]
enddef

# Zoom: ctrl-click statusline zooms window to full height.
export def Zoom()
	var m = getmousepos()
	var w = m.winid
	if w == 0
		return
	endif
	if m.winrow > winheight(win_id2win(w))
		win_execute(w, 'resize')
	endif
enddef

# Sort: sort visible windows by buffer name.
export def Sort()
	var w = range(1, winnr('$'))
	var b = filter(map(copy(w), (_, v) => winbufnr(v)),
		(_, v) => bufexists(v) && !empty(bufname(v)))
	if empty(b)
		return
	endif
	var s = sort(copy(b), (x, y) => bufname(x) > bufname(y) ? 1 : -1)
	for i in range(len(s))
		win_execute(win_getid(w[i]), 'silent! buffer ' .. s[i])
	endfor
enddef

# Bufmatch: match buffers by /re/ and optionally delete with /D.
export def Bufmatch(a: string)
	var i = stridx(a, '/')
	var j = strridx(a, '/')
	if i == -1 || i == j
		g:Err('Usage: :B /regex/[D]')
		return
	endif
	var re = a[i + 1 : j - 1]
	var tail = a[j + 1 :]
	var b = filter(map(getbufinfo({'bufloaded': 1}),
		(_, v) => v.bufnr),
		(_, v) => bufname(v) =~ re)
	if empty(b)
		return
	endif
	if tail ==? 'd'
		exe 'bwipeout' join(b)
		return
	endif
	exe 'sbuffer' Scratch(getcwd() .. '/+Errors')
	setline(1, map(b, (_, v) => bufname(v)))
enddef

# Entry: return the directory entry under the cursor.
def Entry(): string
	return getline('.')
enddef

# Open: navigate to entry in-place (reuse current window).
def Open(entry: string)
	var path = simplify(b:dir .. entry)
	if isdirectory(path)
		Dir(path, true)
		return
	endif
	var fp = fnamemodify(path, ':.')
	var w = bufwinnr(fp)
	if w != -1
		exe w .. 'wincmd w'
	elseif bufexists(fp)
		exe 'buffer' fnameescape(fp)
	else
		exe 'edit' fnameescape(fp)
	endif
enddef

# Rename: rename entry under cursor in a Dir buffer.
def Rename()
	var old = b:dir .. Entry()
	var neu = input('Rename: ', old)
	if neu == '' || neu == old
		return
	endif
	if rename(old, neu) != 0
		g:Err('rename failed: ' .. old)
		return
	endif
	Dir(b:dir, true)
enddef

# Delete: delete entry under cursor in a Dir buffer.
def Delete()
	var path = b:dir .. Entry()
	if input('Delete ' .. path .. '? ') !~? '^y'
		return
	endif
	if delete(path, isdirectory(path) ? 'rf' : '') != 0
		g:Err('delete failed: ' .. path)
		return
	endif
	Dir(b:dir, true)
enddef

# Dir: read a directory into a scratch buffer.
export def Dir(path: string, replace: bool = false)
	var d = empty(path) ? (empty(expand('%:p')) ? getcwd() : expand('%:p:h')) : fnamemodify(path, ':p')
	d = d =~# '/$' ? d : d .. '/'
	if &filetype ==# 'dir' && get(b:, 'dir', '') ==# d
		silent execute ':%!/bin/ls -1ap ' .. shellescape(d)
		setlocal nomodified
		return
	endif
	if replace
		noautocmd execute 'file ' .. fnameescape(d)
	else
		noautocmd execute 'new ' .. fnameescape(d)
	endif
	setlocal bufhidden=wipe buftype=nofile noswapfile filetype=dir
	silent execute ':%!/bin/ls -1ap ' .. shellescape(d)
	setlocal nomodified
	b:dir = d
	# Dir keybindings: CR/- reuse window; rightmouse plumb (split); middlemouse execute
	nnoremap <silent> <buffer> <CR> <ScriptCmd>Open(Entry())<CR>
	nnoremap <silent> <buffer> <leader><CR> <ScriptCmd>plumb.Do(b:dir, {}, Entry())<CR>
	nnoremap <silent> <buffer> <rightmouse> <leftmouse><ScriptCmd>plumb.Do(b:dir, {}, Entry())<CR>
	nnoremap <silent> <buffer> <middlemouse> <leftmouse><ScriptCmd>exec.Cmd(Entry(), 0, 0, 0)<CR>
	nnoremap <silent> <buffer> <c-leftmouse> <leftmouse><ScriptCmd>exec.Cmd(Entry(), 0, 0, 0)<CR>
	# :h strips trailing /, second :h goes up one level
	nnoremap <silent> <buffer> - <ScriptCmd>Dir(fnamemodify(b:dir, ':h:h'), true)<CR>
	# Explicit <c-j> to prevent global <CR> mapping from shadowing it
	nnoremap <silent> <buffer> <c-j> <ScriptCmd>Next()<CR>
	nnoremap <silent> <buffer> <leader>R <ScriptCmd>Rename()<CR>
	nnoremap <silent> <buffer> <leader>D <ScriptCmd>Delete()<CR>
enddef

# Browse: toggle the directory buffer.
export def Browse()
	if &filetype ==# 'dir'
		execute('bwipeout')
		return
	endif
	Dir('')
enddef

# Selection returns the text selected in visual mode.
export def Selection(): string
	return join(getregion(getpos('v'), getpos('.'), {type: mode()}), "\n")
enddef

# SearchSel sets / to a literal search of the visual selection.
export def SearchSel()
	@/ = substitute('\m\C' .. escape(Selection(), '\.^$~[]*'), "\n$", '', '')
enddef

# Trim removes trailing whitespace from all lines.
export def Trim()
	var last_pos = getcurpos()
	var last_search = @/
	noautocmd silent! :%s/\m\C\s\+$//e
	@/ = last_search
	setpos('.', last_pos)
enddef

# TabLine returns the formatted tab line string.
export def TabLine(): string
	var s = ''
	for i in range(1, tabpagenr('$'))
		if i == tabpagenr()
			s ..= '%#TabLineSel#'
		else
			s ..= '%#TabLine#'
		endif
		s ..= '%' .. i .. 'T'
		s ..= ' %{view#TabLabel(' .. i .. ')} '
	endfor
	s ..= '%#TabLineFill#%T'
	var jobs = exec.Jobs()
	if !empty(jobs)
		s ..= '%#TabLine# ' .. escape(jobs, '%') .. ' '
	endif
	return s
enddef

# TabLabel returns the display label for tab n, preferring t:label.
export def TabLabel(n: number): string
	var tabl = gettabvar(n, 'label', '')
	if !empty(tabl)
		return tabl
	endif

	var bnr = tabpagebuflist(n)[tabpagewinnr(n) - 1]
	var bt = getbufvar(bnr, '&buftype')
	var name = bufname(bnr)

	if empty(name)
		return empty(bt) ? '-' : '-' .. bt
	endif

	var label = fnamemodify(name, ':t')
	if empty(label)
		label = fnamemodify(name, ':h:t') .. '/'
	endif

	if bt ==# 'help'
		return '-help:' .. label
	endif
	if bt ==# 'quickfix'
		var winid = win_getid(tabpagewinnr(n), n)
		var winfo = getwininfo(winid)
		return (!empty(winfo) && winfo[0].loclist != 0 ? '-loc:' : '-qf:') .. label
	endif
	if bt ==# 'terminal'
		return '-terminal:' .. label
	endif
	return label
enddef

# TermStatus returns a compact status line for terminal buffers.
export def TermStatus(): string
	var job = term_getjob(bufnr('%'))
	if job == v:null
		return ''
	endif
	var info = job_info(job)
	var status = info.status
	var cmd = len(info.cmd) > 0 ? split(info.cmd[0], '/')[-1] : 'unknown'
	var pid = has_key(info, 'process') ? info.process : 'no-pid'
	var bnr = bufnr('%')
	var cwd = has_key(info, 'cwd') ? fnamemodify(info.cwd, ':t') : fnamemodify(getcwd(), ':t')
	return printf('%d [%s] %s(%s) %s', bnr, cwd, cmd, pid, toupper(status))
enddef
