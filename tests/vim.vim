set nocompatible
set nomore

let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
let $PATH = s:root . '/tests/data:' . $PATH
let g:dotfiles_skip_local = 1
execute 'source' fnameescape(s:root . '/dot.vimrc')
set noconfirm noautowrite noautowriteall

" Poll until Pred() returns true or timeout (50ms ticks, 5s max).
function! s:WaitFor(Pred) abort
	for i in range(100)
		if a:Pred()
			return 1
		endif
		sleep 50m
	endfor
	return 0
endfunction

" Force-load autoload modules so exists() works
runtime autoload/plumb.vim
runtime autoload/exec.vim
runtime autoload/view.vim
runtime autoload/plugins.vim
runtime autoload/text.vim

function! s:Style(id) abort
	let id = a:id ? synIDtrans(a:id) : hlID('Normal')
	let style = map(['fg', 'bg', 'bold', 'italic', 'underline', 'reverse'],
		\ {_, attr -> synIDattr(id, attr, 'cterm')})
	if style[0] ==# ''
		let style[0] = synIDattr(hlID('Normal'), 'fg', 'cterm')
	endif
	return style
endfunction

" Reference xterm colors; the terminal still controls the actual background.
function! s:Luminance(color) abort
	let color = str2nr(a:color)
	if color >= 232
		let rgb = repeat([8 + 10 * (color - 232)], 3)
	else
		let cube = [0, 95, 135, 175, 215, 255]
		let color -= 16
		let rgb = [cube[color / 36], cube[color / 6 % 6], cube[color % 6]]
	endif
	let linear = map(rgb, {_, c -> c <= 10 ? c / 3294.6 : pow((c / 255.0 + 0.055) / 1.055, 2.4)})
	return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
endfunction

