vim9script

# Comment toggles line comments. Operator: <leader>c{motion}, <leader>cc, visual <leader>c.

export def Comment(type = ''): string
	if type == ''
		&operatorfunc = 'text#Comment'
		return 'g@'
	endif
	var l = trim(substitute(&commentstring, '%s', '', ''))
	var lp = '\V' .. escape(l, '\')
	var lnum1 = line("'[")
	var lnum2 = line("']")
	var uncomment = true
	for nr in range(lnum1, lnum2)
		var line = getline(nr)
		if line =~ '\S' && line !~ '^' .. lp
			uncomment = false
			break
		endif
	endfor
	var lines: list<string> = []
	for nr in range(lnum1, lnum2)
		var line = getline(nr)
		if uncomment
			line = substitute(line, '^' .. lp .. '\m \?', '', '')
		elseif line =~ '\S'
			line = l .. ' ' .. line
		endif
		add(lines, line)
	endfor
	setline(lnum1, lines)
	return ''
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

# SearchSel sets regular expression to a literal search of the addressed text.
export def SearchSel()
	@/ = substitute('\m\C' .. escape(Selection(), '\.^$~[]*'), "\n$", '', '')
enddef

# Selection returns the text selected in visual mode.
# Yanks via register z; works on Vim builds without getregion().
# noautocmd suppresses TextYankPost (which fires OSC 52 to /dev/tty).
export def Selection(): string
	var save = getreginfo('z')
	# When called via <Cmd> from xnoremap we are still in visual mode,
	# so gv has nothing to restore — yank the live selection. Otherwise
	# (e.g. called after <Esc>) reselect with gv first.
	var cmd = mode() =~? "^[vs\<C-v>\<C-s>]" ? '"zy' : 'gv"zy'
	silent execute 'noautocmd normal! ' .. cmd
	var text = substitute(getreg('z'), "\n$", '', '')
	setreg('z', save)
	return text
enddef

# Trim removes trailing whitespace from all lines.
export def Trim()
	var last_pos = getcurpos()
	var last_search = @/
	noautocmd silent! :%s/\m\C\s\+$//e
	@/ = last_search
	setpos('.', last_pos)
enddef
