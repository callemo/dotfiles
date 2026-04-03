vim9script

# CmdDone handles job completion: show +Errors if output or failure.
def CmdDone(job: job, code: number, name: string)
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

# Cmd executes a command asynchronously via /bin/sh -c, output to +Errors.
# Matches Acme's model: no-range runs cmd with no stdin; range pipes buffer lines.
export def Cmd(cmd: string, range: number, line1: number, line2: number)
	var bufname = view#Scratch('/+Errors')
	var text = empty(cmd) ? expand('<cWORD>') : cmd
	var prog = ['/bin/sh', '-c', text]
	var opts = {
		'mode': 'raw',
		'out_io': 'buffer', 'out_name': bufname, 'out_msg': 0,
		'err_io': 'buffer', 'err_name': bufname, 'err_msg': 0,
		'exit_cb': (job, code) => CmdDone(job, code, text),
		'timeout': 300000,
		'stoponexit': 'term'
		}
	opts.cwd = expand('%:p:h')
	if range > 0
		opts.in_io = 'buffer'
		opts.in_buf = bufnr('%')
		opts.in_top = line1
		opts.in_bot = line2
	else
		opts.in_io = 'null'
	endif
	job_start(prog, opts)
enddef

# Yank copies text to clipboard via OSC 52.
export def Yank(text: string)
	var encoded = system('printf %s ' .. shellescape(text) .. ' | base64 | tr -d "\n"')
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
	Cmd(cmd .. ' ' .. expand('%:S'), 0, 0, 0)
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
		? 'prettier --stdin-filepath ' .. expand('%:S') .. ' --log-level warn'
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
	Cmd(cmd .. ' ' .. expand('%:S'), 0, 0, 0)
	checktime
enddef

# Rg executes the ripgrep program loading its results on the location list.
export def Rg(args: string)
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

# Toc populates the location list with lines matching pat (default: markdown headings).
export def Toc(pat: string = '^#\+\s')
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
export def Fts(query: string)
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
