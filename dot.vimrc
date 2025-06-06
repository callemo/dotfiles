set nocompatible

set autoindent
set autoread
set backspace=indent,eol,start
set cmdheight=2
set commentstring=#%s
set complete-=i
set confirm
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set fillchars=vert:\ ,fold:-
set hidden
set history=1000
set laststatus=2
set listchars=eol:$,tab:>\ ,space:.
set nobackup
set noequalalways
set noexpandtab
set nofoldenable
set noincsearch
set nojoinspaces
set noswapfile
set nowritebackup
set nrformats-=octal
set path=.,,
set scrollfocus=1
set scrolloff=0
set shiftwidth=4
set shortmess=atI
set showcmd
set softtabstop=4
set splitbelow
set splitright
set statusline=[%{fnamemodify(getcwd('%'),':t')}]\ %f:%l:%-2c\ %M%R%Y
set switchbuf=useopen,split
set tabline=%!TabLine()
set tabstop=4
set textwidth=0
set updatetime=300
set viewoptions-=options
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu
set wildmode=longest,list

if has('mac')
	set clipboard=unnamed
endif

if has('syntax') && has('eval')
	packadd! matchit
endif

runtime! ftplugin/man.vim
filetype plugin on
syntax on

let mapleader = ' '

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

let g:cmd_async = 1
let g:cmd_async_tasks = {}

let g:NERDTreeShowHidden=1
let g:NERDTreeSortHiddenFirst=1
let g:NERDTreeWinPos='right'
let g:NERDTreeWinSize=40
let g:NERDTreeMinimalMenu=1
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeMapJumpNextSibling=''
let g:NERDTreeMapJumpPrevSibling=''
let g:NERDTreeMapToggleFilters=''
let g:NERDTreeMapJumpParent=''
let g:NERDTreeMapOpenRecursively="+"
let g:NERDTreeMapCloseChildren="-"
let g:NERDTreeMapPreview='p'
let g:NERDTreeMapActivateNode='gf'
let g:NERDTreeMapOpenSplit='<C-x>'
let g:NERDTreeMapOpenInTab='<C-t>'

let g:go_def_mode           = 'gopls'
let g:go_info_mode          = 'gopls'
let g:go_decls_mode         = 'fzf'
let g:go_term_close_on_exit = 0
let g:go_term_enabled       = 1
let g:go_term_mode          = 'split'
let g:go_term_reuse         = 1

let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_text_changed = 0

augroup dotfiles
	autocmd!
	autocmd BufReadPost * exe 'silent! normal! g`"'
	autocmd BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | endif
	autocmd BufWritePre * :call TrimTrailingBlanks()
	autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
	autocmd InsertEnter,WinLeave * setl nocursorline
	autocmd InsertLeave,WinEnter * setl cursorline
	autocmd OptionSet * if &diff | setl nocursorline | endif

	if v:version > 800 && has('terminal')
		autocmd FileType perl setl et keywordprg=:terminal\ perldoc\ -f
		autocmd FileType python setl keywordprg=:terminal\ pydoc3
		autocmd TerminalOpen * setl nonumber | noremap <buffer> q i
	endif

	autocmd FileType c,cpp setl path+=/usr/include
	autocmd FileType css,html,htmldjango,scss setl iskeyword+=-
	autocmd FileType gitcommit setl spell fdm=syntax fdl=1 iskeyword+=.,-
	autocmd FileType go nnoremap <buffer> <leader>d :GoDeclsDir<CR>
	autocmd FileType go nnoremap <buffer> <leader>t :GoTestFile -v<CR>
	autocmd FileType go nnoremap <buffer> <leader>i :GoInfo<CR>
	autocmd FileType go nnoremap <buffer> <leader>c :GoCallers<CR>
	autocmd FileType groff setl commentstring=.\\\"\ %s
	autocmd FileType javascript,json setl sw=4 sts=4 et
	autocmd FileType typescript setl sw=4 sts=4 et syn=javascript " syntax/typescript.vim is too buggy
	autocmd FileType yaml setl ts=2 sw=2 sts=2 et syn=conf        " syntax/yaml.vim is too buggy
	autocmd FileType markdown,python setl sw=4 sts=4 et
	autocmd FileType sh setl noet sw=0 sts=0
