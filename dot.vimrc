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
set hlsearch
set laststatus=2
set listchars=eol:$,tab:>\ ,space:.
set nobackup
set noequalalways
set noexpandtab
set nofoldenable
set noincsearch
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set nrformats-=octal
set path=.,,
set scrolloff=0
set shiftwidth=4
set shortmess=atI
set showcmd
set softtabstop=4
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

let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='-'
let g:NERDTreeShowHidden=1
let g:NERDTreeSortHiddenFirst=1
let g:NERDTreeMapJumpNextSibling=''
let g:NERDTreeMapJumpPrevSibling=''
let g:NERDTreeMapToggleFilters=''
let g:NERDTreeMapJumpParent=''
let g:NERDTreeMapOpenRecursively="+"
let g:NERDTreeMapCloseChildren="-"
let g:NERDTreeMapPreview='p'
let g:NERDTreeMapActivateNode='gf'
let g:NERDTreeMapOpenSplit='<C-w>f'
let g:NERDTreeMapOpenInTab='<C-w>t'

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

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
	autocmd FileType javascript,json,typescript setl sw=2 sts=2 et
	autocmd FileType markdown,python,yaml setl et
	autocmd FileType sh setl noet sw=0 sts=0
	autocmd FileType text,markdown nnoremap <buffer> <Enter>
		\ :call WikiLink(expand('<cword>'), 0)<CR>
	autocmd FileType text,markdown nnoremap <buffer> <C-w><Enter>
		\ :call WikiLink(expand('<cword>'), 1)<CR>
augroup END

command! -nargs=+ -complete=file -range
	\ Cmd call Cmd(<range>, <line1>, <line2>, <q-args>)

command!          Lint call LintFile()
command! -nargs=? Fmt call FormatFile(<f-args>)
command! -nargs=* Rg call Rg(<q-args>)
command! -nargs=* Fts call Fts(<q-args>)

if has('terminal')
	command! -nargs=? -range Send call Send(<range>, <line1>, <line2>, <args>)
endif

nnoremap <down> <c-e>
nnoremap <up> <c-y>
inoremap <down> <c-o><c-e>
inoremap <up> <c-o><c-y>
nnoremap <c-w>+ :exe 'resize' (winheight(0) * 3/2)<CR>
nnoremap <c-w>- :exe 'resize' (winheight(0) * 1/2)<CR>
nnoremap <c-w>z :resize<CR>

nnoremap <c-l>        :nohlsearch \| diffupdate \| syntax sync fromstart<CR><c-l>
nnoremap <leader>!    :Cmd<space>
nnoremap <leader>.    :lcd %:p:h<CR>
nnoremap <leader><CR> :Send<CR>
nnoremap <leader>F    :Fmt<CR>
nnoremap <leader>L    :Lint<CR>
nnoremap <leader>b    :buffers<CR>
nnoremap <leader>d    :bwipeout<CR>
nnoremap <leader>e    :edit <c-r>=expand('%:h')<CR>/
nnoremap <leader>f    :NERDTreeFind<CR>
nnoremap <leader>gf   :drop <cfile><CR>
nnoremap <leader>n    :NERDTreeFocus<CR>
nnoremap <leader>p    :let @"=expand('%:p')<CR>
nnoremap <leader>r    :registers<CR>
nnoremap <leader>t    :call Tmux()<CR>

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
nnoremap yoc :setl invcursorline<CR>
nnoremap yoh :setl invhlsearch<CR>
nnoremap yol :setl invlist<CR>
nnoremap yon :setl invnumber<CR>
nnoremap yop :setl invpaste<CR>
nnoremap yor :setl invrelativenumber<CR>
nnoremap yos :setl invspell<CR>
nnoremap yow :setl invwrap<CR>
vnoremap * :call SetVisualSearch()<CR>/<CR>
vnoremap <leader>! :<c-u>call ExecVisualText()<CR>
vnoremap <leader><CR> :Send<CR>
inoremap <c-a> <home>
inoremap <c-e> <end>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

if has('macunix')
	nnoremap <silent> gx :call Cmd(0, 0, 0, 'open ' . expand('<cfile>'))<CR>
elseif has('unix')
	nnoremap <silent> gx :call Cmd(0, 0, 0, 'xdg-open ' . expand('<cfile>'))<CR>
endif

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
	tnoremap <c-w>+ <c-w>:exe 'resize' (winheight(0) * 3/2)<CR>
	tnoremap <c-w>- <c-w>:exe 'resize' (winheight(0) * 1/2)<CR>
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
set mouse=nvi
if has('mouse_sgr')
	set ttymouse=sgr
