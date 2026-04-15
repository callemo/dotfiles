vim9script

import autoload 'plumb.vim'
import autoload 'exec.vim'

# Scratch creates a temporary buffer with the given suffix returning its name.
export def Scratch(suffix: string): string
	var bufname = suffix[0] == '/' ? suffix : getcwd() .. suffix
	if !bufexists(bufname)
		var bnr = bufnr(bufname, 1)
		setbufvar(bnr, '&bufhidden', 'wipe')
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
		exe 'close' .. bang
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

# Expand: select structural block at the current character (brackets/quotes → vi obj, else viw).
export def Expand()
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

	exe "normal! \<Esc>vi" .. obj[c]
enddef

# DblClick: double-click statusline closes window, body expands structural block or word.
export def DblClick()
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
	Expand()
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

# MidClick: middle-click statusline zooms window, body executes word.
export def MidClick()
	var m = getmousepos()
	var w = m.winid
	if w != 0 && m.winrow > winheight(win_id2win(w))
		win_execute(w, 'resize')
		return
	endif
	exec.Cmd(expand('<cWORD>'), 0, 0, 0)
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

# Bufmatch: match buffers by /regular expression/ and optionally delete with /D.
export def Bufmatch(a: string)
	var i = stridx(a, '/')
	var j = strridx(a, '/')
	if i == -1 || i == j
		g:Err('Usage: :B /regular expression/[D]')
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
	exe 'resize' min([max([3, line('$')]), &lines / 2])
enddef

# entry: return the directory entry under the current character.
def Entry(): string
	return getline('.')
enddef

# open: navigate to entry in-place (reuse current window).
def Open(e: string)
	var path = simplify(b:dir .. e)
	if isdirectory(path)
		Dir(path, true)
		return
	endif
	var fp = fnamemodify(path, ':.')
	var w = bufwinnr(fp)
	if w != -1
		exe ':' .. w .. 'wincmd w'
	elseif bufexists(fp)
		exe 'buffer' fnameescape(fp)
	else
		exe 'edit' fnameescape(fp)
	endif
enddef

# renameItem: rename entry under the current character in a Dir buffer.
def RenameItem()
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

# deleteItem: delete entry under the current character in a Dir buffer.
def DeleteItem()
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

# Dir: read a directory into a temporary buffer.
export def Dir(path: string, replace: bool = false)
	var d = empty(path) ? (empty(expand('%:p')) ? getcwd() : expand('%:p:h')) : fnamemodify(path, ':p')
	d = d =~# '/$' ? d : d .. '/'
	if &filetype ==# 'dir' && get(b:, 'dir', '') ==# d
		silent execute ':%!/bin/ls -1ap ' .. shellescape(d) .. ' | grep -v "^\\.\\.\\?/$"'
		setlocal nomodified
		return
	endif
	if replace
		silent noautocmd execute 'file ' .. fnameescape(d)
	else
		silent noautocmd execute 'new ' .. fnameescape(d)
	endif
	setlocal bufhidden=wipe buftype=nofile noswapfile filetype=dir
	silent execute ':%!/bin/ls -1ap ' .. shellescape(d) .. ' | grep -v "^\\.\\.\\?/$"'
	setlocal nomodified
	if !replace
		exe 'resize' min([max([3, line('$')]), &lines / 2])
	endif
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
	nnoremap <silent> <buffer> <leader>r <ScriptCmd>RenameItem()<CR>
	nnoremap <silent> <buffer> <leader>d <ScriptCmd>DeleteItem()<CR>
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

# SearchSel sets regular expression to a literal search of the addressed text.
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

var outlines = {
	'go':       '^func\s\|^type\s',
	'sh':       '^\w\+\s*()',
	'bash':     '^\w\+\s*()',
	'perl':     '^sub\s',
	'python':   '^\(class\s\|def\s\|async\s\+def\s\)',
	'vim':      '^\(export\s\+\)\?def\s',
	'markdown': '^#\+\s',
	}

# Toc populates the location list with an outline for the current buffer.
export def Toc(pat: string = '')
	var re = empty(pat) ? get(outlines, &filetype, outlines.markdown) : pat
	var items = []
	for i in range(1, line('$'))
		if getline(i) =~ re
			add(items, {'bufnr': bufnr('%'), 'lnum': i, 'text': getline(i)})
		endif
	endfor
	setloclist(0, [], 'r', {'title': 'TOC', 'items': items})
	exe 'lwindow' min([max([3, len(items)]), &lines / 2])
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

# StatusGrow: grow the current window like + mapping.
def StatusGrow(w: number)
	win_execute(w, 'execute "resize " .. (winheight(0) + max([5, winheight(0) / 2]))')
enddef

# Click: single-click handler; column 1 of statusline grows window.
export def Click()
	var m = getmousepos()
	var w = m.winid
	if w == 0
		feedkeys("\<LeftMouse>", 'n')
		return
	endif
	if m.winrow > winheight(win_id2win(w)) && m.wincol == 1
		StatusGrow(w)
		return
	endif
	feedkeys("\<LeftMouse>", 'n')
enddef

# TermStatus returns a terminal status line matching the normal layout.
export def TermStatus(): string
	var cwd = fnamemodify(getcwd(), ':t')
	var cmd = 'terminal'
	var pid = ''
	var status = ''
	var job = term_getjob(bufnr('%'))
	if job != v:null
		var info = job_info(job)
		if has_key(info, 'cwd') && !empty(info.cwd)
			cwd = fnamemodify(info.cwd, ':t')
		endif
		if has_key(info, 'cmd') && len(info.cmd) > 0
			var tail = split(info.cmd[-1], '/')[-1]
			var words = split(tail)
			if !empty(words)
				cmd = words[0]
			elseif !empty(tail)
				cmd = tail
			endif
		endif
		if has_key(info, 'process')
			pid = string(info.process)
		endif
		status = has_key(info, 'status') ? toupper(info.status) : ''
	endif

	var file = pid == '' ? cmd : cmd .. '(' .. pid .. ')'
	if !empty(status)
		file ..= ' ' .. status
	endif
	var lhs = substitute(cwd, '%', '%%', 'g') .. ' › ' .. substitute(file, '%', '%%', 'g')
	var rhs = '[term]'
	return lhs .. '%=' .. rhs
enddef
