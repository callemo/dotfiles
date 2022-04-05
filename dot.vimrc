set nocompatible

set autoindent
set autoread
set backspace=indent,eol,start
set cmdheight=2
set commentstring=#%s
set complete-=i
set completeopt-=preview
set confirm
set cursorline
set dictionary+=/usr/share/dict/words
set encoding=utf-8
set fillchars=vert:\ ,fold:-
set hidden
set history=1000
set hlsearch
set laststatus=2
set lazyredraw
set listchars=eol:$,tab:>\ ,space:.
set mouse=nvi
set nobackup
set noequalalways
set noexpandtab
set nofoldenable
set noswapfile
set notimeout
set nottimeout
set nowritebackup
set nrformats-=octal
set path=.,,
set sessionoptions-=options
set shiftwidth=4
set shortmess=atI
set showcmd
set softtabstop=4
set splitbelow
set splitright
set statusline=%n:%<%f\ %y%m%r%=[%{fnamemodify(getcwd(),':t')}]\ %-14.(%l,%c%V%)\ %P
set switchbuf=useopen,split
set tabstop=4
set textwidth=0
set updatetime=300
set viewoptions-=options
set visualbell
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.DS_Store
set wildmenu

let mapleader = ' '

if has('syntax') && has('eval')
	packadd! matchit
endif
if has('mouse_sgr')
	set ttymouse=sgr
endif
runtime! ftplugin/man.vim
if exists(':Man')
	set keywordprg=:Man
endif
filetype plugin on
syntax on

" GetVisualText() returns the text selected in visual mode.
function! GetVisualText() abort
	let reg = @"
	exe 'normal! vgvy'
	let text = @"
	let @" = reg
	return text
endfunction

" SetVisualSearch() literal search of the selected text in visual mode. Any
" regex special characters are escaped.
function! SetVisualSearch() abort
	let @/ = substitute('\m\C' . escape(GetVisualText(), '\.$*~'), "\n$", '', '')
endfunction

let g:cmd_async = 1
let g:cmd_async_tasks = {}

" Cmd() executes a command with an optional rage for input.
function! Cmd(range, line1, line2, cmd) abort
	if g:cmd_async && exists('*job_start')
		call StartAsyncCmd(a:range, a:line1, a:line2, a:cmd)
	else
		call RunShellCmd(a:range, a:line1, a:line2, a:cmd)
	endif
endfunction

" MakeTempBuffer() Creates a scratch buffer. Returns the buffer name.
function! MakeTempBuffer() abort
	let bufname = getcwd() . '/+Errors'
	if !bufexists(bufname)
		let bufnr = bufadd(bufname)
		call bufload(bufnr)
		call setbufvar(bufnr, '&buflisted', 1)
		call setbufvar(bufnr, '&buftype', 'nofile' )
		call setbufvar(bufnr, '&number', 0)
		call setbufvar(bufnr, '&swapfile', 0)
	endif
	return bufname
endfunction

" RunShellCmd() synchronously execute a command.
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

" StartAsyncCmd() asynchronously execute a command.
function! StartAsyncCmd(range, line1, line2, cmd) abort
	let bufname = MakeTempBuffer()
	let opts = { 'in_io': 'null', 'mode': 'raw',
		\ 'out_io': 'buffer', 'out_name': bufname, 'out_msg': 0,
		\ 'err_io': 'buffer', 'err_name': bufname, 'err_msg': 0,
		\ 'callback': 'CmdAsyncOutputHandler',
		\ 'close_cb': 'CmdAsyncCloseHandler',
		\ 'exit_cb': 'CmdAsyncExitHandler' }
	if a:range > 0
		let opts.in_io = 'buffer'
		let opts.in_buf = bufnr('%')
		let opts.in_top = a:line1
		let opts.in_bot = a:line2
	endif
	let job = job_start([&sh, &shcf, a:cmd], opts)
	let pid = job_info(job).process
	let name = split(a:cmd)[0]
	let g:cmd_async_tasks[pid] = { 'name': name, 'output': 0, 'exited': -1, 'closed': 0 }
endfunction

" CmdAsyncOutputHandler() job output handler.
function! CmdAsyncOutputHandler(channel, msg) abort
	let job = ch_getjob(a:channel)
	let pid = job_info(job).process
	let g:cmd_async_tasks[pid].output += 1
endfunction

" CmdAsyncCloseHandler() channel close handler.
function! CmdAsyncCloseHandler(channel) abort
	let job = ch_getjob(a:channel)
	let pid = job_info(job).process
	let g:cmd_async_tasks[pid].closed = 1

	if g:cmd_async_tasks[pid].exited != -1
		call CmdAsyncDone(job)
	endif
