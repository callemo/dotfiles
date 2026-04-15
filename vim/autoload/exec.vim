vim9script

var running: list<job> = []
var base64cmd = executable('base64') ? 'base64'
	: executable('openssl') ? 'openssl base64'
	: executable('python3') ? "python3 -c 'import base64,sys;print(base64.b64encode(sys.stdin.buffer.read()).decode(),end=\"\")'"
	: ''

# Jobs returns the program names of currently running Cmd jobs.
export def Jobs(): string
	return join(map(copy(running),
		(_, j) => fnamemodify(split(job_info(j).cmd[2])[0], ':t')), ' ')
enddef

# CmdClose fires after all out_cb/err_cb calls complete: show +Errors if needed.
def CmdClose(ch: channel, name: string, bnr: number, wrote: list<bool>)
	var j = ch_getjob(ch)
	var code = job_info(j).exitval
	filter(running, (_, r) => r != j)
	redrawtabline
	if wrote[0] || code > 0
		# trim leading blank line left by bufload seed
		if getbufline(bnr, 1) == ['']
			deletebufline(bnr, 1)
		endif
		exe 'sbuffer' bnr
		if code > 0
			append(line('$'), name .. ': exit ' .. code)
		endif
		cursor(line('$'), 1)
		exe 'resize' min([max([3, line('$')]), &lines / 2])
	endif
enddef

# Cmd executes a command asynchronously via /bin/sh -c, output to +Errors.
# Matches Acme's model: no address runs cmd with no stdin; address pipes addressed lines.
export def Cmd(cmd: string, addr: number, line1: number, line2: number)
	var dir = expand('%:p:h')
	var bufname = view#Scratch(dir .. '/+Errors')
	var text = empty(cmd) ? expand('<cWORD>') : cmd
	if empty(text)
		return
	endif
	var bnr = bufnr(bufname)
	bufload(bnr)
	var wrote = [false]  # list to allow mutation from lambda (vim9 captures by value)
	var Append = (ch: channel, data: string) => {
		wrote[0] = true
		appendbufline(bnr, '$', split(data, "\n", 1))
	}
	var prog = ['/bin/sh', '-c', text]
	var opts = {
		'out_cb': Append,
		'err_cb': Append,
		'close_cb': (ch) => CmdClose(ch, text, bnr, wrote),
		'cwd': dir,
		'stoponexit': 'term'
		}
	if addr > 0
		opts.in_io = 'buffer'
		opts.in_buf = bufnr('%')
		opts.in_top = line1
		opts.in_bot = line2
	else
		opts.in_io = 'null'
	endif
	add(running, job_start(prog, opts))
	redrawtabline
enddef

# Yank copies text to clipboard via OSC 52.
export def Yank(text: string)
	if empty(base64cmd)
		g:Err('no base64 encoder found')
		return
	endif
	var encoded = substitute(system(base64cmd, text), '\n', '', 'g')
	if v:shell_error != 0
		g:Err('base64 failed: ' .. base64cmd .. ' (exit ' .. v:shell_error .. ')')
		return
	endif
	var osc = "\e]52;c;" .. encoded .. "\x07"
	writefile([osc], '/dev/tty', 'b')
enddef