augroup END

command! -nargs=+ -complete=file -range
	\ Cmd call Cmd(<q-args>, <range>, <line1>, <line2>)

command! Date execute "normal! A" . strftime("%Y-%m-%d")
command! Week execute "normal! A" . strftime("%YW%V")

command!          Lint call LintFile()
command! -nargs=? Fmt call FormatFile(<f-args>)
command! -nargs=* Rg call Rg(<q-args>)
command! -nargs=* Fts call Fts(<q-args>)

command! -nargs=1 BDelete call BufferDelete(<f-args>, v:false)
command! -nargs=1 BVDelete call BufferDelete(<f-args>, v:true)
command! -nargs=1 B call BufferList(<f-args>, v:false)
command! -nargs=1 BV call BufferList(<f-args>, v:true)

if has('terminal')
	command! -nargs=? -range Send call Send(<range>, <line1>, <line2>, <args>)
endif

nnoremap <down> <c-e>
nnoremap <up> <c-y>
inoremap <down> <c-o><c-e>
inoremap <up> <c-o><c-y>
nnoremap <silent> <c-w>+ :exe 'resize' ((winheight(0) * 3/2) + 1)<CR>
nnoremap <silent> <c-w>- :exe 'resize' (winheight(0) * 1/2)<CR>
nnoremap <c-w>N :new <c-r>=expand('%:h')<CR>/
nnoremap <c-w>Q :bwipeout<CR>
nnoremap <c-w>z :resize<CR>
nmap     +      <c-w>+
nmap     -      <c-w>-

nnoremap <c-l>        :nohlsearch \| call clearmatches() \| diffupdate \| syntax sync fromstart<CR><c-l>
nnoremap <c-p>        :FZF<CR>
nnoremap <leader>!    :Cmd<space>
nnoremap <leader>"    :call TmuxSwapBuffer()<CR>
nnoremap <leader>.    :lcd %:p:h<CR>
nnoremap <leader><CR> :call Plumb(expand('%:h'), {'word': expand('<cword>')}, expand('<cWORD>'))<CR>
nnoremap <leader>B    :NERDTreeToggle<CR>
nnoremap <leader>Bf   :NERDTreeFind<CR>
nnoremap <leader>Bt   :TagbarToggle<CR>
nnoremap <leader>f    :Fmt<CR>
nnoremap <leader>l    :Lint<CR>

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
nnoremap yoc :setl invignorecase<CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>
vnoremap * :call SetVisualSearch()<CR>/<CR>
vnoremap <silent> <leader>! :<c-u>call ExecVisualText()<CR>
vnoremap <silent> <leader><CR> :<c-u>call Plumb(expand('%:h'), {'visual':1}, GetVisualText())<CR>
inoremap <c-a> <home>
inoremap <c-e> <end>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

if !empty($TMUX)
	nnoremap <expr> <silent> <c-j>
		\ winnr() == winnr('$') ? ':call system("tmux selectp -t :.+")<CR>' : ':wincmd w<CR>'
	nnoremap <expr> <silent> <c-k>
		\ winnr() == 1 ? ':call system("tmux selectp -t :.-")<CR>' : ':wincmd W<CR>'
else
	nnoremap <silent> <c-j> :wincmd w<CR>
	nnoremap <silent> <c-k> :wincmd W<CR>
endif

