if !has('vim9script') | set nocompatible | finish | endif
vim9script
set nocompatible
set autoindent
set autoread
set backspace=indent,eol,start
if has('clipboard')
	set clipboard=unnamed
endif
set cmdheight=1
set commentstring=#%s
set complete-=i
set confirm
set cursorline
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set fillchars=vert:\ ,fold:-
set hidden
set history=1000
set hlsearch
set incsearch
set laststatus=2
set listchars=eol:$,tab:>\ ,space:.
set nobackup
set noequalalways
set winminheight=0
set noexpandtab
set nofoldenable
set nojoinspaces
set noswapfile
set nowritebackup
set nrformats-=octal
set number
set path=.,,
set scrolloff=0
set shiftwidth=4
set shortmess=atI
set showcmd
set softtabstop=4
set splitbelow
set splitright
set statusline=\ %{fnamemodify(getcwd(),':t')}\ ›\ %f\ %=%l:%c\ %y\ %M%R
set switchbuf=useopen,split
set tabline=%!TabLine()
set tabstop=4
set textwidth=0
set updatetime=300
set notimeout
set ttimeout
set ttimeoutlen=50
set viewoptions-=options
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu
set wildmode=longest,list

packadd! matchit

runtime! ftplugin/man.vim
filetype plugin on
syntax on

g:mapleader = ' '

# Disable netrw
g:loaded_netrw = 1
g:loaded_netrwPlugin = 1


augroup dotfiles
	autocmd!
	if !has('clipboard')
		autocmd TextYankPost * if v:event.operator ==# 'y' | call OscYank(getreg('"')) | endif
	endif
	if executable('tmux')
		autocmd TextYankPost * if v:event.operator ==# 'y' | call system('tmux loadb -', getreg('"')) | endif
	endif
	autocmd BufReadPost * exe 'silent! normal! g`"'
	autocmd BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | setl nowrap | endif
	autocmd BufWritePre * :call TrimTrailingBlanks()
	autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
	autocmd InsertEnter,WinLeave * setl nocursorline
	autocmd InsertLeave,WinEnter * setl cursorline
	autocmd OptionSet diff if &diff | setl nocursorline | endif

	autocmd FileType perl setl et keywordprg=:terminal\ perldoc\ -f
	autocmd FileType python setl keywordprg=:terminal\ pydoc3
	autocmd TerminalWinOpen *
		\ setl nonumber
		\ | setl statusline=%{TerminalStatusLine()}
		\ | nnoremap <buffer> q i

	autocmd FileType c,cpp setl path+=/usr/include
	autocmd BufNewFile,BufRead *.tidal setfiletype haskell
	autocmd FileType css,html,htmldjango,scss setl iskeyword+=-
	autocmd FileType gitcommit setl spell fdm=syntax fdl=1 iskeyword+=.,-
	autocmd FileType groff setl commentstring=.\\\"\ %s
	autocmd FileType javascript,json setl sw=4 sts=4 et
	autocmd FileType lilypond setl et sw=2 ts=2 sts=2 ai fdm=indent fdl=0 fdc=2 cms=%\ %s
	autocmd FileType typescript setl sw=4 sts=4 et syn=javascript
		# syntax/typescript.vim is too buggy
	autocmd FileType yaml setl ts=2 sw=2 sts=2 et syn=conf
		# syntax/yaml.vim is too buggy
	autocmd FileType markdown,python setl sw=4 sts=4 et
	autocmd FileType sh setl noet sw=0 sts=0
	autocmd VimEnter * if argc() == 0 && empty(bufname()) | call Dir('', true) | endif
	# BufReadCmd matches trailing / (dir buffer names); BufReadPost catches :e .
	autocmd BufReadCmd */ call Dir(expand('<afile>:p'), true)
	autocmd BufReadPost * if isdirectory(expand('<afile>:p')) | call Dir(expand('<afile>:p'), true) | endif
