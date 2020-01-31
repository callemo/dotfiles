if exists("g:loaded_tabline")
	finish
endif
let g:loaded_tabline = 1

function TabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		let s .= '%' . (i + 1) . 'T'
		let s .= ' %{TabLabel(' . (i + 1) . ')} '
	endfor
	let s .= '%#TabLineFill#%T'
	return s
endfunction

function TabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let bufnr = buflist[winnr - 1]
	let label = bufname(bufnr)
	let buftype = getbufvar(bufnr, '&buftype')
	if label == ''
		if buftype == ''
			return '[No Name]'
		endif
		return '[' . buftype . ']'
	endif
	if filereadable(label)
		let label = fnamemodify(label, ':p:t')
	elseif isdirectory(label)
		let label = fnamemodify(label, ':~:.') . '/'
	elseif label[-1:] == '/'
		let label = split(label, '/')[-1] . '/'
	else
		let label = split(label, '/')[-1]
	endif
	let modified = getbufvar(bufnr, "&modified")
	if modified
		let label = label .'+'
	endif
	return label
endfunction

set tabline=%!TabLine()
