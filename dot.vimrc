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

let mapleader = ' '

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1


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
		" syntax/typescript.vim is too buggy
	autocmd FileType yaml setl ts=2 sw=2 sts=2 et syn=conf
		" syntax/yaml.vim is too buggy
	autocmd FileType markdown,python setl sw=4 sts=4 et
	autocmd FileType sh setl noet sw=0 sts=0
	autocmd VimEnter * if argc() == 0 && empty(bufname()) | call Dir('', 1) | endif
	" BufReadCmd matches trailing / (dir buffer names); BufReadPost catches :e .
	autocmd BufReadCmd */ call Dir(expand('<afile>:p'), 1)
	autocmd BufReadPost * if isdirectory(expand('<afile>:p')) | call Dir(expand('<afile>:p'), 1) | endif
augroup END

command! -nargs=+ -complete=file -range
	\ Cmd call Cmd(<q-args>, <range>, <line1>, <line2>)

inoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
inoremap <C-x>w <C-r>=strftime("%YW%V")<CR>
cnoremap <C-x>d <C-r>=strftime("%Y-%m-%d")<CR>
cnoremap <C-x>w <C-r>=strftime("%YW%V")<CR>

command! -nargs=? Lint call LintFile(<f-args>)
command! -nargs=? -range=% Fmt call FormatFile(<f-args>)
command! -nargs=* Rg call Rg(<q-args>)
command! -nargs=* Fts call Fts(<q-args>)
command! -nargs=? Oln call Outline(<f-args>)

command!           Sort   call SortWindows()
command! -nargs=1 B call BufferMatch(<q-args>)

function! SendToTmux(line1, line2, target) abort
	if a:target != ''
		let w:send_tmux_target = a:target
	endif
	let target = get(w:, 'send_tmux_target', '')
	let text = join(getline(a:line1, a:line2), "\n") . "\n"
	if target != ''
		call system('tmux loadb - \; pasteb -d -t ' . shellescape(target), text)
	else
		call system('tmux loadb - \; pasteb -d', text)
	endif
endfunction
command! -range -nargs=? Send call SendToTmux(<line1>, <line2>, <q-args>)
nnoremap <silent> <leader>; :Send<CR>
xnoremap <silent> <leader>; :Send<CR>

nnoremap <down> <c-e>
nnoremap <up> <c-y>
inoremap <down> <c-o><c-e>
inoremap <up> <c-o><c-y>
nnoremap <c-w>N :new <c-r>=expand('%:h')<CR>/
nnoremap <c-w>z :resize<CR>
nnoremap <silent> + :exe 'resize' (winheight(0) + max([5, winheight(0) / 2]))<CR>

nnoremap <c-l>
	\ :nohlsearch \| call clearmatches() \| diffupdate \| syntax sync fromstart<CR><c-l>
