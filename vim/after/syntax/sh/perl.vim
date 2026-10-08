let s:syntax = b:current_syntax
let s:isk = trim(execute('syntax iskeyword'))
unlet b:current_syntax
let b:basic_perl_include = 1
syntax include @shPerlScript syntax/perl.vim
unlet b:basic_perl_include
" :syntax include ignores clears; replace shared groups only after it returns.
syntax clear perlQR perlSpecialString perlSpecialStringU perlSpecialStringU2
syntax clear perlParensSQ perlBracketsSQ perlBracesSQ perlAnglesSQ
syntax clear perlParensDQ perlBracketsDQ perlBracesDQ perlAnglesDQ
let b:basic_perl_shell = 1
execute 'syntax include @shPerlScript ' . fnameescape(expand('<sfile>:p:h:h') . '/perl.vim')
unlet b:basic_perl_shell
execute s:isk ==# 'syntax iskeyword not set' ? 'syntax iskeyword clear' : s:isk
syntax sync fromstart
syntax clear perlPOD
let s:fold = get(g:, 'perl_fold', 1) ? ' fold' : ''
let s:pod = get(g:, 'perl_include_pod', 1) ? ' contains=@Pod,@Spell,perlTodo' : ''
execute 'syntax region perlPOD contained start=+^=[a-z]+ end=+^=cut+' .
	\ " end=+'\\@=+ keepend" . s:fold . s:pod
if get(g:, 'perl_include_pod', 1)
	execute 'syntax region perlPOD contained start=+^=cut+ end=+^=cut+' .
		\ " end=+'\\@=+ keepend contains=perlTodo" . s:fold
	syntax clear podBeginComment
	let s:pod = exists('g:perl_pod_no_comment_fold') ? '' : ',podTodo fold'
	execute 'syntax region podBeginComment contained start=+^=begin\s\+comment\s*$+ end=+^=end\s\+comment\ze\s*$+' .
		\ " end=+'\\@=+ keepend contains=podCommand" . s:pod
