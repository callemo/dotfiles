vim9script

# file opens file f at optional address addr, reusing existing windows.
def File(f: string, addr: string)
	var fp = fnamemodify(f, ':.')
	var w = bufwinnr(fp)
	if w != -1
		exe w .. 'wincmd w'
		if !empty(addr)
			exe addr
		endif
	elseif bufexists(fp)
		silent exe 'sbuffer' (empty(addr) ? '' : '+' .. addr) fnameescape(fp)
	else
		silent exe 'split' (empty(addr) ? '' : '+' .. addr) fnameescape(fp)
	endif
enddef

# url opens the given URL in the system browser.
def Url(link: string)
	echom 'url:' link
	var cmd = has('mac') ? 'open' : (executable('xdg-open') ? 'xdg-open' : '')
	if !empty(cmd)
		job_start(['/bin/sh', '-c', cmd .. ' ' .. shellescape(link)])
	endif
enddef

# wiki searches for a file path and opens it.
def Wiki(name: string)
	var f = trim(system('n look ' .. shellescape(name)))
	if empty(f)
		g:Err('wikilink: not found:' .. name)
		return
	endif
	echom 'wikilink:' f
	File(f, '')
enddef

# Open dispatches the handling of an acquisition gesture.
export def Do(wdir: string, attr: dict<any>, data: string)
	# Quickfix/location list: jump to entry under cursor
	if &buftype ==# 'quickfix'
		exe "normal! \<CR>"
		return
	endif

	var text = substitute(data, '[):.,;]\+$', '', '')
	# URLs
	var m = matchlist(text,
		'\(https\?\|ftp\)://[a-zA-Z0-9_@\-]\+'
		.. '\([.:][a-zA-Z0-9_@\-]\+\)*'
		.. '\(/[a-zA-Z0-9_?,%#~&/\-+=.@]*\)*')
	if !empty(m)
		Url(m[0])
		return
	endif

	# Wiki link
	m = matchlist(data, '\[\[\([a-zA-Z0-9_\-./ ]\+\)\]\]')
	if !empty(m)
		Wiki(m[1])
		return
	endif

	# File with address
	m = matchlist(data, '^\([a-zA-Z0-9_\-./ ]\+\):\([0-9]\+\):\?')
	if !empty(m)
		var f = simplify(m[1][0] != '/' ? wdir .. '/' .. m[1] : m[1])
		if filereadable(f)
			File(f, m[2])
			return
		endif
	endif

	# File
	m = matchlist(data, '^\([a-zA-Z0-9_\-./ ]\+\)')
	if !empty(m)
		var f = simplify(m[1][0] != '/' ? wdir .. '/' .. m[1] : m[1])
		if filereadable(f)
			File(f, '')
			return
		endif
		if isdirectory(f)
			silent view#Dir(f)
			return
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