endfunction

" CmdAsyncExitHandler() job exit handler.
function! CmdAsyncExitHandler(job, code) abort
	let pid = job_info(a:job).process
	echom g:cmd_async_tasks[pid].name . ': exit ' . a:code
	let g:cmd_async_tasks[pid].exited = a:code

	if g:cmd_async_tasks[pid].closed
		call CmdAsyncDone(a:job)
	endif
endfunction

" CmdAsyncDone() cleans up after close and exit have finished.
function! CmdAsyncDone(job) abort
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

" UpdateCurrentWindow() appends texts to the active buffer and moves the
" cursor to the bottom.
function! UpdateCurrentWindow(text) abort
	if wordcount().bytes == 0
		call setline(1, a:text)
	else
		call append(line('$'), a:text)
	endif
	call cursor(line('$'), '.')
endfunction

" ExecVisualText() executes the selected visual text as the command.
function! ExecVisualText() abort
	call Cmd(0, 0, 0, escape(GetVisualText(), '%#'))
endfunction

" LintFile() runs a linter for the current file.
function! LintFile() abort
	let linters = {
				\ 'bash': 'shellcheck -f gcc',
				\ 'css': 'stylelint',
				\ 'perl': 'perlcritic',
				\ 'python': 'pylint -s n',
				\ 'scss': 'stylelint',
				\ 'sh': 'shellcheck -f gcc',
				\ }
	let cmd = get(linters, &filetype, v:null)
	if cmd == v:null
		echohl ErrorMsg | echo 'No linter for ' . &filetype | echohl None
		return
	endif
	update
	call Cmd(0, 0, 0, cmd . ' ' . expand('%:S'))
	checktime
endfunction

" FormatFile() runs a formatter for the current file.
function! FormatFile(...) abort
	let fallback = 'prettier --write'
	let formatters = {
				\ 'c': 'clang-format -i',
				\ 'cpp': 'clang-format -i',
				\ 'go': 'gofmt -w',
				\ 'java': 'clang-format -i',
				\ 'perl': 'perltidy -b -bext /',
				\ 'python': 'black -q',
				\ }
	let cmd = a:0 > 0 ? a:1 : get(formatters, &filetype, fallback)
	update
	call Cmd(0, 0, 0, cmd . ' ' . expand('%:S'))
	checktime
endfunction

" Send() types the current line or range to a terminal buffer as it was typed
" by the user.
function! Send(range, start, end, ...) abort
	if a:0 > 0
		let buf = a:1
	elseif exists('w:send_terminal_buf')
		let buf = w:send_terminal_buf
	else
		echohl ErrorMsg | echo 'No terminal link' | echohl None
		return
	endif
	let keys = join(getline(a:start, a:end), "\n")
	call term_sendkeys(buf, keys)
	if a:range
		call term_sendkeys(buf, "\n")
	endif
	let w:send_terminal_buf = buf
endfunction

" TrimTrailingBlanks() remove tailing consecutive blanks.
function! TrimTrailingBlanks() abort
	let last_pos = getcurpos()
	let last_search = @/
	silent! %s/\m\C\s\+$//e
	let @/ = last_search
	call setpos('.', last_pos)
endfunction

function! Bx(regexp, command) abort
	let prev = bufnr('%')
	for b in getbufinfo({'buflisted': 1})
		if b.name =~# a:regexp
			exe 'buffer' b.bufnr
			exe a:command
		endif
	endfor
	exe buflisted(prev) ? 'buffer ' . prev : 'bfirst'
endfunction

augroup dotfiles
	autocmd!
	autocmd BufReadPost * exe 'silent! norm! g''"'
	autocmd BufWinEnter * if &bt ==# 'quickfix' || &pvw | set nowfh | endif
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
augroup END

command! -nargs=+ -complete=file -range
	\ Cmd call Cmd(<range>, <line1>, <line2>, <q-args>)

command!          Lint call LintFile()
command! -nargs=? Fmt call FormatFile(<f-args>)
command!          Trim call TrimTrailingBlanks()
command! -nargs=+ Bx call Bx(<f-args>)

if has('terminal')
	command! -nargs=? -range Send call Send(<range>, <line1>, <line2>, <args>)
endif

nnoremap <c-w>+ :exe 'resize' (winheight(0) * 3/2)<cr>
nmap <down> <c-d>
nmap <up> <c-u>