endif
unlet s:fold s:pod
" Keyword boundaries retain Perl ':' but not the shell's '-'.
syntax clear perlConditional perlRepeat perlOperator perlControl
syntax clear perlStatementStorage perlStatementControl perlStatementScalar perlStatementRegexp perlStatementNumeric
syntax clear perlStatementList perlStatementHash perlStatementIOfunc perlStatementFiledesc perlStatementVector perlStatementFiles
syntax clear perlStatementFlow perlStatementInclude perlStatementProc perlStatementSocket perlStatementIPC
syntax clear perlStatementNetwork perlStatementPword perlStatementTime perlStatementMisc perlNumber perlFloat
syntax match perlConditional contained "\%(\i\|:\)\@<!\%(if\|elsif\|unless\|given\|when\|default\)\%(\i\|:\)\@!"
syntax match perlConditional contained "\%(\i\|:\)\@<!else\%(\%(\_s\*if\%(\i\|:\)\@!\)\|\%(\i\|:\)\@!\)" contains=perlElseIfError skipwhite skipnl skipempty
syntax match perlRepeat contained "\%(\i\|:\)\@<!\%(while\|for\%(each\)\=\|do\|until\|continue\)\%(\i\|:\)\@!"
syntax match perlOperator contained "\%(\i\|:\)\@<!\%(defined\|undef\|eq\|ne\|[gl][et]\|cmp\|not\|and\|or\|xor\|not\|bless\|ref\|do\)\%(\i\|:\)\@!"
syntax match perlControl contained "\%(\i\|:\)\@<!\%(BEGIN\|CHECK\|INIT\|END\|UNITCHECK\)\%(\i\|:\)\@!\_s*" nextgroup=perlFakeGroup
syntax match perlStatementStorage contained "\%(\i\|:\)\@<!\%(my\|our\|local\|state\)\%(\i\|:\)\@!"
syntax match perlStatementControl contained "\%(\i\|:\)\@<!\%(return\|last\|next\|redo\|goto\|break\)\%(\i\|:\)\@!"
syntax match perlStatementScalar contained "\%(\i\|:\)\@<!\%(chom\=p\|chr\|crypt\|r\=index\|lc\%(first\)\=\|length\|ord\|pack\|sprintf\|substr\|fc\|uc\%(first\)\=\)\%(\i\|:\)\@!"
syntax match perlStatementRegexp contained "\%(\i\|:\)\@<!\%(pos\|quotemeta\|split\|study\)\%(\i\|:\)\@!"
syntax match perlStatementNumeric contained "\%(\i\|:\)\@<!\%(abs\|atan2\|cos\|exp\|hex\|int\|log\|oct\|rand\|sin\|sqrt\|srand\)\%(\i\|:\)\@!"
syntax match perlStatementList contained "\%(\i\|:\)\@<!\%(splice\|unshift\|shift\|push\|pop\|join\|reverse\|grep\|map\|sort\|unpack\)\%(\i\|:\)\@!"
syntax match perlStatementHash contained "\%(\i\|:\)\@<!\%(delete\|each\|exists\|keys\|values\)\%(\i\|:\)\@!"
syntax match perlStatementIOfunc contained "\%(\i\|:\)\@<!\%(syscall\|dbmopen\|dbmclose\)\%(\i\|:\)\@!"
syntax match perlStatementFiledesc contained "\%(\i\|:\)\@<!\%(binmode\|close\%(dir\)\=\|eof\|fileno\|getc\|lstat\|printf\=\|read\%(dir\|line\|pipe\)\|rewinddir\|say\|select\|stat\|tell\%(dir\)\=\|write\)\%(\i\|:\)\@!" nextgroup=perlFiledescStatementNocomma skipwhite
syntax match perlStatementFiledesc contained "\%(\i\|:\)\@<!\%(fcntl\|flock\|ioctl\|open\%(dir\)\=\|read\|seek\%(dir\)\=\|sys\%(open\|read\|seek\|write\)\|truncate\)\%(\i\|:\)\@!" nextgroup=perlFiledescStatementComma skipwhite
syntax match perlStatementVector contained "\%(\i\|:\)\@<!vec\%(\i\|:\)\@!"
syntax match perlStatementFiles contained "\%(\i\|:\)\@<!\%(ch\%(dir\|mod\|own\|root\)\|glob\|link\|mkdir\|readlink\|rename\|rmdir\|symlink\|umask\|unlink\|utime\)\%(\i\|:\)\@!"
syntax match perlStatementFiles contained "-[rwxoRWXOezsfdlpSbctugkTBMAC]\%(\i\|:\)\@!"
syntax match perlStatementFlow contained "\%(\i\|:\)\@<!\%(caller\|die\|dump\|eval\|exit\|wantarray\|evalbytes\)\%(\i\|:\)\@!"
syntax match perlStatementInclude contained "\%(\i\|:\)\@<!\%(require\|import\|unimport\)\%(\i\|:\)\@!"
syntax match perlStatementInclude contained "\%(\i\|:\)\@<!\%(use\|no\)\s\+\%(\%(attributes\|attrs\|autodie\%(::\%(exception\%(::system\)\=\|hints\|skip\)\)\=\|autouse\|parent\|base\|big\%(int\|num\|rat\)\|blib\|bytes\|charnames\|constant\|deprecate\|diagnostics\|encoding\%(::warnings\)\=\|experimental\|feature\|fields\|filetest\|if\|integer\|less\|lib\|locale\|mro\|ok\|open\|ops\|overload\|overloading\|re\|sigtrap\|sort\|strict\|subs\|threads\%(::shared\)\=\|utf8\|vars\|version\|vmsish\|warnings\%(::register\)\=\)\%(\i\|:\)\@!\)\="
syntax match perlStatementProc contained "\%(\i\|:\)\@<!\%(alarm\|exec\|fork\|get\%(pgrp\|ppid\|priority\)\|kill\|pipe\|set\%(pgrp\|priority\)\|sleep\|system\|times\|wait\%(pid\)\=\)\%(\i\|:\)\@!"
syntax match perlStatementSocket contained "\%(\i\|:\)\@<!\%(accept\|bind\|connect\|get\%(peername\|sock\%(name\|opt\)\)\|listen\|recv\|send\|setsockopt\|shutdown\|socket\%(pair\)\=\)\%(\i\|:\)\@!"
syntax match perlStatementIPC contained "\%(\i\|:\)\@<!\%(msg\%(ctl\|get\|rcv\|snd\)\|sem\%(ctl\|get\|op\)\|shm\%(ctl\|get\|read\|write\)\)\%(\i\|:\)\@!"
syntax match perlStatementNetwork contained "\%(\i\|:\)\@<!\%(\%(end\|[gs]et\)\%(host\|net\|proto\|serv\)ent\|get\%(\%(host\|net\)by\%(addr\|name\)\|protoby\%(name\|number\)\|servby\%(name\|port\)\)\)\%(\i\|:\)\@!"
syntax match perlStatementPword contained "\%(\i\|:\)\@<!\%(get\%(pw\%(uid\|nam\)\|gr\%(gid\|nam\)\|login\)\)\|\%(end\|[gs]et\)\%(pw\|gr\)ent\%(\i\|:\)\@!"
syntax match perlStatementTime contained "\%(\i\|:\)\@<!\%(gmtime\|localtime\|time\)\%(\i\|:\)\@!"
syntax match perlStatementMisc contained "\%(\i\|:\)\@<!\%(warn\|format\|formline\|reset\|scalar\|prototype\|lock\|tied\=\|untie\)\%(\i\|:\)\@!"
syntax case ignore
syntax match perlNumber contained "\i\@<!\%(0\|[1-9]\%(_\=\d\)*\)\i\@!"
syntax match perlNumber contained "\i\@<!0\%(x\x\%(_\=\x\)*\|b[01]\%(_\=[01]\)*\|o\=\%(_\=\o\)*\)\i\@!"
syntax match perlFloat contained "\i\@<!\d\%(_\=\d\)*e[-+]\=\d\%(_\=\d\)*"
syntax match perlFloat contained "\i\@<!\d\%(_\=\d\)*\.\%(\d\%(_\=\d\)*\)\=\%(e[-+]\=\d\%(_\=\d\)*\)\="
syntax match perlFloat contained "\.\d\%(_\=\d\)*\%(e[-+]\=\d\%(_\=\d\)*\)\="
syntax match perlFloat contained "\i\@<!0x\x\%(_\=\x\)*p[-+]\=\d\%(_\=\d\)*"
syntax match perlFloat contained "\i\@<!0x\x\%(_\=\x\)*\.\%(\x\%(_\=\x\)*\)\=\%(p[-+]\=\d\%(_\=\d\)*\)\="
syntax match perlFloat contained "\i\@<!0x\.\x\%(_\=\x\)*\%(p[-+]\=\d\%(_\=\d\)*\)\="
syntax case match
" Shell quotes end the program even inside a Perl comment or unfinished string.
syntax clear perlStringUnexpanded
syntax match perlComment contained "#[^']*" contains=perlTodo,@Spell
syntax match perlSpecialMatch contained "\[[]-]\=[^\[\]']*'\@=" extend
syntax region perlString contained matchgroup=perlStringStartEnd start=+"+ end=+"+ end=+'\@=+ contains=@perlInterpDQ keepend
syntax region perlBraces contained transparent start=+{+ end=+}+ end=+'\@=+ keepend extend
if !get(g:, 'perl_no_extended_vars', 0)
	syntax region perlVarBlock contained matchgroup=perlVarPlain start="\%($#\|[$@]\)\$*{" skip="\\}" end=+}\|\%(\%(<<\%('\|"\)\?\)\@=\)+ end=+'\@=+ contains=@perlExpr nextgroup=perlVarMember,perlVarSimpleMember,perlPostDeref keepend extend
	syntax region perlVarBlock2 contained matchgroup=perlVarPlain start="[%&*]\$*{" skip="\\}" end=+}\|\%(\%(<<\%('\|"\)\?\)\@=\)+ end=+'\@=+ contains=@perlExpr nextgroup=perlVarMember,perlVarSimpleMember,perlPostDeref keepend extend
	syntax region perlVarMember contained matchgroup=perlVarPlain start="\%(->\)\={" skip="\\}" end=+}+ end=+'\@=+ contains=@perlExpr nextgroup=perlVarMember,perlVarSimpleMember,perlPostDeref keepend extend
	syntax region perlVarMember contained matchgroup=perlVarPlain start="\%(->\)\=\[" skip="\\]" end=+\]+ end=+'\@=+ contains=@perlExpr nextgroup=perlVarMember,perlVarSimpleMember,perlPostDeref keepend extend
	syntax region perlPostDeref contained matchgroup=perlPostDeref start="->\%($#\|[$@%&*]\){" skip="\\}" end=+}+ end=+'\@=+ contains=@perlExpr nextgroup=perlVarSimpleMember,perlVarMember,perlPostDeref keepend extend
	syntax match perlVarSimpleMember "\%(->\)\={\s*\I\i*\s*}" nextgroup=perlVarMember,perlVarSimpleMember,perlPostDeref contains=perlVarSimpleMemberName contained extend
endif
" Quote-like operators also need Perl boundaries, including after the shell opener.
syntax clear perlMatch perlQR perlQ perlQQ perlQW perlSubstitutionGQQ perlSubstitutionSQ
for [s:group, s:op, s:quotes, s:interp, s:nesting, s:next] in [
	\ ['perlMatch', 'm', 'perlMatchStartEnd', '@perlInterpMatch', 'DQ', 'nextgroup=perlMatchModifiers'],
	\ ['perlMatch', 's', 'perlMatchStartEnd', '@perlInterpMatch', 'DQ', 'nextgroup=perlSubstitutionGQQ skipwhite skipempty skipnl'],
	\ ['perlMatch', '\%(tr\|y\)', 'perlMatchStartEnd', '@perlInterpSQ', 'SQ', 'nextgroup=perlTranslationGQ skipwhite skipempty skipnl'],
	\ ['perlQR', 'qr', 'perlMatchStartEnd', '@perlInterpMatch', 'DQ', 'nextgroup=perlQRModifiers'],
	\ ['perlQ', 'q', 'perlStringStartEnd', '@perlInterpSQ', 'SQ', ''],
	\ ['perlQQ', 'q[qx]', 'perlStringStartEnd', '@perlInterpDQ', 'DQ', ''],
	\ ['perlQW', 'qw', 'perlStringStartEnd', '@perlInterpSQ', 'SQ', ''],
	\ ['perlSubstitutionGQQ', '', 'perlMatchStartEnd', '@perlInterpDQ', 'DQ', 'nextgroup=perlSubstitutionModifiers']]
	for [s:open, s:close, s:nest] in [
		\ ['\z([^[:space:]#([{<''/]\)', '\z1', ''],
		\ ['/', '/', ''], ['#', '#', ''],
		\ ['(', ')', 'perlParens'], ['{', '}', 'perlBraces'],
		\ ['<', '>', 'perlAngles'], ['\[', '\]', 'perlBrackets']]
		let s:inner = s:interp ==# '@perlInterpMatch' && s:open ==# '/' ? '@perlInterpSlash' : s:interp
		if s:nest !=# ''
			let s:inner .= ',' . s:nest . s:nesting
		endif
		if s:group ==# 'perlQR' && index(['{', '<', '\['], s:open) >= 0
			let s:inner .= ',perlComment'
		endif
		let s:space = s:open ==# '#' ? '' : '\s*'
		let s:offset = (s:op ==# 's' || s:op ==# '\%(tr\|y\)') && s:nest ==# '' ? 'me=e-1' : ''
		let s:start = s:op ==# '' ? '' : '\i\@<!\%(::\|->\)\@<!' . s:op . '\i\@!' . s:space
		execute 'syntax region ' . s:group . ' contained matchgroup=' . s:quotes .
			\ ' start=+' . s:start . s:open .
			\ '+ end=+' . s:close . '+' . s:offset . " end=+'\\@=+ contains=" . s:inner .
			\ ' keepend extend ' . s:next
	endfor
endfor
syntax region perlMatch contained matchgroup=perlMatchStartEnd start="\%([$@%&*]\@<!\%(\%(\i\|:\)\@<!\%(split\|while\|if\|unless\)\%(\i\|:\)\@!\|\.\.\|[-+*!~(\[{=]\)\s*\)\@<=/\%(/=\)\@!" start=+^/\%(/=\)\@!+ start=+'\@<=/\%(/=\)\@!+ start=+\s\@<=/\%(/=\)\@![^[:space:][:digit:]$@%=]\@=\%(/\_s*\%([([{$@%&*[:digit:]"'`]\|\_s\w\|[[:upper:]_abd-fhjklnqrt-wyz]\)\)\@!+ skip=+\\/+ end=+/+ end=+'\@=+ contains=@perlInterpSlash keepend extend nextgroup=perlMatchModifiers
" Version strings take precedence over the numeric rules.
syntax match perlString contained "\i\@<!\%(v\d\+\%(\.\d\+\)*\|\d\+\%(\.\d\+\)\{2,}\)\i\@!" contains=perlVStringV
" Bare hash keys remain strings, even when their names are Perl keywords.
syntax match perlString contained "\I\@<!-\?\I\i*\%(\s*=>\)\@="
syntax region shPerl matchgroup=shSingleQuote start=+\<perl\>\s\+\%(-[[:alnum:]][^[:space:]'"\\;|&<>()`]*\s\+\)*-[[:alpha:]]*[eE]\s\+'+ end=+'+ keepend contains=@shPerlScript
syntax cluster shCommandSubList add=shPerl
let b:current_syntax = s:syntax
unlet s:syntax s:isk
unlet s:group s:op s:quotes s:interp s:nesting s:next s:open s:close s:nest s:inner s:space s:offset s:start
