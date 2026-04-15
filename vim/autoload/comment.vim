vim9script

# Toggle line comments. Operator: <leader>c{motion}, <leader>cc, visual <leader>c.

export def Toggle(type = ''): string
	if type == ''
		&operatorfunc = 'comment#Toggle'
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
