vim9script

# Unwrap removes balanced surrounding quotes or brackets.
def Unwrap(s: string): string
	var text = trim(s)
	var pairs = {'"': '"', "'": "'", '(': ')', '[': ']', '{': '}', '<': '>'}
	while len(text) > 1 && get(pairs, text[0], '') == text[-1]
		text = text[1 : -2]
	endwhile
	return text
enddef

# File opens a target at a Vim address; an empty name addresses the current buffer.
def File(f: string, addr: string = '', col: number = 0): bool
	if !empty(f) && !view#Open(f)
		return false
	endif
	if !empty(addr)
		exe 'silent :' .. addr
	endif
	if col > 0
		cursor(line('.'), col)
	endif
	return true
enddef

# url opens the given URL in the system browser.
def Url(link: string)
	var url = substitute(link, '[.,;]\+$', '', '')
	var pairs = {')': '(', ']': '[', '}': '{'}
	while has_key(pairs, url[-1]) && count(url, url[-1]) > count(url, pairs[url[-1]])
		url = url[ : -2]
	endwhile
	echom 'url:' url
	var cmd = has('mac') ? 'open' : (executable('xdg-open') ? 'xdg-open' : '')
	if empty(cmd)
		g:Err('url: no browser opener')
		return
	endif
	job_start([cmd, url])
enddef

# wiki searches for a file path and opens it.
def Wiki(name: string)
	var f = trim(system('n look ' .. shellescape(name)))
	if empty(f)
		g:Err('wikilink: not found:' .. name)
		return
	endif
	if !File(f)
		g:Err('wikilink: cannot open:' .. f)
	endif
enddef

# Open dispatches the handling of an acquisition gesture.
export def Do(wdir: string, attr: dict<any>, data: string)
	# Quickfix/location list: jump to entry under cursor
	if &buftype ==# 'quickfix'
		exe "normal! \<CR>"
		return
	endif

	var text = Unwrap(data)
	# URLs
	var link = matchstr(text, '\c\<[a-z][a-z0-9+.-]*://[^[:space:]<>"'']\+')
	if !empty(link)
		Url(link)
		return
	endif

	# Wiki link
	var m = matchlist(data, '\[\[\([a-zA-Z0-9_\-./ ]\+\)\]\]')
	if !empty(m)
		Wiki(m[1])
		return
	endif

	# Complete names take precedence over quoting and address syntax.
	var dir = empty(wdir) ? getcwd() : wdir
	for name in uniq([data, text])
		if !empty(name) && File(simplify(name[0] == '/' ? name : dir .. '/' .. name))
			return
		endif
	endfor

	# Only bounded Vim address syntax reaches Ex, never arbitrary commands.
	if text !~# '[\r\n]'
		var atom = '\%(\d\+\|[.$]\|/\%([^/\\]\|\\.\)*/\|?\%([^?\\]\|\\.\)*?\)\%([+-]\d*\)*'
		var addr = atom .. '\%([,;]' .. atom .. '\)*'
		m = matchlist(text, '^\(.\{-}\):\(' .. addr .. '\)\%(:\([1-9]\d*\)\)\?\%(:\%(\s.*\)\?\)\?$')
		if !empty(m)
			var name = Unwrap(m[1])
			var f = empty(name) ? '' : simplify(name[0] == '/' ? name : dir .. '/' .. name)
			if File(f, m[2], str2nr(m[3]))
				return
			endif
		endif
	endif

	# Text search
	if get(attr, 'visual', 0) != 0
		@/ = substitute('\m\C' .. escape(data, '\.^$[]*~'), "\n", '\\n', 'g')
		feedkeys("/\<CR>")
	elseif has_key(attr, 'word')
		@/ = '\<' .. attr['word'] .. '\>'
		feedkeys("/\<CR>")
	endif
enddef