" Basic keeps ordinary syntax plain after loading syntax and reloading colors.
let s:last_number = ''
for s:bg in ['dark', 'light', 'dark']
	execute 'set background=' . s:bg
	let s:plain = s:Style(hlID('Normal'))
	let s:keyword = s:Style(hlID('Statement'))
	let s:number = s:Style(hlID('Number'))
	let s:comment = s:Style(hlID('Comment'))
	let s:constant = s:Style(hlID('Constant'))
	let s:string = s:Style(hlID('LiteralString'))
	let s:contrasts = []
	for s:role in [s:plain, s:keyword, s:string, s:number]
		call assert_match('^\d\+$', s:role[0], s:bg . ' foreground')
		let s:color = str2nr(s:role[0])
		call assert_inrange(16, 255, s:color)
		if s:color >= 16 && s:color <= 255
			let s:luminance = s:Luminance(s:role[0])
			let s:contrast = s:bg ==# 'dark' ? (s:luminance + 0.05) / 0.05 : 1.05 / (s:luminance + 0.05)
			call assert_true(s:contrast >= 4.5, s:bg . ' text contrast')
			call add(s:contrasts, s:contrast)
		endif
	endfor
	call assert_equal(4, len(s:contrasts))
	if len(s:contrasts) == 4
		let s:least = s:contrasts[0]
		let s:most = s:least
		for s:contrast in s:contrasts
			let s:least = s:contrast < s:least ? s:contrast : s:least
			let s:most = s:contrast > s:most ? s:contrast : s:most
		endfor
		call assert_true(s:most / s:least <= 1.2, s:bg . ' balanced role contrast')
	endif
	call assert_notequal(s:plain[0], s:number[0])
	call assert_notequal(s:plain[0], s:comment[0])
	call assert_notequal(s:plain[0], s:constant[0])
	call assert_notequal(s:plain[0], s:keyword[0])
	call assert_notequal(s:constant[0], s:keyword[0])
	call assert_notequal(s:plain[0], s:string[0])
	call assert_notequal(s:constant[0], s:string[0])
	call assert_notequal(s:keyword[0], s:string[0])
	call assert_equal('1', s:keyword[2])
	call assert_equal(s:plain[1], s:keyword[1])
	call assert_equal(s:plain[3:], s:keyword[3:])
	call assert_notequal(s:last_number, s:number[0])
	call assert_equal(s:plain[1:], s:number[1:])
	call assert_equal(s:plain[1:], s:comment[1:])
	call assert_equal(s:plain[1:], s:constant[1:])
	call assert_equal(s:plain[1:], s:string[1:])
	let s:last_number = s:number[0]
	let s:styles = {'plain': s:plain, 'keyword': s:keyword, 'number': s:number,
		\ 'comment': s:comment, 'constant': s:constant, 'string': s:string}
	for s:fixture in [
		\ ['sh', [
			\ '#!/bin/bash',
			\ 'count=12',
			\ 'if [ "$count" -gt 10 ]; then',
			\ '  printf "%s\n" "${count:-0}" > output',
			\ 'fi',
			\ 'for item in a b; do',
			\ '  echo "$item"',
			\ 'done',
			\ 'case "$item" in',
			\ '  (a|b) echo value ;;',
			\ 'esac',
			\ '# TODO: 99',
			\ 'name() { echo value; }',
			\ 'cat <<EOF',
			\ 'for 45 literal',
			\ 'EOF',
			\ 'while test "$count" -gt 2; do',
			\ '  count=3',
			\ 'done',
			\ 'function other { return 4; }'], [
			\ [1, '#!', 'comment'], [2, 'count', 'plain'], [2, '12', 'number'],
			\ [3, 'if', 'keyword'], [3, '"', 'plain'],
			\ [3, '$count', 'plain'], [3, '-gt', 'plain'],
			\ [3, '10', 'number'], [3, ']', 'plain'],
			\ [3, ';', 'plain'], [3, 'then', 'keyword'],
			\ [4, 'printf', 'plain'], [4, '%s', 'plain'],
			\ [4, '\n', 'plain'], [4, ':-', 'plain'], [4, '>', 'plain'],
			\ [5, 'fi', 'keyword'], [6, 'for', 'keyword'],
			\ [6, 'item', 'plain'], [6, 'in', 'keyword'],
			\ [6, 'do', 'keyword'], [7, 'echo', 'plain'],
			\ [8, 'done', 'keyword'], [9, 'case', 'keyword'],
			\ [9, 'in', 'keyword'], [10, '(', 'plain'],
			\ [10, '|', 'plain'], [10, ')', 'plain'], [10, ';;', 'plain'],
			\ [11, 'esac', 'keyword'], [12, 'TODO', 'comment'],
			\ [12, '99', 'comment'], [13, 'name', 'plain'],
			\ [14, '<<', 'plain'], [15, 'for', 'plain'],
			\ [15, '45', 'plain'], [16, 'EOF', 'plain'],
			\ [17, 'while', 'keyword'], [17, 'test', 'plain'],
			\ [17, '"', 'plain'], [17, '-gt', 'plain'],
			\ [18, '3', 'number'], [20, 'function', 'keyword'],
			\ [20, 'other', 'plain'], [20, 'return', 'plain']]],
		\ ['sh', [
			\ '#!/bin/sh',
			\ 'n=7',
			\ 'if [ "$n" -gt 2 ]; then printf "%s\n" "$n" > output; fi'], [
			\ [2, 'n', 'plain'], [2, '7', 'number'],
			\ [3, 'if', 'keyword'], [3, '"', 'plain'],
			\ [3, '-gt', 'plain'], [3, 'then', 'keyword'],
			\ [3, 'printf', 'plain'], [3, '\n', 'plain'],
			\ [3, '>', 'plain'], [3, 'fi', 'keyword']]],
		\ ['sh', [
			\ '#!/bin/sh',
			\ 'if true; then',
			\ "  result=$(awk 'BEGIN { print \"hello\\n\", 12 }')",
			\ "  awk '",
			\ '    function f(x) { if (x > 2) return x }',
			\ '    # TODO: "comment"',
			\ '    $1 ~ /^hello[0-9]+[[:space:]]\t\/\x41\101.*$/ { print $1 }',
			\ '    END { print "done" }',
			\ "  '",
			\ '  printf "%s\n" "$result"',
			\ 'fi',
			\ "gawk 'BEGIN { print 3 }'",
			\ "mawk 'BEGIN { print 4 }'",
			\ "nawk 'BEGIN { print 5 }'",
			\ "echo 'awk BEGIN 42'",
			\ "# awk 'BEGIN 42'",
			\ "notawk 'BEGIN 42'",
			\ "awk 'BEGIN { print \"hello\" } # tail' ; echo 'plain 99'",
			\ "echo \"awk 'BEGIN 42'\"",
			\ 'echo word-if',
			\ 'word-if',
			\ "awk 'BEGIN { print x-2 }'",
			\ "awk 'BEGIN { print x-2.5, x-2e-3 }'"], [
			\ [2, 'if', 'keyword'], [3, 'awk', 'plain'],
			\ [3, 'BEGIN', 'keyword'], [3, 'print', 'keyword'],
			\ [3, 'hello', 'string'], [3, '\n', 'string'],
			\ [3, '12', 'number'], [5, 'function', 'keyword'],
			\ [5, 'f(x)', 'plain'], [5, 'if', 'keyword'],
			\ [5, '2', 'number'], [5, 'return', 'keyword'],
			\ [6, 'TODO', 'comment'], [6, '"', 'comment'],
			\ [7, '$1', 'plain'], [7, '/', 'plain'],
			\ [7, '^', 'plain'], [7, 'hello', 'plain'],
			\ [7, '0-9', 'plain'], [7, '+', 'plain'],
			\ [7, '[:space:]', 'plain'], [7, '\t', 'plain'],
			\ [7, '\/', 'plain'], [7, '\x41', 'plain'],
			\ [7, '\101', 'plain'], [7, '.*', 'plain'],
			\ [7, '$/', 'plain'], [8, 'END', 'keyword'],
			\ [8, 'done', 'string'], [10, 'printf', 'plain'],
			\ [10, '\n', 'plain'], [11, 'fi', 'keyword'],
			\ [12, 'BEGIN', 'keyword'], [13, 'BEGIN', 'keyword'],
			\ [14, 'BEGIN', 'keyword'], [15, 'BEGIN', 'plain'],
			\ [15, '42', 'plain'], [16, 'BEGIN', 'comment'],
			\ [17, 'BEGIN', 'plain'], [17, '42', 'plain'],
			\ [18, 'tail', 'comment'], [18, 'echo', 'plain'],
			\ [18, '99', 'plain'], [19, 'BEGIN', 'plain'],
			\ [19, '42', 'plain'], [20, 'if', 'plain'],
			\ [21, 'if', 'plain'], [22, '2', 'number'],
			\ [23, '2.5', 'number'], [23, '.5', 'number'],
			\ [23, '2e-3', 'number'], [23, 'e-3', 'number'],
			\ [23, '3 }', 'number', 1]]],
		\ ['sh', [
			\ '#!/bin/sh',
			\ 'if true; then',
			\ "  result=$(perl -e '",
			\ '    my $message = "hello\n";',
			\ '    print $message if 12;',
			\ "  ' | awk '{ print \"done\", 3 }')",
			\ 'fi',
			\ "perl -ne 'print \"line\" if 4'",
			\ "perl -0777 -pe 'print \"whole\"'",
			\ "perl -E 'say \"new\"'",
			\ "echo 'perl -e print 42'",
			\ "# perl -e 'print 42'",
			\ "notperl -e 'print 42'",
			\ "perl -e '# tail' ; echo 'plain 99'",
			\ "perl -e 'print \"unfinished' ; echo 'plain 98'",
			\ 'echo word-if',
			\ 'word-if',
			\ "perl -e 'my $p = qr{(?:hello|\\x{41})[[:space:]]+}i; print \"regex\\n\";'",
			\ "perl -ne 's{hello\\d+}{replacement\\n}; print;'",
			\ "perl -pe 's/hello(\\d+)/replacement\\n/g'",
			\ "perl -e 'qr{hello[0-9]+\\d}i; print \"done\"'",
			\ "perl -e 'qq{quoted (text) \\n}'",
			\ "perl -ne '/hello[0-9]+\\d/ && print'",
			\ "perl -e 'print $x-2.5, .1'",
			\ 'echo "perl -e ''print 42''"',
			\ "perl -e 'qr{a{2}}; print \"done\";'",
			\ 'if true; then :; fi',
			\ "perl -e 'qq{a{nested}}; print \"quoted\";'",
			\ 'if true; then :; fi',
			\ "perl -e 'my $a=1; $a--if $a; print $a-0xff, $a-1_000, -sin 2;'",
			\ "perl -e 'tr/print/sleep/;'",
			\ "perl -e 'y{print}{sleep};'",
			\ "perl -e 'my %hash = (if => \"value\", sin => \"value\");'",
			\ "perl -e 'use utf8; sub caféif {}; caféif();'",
			\ "perl -e 'my $p = qr-print-; print q-text-;'",
			\ "perl -e 'print 1.2.3, v1.2.3;'",
			\ "perl -e 'print \"\\' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e 'print \"${x' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e 'my $a=1; $a--if /12/;'",
			\ "perl -e 'my $p = qr{a # comment",
			\ "b}x;'",
			\ "perl -e 'my $p = qr<a # comment",
			\ "b>x;'",
			\ "perl -e 'my $p = qr[a # comment",
			\ "b]x;'",
			\ "perl -I. -e 'print \"ok\";'",
			\ "perl -MData::Dumper -e 'print \"ok\";'",
			\ "perl -e 'my $a=12; print $a / 2;'",
			\ "perl -e 'print \"${$a{key}}\"; print \"after\";'",
			\ "perl -e 'qq{a{unfinished' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -pe 's/a/replacement' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e 'my $p = m/[abc' ; echo outside ]",
			\ 'if true; then :; fi',
			\ "perl -I . -e 'print \"no\";'",
			\ "perl \"-I.\" -e 'print \"no\";'",
			\ "perl -- -e 'print \"no\";'",
			\ "perl -e 'q' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e '",
			\ '=pod',
			\ 'words',
			\ "' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e '",
			\ '=begin comment',
			\ 'unfinished',
			\ "' ; echo outside",
			\ 'if true; then :; fi',
			\ "perl -e 'Foo::print(\"ok\"); Foo::sin(2); print \"after\";'",
			\ "perl -e 'print: print \"ok\";'"], [
			\ [2, 'if', 'keyword'], [3, 'perl', 'plain'],
			\ [3, '-e', 'plain'], [4, 'my', 'keyword'],
			\ [4, '$message', 'plain'], [4, 'hello', 'string'],
			\ [4, '\n', 'string'], [5, 'print', 'keyword'],
			\ [5, 'if', 'keyword'], [5, '12', 'number'],
			\ [6, 'awk', 'plain'], [6, 'print', 'keyword'],
			\ [6, 'done', 'string'], [6, '3', 'number'],
			\ [7, 'fi', 'keyword'], [8, 'print', 'keyword'],
			\ [8, 'line', 'string'], [8, '4', 'number'],
			\ [9, 'whole', 'string'], [10, 'say', 'keyword'],
			\ [10, 'new', 'string'], [11, 'print', 'plain'],
			\ [11, '42', 'plain'], [12, 'print', 'comment'],
			\ [13, 'print', 'plain'], [13, '42', 'plain'],
			\ [14, 'tail', 'comment'], [14, 'echo', 'plain'],
			\ [14, '99', 'plain'], [15, 'unfinished', 'string'],
			\ [15, 'echo', 'plain'], [15, '98', 'plain'],
			\ [16, 'if', 'plain'], [17, 'if', 'plain'],
			\ [18, 'qr{', 'plain'], [18, 'hello', 'plain'],
			\ [18, '\x{41}', 'plain'], [18, '[:space:]', 'plain'],
			\ [18, '+', 'plain'], [18, '}i', 'plain'],
			\ [18, 'regex', 'string'], [18, '\n', 'string'],
			\ [19, 'hello', 'plain'], [19, '\d', 'plain'],
			\ [19, 'replacement', 'string'], [19, '\n', 'string'],
			\ [20, 'hello', 'plain'], [20, '\d', 'plain'],
			\ [20, 'replacement', 'string'], [20, '\n', 'string'],
			\ [21, 'qr{', 'plain'], [21, '0-9', 'plain'],
			\ [21, '\d', 'plain'], [21, 'done', 'string'],
			\ [22, 'qq{', 'string'], [22, 'quoted', 'string'],
			\ [22, 'text', 'string'], [22, '\n', 'string'],
			\ [23, '0-9', 'plain'], [23, '\d', 'plain'],
			\ [23, 'print', 'keyword'], [24, '2.5', 'number'],
			\ [24, '.1', 'number'], [25, 'print', 'plain'],
			\ [25, '42', 'plain'], [26, '{2}', 'plain'],
			\ [26, 'print', 'keyword'], [26, 'done', 'string'],
			\ [27, 'if', 'keyword'], [28, 'nested', 'string'],
			\ [28, 'print', 'keyword'], [28, 'quoted', 'string'],
			\ [29, 'if', 'keyword'], [30, 'if', 'keyword'],
			\ [30, '0xff', 'number'], [30, '1_000', 'number'],
			\ [30, 'sin', 'keyword'], [31, 'print', 'plain'],
			\ [31, 'sleep', 'string'], [32, 'print', 'plain'],
			\ [32, 'sleep', 'string'], [33, 'if', 'string'],
			\ [33, 'sin', 'string'], [33, 'value', 'string'],
			\ [34, 'caféif()', 'plain'], [35, 'qr-print-', 'plain'],
			\ [35, 'q-text-', 'string'], [36, '1.2.3', 'string'],
			\ [36, 'v1.2.3', 'string'], [37, 'outside', 'plain'],
			\ [38, 'if', 'keyword'], [39, 'outside', 'plain'],
			\ [40, 'if', 'keyword'], [41, '12', 'plain'],
			\ [42, 'comment', 'comment'], [43, 'b', 'plain'],
			\ [44, 'comment', 'comment'], [45, 'b', 'plain'],
			\ [46, 'comment', 'comment'], [47, 'b', 'plain'],
			\ [48, 'print', 'keyword'], [48, 'ok', 'string'],
			\ [49, 'print', 'keyword'], [49, 'ok', 'string'],
			\ [50, '2;', 'number', 1], [51, '$a', 'plain'],
			\ [51, 'key', 'string'], [51, 'after', 'string'],
			\ [52, 'outside', 'plain'],
			\ [53, 'if', 'keyword'], [54, 'outside', 'plain'],
			\ [55, 'if', 'keyword'], [56, 'outside', 'plain'],
			\ [57, 'if', 'keyword'], [58, 'print', 'plain'],
			\ [59, 'print', 'plain'], [60, 'print', 'plain'],
			\ [61, 'outside', 'plain'], [62, 'if', 'keyword'],
			\ [66, 'outside', 'plain'], [67, 'if', 'keyword'],
			\ [71, 'outside', 'plain'], [72, 'if', 'keyword'],
			\ [73, 'Foo::print', 'plain'], [73, 'Foo::sin', 'plain'],
			\ [73, 'print "after"', 'keyword', 5],
			\ [74, 'print:', 'plain'], [74, 'print "ok"', 'keyword', 5]]],
		\ ['go', [
			\ 'package main',
			\ 'func main() {',
			\ '  var count = 42',
			\ '  if count > 2 { println("hello", true) }',
			\ '  var scale = 4.5',
			\ '  var pointer = nil',
			\ '}',
			\ 'import "fmt"',
			\ 'var escaped = "line\n\x41\u0042\U00000043\101"',
			\ 'var raw = `literal \n',
			\ 'next line`',
			\ 'var format = "value=%d"',
			\ "var letter = 'x'",
			\ "var newline = '\\n'",
			\ '// TODO: "not a string"'], [
			\ [1, 'package', 'keyword'], [2, 'func', 'keyword'],
			\ [2, 'main', 'plain'], [3, 'var', 'keyword'],
			\ [3, '42', 'number'], [4, 'if', 'keyword'],
			\ [4, 'println', 'plain'], [4, '"hello"', 'string'],
			\ [4, 'true', 'constant'], [5, '4.5', 'number'],
			\ [6, 'nil', 'constant'], [8, '"fmt"', 'string'],
			\ [9, '"line', 'string'], [9, '\n', 'string'],
			\ [9, '\x41', 'string'], [9, '\u0042', 'string'],
			\ [9, '\U00000043', 'string'], [9, '\101"', 'string'],
			\ [10, '`literal', 'string'], [10, '\n', 'string'],
			\ [11, 'next line`', 'string'], [12, '%d', 'string'],
			\ [13, "'x'", 'string'], [14, "'\\n'", 'string'],
			\ [15, '"not a string"', 'comment']]],
		\ ['c', [
			\ 'int main(void) {',
			\ '  int count = 42;',
			\ '  if (count > 2) printf("hello %03d\n", count);',
			\ '  const char *text = "quote: \" slash: \\ hex: \x41";',
			\ '  const wchar_t *wide = L"wide";',
			\ '  const char *multi = "first\',
			\ 'second";',
			\ '#define MESSAGE "macro\n"',
			\ "  char letter = 'x';",
			\ "  char newline = '\\n';",
			\ '  // TODO: "not a string"',
			\ '  /* "also a comment" */',
			\ '  return 0;',
			\ '}'], [
			\ [1, 'int', 'plain'], [1, 'main', 'plain'],
			\ [2, 'count', 'plain'], [2, '42', 'number'],
			\ [3, 'if', 'keyword'], [3, 'printf', 'plain'],
			\ [3, '"hello', 'string'], [3, '%03d', 'string'],
			\ [3, '\n"', 'string'], [4, 'text', 'plain'],
			\ [4, '\"', 'string'], [4, '\\', 'string'],
			\ [4, '\x41', 'string'], [5, 'L"wide"', 'string'],
			\ [6, '"first\', 'string'], [7, 'second"', 'string'],
			\ [8, '"macro', 'string'], [8, '\n"', 'string'],
			\ [9, "'x'", 'string'], [10, "'\\n'", 'string'],
			\ [11, '"not a string"', 'comment'],
			\ [12, '"also a comment"', 'comment'],
			\ [13, 'return', 'keyword'], [13, '0', 'number']]],
		\ ['javascript', [
			\ 'const count = 42;',
			\ 'if (count > 2) console.log("hello", true);',
			\ "const single = 'hello';",
			\ 'const quoted = "quote: \" slash: \\ unicode: \u0041";',
			\ "const character = '\\n';",
			\ 'const template = `hello ${value}\n',
			\ 'next line`;',
			\ 'const escaped = `tick: \` slash: \\`;',
			\ 'const message = `ready=${true}`;',
			\ 'const pattern = /hello[0-9]+\d/;',
			\ '// TODO: "not a string"',
			\ '/* `also a comment` */'], [
			\ [1, 'const', 'keyword'], [1, 'count', 'plain'],
			\ [1, '42', 'number'], [2, 'if', 'keyword'],
			\ [2, 'console', 'plain'], [2, '"hello"', 'string'],
			\ [2, 'true', 'constant'], [3, "'hello'", 'string'],
			\ [4, '\"', 'string'], [4, '\\', 'string'],
			\ [4, '\u0041', 'string'], [5, "'\\n'", 'string'],
			\ [6, '`hello', 'string'], [6, '${value}', 'plain'],
			\ [6, '\n', 'string'], [7, 'next line`', 'string'],
			\ [8, '\`', 'string'], [8, '\\', 'string'],
			\ [9, 'ready=', 'string'], [9, 'true', 'constant'],
			\ [10, 'hello', 'plain'], [10, '\d', 'plain'],
			\ [11, '"not a string"', 'comment'],
			\ [12, '`also a comment`', 'comment']]],
		\ ['python', [
			\ 'def f():',
			\ '  if count > 12:',
			\ '    return "hello"',
			\ "  text = 'single'",
			\ '  raw = r"\w+"',
			\ '  escaped = "line\n"',
			\ '  multi = """two',
			\ 'lines"""',
			\ 'from os import path',
			\ 'if ready and value: pass',
			\ '# TODO: "comment"'], [
			\ [1, 'def', 'keyword'], [1, 'f()', 'plain'],
			\ [2, 'if', 'keyword'], [2, '12', 'number'],
			\ [3, 'return', 'keyword'], [3, '"', 'string'],
			\ [3, 'hello', 'string'], [4, 'single', 'string'],
			\ [5, 'r"', 'string'], [5, '\w', 'string'],
			\ [6, '\n', 'string'], [7, '"""', 'string'],
			\ [7, 'two', 'string'], [8, 'lines', 'string'],
			\ [9, 'from', 'keyword'], [9, 'import', 'keyword'],
			\ [9, 'os', 'plain'], [10, 'and', 'keyword'],
			\ [11, 'TODO', 'comment'], [11, '"', 'comment']]],
		\ ['perl', [
			\ 'use strict;',
			\ 'my $message = "hello\n";',
			\ "my $single = 'single';",
			\ 'my @words = qw(one two);',
			\ 'my $copy = qq{hello $message};',
			\ 'my $pattern = qr{hello[0-9]+};',
			\ 'if ($message) { print $single; }',
			\ '# TODO: "comment"',
			\ 'BEGIN { }',
			\ 'my $regex = qr{(?:hello|\x{41})[[:space:]]+}i;',
			\ '$message =~ s{hello\d+}{replacement\n};',
			\ 'my $quoted = qq{nested (text) \x{41}};',
			\ 'my %hash = (if => "value", sin => "value");',
			\ 'my $p = qr-print-; print q-text-;',
			\ 'use utf8; sub caféif {}; caféif();',
			\ 'print 1.2.3, v1.2.3;',
			\ 'print "${$a{key}}"; print "after";',
			\ 'Foo::print("ok"); Foo::sin(2); print "after";',
			\ 'print: print "ok";'], [
			\ [1, 'use', 'keyword'], [2, 'my', 'keyword'],
			\ [2, '$message', 'plain'], [2, '"', 'string'],
			\ [2, 'hello', 'string'], [2, '\n', 'string'],
			\ [3, "single'", 'string'], [4, 'qw(', 'string'],
			\ [4, 'one', 'string'], [5, 'qq{', 'string'],
			\ [5, 'hello', 'string'], [5, '$message', 'plain'],
			\ [6, 'qr{', 'plain'], [6, '[0-9]', 'plain'],
			\ [7, 'if', 'keyword'], [7, 'print', 'keyword'],
			\ [8, 'TODO', 'comment'], [8, '"', 'comment'],
			\ [9, 'BEGIN', 'keyword'],
			\ [10, 'qr{', 'plain'], [10, 'hello', 'plain'],
			\ [10, '\x{41}', 'plain'], [10, '[:space:]', 'plain'],
			\ [10, '+', 'plain'], [10, '}i', 'plain'],
			\ [11, 'hello', 'plain'], [11, '\d', 'plain'],
			\ [11, 'replacement', 'string'], [11, '\n', 'string'],
			\ [12, 'nested', 'string'], [12, 'text', 'string'],
			\ [12, '\x{41}', 'string'], [13, 'if', 'string'],
			\ [13, 'sin', 'string'], [13, 'value', 'string'],
			\ [14, 'qr-print-', 'plain'], [14, 'q-text-', 'string'],
			\ [15, 'caféif()', 'plain'], [16, '1.2.3', 'string'],
			\ [16, 'v1.2.3', 'string'], [17, '$a', 'plain'],
			\ [17, 'key', 'string'], [17, 'after', 'string'],
			\ [18, 'Foo::print', 'plain'], [18, 'Foo::sin', 'plain'],
			\ [18, 'print "after"', 'keyword', 5],
			\ [19, 'print:', 'plain'], [19, 'print "ok"', 'keyword', 5]]],
		\ ['awk', [
			\ 'BEGIN { count = 12; print "hello\n"; printf "%s", count }',
			\ '$1 ~ /^hello[0-9]+[[:space:]]\t\/\x41\101.*$/ { if (count > 2) print $1 }',
			\ '# TODO: "comment"',
			\ 'function f(value) { return value + 1 }'], [
			\ [1, 'BEGIN', 'keyword'], [1, 'count', 'plain'],
			\ [1, '12', 'number'], [1, 'print', 'keyword'],
			\ [1, '"', 'string'], [1, 'hello', 'string'],
			\ [1, '\n', 'string'], [1, '%s', 'string'],
			\ [2, '$1', 'plain'], [2, '/', 'plain'],
			\ [2, '^', 'plain'], [2, 'hello', 'plain'],
			\ [2, '0-9', 'plain'], [2, '+', 'plain'],
			\ [2, '[:space:]', 'plain'], [2, '\t', 'plain'],
			\ [2, '\/', 'plain'], [2, '\x41', 'plain'],
			\ [2, '\101', 'plain'], [2, '.*', 'plain'],
			\ [2, '$/', 'plain'], [2, 'if', 'keyword'],
			\ [3, 'TODO', 'comment'], [3, '"', 'comment'],
			\ [4, 'function', 'keyword'], [4, 'return', 'keyword'],
			\ [4, '+', 'plain']]]]
		enew
		call setline(1, s:fixture[1])
		execute 'setfiletype' s:fixture[0]
		let s:native_syntax = b:current_syntax
		for s:reload in range(3)
			if s:reload == 2
				execute 'set syntax=' . s:fixture[0]
				call assert_equal(s:native_syntax, b:current_syntax)
			endif
			if s:reload
				colorscheme basic
			endif
			syntax sync fromstart
			for s:case in s:fixture[2]
				let s:col = stridx(getline(s:case[0]), s:case[1]) + 1
				call assert_true(s:col > 0, string(s:case))
				" A fourth field limits the width when trailing text only locates a token.
				for s:offset in range(get(s:case, 3, strlen(s:case[1])))
					call assert_equal(s:styles[s:case[2]], s:Style(synID(s:case[0], s:col + s:offset, 1)),
						\ s:bg . ' ' . s:fixture[0] . ' ' . string(s:case))
				endfor
			endfor
		endfor
		bwipeout!
	endfor
	execute 'edit' fnameescape(s:root . '/bin/fivenum')
	call assert_equal('sh', &filetype)
	let s:shell_syntax = b:current_syntax
	call assert_match('^\%(sh\|bash\|ksh\|posix\)$', s:shell_syntax)
	for s:reload in range(2)
		if s:reload
			set syntax=sh
			colorscheme basic
		endif
		call assert_equal(s:shell_syntax, b:current_syntax)
		syntax sync fromstart
		for s:case in [
			\ ['^cat', 'plain'],
			\ ['^function', 'keyword'],
			\ ['^function \zsmedian', 'plain'],
			\ ['^\s*\zsif', 'keyword'],
			\ ['len % \zs2', 'number'],
			\ ['# \zsodd length', 'comment'],
			\ ['^END', 'keyword'],
			\ ['x\[NR\] = \zs\$1', 'plain']]
			call cursor(1, 1)
			let s:pos = searchpos(s:case[0], 'cnW')
			call assert_true(s:pos[0] > 0, string(s:case))
			call assert_equal(s:styles[s:case[1]], s:Style(synID(s:pos[0], s:pos[1], 1)),
				\ s:bg . ' fivenum ' . string(s:case))
		endfor
	endfor
	bwipeout!
	execute 'edit' fnameescape(s:root . '/acme/afmt')
	call assert_equal('sh', &filetype)
	let s:shell_syntax = b:current_syntax
	for s:reload in range(2)
		if s:reload
			set syntax=sh
			colorscheme basic
		endif
		call assert_equal(s:shell_syntax, b:current_syntax)
		for s:case in [
			\ ['cur="\$(\zsperl', 'plain'],
			\ ['^\s*\zsopen \$pipe', 'keyword'],
			\ ['"\zs|-', 'string'],
			\ ['"\zsecho addr=dot', 'string'],
			\ ['^\s*\zsclose \$pipe', 'keyword'],
			\ [';''\zs --', 'plain'],
			\ ['awk ''{ \zsprintf', 'keyword'],
			\ ['awk ''{ printf "\zs#%d', 'string'],
			\ ['^\zsprintf ,', 'plain']]
			call cursor(1, 1)
			let s:pos = searchpos(s:case[0], 'cnW')
			call assert_true(s:pos[0] > 0, string(s:case))
			call assert_equal(s:styles[s:case[1]], s:Style(synID(s:pos[0], s:pos[1], 1)),
				\ s:bg . ' afmt ' . string(s:case))
		endfor
	endfor
	bwipeout!
endfor

" A cold syntax lookup inside a long AWK program keeps the enclosing region.
let s:awk_file = tempname() . '.sh'
call writefile(['#!/bin/sh', "awk '"] + repeat(['{ value = $1 }'], 450) +
	\ ['END { print "done", 1 }', "'", 'if true; then :; fi'], s:awk_file)
execute 'edit' fnameescape(s:awk_file)
call assert_equal('sh', &filetype)
call assert_equal(s:keyword, s:Style(synID(453, 1, 1)))
call assert_equal(s:string, s:Style(synID(453, 14, 1)))
call assert_equal(s:number, s:Style(synID(453, 21, 1)))
call assert_equal(s:keyword, s:Style(synID(455, 1, 1)))
bwipeout!
call delete(s:awk_file)

" Native Perl synchronization must not escape a long shell-embedded program.
let s:perl_file = tempname() . '.sh'
call writefile(['#!/bin/sh', "perl -e '"] + repeat(['my $value = 1;'], 450) +
	\ ['my $pattern = qr{a{2}}; print "done", 2;', "'", 'if true; then :; fi'], s:perl_file)
execute 'edit' fnameescape(s:perl_file)
call assert_equal('sh', &filetype)
call assert_equal(s:keyword, s:Style(synID(453, stridx(getline(453), 'print') + 1, 1)))
call assert_equal(s:string, s:Style(synID(453, stridx(getline(453), 'done') + 1, 1)))
call assert_equal(s:number, s:Style(synID(453, strridx(getline(453), '2') + 1, 1)))
call assert_equal(s:keyword, s:Style(synID(455, 1, 1)))
bwipeout!
call delete(s:perl_file)

" Terminal mappings trigger view navigation
let s:tj = maparg('<c-j>', 't', 0, 1)
let s:tk = maparg('<c-k>', 't', 0, 1)
call assert_match('view[#.]Next', s:tj.rhs)
call assert_match('view[#.]Prev', s:tk.rhs)

" Send: shadow the command in a scratch buffer so mappings never invoke tmux.
enew
call setline(1, ['first', 'second', 'third'])
let s:send_ranges = []
let s:send_mode = mode()
command! -buffer -range -nargs=? Send call add(s:send_ranges, [<line1>, <line2>])
call feedkeys("ggVj ;\<Cmd>call assert_equal(s:send_mode, mode())\<CR>", 'xt')
call feedkeys("ggjVk ;\<Cmd>call assert_equal(s:send_mode, mode())\<CR>", 'xt')
call feedkeys("G ;\<Cmd>call assert_equal(s:send_mode, mode())\<CR>", 'xt')
call assert_equal([[1, 2], [1, 2], [3, 3]], s:send_ranges)
bwipeout!
unlet s:send_ranges s:send_mode

" Win: open a shell in the current file's directory.
let s:win_tmpdir = tempname() . ' space'
call mkdir(s:win_tmpdir, 'p')
let s:win_file = s:win_tmpdir . '/file.txt'
call writefile(['hello'], s:win_file)
execute 'edit' fnameescape(s:win_file)
let s:win_source = bufnr('%')
let s:old_shell = &shell
let &shell = '/bin/pwd'
Win
let &shell = s:old_shell
call assert_equal('terminal', &buftype)
let s:win_bnr = bufnr('%')
call assert_true(s:WaitFor({-> term_getstatus(s:win_bnr) =~# 'finished'}))
call assert_true(index(map(getbufline(s:win_bnr, 1, '$'), {_, line -> trim(line)}), resolve(s:win_tmpdir)) >= 0)
bwipeout!

" Win: a pathless buffer uses the current directory.
enew
execute 'lcd' fnameescape(s:win_tmpdir)
let &shell = '/bin/pwd'
Win
let &shell = s:old_shell
call assert_equal('terminal', &buftype)
let s:win_bnr = bufnr('%')
call assert_true(s:WaitFor({-> term_getstatus(s:win_bnr) =~# 'finished'}))
call assert_true(index(map(getbufline(s:win_bnr, 1, '$'), {_, line -> trim(line)}), resolve(s:win_tmpdir)) >= 0)
bwipeout!

" Win: arguments run in the shell.
let s:win_out = s:win_tmpdir . '/args.txt'
let &shell = '/bin/sh'
call view#Win('echo hi > ' . shellescape(s:win_out))
let &shell = s:old_shell
let s:win_bnr = bufnr('%')
call assert_true(s:WaitFor({-> term_getstatus(s:win_bnr) =~# 'finished'}))
call assert_equal(['hi'], readfile(s:win_out))
bwipeout!
execute 'lcd' fnameescape(s:root)
execute 'bwipeout!' s:win_source
call delete(s:win_tmpdir, 'rf')

" Next/Prev: move down and up. Tmux takes over at the bottom and top edge.
let s:tmux_save = $TMUX
let $TMUX = 'test'
enew
new
execute '1wincmd w'
call view#Next()
call assert_equal(2, winnr())
call view#Next()
call assert_equal(2, winnr())
call view#Prev()
call assert_equal(1, winnr())
call view#Prev()
call assert_equal(1, winnr())
only
call assert_equal(1, winnr('$'))
call view#Next()
call assert_equal(1, winnr())
if empty(s:tmux_save)
	unlet $TMUX
else
	let $TMUX = s:tmux_save
endif

" Clipboard path mappings
let s:path_y = maparg('<leader>y', 'n', 0, 1)
let s:path_Y = maparg('<leader>Y', 'n', 0, 1)
call assert_match("exec\\.Yank(fnamemodify(expand('%:p'), ':\\.'))", s:path_y.rhs)
call assert_match("exec\\.Yank(expand('%:p'))", s:path_Y.rhs)

" Host clipboard command: skip_local suppresses host config during tests.
call assert_false(exists('g:dotfiles_copy_command'))
let s:copy_file = tempname()
let g:dotfiles_copy_command = 'cat > ' . shellescape(s:copy_file)
call exec#Yank("alpha\nbeta")
call assert_equal(['alpha', 'beta'], readfile(s:copy_file, 'b'))
unlet g:dotfiles_copy_command
call delete(s:copy_file)

" Plumb: url dispatches through Url() which logs via echom
let s:url = 'https://example.com/path?x=1'
messages clear
call plumb#Do('', {}, s:url)
call assert_match('url: https://example\.com/path?x=1', execute('messages'))

" URLs retain reserved characters and balanced parentheses, not prose wrappers.
for s:case in [
	\ ['https://example.com/docs:v2?q=$value!#part', 'https://example.com/docs:v2?q=$value!#part'],
	\ ['See (https://example.com/Foo_(bar)).', 'https://example.com/Foo_(bar)'],
	\ ['file:///tmp/file.txt', 'file:///tmp/file.txt']]
	messages clear
	call plumb#Do('', {}, s:case[0])
	call assert_equal('url: ' . s:case[1], trim(execute('messages')))
endfor

" File acquisition uses complete names and Vim addresses.
let s:plumb_tmpdir = tempname() . ' space'
call mkdir(s:plumb_tmpdir, 'p')
let s:plumb_source = s:plumb_tmpdir . '/source.txt'
let s:plumb_file = s:plumb_tmpdir . '/main.txt'
let s:plumb_lines = ['one first line', 'two target line', 'needle third line', 'path/name fourth line', 'five final line']
call writefile(s:plumb_lines, s:plumb_source)
call writefile(s:plumb_lines, s:plumb_file)
for s:case in [
	\ ['main.txt:2:7', [2, 7]],
	\ ['"main.txt":3:4', [3, 4]],
	\ ['(main.txt:2:4)', [2, 4]],
	\ ['main.txt:2:5: diagnostic text', [2, 5]],
	\ ['main.txt:2,4', [4, 1]],
	\ ['main.txt:/needle/', [3, 1]],
	\ ['main.txt:/path\/name/', [4, 1]],
	\ [':2:5', [2, 5]]]
	execute 'edit' fnameescape(s:plumb_source)
	call cursor(1, 1)
	call plumb#Do(s:plumb_tmpdir, {}, s:case[0])
	call assert_equal(s:case[0][0] == ':' ? s:plumb_source : s:plumb_file, expand('%:p'), s:case[0])
	call assert_equal(s:case[1], getcurpos()[1:2], s:case[0])
endfor
execute 'edit' fnameescape(s:plumb_source)
call plumb#Do(s:plumb_tmpdir, {}, '"main.txt"')
call assert_equal(s:plumb_file, expand('%:p'))

" Unsupported suffixes must not become Ex commands or partial file references.
for s:ref in [
	\ 'main.txt:2|let g:plumb_executed=1',
	\ "main.txt:/one\nlet g:plumb_executed=1\n/",
	\ "main.txt:/one\rlet g:plumb_executed=1\r/"]
	execute 'edit' fnameescape(s:plumb_source)
	let g:plumb_executed = 0
	call plumb#Do(s:plumb_tmpdir, {}, s:ref)
	call assert_equal(0, g:plumb_executed)
	call assert_equal(s:plumb_source, expand('%:p'))
endfor
unlet g:plumb_executed

" Literal filenames win over prefixes, patterns, and address-like suffixes.
call writefile(s:plumb_lines, s:plumb_tmpdir . '/a')
call writefile(s:plumb_lines, s:plumb_tmpdir . '/release')
for s:name in ['a+b@é[1].txt', 'release:2', ' spaced name ']
	call writefile(s:plumb_lines, s:plumb_tmpdir . '/' . s:name)
	execute 'edit' fnameescape(s:plumb_source)
	call plumb#Do(s:plumb_tmpdir, {}, s:name)
	call assert_equal(s:plumb_tmpdir . '/' . s:name, expand('%:p'), s:name)
endfor

" Named buffers remain navigable without a file on disk.
execute 'edit' fnameescape(s:plumb_tmpdir . '/new.txt')
call setline(1, s:plumb_lines)
let s:plumb_new = bufnr('%')
execute 'edit' fnameescape(s:plumb_source)
call plumb#Do(s:plumb_tmpdir, {}, 'new.txt:2:3')
call assert_equal(s:plumb_new, bufnr('%'))
call assert_equal([2, 3], getcurpos()[1:2])
call assert_equal(s:plumb_lines, getline(1, '$'))
call assert_false(filereadable(s:plumb_tmpdir . '/new.txt'))
execute 'bwipeout!' s:plumb_new
let s:plumb_deleted = s:plumb_tmpdir . '/deleted.txt'
call writefile(s:plumb_lines, s:plumb_deleted)
execute 'edit' fnameescape(s:plumb_deleted)
let s:plumb_bnr = bufnr('%')
call delete(s:plumb_deleted)
execute 'edit' fnameescape(s:plumb_source)
call plumb#Do(s:plumb_tmpdir, {}, 'deleted.txt')
call assert_equal(s:plumb_bnr, bufnr('%'))
call assert_equal(s:plumb_lines, getline(1, '$'))

" File plumbing and directory Enter reuse a window in another tab.
silent! tabonly!
silent! only!
execute 'edit' fnameescape(s:plumb_source)
execute 'tabnew' fnameescape(s:plumb_file)
let s:plumb_win = win_getid()
let s:plumb_bnr = bufnr('%')
tabprevious
call plumb#Do(s:plumb_tmpdir, {}, 'main.txt:2:6')
call assert_equal(s:plumb_win, win_getid())
call assert_equal([2, 6], getcurpos()[1:2])
call assert_equal([s:plumb_win], win_findbuf(s:plumb_bnr))
tabnext 1
call view#Dir(s:plumb_tmpdir, v:true)
call search('^main\.txt$')
call feedkeys("\<CR>", 'xt')
call assert_equal(s:plumb_win, win_getid())
call assert_equal([s:plumb_win], win_findbuf(s:plumb_bnr))

" When a file is visible in both tabs, prefer the current tab's window.
execute 'tabnew' fnameescape(s:plumb_file)
let s:plumb_current = win_getid()
call plumb#Do(s:plumb_tmpdir, {}, 'main.txt:3:2')
call assert_equal(s:plumb_current, win_getid())
tabclose

" Directory acquisition reuses the window without reloading edited text.
tabnext 1
call view#Dir(s:plumb_tmpdir, v:true)
let s:plumb_dirwin = win_getid()
let s:plumb_dirbnr = bufnr('%')
call append(0, 'directory annotation')
let s:plumb_dirlines = getline(1, '$')
tabnext 2
call plumb#Do('', {}, s:plumb_tmpdir)
call assert_equal(s:plumb_dirwin, win_getid())
call assert_equal([s:plumb_dirwin], win_findbuf(s:plumb_dirbnr))
call assert_equal(s:plumb_dirlines, getline(1, '$'))

" A retained directory buffer also keeps its text when no window shows it.
setlocal bufhidden=hide
enew
call plumb#Do('', {}, s:plumb_tmpdir)
call assert_equal(s:plumb_dirbnr, bufnr('%'))
call assert_equal(s:plumb_dirlines, getline(1, '$'))

" An unmatched directory entry searches for the whole literal line.
call setline(1, ['annotation [x]', 'other text', 'annotation [x]'])
if line('$') > 3 | 4,$delete _ | endif
call cursor(1, 1)
call feedkeys(" \<CR>", 'xt')
call assert_equal([3, 1], getcurpos()[1:2])
call assert_equal('annotation [x]', getline('.'))

silent! tabonly!
silent! only!
enew!
for s:buf in getbufinfo()
	if s:buf.name ==# s:plumb_tmpdir || stridx(s:buf.name, s:plumb_tmpdir . '/') == 0
		execute 'bwipeout!' s:buf.bufnr
	endif
endfor
call delete(s:plumb_tmpdir, 'rf')

let s:fts_tmpdir = tempname()
call mkdir(s:fts_tmpdir, 'p')
let s:fts_log = s:fts_tmpdir . '/args.log'
let s:fts_pwn = s:fts_tmpdir . '/pwn'
let s:had_fts_log = exists('$FTS_LOG')
if s:had_fts_log
	let s:old_fts_log = $FTS_LOG
endif
let $FTS_LOG = s:fts_log
call exec#Fts('needle; touch ' . s:fts_pwn)
call assert_false(filereadable(s:fts_pwn))
call assert_equal('arg1=needle; touch ' . s:fts_pwn, get(readfile(s:fts_log), 0, ''))
if s:had_fts_log
	let $FTS_LOG = s:old_fts_log
else
	unlet $FTS_LOG
endif
call delete(s:fts_tmpdir, 'rf')

" Dir(): opens a directory buffer with ls output and correct mappings
let s:dir_tmpdir = tempname()
call mkdir(s:dir_tmpdir, 'p')
call writefile(['hello'], s:dir_tmpdir . '/afile.txt')
enew
call view#Dir(s:dir_tmpdir, v:true)
call assert_equal('dir', &filetype)
call assert_equal(s:dir_tmpdir . '/', b:dir)
call assert_equal(s:dir_tmpdir . '/', expand('%:p'))
call assert_match('afile\.txt', join(getline(1, '$'), "\n"))
call assert_equal(-1, index(getline(1, '$'), './'))
call assert_equal(-1, index(getline(1, '$'), '../'))
" Verify buffer-local CR mapping reuses the current window
let s:cr_map = maparg('<CR>', 'n', 0, 1)
call assert_true(!empty(s:cr_map))
call assert_match('OpenEntry()', s:cr_map.rhs)
bwipeout!
call delete(s:dir_tmpdir, 'rf')

" Dir(''): from a file, swaps the buffer's identity to the file's parent dir.
" Regression: prior code left bufname() at the file path, so :e clobbered the
" listing and :e . listed the wrong dir.
let s:dir_tmpdir = tempname()
call mkdir(s:dir_tmpdir . '/sub', 'p')
call writefile(['hello'], s:dir_tmpdir . '/sub/file.txt')
exe 'edit' fnameescape(s:dir_tmpdir . '/sub/file.txt')
call view#Dir('', v:true)
call assert_equal('dir', &filetype)
call assert_equal(s:dir_tmpdir . '/sub/', b:dir)
call assert_equal(s:dir_tmpdir . '/sub/', expand('%:p'))
call assert_match('file\.txt', join(getline(1, '$'), "\n"))
exe 'bwipeout!' bufnr(s:dir_tmpdir . '/sub/')
let s:file_bnr = bufnr(s:dir_tmpdir . '/sub/file.txt')
if s:file_bnr > 0 | exe 'bwipeout!' s:file_bnr | endif
call delete(s:dir_tmpdir, 'rf')

" Selection(): returns visually-selected text via gv reselection.
" Tests the non-visual-mode path (gv"zy) since feedkeys visual
" doesn't work in -es (ex mode). The xnoremap <Cmd> path is
" equivalent: mode() is 'v' there, so it takes the "zy branch.
enew
call setline(1, ['ls -ls', 'second'])
setlocal modified
call setpos("'<", [0, 1, 1, 0])
call setpos("'>", [0, 1, 7, 0])
let @z = 'sentinel'
let g:sel = text#Selection()
call assert_equal('ls -ls', g:sel)
call assert_equal('sentinel', @z)
unlet g:sel
bwipeout!

" Cmd(): no-range produces output
call exec#Cmd('echo cmd-test-ok', 0, 0, 0)
call s:WaitFor({-> getbufline(bufnr(getcwd() . '/+Errors'), 1, '$') != ['']})
let s:errbnr = bufnr(getcwd() . '/+Errors')
call assert_match('cmd-test-ok', join(getbufline(s:errbnr, 1, '$'), "\n"))
exe 'bwipeout!' s:errbnr

" Cmd(): ranged pipes buffer lines as stdin
enew
call setline(1, ['cherry', 'apple', 'banana'])
let s:tmpf = tempname()
call exec#Cmd('sort > ' . s:tmpf, 2, 1, 3)
call s:WaitFor({-> filereadable(s:tmpf) && readfile(s:tmpf) != []})
call assert_equal(['apple', 'banana', 'cherry'], readfile(s:tmpf))
call delete(s:tmpf)
bwipeout!
let s:errbnr = bufnr(getcwd() . '/+Errors')
if s:errbnr > 0 | exe 'bwipeout!' s:errbnr | endif

" Cmd(): shell syntax (pipes, redirects) works
let s:tmpf = tempname()
call exec#Cmd('echo hello world | tr a-z A-Z > ' . s:tmpf, 0, 0, 0)
call s:WaitFor({-> filereadable(s:tmpf) && readfile(s:tmpf) != []})
call assert_match('HELLO WORLD', join(readfile(s:tmpf), ''))
call delete(s:tmpf)
let s:errbnr = bufnr(getcwd() . '/+Errors')
if s:errbnr > 0 | exe 'bwipeout!' s:errbnr | endif

" Toc(): populates location list with heading lines
enew
call setline(1, ['# One', 'text', '## Two', 'more'])
call view#Toc()
let s:ll = getloclist(0)
call assert_equal(2, len(s:ll))
call assert_equal('# One', s:ll[0].text)
call assert_equal('## Two', s:ll[1].text)
lclose
bwipeout!

" Sort(): sorts named windows in place, leaves unnamed windows untouched.
" Regression: prior code zipped the full window list against a filtered buffer
" list, so unnamed windows shifted slots and one named buffer was duplicated.
silent! tabonly!
silent! only!
edit z_sort.txt
split a_sort.txt
split
enew
split m_sort.txt
call view#Sort()
let s:names = []
for i in range(1, winnr('$'))
	call add(s:names, bufname(winbufnr(i)))
endfor
call assert_equal(['a_sort.txt', 'm_sort.txt', '', 'z_sort.txt'], s:names)
silent! tabonly!
silent! only!
for s:b in ['z_sort.txt', 'a_sort.txt', 'm_sort.txt']
	let s:bn = bufnr(s:b)
	if s:bn > 0 | exe 'bwipeout!' s:bn | endif
endfor

" Cmd(): runs in buffer's directory (Acme model)
let s:cmd_tmpdir = tempname()
call mkdir(s:cmd_tmpdir, 'p')
call writefile([], s:cmd_tmpdir . '/marker')
exe 'edit' fnameescape(s:cmd_tmpdir . '/marker')
let s:pwdf = tempname()
call exec#Cmd('pwd > ' . s:pwdf, 0, 0, 0)
call s:WaitFor({-> filereadable(s:pwdf) && readfile(s:pwdf) != []})
call assert_match(s:cmd_tmpdir, join(readfile(s:pwdf), ''))
call delete(s:pwdf)
" +Errors buffer belongs to the buffer's directory, not vim's cwd
call assert_true(bufexists(s:cmd_tmpdir . '/+Errors'))
bwipeout!
exe 'bwipeout!' bufnr(s:cmd_tmpdir . '/+Errors')
call delete(s:cmd_tmpdir, 'rf')

" Cmd(): concurrent jobs both appear in +Errors
call exec#Cmd('echo job-aaa', 0, 0, 0)
call exec#Cmd('echo job-bbb', 0, 0, 0)
let s:errbnr = bufnr(getcwd() . '/+Errors')
call s:WaitFor({-> join(getbufline(s:errbnr, 1, '$'), "\n") =~ 'job-aaa' && join(getbufline(s:errbnr, 1, '$'), "\n") =~ 'job-bbb'})
let s:errtxt = join(getbufline(s:errbnr, 1, '$'), "\n")
call assert_match('job-aaa', s:errtxt)
call assert_match('job-bbb', s:errtxt)
exe 'bwipeout!' s:errbnr

" Cmd(): multi-line output preserved
call exec#Cmd('printf "line1\nline2\nline3"', 0, 0, 0)
let s:errbnr = bufnr(getcwd() . '/+Errors')
call s:WaitFor({-> len(getbufline(s:errbnr, 1, '$')) >= 3})
let s:errtxt = join(getbufline(s:errbnr, 1, '$'), "\n")
call assert_match('line1', s:errtxt)
call assert_match('line3', s:errtxt)
exe 'bwipeout!' s:errbnr

" Cmd(): Done callback fires after the job exits — used by Fmt for post-write reload.
let g:cmd_done_marker = 0
call exec#Cmd('true', 0, 0, 0, {-> extend(g:, {'cmd_done_marker': 1})})
call s:WaitFor({-> g:cmd_done_marker == 1})
call assert_equal(1, g:cmd_done_marker)
unlet g:cmd_done_marker
let s:errbnr = bufnr(getcwd() . '/+Errors')
if s:errbnr > 0 | exe 'bwipeout!' s:errbnr | endif

" Cmd(): closing the output window preserves output during and after the job.
silent! only!
let s:cmd_tmpdir = tempname()
call mkdir(s:cmd_tmpdir, 'p')
exe 'edit' fnameescape(s:cmd_tmpdir . '/source.txt')
let s:source_bnr = bufnr('%')
let s:cmd_err = v:errmsg
let v:errmsg = ''
let g:cmd_done_marker = 0
call exec#Cmd('while [ ! -f release ]; do sleep 0.01; done; echo retained-output',
	\ 0, 0, 0, {-> extend(g:, {'cmd_done_marker': 1})})
let s:errbnr = bufnr(s:cmd_tmpdir . '/+Errors')
exe 'sbuffer' s:errbnr
close
call assert_true(bufexists(s:errbnr))
call assert_true(bufloaded(s:errbnr))
call writefile([], s:cmd_tmpdir . '/release')
call assert_true(s:WaitFor({-> g:cmd_done_marker == 1}))
call assert_equal(['retained-output'], getbufline(s:errbnr, 1, '$'))
call assert_equal(s:errbnr, bufnr('%'))
close
call assert_true(bufloaded(s:errbnr))
call assert_equal(['retained-output'], getbufline(s:errbnr, 1, '$'))
call assert_equal('', v:errmsg)
let v:errmsg = s:cmd_err
unlet g:cmd_done_marker
exe 'bwipeout!' s:errbnr
exe 'bwipeout!' s:source_bnr
call delete(s:cmd_tmpdir, 'rf')

" Cmd(): from an unnamed buffer, +Errors is bufnr-tagged so two unnamed buffers
" don't collide on the same scratch. Regression: prior code used cwd alone.
silent! tabonly!
silent! only!
enew
let s:bn1 = bufnr('%')
call exec#Cmd('echo unnamed-aaa', 0, 0, 0)
new
enew
let s:bn2 = bufnr('%')
call exec#Cmd('echo unnamed-bbb', 0, 0, 0)
let s:errnr1 = bufnr(getcwd() . '/+Errors/' . s:bn1)
let s:errnr2 = bufnr(getcwd() . '/+Errors/' . s:bn2)
call assert_true(s:errnr1 > 0)
call assert_true(s:errnr2 > 0)
call assert_notequal(s:errnr1, s:errnr2)
call s:WaitFor({-> join(getbufline(s:errnr1, 1, '$'), "\n") =~ 'unnamed-aaa'})
call s:WaitFor({-> join(getbufline(s:errnr2, 1, '$'), "\n") =~ 'unnamed-bbb'})
call assert_match('unnamed-aaa', join(getbufline(s:errnr1, 1, '$'), "\n"))
call assert_match('unnamed-bbb', join(getbufline(s:errnr2, 1, '$'), "\n"))
call assert_notmatch('unnamed-bbb', join(getbufline(s:errnr1, 1, '$'), "\n"))
exe 'bwipeout!' s:errnr1
exe 'bwipeout!' s:errnr2
silent! only!

" DblClick/Expand: mappings are wired up
let s:expand_map = maparg('<Space><Space>', 'n', 0, 1)
call assert_true(!empty(s:expand_map))
call assert_match('text[#.]Expand', s:expand_map.rhs)
let s:c2_map = maparg('<2-LeftMouse>', 'n', 0, 1)
call assert_true(!empty(s:c2_map))
call assert_match('view[#.]DblClick', s:c2_map.rhs)

" Comment(): paired commentstring (<!--%s-->) — must wrap, not concatenate.
enew
setlocal commentstring=<!--%s-->
call setline(1, ['<div>', '  <p>hi</p>', '</div>'])
call setpos("'[", [0, 1, 1, 0])
call setpos("']", [0, 3, 1, 0])
call text#Comment('line')
call assert_equal(['<!-- <div> -->', '  <!-- <p>hi</p> -->', '<!-- </div> -->'], getline(1, '$'))
call setpos("'[", [0, 1, 1, 0])
call setpos("']", [0, 3, 1, 0])
call text#Comment('line')
call assert_equal(['<div>', '  <p>hi</p>', '</div>'], getline(1, '$'))
bwipeout!

" Comment(): mixed indent levels round-trip cleanly.
enew
setlocal commentstring=#%s
call setline(1, ['top', '  mid', '    deep'])
call setpos("'[", [0, 1, 1, 0])
call setpos("']", [0, 3, 1, 0])
call text#Comment('line')
call assert_equal(['# top', '  # mid', '    # deep'], getline(1, '$'))
call setpos("'[", [0, 1, 1, 0])
call setpos("']", [0, 3, 1, 0])
call text#Comment('line')
call assert_equal(['top', '  mid', '    deep'], getline(1, '$'))
bwipeout!

" TabLabel(): escapes % so file names like '100%done' don't break the tabline.
silent! tabonly!
silent! only!
let s:pct = tempname() . '_100%done.txt'
call writefile(['x'], s:pct)
exe 'edit' fnameescape(s:pct)
call assert_match('100%%done', view#TabLabel(1))
call assert_notmatch('[^%]%[^%]', view#TabLabel(1))
let t:label = 'foo%bar'
call assert_equal('foo%%bar', view#TabLabel(1))
unlet t:label
exe 'bwipeout!' bufnr(s:pct)
call delete(s:pct)

" Browse(): toggling closes a dir buffer even if the user edited it. Dir
" buffers are scratch by design and don't merit a write prompt.
let s:browse_tmpdir = tempname()
call mkdir(s:browse_tmpdir, 'p')
call writefile(['hi'], s:browse_tmpdir . '/file.txt')
call view#Dir(s:browse_tmpdir, v:true)
call append(0, 'EDITED-LINE')
call view#Browse()
call assert_notequal('dir', &filetype)
call delete(s:browse_tmpdir, 'rf')

" Dump/Load: round-trip preserves clean file
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
let s:test_file = s:dump_tmpdir . '/testfile.txt'
call writefile(['line1', 'line2'], s:test_file)
silent! tabonly!
silent! only!
exe 'edit' fnameescape(s:test_file)
call cursor(2, 3)
call exec#Dump(s:dump_file)
call assert_true(filereadable(s:dump_file))
let s:dump_lines = readfile(s:dump_file)
call assert_match('^f1\t', s:dump_lines[3])
call assert_match(s:test_file, join(s:dump_lines, "\n"))
" Load into fresh state
enew!
call exec#Load(s:dump_file)
call assert_true(get(g:, 'dotfiles_loaded_dump', v:false))
	call assert_equal(resolve(fnamemodify(s:test_file, ':p')), resolve(expand('%:p')))
call assert_equal(2, line('.'))
call delete(s:dump_tmpdir, 'rf')

" Dump/Load: dirty buffer embeds content
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
silent! tabonly!
silent! only!
enew
call setline(1, ['dirty1', 'dirty2', 'dirty3'])
setlocal modified
call cursor(2, 1)
call exec#Dump(s:dump_file)
let s:dump_lines = readfile(s:dump_file)
call assert_match('^F1\t', s:dump_lines[3])
call assert_match('dirty2', join(s:dump_lines, "\n"))
" Load and verify content restored
enew!
call exec#Load(s:dump_file)
call assert_equal(['dirty1', 'dirty2', 'dirty3'], getline(1, '$'))
call assert_true(&modified)
call delete(s:dump_tmpdir, 'rf')

" Dump/Load: repeated scratch windows share a buffer and retain their cursors.
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
let s:test_file = s:dump_tmpdir . '/file.txt'
call writefile(['file content'], s:test_file)
silent! tabonly!
silent! only!
let s:scratch = view#Scratch(s:dump_tmpdir . '/scratch')
exe 'buffer' fnameescape(s:scratch)
call setline(1, ['alpha', 'beta', 'gamma'])
call cursor(1, 2)
exe 'split' fnameescape(s:test_file)
split
exe 'buffer' fnameescape(s:scratch)
call cursor(3, 4)
call exec#Dump(s:dump_file)
call exec#Load(s:dump_file)
let s:wins = getwininfo()
call assert_equal(3, len(s:wins))
call assert_equal(s:wins[0].bufnr, s:wins[2].bufnr)
call assert_notequal(s:wins[0].bufnr, s:wins[1].bufnr)
call assert_equal(['alpha', 'beta', 'gamma'], getbufline(s:wins[0].bufnr, 1, '$'))
call assert_equal(s:test_file, fnamemodify(bufname(s:wins[1].bufnr), ':p'))
call assert_equal([1, 2], getcurpos(s:wins[0].winid)[1:2])
call assert_equal([3, 4], getcurpos(s:wins[2].winid)[1:2])
silent! only!
exe 'bwipeout!' s:wins[0].bufnr
exe 'bwipeout!' s:wins[1].bufnr
call delete(s:dump_tmpdir, 'rf')

" Dump/Load: tabs with only skipped windows (help, terminal, quickfix) do not
" emit orphan 't' records. Regression: prior code added 't<N>' before checking
" whether any window survived the skip filter, leaving Load to mis-apply
" tab boundaries.
let s:dump_tmpdir = tempname()
call mkdir(s:dump_tmpdir, 'p')
let s:dump_file = s:dump_tmpdir . '/vim.dump'
let s:real_a = s:dump_tmpdir . '/a.txt'
let s:real_c = s:dump_tmpdir . '/c.txt'
call writefile(['aaa'], s:real_a)
call writefile(['ccc'], s:real_c)
silent! tabonly!
silent! only!
exe 'edit' fnameescape(s:real_a)
tabnew
" Tab 2: help-only — must be skipped entirely
silent help
tabnew
exe 'edit' fnameescape(s:real_c)
call exec#Dump(s:dump_file)
let s:dump_lines = readfile(s:dump_file)
let s:t_lines = filter(copy(s:dump_lines), {_, v -> v =~ '^t\d'})
call assert_equal(2, len(s:t_lines))
call assert_false(index(s:dump_lines, 't2') >= 0)
call assert_match('^t1\t', s:t_lines[0])
call assert_match('^t3\t', s:t_lines[1])

" Load translates the active tab number after omitting a middle tab.
let s:real_d = s:dump_tmpdir . '/d.txt'
call writefile(['ddd'], s:real_d)
tabnew
exe 'edit' fnameescape(s:real_d)
tabnext 3
call exec#Dump(s:dump_file)
call exec#Load(s:dump_file)
call assert_equal(3, tabpagenr('$'))
call assert_equal(2, tabpagenr())
call assert_equal(s:real_c, expand('%:p'))
call assert_equal([s:real_a, s:real_c, s:real_d],
	\ map(range(1, tabpagenr('$')), {_, n -> fnamemodify(bufname(tabpagebuflist(n)[0]), ':p')}))

" An omitted first active tab falls back to the first retained tab.
silent! tabonly!
silent! only!
enew
silent help
tabnew
exe 'edit' fnameescape(s:real_a)
tabnext 1
call exec#Dump(s:dump_file)
call exec#Load(s:dump_file)
call assert_equal(1, tabpagenr('$'))
call assert_equal(1, tabpagenr())
call assert_equal(s:real_a, expand('%:p'))
silent! tabonly!
silent! only!
call delete(s:dump_tmpdir, 'rf')

if len(v:errors)
	for e in v:errors
		echo e
	endfor
	cquit 1
endif

qall!