var linters = {
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

# Lint runs a linter for the current file.
export def Lint(ft: string = &filetype)
	var cmd = get(linters, ft, v:null)
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
	Cmd(cmd .. ' ' .. shellescape(expand('%:t')), 0, 0, 0)
	checktime
enddef

var formatters = {
	'c':      ['clang-format -i', 'clang-format'],
	'cpp':    ['clang-format -i', 'clang-format'],
	'go':     ['goimports -w',    'goimports'],
	'java':   ['clang-format -i', 'clang-format'],
	'perl':   ['perltidy -b -bext /', 'perltidy'],
	'python': ['black -q',        'black -q -'],
	}

# Fmt runs a formatter for the current file.
export def Fmt(line1: number, line2: number, ft: string = &filetype)
	var sel = line1 != 1 || line2 != line('$')
	var pfx = sel
		? 'prettier --stdin-filepath ' .. shellescape(expand('%:p')) .. ' --log-level warn'
		: 'prettier --write --log-level warn'
	var pair = get(formatters, ft, [])
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
	Cmd(cmd .. ' ' .. shellescape(expand('%:t')), 0, 0, 0)
	checktime
enddef

# Fts runs fts and populates the location list.
export def Fts(query: string)
	if !executable('fts')
		g:Err('fts not found')
		return
	endif
	setloclist(0, [], 'r', {
		'title': 'Fts ' .. query,
		'lines': systemlist('fts ' .. shellescape(query) .. ' | cut -f 1,2'),
		'efm': '%f	%m'})
	exe 'lwindow' min([max([3, len(getloclist(0))]), &lines / 2])
enddef

# SendToTmux sends lines to a tmux pane.
export def Tmux(line1: number, line2: number, target: string)
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

# ── Dump/Load ────────────────────────────────────────────
# Acme-style session dump/load.
# Format: header + per-tab + per-window records.
# Record types:
#   t<N> [<height>...]                                tab (heights optional)
#   f<tab> <win> <bufnr> <line> <col> <path>       clean file
#   F<tab> <win> <bufnr> <line> <col> <nlines> <path>  dirty (content follows)
#   s<tab> <win> <bufnr> <line> <col> <nlines> <path>  scratch (nofile, content follows)
#   x<tab> <win> <ref>   <line> <col>               zerox
#   d<tab> <win> <path>                             directory

# Dump saves the current state to file (default: $PWD/vim.dump).
export def Dump(file: string = '')
	var path = empty(file) ? getcwd() .. '/vim.dump' : fnamemodify(file, ':p')
	var tmp = tempname()

	var lines: list<string> = []

	# Header: working directory, active tab
	add(lines, getcwd())
	add(lines, string(tabpagenr()))

	# Track dumped buffers for zerox detection (Acme dumpid pattern)
	var dumped: list<number> = []

	for ti in range(1, tabpagenr('$'))
		var wins = tabpagebuflist(ti)
		if empty(wins)
			continue
		endif

		var tline_idx = len(lines)
		add(lines, 't' .. ti)
		var heights: list<number> = []

		for wi in range(1, len(wins))
			var w = win_getid(wi, ti)
			var info = getwininfo(w)[0]
			var bnr = info.bufnr
			var bt = getbufvar(bnr, '&buftype')
			var ft = getbufvar(bnr, '&filetype')

			# Skip special buffers (quickfix, help, terminal)
			if bt =~# 'quickfix\|help\|terminal'
				continue
			endif

			var lnum = line('.', w)
			var cnum = col('.', w)

			# Directory buffer (must have b:dir set by view#Dir)
			if ft ==# 'dir'
				var dpath = getbufvar(bnr, 'dir', '')
				if !empty(dpath)
					add(lines, 'd' .. ti .. "\t" .. wi .. "\t" .. dpath)
					add(heights, info.height)
					continue
				endif
				# ft=dir but no b:dir — fall through to file handling
			endif

			var bname = bufname(bnr)
			var fpath = empty(bname) ? '' : fnamemodify(bname, ':p')

			# Empty unnamed buffer — skip
			if empty(fpath) && !getbufvar(bnr, '&modified') && getbufline(bnr, 1, '$') == ['']
				continue
			endif

			# Zerox: buffer already dumped, this is a second window
			if index(dumped, bnr) >= 0
				add(lines, 'x' .. ti .. "\t" .. wi .. "\t" .. bnr .. "\t" .. lnum .. "\t" .. cnum)
				add(heights, info.height)
				continue
			endif

			add(dumped, bnr)

			# s: scratch buffer (nofile) — embed content
			if bt ==# 'nofile'
				var content = getbufline(bnr, 1, '$')
				add(lines, 's' .. ti .. "\t" .. wi .. "\t" .. bnr .. "\t" .. lnum .. "\t" .. cnum .. "\t" .. len(content) .. "\t" .. fpath)
				extend(lines, content)
			elseif !getbufvar(bnr, '&modified') && !empty(fpath) && filereadable(fpath)
				# f: clean file on disk
				add(lines, 'f' .. ti .. "\t" .. wi .. "\t" .. bnr .. "\t" .. lnum .. "\t" .. cnum .. "\t" .. fpath)
			else
				# F: dirty or new file — embed content
				var content = getbufline(bnr, 1, '$')
				add(lines, 'F' .. ti .. "\t" .. wi .. "\t" .. bnr .. "\t" .. lnum .. "\t" .. cnum .. "\t" .. len(content) .. "\t" .. fpath)
				extend(lines, content)
			endif
			add(heights, info.height)
		endfor

		# Update t record with window heights
		if !empty(heights)
			lines[tline_idx] = 't' .. ti .. "\t" .. join(map(copy(heights), (_, v) => string(v)), "\t")
		endif
	endfor

	# Atomic write via tempfile + rename (Acme pattern)
	writefile(lines, tmp)
	if rename(tmp, path) != 0
		g:Err('Dump: rename failed')
		delete(tmp)
		return
	endif
	echo 'Dumped to ' .. fnamemodify(path, ':~')
enddef

# Load restores state from file (default: $PWD/vim.dump).
export def Load(file: string = '')
	var path = empty(file) ? getcwd() .. '/vim.dump' : fnamemodify(file, ':p')
	if !filereadable(path)
		g:Err('Load: file not found: ' .. path)
		return
	endif

	var lines = readfile(path)
	if len(lines) < 2
		g:Err('Load: invalid dump file')
		return
	endif

	var idx = 0
	var wdir = lines[idx]
	idx += 1
	var activetab = str2nr(lines[idx])
	idx += 1

	# Change to saved working directory
	if isdirectory(wdir)
		noautocmd execute 'cd' fnameescape(wdir)
	endif

	# Map old bufnr → new bufnr for zerox references
	var bufmap: dict<number> = {}

	# Close all windows except one (clean slate)
	silent! noautocmd tabonly!
	silent! noautocmd only!
	noautocmd enew!

	var curtab = 1
	var firstwin = true
	var tabwins: list<number> = []
	var tabheights: list<string> = []

	while idx < len(lines)
		var line = lines[idx]
		idx += 1

		var rectype = line[0]
		var parts = split(line[1 :], "\t")

		if rectype ==# 't'
			# Apply pending heights from previous tab
			for i in range(min([len(tabheights), len(tabwins)]))
				var h = str2nr(tabheights[i])
				if h > 0
					win_execute(tabwins[i], 'resize ' .. h)
				endif
			endfor
			tabwins = []
			tabheights = len(parts) > 1 ? parts[1 :] : []
			var tn = str2nr(parts[0])
			if tn > curtab
				noautocmd tabnew
				curtab = tn
			endif
			firstwin = true
			continue
		endif

		# All window records: split unless first window
		if !firstwin
			noautocmd split
		endif
		firstwin = false

		if rectype ==# 'f'
			# f<tab> <win> <bufnr> <line> <col> <path>
			var oldbnr = str2nr(parts[2])
			var lnum = str2nr(parts[3])
			var cnum = str2nr(parts[4])
			var fpath = parts[5]

			if filereadable(fpath)
				silent execute 'edit' fnameescape(fpath)
			else
				noautocmd enew
				silent execute 'file' fnameescape(fpath)
			endif
			bufmap[string(oldbnr)] = bufnr()
			cursor(lnum, cnum)

		elseif rectype ==# 'F'
			# F<tab> <win> <bufnr> <line> <col> <nlines> <path>
			var oldbnr = str2nr(parts[2])
			var lnum = str2nr(parts[3])
			var cnum = str2nr(parts[4])
			var nlines = str2nr(parts[5])
			var fpath = len(parts) > 6 ? parts[6] : ''

			# Read embedded content
			var content: list<string> = []
			for _ in range(nlines)
				if idx < len(lines)
					add(content, lines[idx])
					idx += 1
				endif
			endfor

			if !empty(fpath)
				silent execute 'edit' fnameescape(fpath)
			else
				noautocmd enew
			endif
			bufmap[string(oldbnr)] = bufnr()

			silent! :%delete _
			setline(1, content)
			setlocal modified
			cursor(lnum, cnum)

		elseif rectype ==# 'x'
			# x<tab> <win> <ref> <line> <col>
			var refbnr = str2nr(parts[2])
			var lnum = str2nr(parts[3])
			var cnum = str2nr(parts[4])

			var newbnr = get(bufmap, string(refbnr), -1)
			if newbnr > 0
				silent execute 'buffer' newbnr
			endif
			cursor(lnum, cnum)

		elseif rectype ==# 'd'
			# d<tab> <win> <path>
			var dpath = parts[2]
			noautocmd enew
			call view#Dir(dpath, true)

		elseif rectype ==# 's'
			# s<tab> <win> <bufnr> <line> <col> <nlines> <path>
			var lnum = str2nr(parts[3])
			var cnum = str2nr(parts[4])
			var nlines = str2nr(parts[5])
			var fpath = len(parts) > 6 ? parts[6] : ''

			var content: list<string> = []
			for _ in range(nlines)
				if idx < len(lines)
					add(content, lines[idx])
					idx += 1
				endif
			endfor

			exe 'buffer' view#Scratch(fpath)
			silent! :%delete _
			setline(1, content)
			setlocal nomodified
			cursor(lnum, cnum)
		endif

		add(tabwins, win_getid())
	endwhile

	# Apply heights for last tab
	for i in range(min([len(tabheights), len(tabwins)]))
		var h = str2nr(tabheights[i])
		if h > 0
			win_execute(tabwins[i], 'resize ' .. h)
		endif
	endfor

	# Restore active tab
	if activetab > 0 && activetab <= tabpagenr('$')
		silent execute 'tabnext' activetab
	endif
enddef