nnoremap <c-p> :FZF<CR>
nnoremap <leader>q :call CloseBuffer('')<CR>
nnoremap <leader>Q :call CloseBuffer('!')<CR>
nnoremap <leader>! :Cmd<space>
nnoremap <leader>. :lcd %:p:h<CR>
nnoremap <silent> <leader><CR>
	\ :call Plumb(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
nnoremap <silent> <leader>B :call DirToggle()<CR>
nnoremap <leader>f :Fmt<CR>
nnoremap <silent> <leader>F :let @+ = fnamemodify(expand('%:p'), ':.')<CR>
nnoremap <leader>l :Lint<CR>

nnoremap m<CR> :make<CR>
nnoremap m<space> :make<space>

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
nnoremap yob :set background=<c-r>=&bg == 'light' ? 'dark' : 'light'<CR><CR>
nnoremap yoi :setl invignorecase<CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>
xnoremap * :call SetVisualSearch()<CR>/<CR>
xnoremap <silent> <leader>! :<c-u>call Cmd(GetVisualText(), 0, 0, 0)<CR>
xnoremap <silent> <leader><CR>
		\ :<c-u>call Plumb(expand('%:h'), {'visual':1}, GetVisualText())<CR>
inoremap <c-a> <home>
inoremap <c-e> <end>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

nnoremap <silent> <c-j> :call WinCycleNext()<CR>
nnoremap <silent> <c-k> :call WinCyclePrev()<CR>

tnoremap <c-r><c-r> <c-r>
tnoremap <c-w>z <c-w>:resize<CR>
tnoremap <c-w><c-w> <c-w>.
tnoremap <c-w>[ <c-\><c-n>
tnoremap <scrollwheelup> <c-\><c-n>
tnoremap <expr> <c-r> '<c-w>"' . nr2char(getchar())
tnoremap <silent> <c-j> <c-w>:call WinCycleNext()<CR>
tnoremap <silent> <c-k> <c-w>:call WinCyclePrev()<CR>

" Mouse
set mouse=nv
if has('mouse_sgr')
	set ttymouse=sgr
endif
nnoremap <silent> <2-LeftMouse> :call WinDblClick()<CR>
nnoremap <silent> <C-LeftMouse> :call WinZoom()<CR>
nnoremap <silent> <middlemouse> <leftmouse>:Cmd <c-r><c-a><CR>
nnoremap <silent> <rightmouse> <leftmouse>:call Plumb(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
xnoremap <silent> <middlemouse> :<c-u>call Cmd(GetVisualText(), 0, 0, 0)<CR>
xnoremap <silent> <rightmouse> :<c-u>call Plumb(expand('%:h'), {'visual':1}, GetVisualText())<CR>

" CloseBuffer: quit if last window, else wipeout the buffer.
function! CloseBuffer(bang) abort
	if winnr('$') == 1
		exe 'quit' . a:bang
	else
		exe 'bwipeout' . a:bang
	endif
endfunction

" WinCycleNext/Prev: cycle vim windows, falling through to tmux panes at edges.
function! WinCycleNext() abort
	if !empty($TMUX) && winnr() == winnr('$')
		call system("tmux selectp -t :.+")
	else
		wincmd w
	endif
endfunction

function! WinCyclePrev() abort
	if !empty($TMUX) && winnr() == 1
		call system("tmux selectp -t :.-")
	else
		wincmd W
	endif
endfunction

" WinDblClick: double-click statusline closes window, body selects word.
function! WinDblClick() abort
	let m = getmousepos()
	let w = m.winid
	if !w | return | endif
	if m.winrow > winheight(win_id2win(w))
		call win_execute(w, 'call CloseBuffer("")')
	else
		exe "normal! \<2-LeftMouse>"
	endif
endfunction

" WinZoom: ctrl-click statusline zooms window to full height.
function! WinZoom() abort
	let m = getmousepos()
	let w = m.winid
	if !w | return | endif
	if m.winrow > winheight(win_id2win(w))
		call win_execute(w, 'resize')
	endif
endfunction

" GetVisualText returns the text selected in visual mode.
function! GetVisualText() abort
	let reg = @"
	silent normal! vgvy
	let text = @"
	let @" = reg
	return text
endfunction

" SetVisualSearch sets / to a literal search of the visual selection.
function! SetVisualSearch() abort
	let @/ = substitute('\m\C' . escape(GetVisualText(), '\.^$~[]*'), "\n$", '', '')
endfunction

function! Err(msg) abort
	echohl ErrorMsg | echo a:msg | echohl None
endfunction

" NewBuffer creates a scratch buffer with the given suffix returning its name
function! NewBuffer(suffix) abort
	let bufname = getcwd() . a:suffix
	if !bufexists(bufname)
		let bufnr = bufnr(bufname, 1)
		call setbufvar(bufnr, '&buflisted', 1)
		call setbufvar(bufnr, '&buftype', 'nofile' )
		call setbufvar(bufnr, '&number', 0)
		call setbufvar(bufnr, '&swapfile', 0)
	endif
	return bufname
endfunction

" Cmd executes a shell command asynchronously, output to +Errors.
function! Cmd(cmd, range, line1, line2) abort
	let bufname = NewBuffer('/+Errors')
	let opts = {
		\ 'in_io': 'null', 'mode': 'raw',
		\ 'out_io': 'buffer', 'out_name': bufname, 'out_msg': 0,
		\ 'err_io': 'buffer', 'err_name': bufname, 'err_msg': 0,
		\ 'exit_cb': {job, code -> CmdDone(job, code, split(a:cmd)[0])},
		\ 'timeout': 300000,
		\ 'stoponexit': 'term'
		\ }
	if a:range > 0
		let opts.in_io = 'buffer'
		let opts.in_buf = bufnr('%')
		let opts.in_top = a:line1
		let opts.in_bot = a:line2
	endif
	call job_start([&sh, &shcf, a:cmd], opts)
endfunction

" CmdDone handles job completion: show +Errors if output or failure.
function! CmdDone(job, code, name) abort
	echom a:name . ': exit ' . a:code
	let bufnr = ch_getbufnr(a:job, 'out')
	if getbufline(bufnr, 1, '$') != [''] || a:code > 0
		exe 'sbuffer' bufnr
		call cursor(line('$'), '.')
		if a:code > 0
			call append(line('$'), a:name . ': exit ' . a:code)
			call cursor(line('$'), '.')
		endif
	endif
endfunction

" OscYank copies text to clipboard via OSC 52.
function! OscYank(text) abort
	let encoded = system('printf %s ' . shellescape(a:text) . ' | base64 | tr -d "\n"')
	let osc = "\e]52;c;" . encoded . "\x07"
	call writefile([osc], '/dev/tty', 'b')
endfunction

let g:linters = {
			\ 'bash': 'shellcheck -f gcc',
			\ 'css': 'stylelint',
			\ 'go': 'go vet',
			\ 'json': 'python3 -c "import json,sys;json.load(open(sys.argv[1]))"',
			\ 'markdown': 'prettier --check',
			\ 'perl': 'perlcritic',
			\ 'python': 'pylint -s n',
			\ 'scss': 'stylelint',
			\ 'sh': 'shellcheck -f gcc',
			\ 'yaml': 'python3 -c "import yaml,sys;yaml.safe_load(open(sys.argv[1]))"',
			\ }

" LintFile runs a linter for the current file.
function! LintFile(...) abort
	let ft = a:0 ? a:1 : &filetype
	let cmd = get(g:linters, ft, v:null)
	if cmd == v:null
		call Err('No linter for ' . ft)
		return
	endif
	let exe = split(cmd)[0]
	if !executable(exe)
		call Err(exe . ' not found')
		return
	endif
	update
	call Cmd(cmd . ' ' . expand('%:S'), 0, 0, 0)
	checktime
endfunction

let g:formatters = {
			\ 'c':      ['clang-format -i', 'clang-format'],
			\ 'cpp':    ['clang-format -i', 'clang-format'],
			\ 'go':     ['goimports -w',    'goimports'],
			\ 'java':   ['clang-format -i', 'clang-format'],
			\ 'perl':   ['perltidy -b -bext /', 'perltidy'],
			\ 'python': ['black -q',        'black -q -'],
			\ }

" FormatFile runs a formatter for the current file.
function! FormatFile(...) range abort
	let ft  = a:0 ? a:1 : &filetype
	let sel = a:firstline != 1 || a:lastline != line('$')
	let pfx = sel
		\ ? 'prettier --stdin-filepath ' . expand('%:S') . ' --log-level warn'
		\ : 'prettier --write --log-level warn'
	let pair = get(g:formatters, ft, [])
	let cmd = empty(pair) ? pfx . (a:0 ? ' --parser ' . ft : '') : pair[sel ? 1 : 0]
	let exe = split(cmd)[0]
	if !executable(exe)
		call Err(exe . ' not found')
		return
	endif
	if sel
		exe a:firstline . ',' . a:lastline . '!' . cmd
		return
	endif
	update
	call Cmd(cmd . ' ' . expand('%:S'), 0, 0, 0)
	checktime
endfunction

" TrimTrailingBlanks removes trailing consecutive blanks.
function! TrimTrailingBlanks() abort
	let last_pos = getcurpos()
	let last_search = @/
	noautocmd silent! %s/\m\C\s\+$//e
	let @/ = last_search
	call setpos('.', last_pos)
endfunction

function! TabLine() abort
	let s = ''
	for i in range(1, tabpagenr('$'))
		if i == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		let s .= '%' . i . 'T'
		let s .= ' %{TabLabel(' . i . ')} '
	endfor
	let s .= '%#TabLineFill#%T'
	return s
endfunction

" TerminalStatusLine returns a compact status line for terminal buffers
function! TerminalStatusLine() abort
	let job = term_getjob(bufnr('%'))
	if job == v:null
		return ''
	endif
	let info = job_info(job)
	let status = info.status
	let cmd = len(info.cmd) > 0 ? split(info.cmd[0], '/')[-1] : 'unknown'
	let pid = has_key(info, 'process') ? info.process : 'no-pid'
	let bufnr = bufnr('%')
	let cwd = has_key(info, 'cwd') ? fnamemodify(info.cwd, ':t') : fnamemodify(getcwd(), ':t')
	return printf('%d [%s] %s(%s) %s', bufnr, cwd, cmd, pid, toupper(status))
endfunction

" TabLabel returns the display label for tab a:n, preferring t:label.
function! TabLabel(n) abort
	let tabl = gettabvar(a:n, 'label')
	if !empty(tabl)
		return tabl
	endif

	let bufnr = tabpagebuflist(a:n)[tabpagewinnr(a:n) - 1]
	let bt = getbufvar(bufnr, '&buftype')
	let name = bufname(bufnr)

	if empty(name)
		return empty(bt) ? '-' : '-' . bt
	endif

	let label = fnamemodify(name, ':t')
	if empty(label)
		let label = fnamemodify(name, ':h:t') . '/'
	endif

	if bt ==# 'help'
		return '-help:' . label
	endif
	if bt ==# 'quickfix'
		let winid = win_getid(tabpagewinnr(a:n), a:n)
		let info = getwininfo(winid)
		return (!empty(info) && info[0].loclist ? '-loc:' : '-qf:') . label
	endif
	if bt ==# 'terminal'
		return '-terminal:' . label
	endif
	return label
endfunction

" Rg executes the ripgrep program loading its results on the quickfix window.
function! Rg(args) abort
	if !executable('rg')
		call Err('ripgrep not found')
		return
	endif
	let oprg = &grepprg
	let &grepprg = 'rg --vimgrep'
	exec 'lgrep' a:args
	let &grepprg = oprg
	botright lwindow
endfunction

" PlumbFile opens file f at optional address addr, reusing existing windows.
function! PlumbFile(f, addr) abort
	let f = fnamemodify(a:f, ':.')
	let w = bufwinnr(f)
	if w != -1
		exe w . 'wincmd w'
		if !empty(a:addr) | exe a:addr | endif
	elseif bufexists(f)
		silent exe 'sbuffer' (empty(a:addr) ? '' : '+'.a:addr) fnameescape(f)
	else
		silent exe 'split' (empty(a:addr) ? '' : '+'.a:addr) fnameescape(f)
	endif
endfunction

" Plumb dispatches the handling of an acquisition gesture.
function! Plumb(wdir, attr, data) abort
	let data = substitute(a:data, '[):.,;]\+$', '', '')
	" URLs
	let m = matchlist(data,
		\ '\(https\?\|ftp\)://[a-zA-Z0-9_@\-]\+'
		\ . '\([.:][a-zA-Z0-9_@\-]\+\)*'
		\ . '\(/[a-zA-Z0-9_?,%#~&/\-+=.@]*\)*')
	if len(m)
		call OpenURL(m[0])
		return
	endif

	" Wiki link
	let m = matchlist(a:data, '\[\[\([a-zA-Z0-9_\-./ ]\+\)\]\]')
	if len(m)
		call OpenWikilink(m[1])
		return
	endif

	" File with address
	let m = matchlist(a:data, '^\([a-zA-Z0-9_\-./ ]\+\):\([0-9]\+\):\?')
	if len(m)
		let f = simplify(m[1][0] != '/' ? a:wdir . '/' . m[1] : m[1])
		if filereadable(f)
			call PlumbFile(f, m[2])
			return
		endif
	endif

	" File
	let m = matchlist(a:data, '^\([a-zA-Z0-9_\-./ ]\+\)')
	if len(m)
		let f = simplify(m[1][0] != '/' ? a:wdir . '/' . m[1] : m[1])
		if filereadable(f)
			call PlumbFile(f, '')
			return
		endif
		if isdirectory(f)
			silent call Dir(f)
			return
		endif
	endif

	" Text search
	if get(a:attr, 'visual', 0)
		let @/ = substitute('\m\C' . escape(a:data, '\.^$[]*~'), "\n", '\\n', 'g')
		call feedkeys("/\<CR>")
	elseif has_key(a:attr, 'word')
		let @/ = '\<' . a:attr['word'] . '\>'
		call feedkeys("/\<CR>")
	endif
endfunction

" OpenURL opens the given URL
function! OpenURL(url) abort
	echom 'url:' a:url
	if has('mac')
		call Cmd('open ' . shellescape(a:url), 0, 0, 0)
	elseif executable('xdg-open')
		call Cmd('xdg-open ' . shellescape(a:url), 0, 0, 0)
	endif
endfunction

" OpenWikilink searches for a file path and opens it.
function! OpenWikilink(name) abort
	let f = trim(system('n look ' . shellescape(a:name)))
	if empty(f)
		call Err('wikilink: not found:' . a:name)
		return
	endif
	echom 'wikilink:' f
	call PlumbFile(f, '')
endfunction

" Outline populates the location list with lines matching pat (default: markdown headings).
function! Outline(...) abort
	let pat = a:0 > 0 && !empty(a:1) ? a:1 : '^#\+\s'
	let items = []
	for i in range(1, line('$'))
		if getline(i) =~ pat
			call add(items, {'bufnr': bufnr('%'), 'lnum': i, 'text': getline(i)})
		endif
	endfor
	call setloclist(0, [], 'r', {'title': 'Outline', 'items': items})
	lwindow
endfunction

" Fts runs fts and populates the location list.
function! Fts(query) abort
	if !executable('fts')
		call Err('fts not found')
		return
	endif
	call setloclist(0, [], 'r', {
		\ 'title' : 'Fts ' . a:query,
		\ 'lines' : systemlist('fts ' . shellescape(a:query) . ' | cut -f 1,2'),
		\ 'efm': '%f	%m' })
	lwindow
endfunction

" Sort visible windows by buffer name.
function! SortWindows() abort
	let w = range(1, winnr('$'))
	let b = filter(map(copy(w), 'winbufnr(v:val)'), 'bufexists(v:val) && !empty(bufname(v:val))')
	if empty(b) | return | endif
	let s = sort(copy(b), {x, y -> bufname(x) > bufname(y) ? 1 : -1})
	for i in range(len(s))
		call win_execute(win_getid(w[i]), 'silent! buffer ' . s[i])
	endfor
endfunction

" Match buffers by /re/ and optionally delete with /D.
function! BufferMatch(a) abort
	let i = stridx(a:a, '/')
	let j = strridx(a:a, '/')
	if i == -1 || i == j
		call Err('Usage: :B /regex/[D]')
		return
	endif
	let re = a:a[i+1 : j-1]
	let tail = a:a[j+1 :]
	let b = filter(map(getbufinfo({'bufloaded': 1}), 'v:val.bufnr'), 'bufname(v:val) =~ re')
	if empty(b) | return | endif
	if tail ==? 'd'
		exe 'bwipeout' join(b)
		return
	endif
	exe 'sbuffer' NewBuffer('/+Errors')
	call setline(1, map(b, 'bufname(v:val)'))
endfunction

" Strip ls -F suffix from a directory entry.
function! DirEntry() abort
	return substitute(getline('.'), '[*=>@|]$', '', '')
endfunction

" Read a directory into a scratch buffer.
function! Dir(path, ...) abort
	let d = empty(a:path) ? (empty(expand('%:p')) ? getcwd() : expand('%:p:h')) : fnamemodify(a:path, ':p')
	let d = d =~# '/$' ? d : d . '/'
	if &filetype ==# 'dir' && get(b:, 'dir', '') ==# d
		setlocal modifiable
		silent execute '%!ls -aF ' . shellescape(d)
		setlocal nomodifiable nomodified
		return
	endif
	let replace = a:0 && a:1
	if replace
		noautocmd execute 'file ' . fnameescape(d)
	else
		noautocmd execute 'new ' . fnameescape(d)
	endif
	setlocal bufhidden=wipe noswapfile filetype=dir
	silent execute '%!ls -aF ' . shellescape(d)
	setlocal nomodifiable nomodified
	let b:dir = d
	nnoremap <silent> <buffer> <CR> :call Plumb(b:dir, {}, DirEntry())<CR>
	" :h strips trailing /, second :h goes up one level
	nnoremap <silent> <buffer> - :call Dir(fnamemodify(b:dir, ':h:h'))<CR>
	nnoremap <silent> <buffer> <leader><CR> :call Plumb(b:dir, {}, DirEntry())<CR>
	nnoremap <silent> <buffer> <rightmouse> <leftmouse>:call Plumb(b:dir, {}, DirEntry())<CR>
	nnoremap <silent> <buffer> <middlemouse> <leftmouse>:Cmd <C-R>=DirEntry()<CR><CR>
endfunction

" Toggle the directory buffer.
function! DirToggle() abort
	if &filetype ==# 'dir' | return execute('bwipeout') | endif
	call Dir('')
endfunction

if exists('$DOTFILES')
	set rtp+=$DOTFILES/vim
	let $PATH=$DOTFILES . '/acme:' . $PATH
	colorscheme basic
elseif isdirectory(expand('~/dotfiles'))
	set rtp+=~/dotfiles/vim
	let $PATH=$HOME . '/acme:' . $PATH
	colorscheme basic
endif

if isdirectory(expand('~/.fzf'))
	set rtp+=~/.fzf
endif

function! LoadVimGo() abort
	let g:go_def_mode           = 'gopls'
	let g:go_info_mode          = 'gopls'
	let g:go_decls_mode         = 'fzf'
	let g:go_term_close_on_exit = 0
	let g:go_term_enabled       = 1
	let g:go_term_mode          = 'split'
	let g:go_term_reuse         = 1
	packadd vim-go
	augroup go_maps
		autocmd!
		autocmd FileType go nnoremap <buffer> <leader>c :GoCallers<CR>
		autocmd FileType go nnoremap <buffer> <leader>d :GoDeclsDir<CR>
		autocmd FileType go nnoremap <buffer> <leader>i :GoInfo<CR>
		autocmd FileType go nnoremap <buffer> <leader>t :GoTestFile -v<CR>
	augroup END
	doautocmd go_maps FileType
endfunction

augroup lazy_plugins
	autocmd!
	autocmd BufRead,BufNewFile *.go ++once call LoadVimGo()
augroup END

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