if has('terminal')
	tnoremap <c-r><c-r> <c-r>
	tnoremap <silent> <c-w>+ <c-w>:exe 'resize' ((winheight(0) * 3/2) + 1)<CR>
	tnoremap <silent> <c-w>- <c-w>:exe 'resize' (winheight(0) * 1/2)<CR>
	tnoremap <c-w>z <c-w>:resize<CR>
	tnoremap <c-w><c-w> <c-w>.
	tnoremap <c-w>[ <c-\><c-n>
	tnoremap <scrollwheelup> <c-\><c-n>
	tnoremap <expr> <c-r> '<c-w>"' . nr2char(getchar())
	if !empty($TMUX)
		tnoremap <expr> <silent> <c-j>
					\ winnr() == winnr('$') ? '<c-w>:call system("tmux selectp -t :.+")<CR>' : '<c-w>:wincmd w<CR>'
		tnoremap <expr> <silent> <c-k>
					\ winnr() == 1 ?'<c-w>:call system("tmux selectp -t :.-")<CR>' : '<c-w>:wincmd W<CR>'
	else
		tnoremap <silent> <c-j> <c-w>:wincmd w<CR>
		tnoremap <silent> <c-k> <c-w>:wincmd W<CR>
	endif
endif

" Mouse
set mouse=nv
if has('mouse_sgr')
	set ttymouse=sgr
endif
nmap <silent> <middlemouse> <leftmouse><leader>!<c-r><c-w><CR>
nmap <silent> <rightmouse>  <leftmouse><leader><CR>
vmap <silent> <middlemouse> <leader>!
vmap <silent> <rightmouse>  <leader><CR>

" GetVisualText returns the text selected in visual mode.
function! GetVisualText() abort
	let reg = @"
	silent normal! vgvy
	let text = @"
	let @" = reg
	return text
endfunction

" SetVisualSearch literal search of the selected text in visual mode. Any
" regex special characters are escaped.
function! SetVisualSearch() abort
	let @/ = substitute('\m\C' . escape(GetVisualText(), '\.$*~'), "\n$", '', '')
endfunction

" Cmd executes a command with an optional rage for input.
function! Cmd(cmd, range, line1, line2) abort
	if g:cmd_async && exists('*job_start')
		call RunCmdAsync(a:range, a:line1, a:line2, a:cmd)
	else
		call RunCmd(a:range, a:line1, a:line2, a:cmd)
	endif
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

" RunCmd executes a shell command
function! RunCmd(range, line1, line2, cmd) abort
	let input = a:range > 0 ? getline(a:line1, a:line2) : []
	silent let output = systemlist(a:cmd, input)
	let msg = split(a:cmd)[0] . ': exit ' . v:shell_error
	if len(output) > 0 || v:shell_error
		let bufname = NewBuffer('/+Errors')
		exe 'sbuffer' bufname
		call UpdateCurrentWindow(output)
		if v:shell_error
			call UpdateCurrentWindow(msg)
		endif
	endif
	echom msg
endfunction

" RunCmdAsync asynchronously executes a shell command.
function! RunCmdAsync(range, line1, line2, cmd) abort
	let bufname = NewBuffer('/+Errors')
	let opts = {
		\ 'in_io': 'null', 'mode': 'raw',
		\ 'out_io': 'buffer', 'out_name': bufname, 'out_msg': 0,
		\ 'err_io': 'buffer', 'err_name': bufname, 'err_msg': 0,
		\ 'callback': 'AsyncCmdOutputHandler',
		\ 'close_cb': 'AsyncCmdCloseHandler',
		\ 'exit_cb': 'AsyncCmdExitHandler'
		\ }
	if a:range > 0
		let opts.in_io = 'buffer'
		let opts.in_buf = bufnr('%')
		let opts.in_top = a:line1
		let opts.in_bot = a:line2
	endif
	let job = job_start([&sh, &shcf, a:cmd], opts)
	let pid = job_info(job).process
	let name = split(a:cmd)[0]
	if !exists('g:cmd_async_tasks')
		let g:cmd_async_tasks = {}
	endif
	let g:cmd_async_tasks[pid] = {
		\ 'name': name,
		\ 'output': 0,
		\ 'exited': -1,
		\ 'closed': 0
		\ }
endfunction

" AsyncCmdOutputHandler job output handler.
function! AsyncCmdOutputHandler(channel, msg) abort
	let job = ch_getjob(a:channel)
	let pid = job_info(job).process
	let g:cmd_async_tasks[pid].output += 1
endfunction

" AsyncCmdCloseHandler channel close handler.
function! AsyncCmdCloseHandler(channel) abort
	let job = ch_getjob(a:channel)
	let pid = job_info(job).process
	let g:cmd_async_tasks[pid].closed = 1

	if g:cmd_async_tasks[pid].exited != -1
		call AsyncCmdDone(job)
	endif
endfunction

" AsyncCmdExitHandler job exit handler.
function! AsyncCmdExitHandler(job, code) abort
	let pid = job_info(a:job).process
	echom g:cmd_async_tasks[pid].name . ': exit ' . a:code
	let g:cmd_async_tasks[pid].exited = a:code

	if g:cmd_async_tasks[pid].closed
		call AsyncCmdDone(a:job)
	endif
endfunction

" AsyncCmdDone cleans up after close and exit have finished.
function! AsyncCmdDone(job) abort
	let pid = job_info(a:job).process
	let name = g:cmd_async_tasks[pid].name
	let code = g:cmd_async_tasks[pid].exited
	if g:cmd_async_tasks[pid].output || code > 0
		let bufnr = ch_getbufnr(a:job, 'out')
		exe 'sbuffer' bufnr
		call cursor(line('$'), '.')
		if code > 0
			let msg =  name . ': exit ' . code
			call UpdateCurrentWindow(msg)
		endif
	endif
	call remove(g:cmd_async_tasks, pid)
endfunction

" UpdateCurrentWindow appends texts to the active buffer and moves the
" cursor to the bottom.
function! UpdateCurrentWindow(text) abort
	if wordcount().bytes == 0
		call setline(1, a:text)
	else
		call append(line('$'), a:text)
	endif
	call cursor(line('$'), '.')
endfunction

" ExecVisualText executes the selected visual text as the command.
function! ExecVisualText() abort
	call Cmd(escape(GetVisualText(), '%#'), 0, 0, 0)
endfunction

" Tmux swaps the unnamed register with the tmux buffer.
function! TmuxSwapBuffer() abort
	silent let tmp = system('tmux showb')
	silent call system('tmux loadb -', @")
	let @" = tmp
endfunction

let g:linters = {
			\ 'bash': 'shellcheck -f gcc',
			\ 'css': 'stylelint',
			\ 'go': 'go vet',
			\ 'perl': 'perlcritic',
			\ 'python': 'pylint -s n',
			\ 'scss': 'stylelint',
			\ 'sh': 'shellcheck -f gcc',
			\ }

" LintFile runs a linter for the current file.
function! LintFile() abort
	let cmd = get(g:linters, &filetype, v:null)
	if cmd == v:null
		echohl ErrorMsg | echo 'No linter for ' . &filetype | echohl None
		return
	endif
	update
	call Cmd(cmd . ' ' . expand('%:S'), 0, 0, 0)
	checktime
endfunction

let g:formatters = {
			\ 'c': 'clang-format -i',
			\ 'cpp': 'clang-format -i',
			\ 'go': 'goimports -w',
			\ 'java': 'clang-format -i',
			\ 'perl': 'perltidy -b -bext /',
			\ 'python': 'black -q',
			\ }

" FormatFile runs a formatter for the current file.
function! FormatFile(...) abort
	let fallback = 'prettier --write --log-level warn'
	let cmd = a:0 > 0 ? a:1 : get(g:formatters, &filetype, fallback)
	update
	call Cmd(cmd . ' ' . expand('%:S'), 0, 0, 0)
	checktime
endfunction

" FindVisibleTerminals returns a list of terminal buffer numbers that are visible
" in the current tab.
function! FindVisibleTerminals() abort
	let terminals = []
	for winnr in range(1, winnr('$'))
		let bufnr = winbufnr(winnr)
		if getbufvar(bufnr, '&buftype') ==# 'terminal'
			call add(terminals, bufnr)
		endif
	endfor
	return terminals
endfunction

" Send types the current line or range to a terminal buffer as it was typed
" by the user.
function! Send(range, start, end, ...) abort
	if a:0 > 0
		let buf = a:1
	elseif exists('w:send_terminal_buf')
		let buf = w:send_terminal_buf
	else
		let terminals = FindVisibleTerminals()
		if len(terminals) == 0
			echohl ErrorMsg | echo 'no terminal visible' | echohl None
			return
		elseif len(terminals) > 1
			echohl ErrorMsg | echo 'multiple terminals visible, please specify one' | echohl None
			return
		endif
		let buf = terminals[0]
	endif
	let keys = join(getline(a:start, a:end), "\n")
	call term_sendkeys(buf, keys)
	if a:range
		call term_sendkeys(buf, "\n")
	endif
	let w:send_terminal_buf = buf
endfunction

" TrimTrailingBlanks remove tailing consecutive blanks.
function! TrimTrailingBlanks() abort
	let last_pos = getcurpos()
	let last_search = @/
	silent! %s/\m\C\s\+$//e
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

" TabLabel returns the a label string for the given tab number a:n. If t:label
" exists then returns it instead.
function! TabLabel(n) abort
	let tabl = gettabvar(a:n, 'label')
	if !empty(tabl)
		return tabl
	endif

	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let bufnr = buflist[winnr - 1]
	let filetype = getbufvar(bufnr, '&filetype')
	let buftype = getbufvar(bufnr, '&buftype')
	let label = bufname(bufnr)

	if filetype == 'fugitive'
		return '-Fugitive'
	elseif filetype == 'git'
		return '-Git'
	endif

	if empty(label)
		if empty(buftype)
			return '-'
		endif
		return '-' . buftype
	endif

	if filereadable(label)
		let label = fnamemodify(label, ':p:t')
		if filetype == 'help'
			let label = '-help:' . label
		endif
	elseif isdirectory(label)
		let label = fnamemodify(label, ':p:~')
	elseif label[-1:] == '/'
		let label = split(label, '/')[-1] . '/'
	else
		let label = split(label, '/')[-1]
	endif

	if buftype == 'terminal'
		return '-terminal:' . label
	endif

	return label
endfunction

" Rg executes the ripgrep program loading its results on the quickfix window.
function! Rg(args)
	let oprg = &grepprg
	let &grepprg = 'rg --vimgrep'
	exec 'grep' a:args
	let &grepprg = oprg
	botright cwindow
	silent! cfirst
endfunction

" Plumb dispatches the handling of an acquisition gesture.
function! Plumb(wdir, attr, data) abort
	" URLs
	let m = matchlist(a:data, '\(https\?\|ftp\)://[a-zA-Z0-9_@\-]\+\([.:][a-zA-Z0-9_@\-]+\)*/\?[a-zA-Z0-9_?,%#~&/\-+=]\+\([:.][a-zA-Z0-9_?,%#~&/\-+=]\+\)*')
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
	let m = matchlist(a:data, '^\([a-zA-Z0-9_\-./ ]\+\):\([0-9]\+\):')
	if len(m)
		let f = m[1][0] != '/' ? a:wdir . '/' . m[1] : m[1]
		if filereadable(f)
			if bufexists(f)
				silent exe 'sbuffer' '+' . m[2] fnameescape(f)
			else
				silent exe 'split' '+' . m[2] fnameescape(f)
			endif
			return
		endif
	endif

	" File
	let m = matchlist(a:data, '^\([a-zA-Z0-9_\-./ ]\+\)')
	if len(m)
		let f = m[1][0] != '/' ? a:wdir . '/' . m[1] : m[1]
		if filereadable(f)
			if bufexists(f)
				silent exe 'sbuffer' fnameescape(f)
			else
				silent exe 'split' fnameescape(f)
			endif
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
	call clearmatches()
	call matchadd('Search', getreg('/'))
endfunction

" OpenURL opens the given URL
function! OpenURL(url) abort
	echom 'url:' a:url
	if has('mac')
		call Cmd('open ''' . a:url . '''', 0, 0, 0)
	else
		call Cmd('xdg-open ''' . a:url . '''', 0, 0, 0)
	endif
endfunction

" OpenWikilink searches for a file path and opens it.
function! OpenWikilink(name) abort
	let f = trim(system('n look ' . shellescape(a:name)))
	if empty(f)
		echohl ErrorMsg
		echo 'wikilink: not found:' . a:name
		echohl None
		return
	endif
	echom 'wikilink:' f
	if bufexists(f)
		silent exe 'sbuffer' fnameescape(f)
	else
		silent exe 'split' fnameescape(f)
	endif
endfunction

" Fts executes a full-text search using the 'fts' command and populates the
" quickfix list with the results.
" @param query: The search query string.
function! Fts(query) abort
	call setqflist([], 'r', {
		\ 'title' : 'Fts ' . a:query,
		\ 'lines' : systemlist('fts ' . a:query . ' | cut -f 1,2'),
		\ 'efm': '%f	%m' })
	cwindow
endfunction

" BufferList lists all buffers matching or not matching the given pattern.
" @param pattern: The pattern to match buffer names against.
" @param inverse: If true, show buffers not matching the pattern instead.
function! BufferList(pattern, inverse) abort
	let buffers = getbufinfo({'buflisted': 1})
	let filtered = []

	for buf in buffers
		let matches = has_key(buf, 'name') && match(buf.name, a:pattern) != -1
		if matches != a:inverse
			call add(filtered, buf)
		endif
	endfor

	if empty(filtered)
		let bufname = NewBuffer('/+Errors')
		exe 'sbuffer' bufname
		call setline(1, 'No buffer match: ' . a:pattern)
		return
	endif

	" Sort filtered buffers by file path
	call sort(filtered, {a, b -> a.name == b.name ? 0 : a.name > b.name ? 1 : -1})

	let output = []
	for buf in filtered
		let prefix = ' '
		if has_key(buf, 'bufnr') && buf.bufnr == bufnr('%')
			let prefix = '>'
		elseif has_key(buf, 'bufnr') && buf.bufnr == bufnr('#')
			let prefix = '+'
		endif

		let status = ' '
		if has_key(buf, 'changed') && buf.changed
			let status = '*'
		endif

		if has_key(buf, 'bufnr') && has_key(buf, 'name')
			call add(output, printf("%s%s %-5d %s", prefix, status, buf.bufnr, buf.name))
		endif
	endfor

	let bufname = NewBuffer('/+Buffers')
	exe 'sbuffer' bufname
	call setline(1, output)
endfunction

" BufferDelete deletes all buffers whose names match
" or don't match the given pattern.
" @param pattern: The pattern to match buffer names against.
" @param inverse: If true, delete buffers NOT matching the pattern instead.
function! BufferDelete(pattern, inverse) abort
	let buffer_list = []
	for buffer in getbufinfo({'buflisted': 1})
		let matches = match(buffer.name, a:pattern) != -1
		if matches != a:inverse
			call add(buffer_list, buffer.bufnr)
		endif
	endfor
	if empty(buffer_list)
		let bufname = NewBuffer('/+Errors')
		exe 'sbuffer' bufname
		call setline(1, 'No buffer match: ' . a:pattern)
		return
	endif
	execute 'bdelete' join(buffer_list)
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

if filereadable('go.mod')
	packadd vim-go
endif

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