nnoremap <c-l>        :nohlsearch \| diffupdate \| syntax sync fromstart<cr><c-l>
nnoremap <leader>!    :Cmd<space>
nnoremap <leader>.    :lcd %:p:h<cr>
nnoremap <leader><cr> :Send<cr>
nnoremap <leader>B    :NERDTreeToggle<cr>
nnoremap <leader>F    :Fmt<cr>
nnoremap <leader>L    :Lint<cr>
nnoremap <leader>b    :buffers<cr>
nnoremap <leader>e    :edit <c-r>=expand('%:h')<cr>/
nnoremap <leader>f    :let @"=expand('%:p') \| let @*=@"<cr>
nnoremap <leader>gf   :edit <cfile><cr>
nnoremap <leader>p    "*p
nnoremap <leader>r    :registers<cr>
nnoremap <leader>y    "*y

if has('macunix')
	nnoremap <silent> gx :call Cmd(0, 0, 0, 'open ' . expand('<cfile>'))<cr>
elseif has('unix')
	nnoremap <silent> gx :call Cmd(0, 0, 0, 'xdg-open ' . expand('<cfile>'))<cr>
endif

if !empty($TMUX)
	nnoremap <expr> <silent> <c-j> winnr() == winnr('$') ? ':silent !tmux selectp -t :.+<cr>' : ':wincmd w<cr>'
	nnoremap <expr> <silent> <c-k> winnr() == 1 ? ':silent !tmux selectp -t :.-<cr>' : ':wincmd W<cr>'
else
	nnoremap <silent> <c-j> :wincmd w<cr>
	nnoremap <silent> <c-k> :wincmd W<cr>
endif

nnoremap ]a :next<cr>
nnoremap [a :previous<cr>
nnoremap ]b :bnext<cr>
nnoremap [b :bprevious<cr>
nnoremap ]l :lnext<cr>
nnoremap [l :lprevious<cr>
nnoremap ]q :cnext<cr>
nnoremap [q :cprevious<cr>
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprevious<cr>
nnoremap yob :set background=<c-r>=&background == 'light' ? 'dark' : 'light'<cr><cr>
nnoremap yoc :setl invcursorline<cr>
nnoremap yoh :setl invhlsearch<cr>
nnoremap yol :setl invlist<cr>
nnoremap yon :setl invnumber<cr>
nnoremap yop :setl invpaste<cr>
nnoremap yor :setl invrelativenumber<cr>
nnoremap yos :setl invspell<cr>
nnoremap yow :setl invwrap<cr>
vnoremap * :call SetVisualSearch()<cr>/<cr>
vnoremap <leader>! :<c-u>call ExecVisualText()<cr>
vnoremap <leader><cr> :Send<cr>
vnoremap <leader>p "*p
vnoremap <leader>x "*x
vnoremap <leader>y "*y
inoremap <c-a> <home>
inoremap <c-e> <end>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-n> <down>
cnoremap <c-p> <up>

if has('terminal')
	tnoremap <c-r><c-r> <c-r>
	tnoremap <c-w>+ <c-w>:exe 'resize' (winheight(0) * 3/2)<cr>
	tnoremap <c-w><c-w> <c-w>.
	tnoremap <c-w>[ <c-\><c-n>
	tnoremap <scrollwheelup> <c-\><c-n>
	tnoremap <expr> <c-r> '<c-w>"' . nr2char(getchar())
	if !empty($TMUX)
		tnoremap <expr> <silent> <c-j> winnr() == winnr('$') ?
					\ '<c-w>:silent !tmux selectp -t :.+<cr>' : '<c-w>:wincmd w<cr>'
		tnoremap <expr> <silent> <c-k> winnr() == 1 ?
					\ '<c-w>:silent !tmux selectp -t :.-<cr>' : '<c-w>:wincmd W<cr>'
	else
		tnoremap <silent> <c-j> <c-w>:wincmd w<cr>
		tnoremap <silent> <c-k> <c-w>:wincmd W<cr>
	endif
endif

nnoremap <c-leftmouse> <leftmouse>gF
nnoremap <c-rightmouse> <c-o>
nnoremap <middlemouse> <leftmouse>:Cmd <c-r><c-w><cr>
nnoremap <rightmouse> <leftmouse>*
nmap <c-a-leftmouse> <middlemouse>
vmap <c-a-leftmouse> <leader>!
vmap <middlemouse> <leader>!
vmap <rightmouse> *

let g:loaded_netrw = 1 " disable netrw
let g:loaded_netrwPlugin = 1
let NERDTreeDirArrowCollapsible='-'
let NERDTreeDirArrowExpandable='+'
let NERDTreeShowHidden=1

if exists('$DOTFILES')
	set rtp+=$DOTFILES/vim
	colorscheme basic
elseif isdirectory(expand('~/dotfiles'))
	set rtp+=~/dotfiles/vim
	colorscheme basic
endif

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