augroup END

command! -nargs=+ -complete=file -range
	\ Cmd call g:Cmd(<q-args>, <range>, <line1>, <line2>)

command! -nargs=? Lint call g:LintFile(<f-args>)
command! -nargs=? -range=% Fmt call g:FormatFile(<line1>, <line2>, <f-args>)
command! -nargs=* Rg call g:Rg(<q-args>)
command! -nargs=* Fts call g:Fts(<q-args>)
command! -nargs=? Oln call g:Outline(<f-args>)

command!           Sort   call g:SortWindows()
command! -nargs=1 B call g:BufferMatch(<q-args>)

def g:SendToTmux(line1: number, line2: number, target: string)
	if target != ''
		w:send_tmux_target = target
	endif
	var tgt = get(w:, 'send_tmux_target', '')
	var text = join(getline(line1, line2), "\n") .. "\n"
	if tgt != ''
		system('tmux loadb - \; pasteb -d -t ' .. shellescape(tgt), text)
	else
		system('tmux loadb - \; pasteb -d', text)
	endif
enddef
command! -range -nargs=? Send call g:SendToTmux(<line1>, <line2>, <q-args>)

# Leader: custom actions
nnoremap <leader>! <cmd>Cmd<space>
nnoremap <leader>. <cmd>lcd %:p:h<CR>
nnoremap <silent> <leader>; <cmd>Send<CR>
nnoremap <silent> <leader><CR> <cmd>call g:Plumb(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
nnoremap <silent> <leader>B <cmd>call g:DirToggle()<CR>
nnoremap <silent> <leader>F <cmd>let @+ = fnamemodify(expand('%:p'), ':.')<CR>
nnoremap <leader>Q <cmd>call g:CloseBuffer('!')<CR>
nnoremap <leader>f <cmd>Fmt<CR>
nnoremap <leader>l <cmd>Lint<CR>
nnoremap <leader>q <cmd>call g:CloseBuffer('')<CR>
nnoremap <leader>z <cmd>resize<CR>

# Visual: data extractors
xnoremap <silent> <leader>! <cmd>call g:Cmd(g:GetVisualText(), 0, 0, 0)<CR>
xnoremap <silent> <leader>; <cmd>Send<CR>
xnoremap <silent> <leader><CR> <cmd>call g:Plumb(expand('%:h'), {'visual': 1}, g:GetVisualText())<CR>
xnoremap * <cmd>call g:SetVisualSearch()<CR>/<CR>
nnoremap ]a :next<CR>
nnoremap [a :previous<CR>
nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprevious<CR>

# yo toggles
nnoremap yob :set background=<c-r>=&bg == 'light' ? 'dark' : 'light'<CR><CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yoi :setl invignorecase<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>

# Ctrl keys: focus pipeline
nnoremap <silent> <c-j> :call g:FocusNext()<CR>
nnoremap <silent> <c-k> :call g:FocusPrev()<CR>
nnoremap <c-l> <cmd>nohlsearch \| call clearmatches() \| diffupdate \| syntax sync fromstart<CR><c-l>
nnoremap <c-p> <cmd>FZF<CR>

# Window and scrolling
nnoremap <c-w>N :new <c-r>=expand('%:h')<CR>/
nnoremap <silent> + :exe 'resize' (winheight(0) + max([5, winheight(0) / 2]))<CR>
nnoremap <down> <c-e>
nnoremap <up> <c-y>

# Insert and cmdline
inoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
inoremap <C-x>w <C-r>=strftime("%YW%V")<CR>
inoremap <c-a> <home>
inoremap <c-e> <end>
inoremap <down> <c-o><c-e>
inoremap <up> <c-o><c-y>
cnoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
cnoremap <C-x>w <C-r>=strftime("%YW%V")<CR>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

# Terminal hand-offs
tnoremap <silent> <c-j> <c-w>:call g:FocusNext()<CR>
tnoremap <silent> <c-k> <c-w>:call g:FocusPrev()<CR>
tnoremap <c-r><c-r> <c-r>
tnoremap <c-w><c-w> <c-w>.
tnoremap <c-w>[ <c-\><c-n>
tnoremap <expr> <c-r> '<c-w>"' .. nr2char(getchar())
tnoremap <leader>z <cmd>resize<CR>
tnoremap <scrollwheelup> <c-\><c-n>

# Mouse: middlemouse = execute, rightmouse = plumb
set mouse=nv
if has('mouse_sgr')
	set ttymouse=sgr
endif
nnoremap <silent> <2-LeftMouse> <cmd>call g:WinDblClick()<CR>
nnoremap <silent> <C-LeftMouse> <cmd>call g:WinZoom()<CR>
nnoremap <silent> <middlemouse> <leftmouse><cmd>call g:Cmd(expand('<cWORD>'), 0, 0, 0)<CR>
nnoremap <silent> <rightmouse> <leftmouse><cmd>call g:Plumb(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
xnoremap <silent> <middlemouse> <cmd>call g:Cmd(g:GetVisualText(), 0, 0, 0)<CR>
xnoremap <silent> <rightmouse> <cmd>call g:Plumb(expand('%:h'), {'visual': 1}, g:GetVisualText())<CR>

# CloseBuffer: quit if last window, else wipeout the buffer.
def g:CloseBuffer(bang: string)
	if winnr('$') == 1
		exe 'quit' .. bang
	else
		exe 'bwipeout' .. bang
	endif
enddef

# FocusNext/Prev: cycle focus across vim windows and tmux panes.
def g:FocusNext()
	if !empty($TMUX) && winnr() == winnr('$')
		system("tmux selectp -t :.+")
	else
		wincmd w
	endif
enddef

def g:FocusPrev()
	if !empty($TMUX) && winnr() == 1
		system("tmux selectp -t :.-")
	else
		wincmd W
	endif
enddef

# WinDblClick: double-click statusline closes window, body selects word.
def g:WinDblClick()
	var m = getmousepos()
	var w = m.winid
	if w == 0
		return
	endif
	if m.winrow > winheight(win_id2win(w))
		win_execute(w, 'call CloseBuffer("")')
	else
		exe "normal! \<2-LeftMouse>"
	endif
enddef

# WinZoom: ctrl-click statusline zooms window to full height.
def g:WinZoom()
	var m = getmousepos()
	var w = m.winid
	if w == 0
		return
	endif
	if m.winrow > winheight(win_id2win(w))
		win_execute(w, 'resize')
	endif
enddef

# GetVisualText returns the text selected in visual mode.
def g:GetVisualText(): string
	var reg = @"
	silent normal! vgvy
	var text = @"
	@" = reg
	return text
enddef

# SetVisualSearch sets / to a literal search of the visual selection.
def g:SetVisualSearch()
	@/ = substitute('\m\C' .. escape(g:GetVisualText(), '\.^$~[]*'), "\n$", '', '')
enddef

def g:Err(msg: string)
	echohl ErrorMsg
	echo msg
	echohl None
enddef

# NewBuffer creates a scratch buffer with the given suffix returning its name
def g:NewBuffer(suffix: string): string
	var bufname = getcwd() .. suffix
	if !bufexists(bufname)
		var bnr = bufnr(bufname, 1)
		setbufvar(bnr, '&buflisted', 1)
		setbufvar(bnr, '&buftype', 'nofile')
		setbufvar(bnr, '&number', 0)
		setbufvar(bnr, '&swapfile', 0)
	endif
	return bufname
enddef

# Cmd executes a shell command asynchronously, output to +Errors.
def g:Cmd(cmd: string, range: number, line1: number, line2: number)
	var bufname = g:NewBuffer('/+Errors')
	var opts = {
		'in_io': 'null', 'mode': 'raw',
		'out_io': 'buffer', 'out_name': bufname, 'out_msg': 0,
		'err_io': 'buffer', 'err_name': bufname, 'err_msg': 0,
		'exit_cb': (job, code) => g:CmdDone(job, code, split(cmd)[0]),
		'timeout': 300000,
		'stoponexit': 'term'
		}
	if range > 0
		opts.in_io = 'buffer'
		opts.in_buf = bufnr('%')
		opts.in_top = line1
		opts.in_bot = line2
	endif
	job_start([&shell, &shellcmdflag, cmd], opts)
enddef

# CmdDone handles job completion: show +Errors if output or failure.
def g:CmdDone(job: job, code: number, name: string)
	echom name .. ': exit ' .. code
	var bufnr = ch_getbufnr(job, 'out')
	if getbufline(bufnr, 1, '$') != [''] || code > 0
		exe 'sbuffer' bufnr
		cursor(line('$'), 1)
		if code > 0
			append(line('$'), name .. ': exit ' .. code)
			cursor(line('$'), 1)
		endif
	endif
enddef

# OscYank copies text to clipboard via OSC 52.
def g:OscYank(text: string)
	var encoded = system('printf %s ' .. shellescape(text) .. ' | base64 | tr -d "\n"')
	var osc = "\e]52;c;" .. encoded .. "\x07"
	writefile([osc], '/dev/tty', 'b')
enddef

g:linters = {
	'bash': 'shellcheck -f gcc',
	'css': 'stylelint',
	'go': 'go vet',
	'json': 'python3 -c "import json,sys;json.load(open(sys.argv[1]))"',
	'markdown': 'prettier --check',
	'perl': 'perlcritic',
	'python': 'pylint -s n',
	'scss': 'stylelint',
	'sh': 'shellcheck -f gcc',
	'yaml': 'python3 -c "import yaml,sys;yaml.safe_load(open(sys.argv[1]))"',
	}

# LintFile runs a linter for the current file.
def g:LintFile(ft: string = &filetype)
	var cmd = get(g:linters, ft, v:null)
	if cmd == v:null
		g:Err('No linter for ' .. ft)
		return
	endif
	var exe = split(cmd)[0]
	if !executable(exe)
		g:Err(exe .. ' not found')
		return
	endif
	update
	g:Cmd(cmd .. ' ' .. expand('%:S'), 0, 0, 0)
	checktime
enddef

g:formatters = {
	'c':      ['clang-format -i', 'clang-format'],
	'cpp':    ['clang-format -i', 'clang-format'],
	'go':     ['goimports -w',    'goimports'],
	'java':   ['clang-format -i', 'clang-format'],
	'perl':   ['perltidy -b -bext /', 'perltidy'],
	'python': ['black -q',        'black -q -'],
	}

# FormatFile runs a formatter for the current file.
def g:FormatFile(line1: number, line2: number, ft: string = &filetype)
	var sel = line1 != 1 || line2 != line('$')
	var pfx = sel
		? 'prettier --stdin-filepath ' .. expand('%:S') .. ' --log-level warn'
		: 'prettier --write --log-level warn'
	var pair = get(g:formatters, ft, [])
	var cmd = empty(pair)
		? pfx .. (ft != &filetype ? ' --parser ' .. ft : '')
		: pair[sel ? 1 : 0]
	var exe = split(cmd)[0]
	if !executable(exe)
		g:Err(exe .. ' not found')
		return
	endif
	if sel
		execute ':' .. line1 .. ',' .. line2 .. '!' .. cmd
		return
	endif
	update
	g:Cmd(cmd .. ' ' .. expand('%:S'), 0, 0, 0)
	checktime
enddef

# TrimTrailingBlanks removes trailing consecutive blanks.
def g:TrimTrailingBlanks()
	var last_pos = getcurpos()
	var last_search = @/
	noautocmd silent! %s/\m\C\s\+$//e
	@/ = last_search
	setpos('.', last_pos)
enddef

def g:TabLine(): string
	var s = ''
	for i in range(1, tabpagenr('$'))
		if i == tabpagenr()
			s ..= '%#TabLineSel#'
		else
			s ..= '%#TabLine#'
		endif
		s ..= '%' .. i .. 'T'
		s ..= ' %{TabLabel(' .. i .. ')} '
	endfor
	s ..= '%#TabLineFill#%T'
	return s
enddef

# TerminalStatusLine returns a compact status line for terminal buffers
def g:TerminalStatusLine(): string
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

# TabLabel returns the display label for tab n, preferring t:label.
def g:TabLabel(n: number): string
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

# Rg executes the ripgrep program loading its results on the quickfix window.
def g:Rg(args: string)
	if !executable('rg')
		g:Err('ripgrep not found')
		return
	endif
	var oprg = &grepprg
	&grepprg = 'rg --vimgrep'
	execute 'lgrep' args
	&grepprg = oprg
	botright lwindow
enddef

# PlumbFile opens file f at optional address addr, reusing existing windows.
def g:PlumbFile(f: string, addr: string)
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

# Plumb dispatches the handling of an acquisition gesture.
def g:Plumb(wdir: string, attr: dict<any>, data: string)
	var text = substitute(data, '[):.,;]\+$', '', '')
	# URLs
	var m = matchlist(text,
		'\(https\?\|ftp\)://[a-zA-Z0-9_@\-]\+'
		.. '\([.:][a-zA-Z0-9_@\-]\+\)*'
		.. '\(/[a-zA-Z0-9_?,%#~&/\-+=.@]*\)*')
	if !empty(m)
		g:OpenURL(m[0])
		return
	endif

	# Wiki link
	m = matchlist(data, '\[\[\([a-zA-Z0-9_\-./ ]\+\)\]\]')
	if !empty(m)
		g:OpenWikilink(m[1])
		return
	endif

	# File with address
	m = matchlist(data, '^\([a-zA-Z0-9_\-./ ]\+\):\([0-9]\+\):\?')
	if !empty(m)
		var f = simplify(m[1][0] != '/' ? wdir .. '/' .. m[1] : m[1])
		if filereadable(f)
			g:PlumbFile(f, m[2])
			return
		endif
	endif

	# File
	m = matchlist(data, '^\([a-zA-Z0-9_\-./ ]\+\)')
	if !empty(m)
		var f = simplify(m[1][0] != '/' ? wdir .. '/' .. m[1] : m[1])
		if filereadable(f)
			g:PlumbFile(f, '')
			return
		endif
		if isdirectory(f)
			silent g:Dir(f)
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

# OpenURL opens the given URL
def g:OpenURL(url: string)
	echom 'url:' url
	if has('mac')
		g:Cmd('open ' .. shellescape(url), 0, 0, 0)
	elseif executable('xdg-open')
		g:Cmd('xdg-open ' .. shellescape(url), 0, 0, 0)
	endif
enddef

# OpenWikilink searches for a file path and opens it.
def g:OpenWikilink(name: string)
	var f = trim(system('n look ' .. shellescape(name)))
	if empty(f)
		g:Err('wikilink: not found:' .. name)
		return
	endif
	echom 'wikilink:' f
	g:PlumbFile(f, '')
enddef

# Outline populates the location list with lines matching pat (default: markdown headings).
def g:Outline(pat: string = '^#\+\s')
	var items = []
	for i in range(1, line('$'))
		if getline(i) =~ pat
			add(items, {'bufnr': bufnr('%'), 'lnum': i, 'text': getline(i)})
		endif
	endfor
	setloclist(0, [], 'r', {'title': 'Outline', 'items': items})
	lwindow
enddef

# Fts runs fts and populates the location list.
def g:Fts(query: string)
	if !executable('fts')
		g:Err('fts not found')
		return
	endif
	setloclist(0, [], 'r', {
		'title': 'Fts ' .. query,
		'lines': systemlist('fts ' .. shellescape(query) .. ' | cut -f 1,2'),
		'efm': '%f	%m'})
	lwindow
enddef

# Sort visible windows by buffer name.
def g:SortWindows()
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

# Match buffers by /re/ and optionally delete with /D.
def g:BufferMatch(a: string)
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
	exe 'sbuffer' g:NewBuffer('/+Errors')
	setline(1, map(b, (_, v) => bufname(v)))
enddef

# Strip ls -F suffix from a directory entry.
def g:DirEntry(): string
	return substitute(getline('.'), '[*=>@|]$', '', '')
enddef

# Read a directory into a scratch buffer.
def g:Dir(path: string, replace: bool = false)
	var d = empty(path) ? (empty(expand('%:p')) ? getcwd() : expand('%:p:h')) : fnamemodify(path, ':p')
	d = d =~# '/$' ? d : d .. '/'
	if &filetype ==# 'dir' && get(b:, 'dir', '') ==# d
		setlocal modifiable
		silent execute ':%!ls -aF ' .. shellescape(d)
		setlocal nomodifiable nomodified
		return
	endif
	if replace
		noautocmd execute 'file ' .. fnameescape(d)
	else
		noautocmd execute 'new ' .. fnameescape(d)
	endif
	setlocal bufhidden=wipe noswapfile filetype=dir modifiable
	silent execute ':%!ls -aF ' .. shellescape(d)
	setlocal nomodifiable nomodified
	b:dir = d
	# Dir keybindings: CR/rightmouse plumb, middlemouse execute, - go up
	nnoremap <silent> <buffer> <CR> <cmd>call g:Plumb(b:dir, {}, g:DirEntry())<CR>
	nnoremap <silent> <buffer> <leader><CR> <cmd>call g:Plumb(b:dir, {}, g:DirEntry())<CR>
	nnoremap <silent> <buffer> <rightmouse> <leftmouse><cmd>call g:Plumb(b:dir, {}, g:DirEntry())<CR>
	nnoremap <silent> <buffer> <middlemouse> <leftmouse><cmd>call g:Cmd(g:DirEntry(), 0, 0, 0)<CR>
	# :h strips trailing /, second :h goes up one level
	nnoremap <silent> <buffer> - <cmd>call g:Dir(fnamemodify(b:dir, ':h:h'))<CR>
enddef

# Toggle the directory buffer.
def g:DirToggle()
	if &filetype ==# 'dir'
		execute('bwipeout')
		return
	endif
	g:Dir('')
enddef

if exists('$DOTFILES')
	set rtp+=$DOTFILES/vim
	$PATH = $DOTFILES .. '/acme:' .. $PATH
	colorscheme basic
elseif isdirectory(expand('~/dotfiles'))
	set rtp+=~/dotfiles/vim
	$PATH = $HOME .. '/acme:' .. $PATH
	colorscheme basic
endif

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
endif

def g:LoadVimGo()
	g:go_def_mode           = 'gopls'
	g:go_info_mode          = 'gopls'
	g:go_decls_mode         = 'fzf'
	g:go_term_close_on_exit = 0
	g:go_term_enabled       = 1
	g:go_term_mode          = 'split'
	g:go_term_reuse         = 1
	packadd vim-go
	augroup go_maps
		autocmd!
		autocmd FileType go nnoremap <buffer> <leader>c :GoCallers<CR>
		autocmd FileType go nnoremap <buffer> <leader>d :GoDeclsDir<CR>
		autocmd FileType go nnoremap <buffer> <leader>i :GoInfo<CR>
		autocmd FileType go nnoremap <buffer> <leader>t :GoTestFile -v<CR>
	augroup END
	doautocmd go_maps FileType
enddef

augroup lazy_plugins
	autocmd!
	autocmd BufRead,BufNewFile *.go ++once call LoadVimGo()
augroup END

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