endif
nnoremap <silent> <middlemouse> <leftmouse>:Cmd <c-r><c-w><CR>
nnoremap <silent> <rightmouse>  <leftmouse>:call Plumb(expand('<cword>'), {}, expand('%:h'))<CR>
vmap     <silent> <middlemouse> <leader>!
vmap     <silent> <rightmouse>  :<c-u>call Plumb(GetVisualText(), {'visual':1}, expand('%:h'))<CR>

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
function! Cmd(range, line1, line2, cmd) abort
	if g:cmd_async && exists('*job_start')
		call StartAsyncCmd(a:range, a:line1, a:line2, a:cmd)
	else
		call RunShellCmd(a:range, a:line1, a:line2, a:cmd)
	endif
endfunction

" MakeTempBuffer Creates a scratch buffer. Returns the buffer name.
function! MakeTempBuffer() abort
	let bufname = getcwd() . '/+Errors'
	if !bufexists(bufname)
		let bufnr = bufnr(bufname, 1)
		call setbufvar(bufnr, '&buflisted', 1)
		call setbufvar(bufnr, '&buftype', 'nofile' )
		call setbufvar(bufnr, '&number', 0)
		call setbufvar(bufnr, '&swapfile', 0)
	endif
	return bufname
endfunction

" RunShellCmd synchronously execute a command.
function! RunShellCmd(range, line1, line2, cmd) abort
	let input = a:range > 0 ? getline(a:line1, a:line2) : []
	silent let output = systemlist(a:cmd, input)
	let msg = split(a:cmd)[0] . ': exit ' . v:shell_error
	if len(output) > 0 || v:shell_error
		let bufname = MakeTempBuffer()
		exe 'sbuffer' bufname
		call UpdateCurrentWindow(output)
		if v:shell_error
			call UpdateCurrentWindow(msg)
		endif
	endif
	echom msg
endfunction

" StartAsyncCmd asynchronously execute a command.
function! StartAsyncCmd(range, line1, line2, cmd) abort
	let bufname = MakeTempBuffer()
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
	call Cmd(0, 0, 0, escape(GetVisualText(), '%#'))
endfunction

" Tmux swaps the unnamed register with the tmux buffer.
function! Tmux() abort
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
	call Cmd(0, 0, 0, cmd . ' ' . expand('%:S'))
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
	let fallback = 'prettier --write --loglevel warn'
	let cmd = a:0 > 0 ? a:1 : get(g:formatters, &filetype, fallback)
	update
	call Cmd(0, 0, 0, cmd . ' ' . expand('%:S'))
	checktime
endfunction

" Send types the current line or range to a terminal buffer as it was typed
" by the user.
function! Send(range, start, end, ...) abort
	if a:0 > 0
		let buf = a:1
	elseif exists('w:send_terminal_buf')
		let buf = w:send_terminal_buf
	else
		echohl ErrorMsg | echo 'no terminal link' | echohl None
		return
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
function! Plumb(msg, attrs, wdir) abort
	if get(a:attrs, 'visual', 0)
		if search(substitute('\m\C' . escape(a:msg, '\.$*~'), "\n$", '', ''))
			let c = getcurpos()
			call setpos("'<", [0, c[1], c[2], 0])
			call setpos("'>", [0, c[1], c[2] + strchars(a:msg) - 1, 0])
			normal! gv
		endif
	else
		call search('\<' . a:msg . '\>', 'w')
	endif
endfunction

" WikiLink searches a wiki node and opens it if found.
function! WikiLink(name, split) abort
	let cmd = a:split ? 'split' : 'edit'
	let found = trim(system('wlnk ' . shellescape(a:name)))
	if empty(found)
		echohl ErrorMsg
		echo 'broken wiki link: ' . a:name
		echohl None
		return
	endif
	silent exe cmd fnameescape(found)
endfunction

function! Fts(query) abort
	call setqflist([], 'r', {
		\ 'title' : 'Fts ' . a:query,
		\ 'lines' : systemlist('fts ' . a:query . ' | cut -f 1,2'),
		\ 'efm': '%f	%m' })
	cwindow
endfunction

if exists('$DOTFILES')
	set rtp+=$DOTFILES/vim
	let $PATH=$DOTFILES . '/acme/bin:' . $PATH
	colorscheme basic
elseif isdirectory(expand('~/dotfiles'))
	set rtp+=~/dotfiles/vim
	let $PATH='~/dotfiles/acme/bin:' . $PATH
	colorscheme basic
endif

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
