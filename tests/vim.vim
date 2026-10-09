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
function! s:RGB(color) abort
	let color = str2nr(a:color)
	if color >= 232
		return repeat([8 + 10 * (color - 232)], 3)
	endif
	let cube = [0, 95, 135, 175, 215, 255]
	let color -= 16
	return [cube[color / 36], cube[color / 6 % 6], cube[color % 6]]
endfunction

function! s:Luminance(color) abort
	let linear = map(s:RGB(a:color), {_, c -> c <= 10 ? c / 3294.6 : pow((c / 255.0 + 0.055) / 1.055, 2.4)})
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
	let s:link = s:Style(hlID('markdownLinkText'))
	let s:contrasts = []
	for s:role in [s:plain, s:keyword, s:string, s:number, s:link]
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
	call assert_equal(5, len(s:contrasts))
	if len(s:contrasts) == 5
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
	let s:link_rgb = s:RGB(s:link[0])
	call assert_true(s:link_rgb[2] > s:link_rgb[1] && s:link_rgb[1] >= s:link_rgb[0],
		\ s:bg . ' links must be blue, not neutral or purple')
	call assert_equal('1', s:link[4], s:bg . ' links must be underlined')
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
	let s:styles.bold = copy(s:plain)
	let s:styles.bold[2] = '1'
	let s:styles.italic = copy(s:plain)
	let s:styles.italic[3] = '1'
	let s:styles.link = s:link
	let s:styles.linkBold = copy(s:link)
	let s:styles.linkBold[2] = '1'
	let s:styles.linkItalic = copy(s:link)
	let s:styles.linkItalic[3] = '1'
	let s:styles.linkBoldItalic = copy(s:styles.linkBold)
	let s:styles.linkBoldItalic[3] = '1'
	let s:styles.headingItalic = copy(s:keyword)
	let s:styles.headingItalic[3] = '1'
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
			\ [14, '99', 'plain'], [15, 'unfinished', 'plain'],
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
		\ ['javascript', [
			\ 'const object = {"name": "value", if: 42, true: false};',
			\ 'object.if = 3; object.return = 4;',
			\ 'const numbers = [0xff, 0b101, 0o52, 1_000, .5, 1.2e-3, 42n];',
			\ 'const division = value / 2 / 3;',
			\ 'function match(value) { return /["''42/]+\d/gi.test(value); }',
			\ 'const nested = `outer ${flag ? `inner ${42}` : "fallback"} end`;',
			\ 'const braces = `object=${({name: "inner", value: 2}).name} done`;',
			\ 'const escaped = `literal \${notCode} \` ${null}`;',
			\ 'const dollars$const = 5; const $if = 6;',
			\ 'const condition = flag ? "yes" : "no";',
			\ 'const continued = "first\',
			\ 'second";'], [
			\ [1, 'const', 'keyword'], [1, '"name"', 'plain'],
			\ [1, '"value"', 'string'], [1, 'if', 'plain'],
			\ [1, '42', 'number'], [1, 'true', 'plain'],
			\ [1, 'false', 'constant'], [2, 'object.if', 'plain'],
			\ [2, 'object.return', 'plain'], [2, '3', 'number'],
			\ [3, '0xff', 'number'], [3, '0b101', 'number'],
			\ [3, '0o52', 'number'], [3, '1_000', 'number'],
			\ [3, '.5', 'number'], [3, '1.2e-3', 'number'],
			\ [3, '42n', 'number'], [4, '/', 'plain'],
			\ [4, '2', 'number'], [4, '3', 'number'],
			\ [5, 'function', 'keyword'], [5, 'return', 'keyword'],
			\ [5, '/["''42/]+\d/gi', 'plain'],
			\ [6, 'outer', 'string'], [6, 'flag', 'plain'],
			\ [6, 'inner', 'string'], [6, '42', 'number'],
			\ [6, '"fallback"', 'string'], [6, 'end', 'string'],
			\ [7, 'object=', 'string'], [7, 'name:', 'plain'],
			\ [7, '"inner"', 'string'], [7, '2', 'number'],
			\ [7, 'done', 'string'], [8, '\${notCode}', 'string'],
			\ [8, '\`', 'string'], [8, 'null', 'constant'],
			\ [9, 'dollars$const', 'plain'], [9, '$if', 'plain'],
			\ [10, '"yes"', 'string'], [10, '"no"', 'string'],
			\ [11, '"first\', 'plain'], [12, 'second"', 'plain']]],
		\ ['javascript', [
			\ '#!/usr/bin/env node',
			\ 'const broken = `unfinished ${value',
			\ 'const safe = 42;',
			\ 'console.log("done");'], [
			\ [1, '#!/usr/bin/env node', 'comment'],
			\ [3, 'const', 'keyword'], [3, '42', 'number'],
			\ [4, '"done"', 'string']]],
		\ ['javascript', [
			\ 'const result = flag ? true : false;',
			\ 'switch (value) { case 42: break; case true: break; }',
			\ 'const object = {42: true, false: null};',
			\ 'const 𐐀if = 7;'], [
			\ [1, 'true', 'constant'], [1, 'false', 'constant'],
			\ [2, '42', 'number'], [2, 'true', 'constant'],
			\ [3, '42', 'plain'], [3, 'true', 'constant'],
			\ [3, 'false', 'plain'], [3, 'null', 'constant'],
			\ [4, '𐐀if', 'plain'], [4, '7', 'number']]],
		\ ['typescript', [
			\ 'export interface Entry { readonly name: string; count: number; }',
			\ 'type Result<T> = { value: T; ok: boolean };',
			\ 'async function render(value: number): Promise<string> {',
			\ '  const title: string = "hello";',
			\ '  if (value > 2) return `value=${value + 42}`;',
			\ '  return title;',
			\ '}',
			\ 'const entry = {"name": "value", count: 42} satisfies Entry;',
			\ 'const pattern: RegExp = /hello[0-9]+\d/;',
			\ '// TODO: "not a string"'], [
			\ [1, 'export', 'keyword'], [1, 'interface', 'keyword'],
			\ [1, 'Entry', 'plain'], [1, 'readonly', 'keyword'],
			\ [1, 'name', 'plain'], [1, 'string', 'plain'],
			\ [1, 'count', 'plain'], [1, 'number', 'plain'],
			\ [2, 'type', 'keyword'], [2, 'Result', 'plain'],
			\ [2, 'value', 'plain'], [2, 'boolean', 'plain'],
			\ [3, 'async', 'keyword'], [3, 'function', 'keyword'],
			\ [3, 'Promise', 'plain'], [4, 'const', 'keyword'],
			\ [4, '"hello"', 'string'], [5, 'if', 'keyword'],
			\ [5, 'return', 'keyword'], [5, 'value=', 'string'],
			\ [5, 'value +', 'plain'], [5, '42', 'number'],
			\ [8, '"name"', 'plain'], [8, '"value"', 'string'],
			\ [8, '42', 'number'], [8, 'satisfies', 'keyword'],
			\ [9, 'RegExp', 'plain'], [9, 'hello', 'plain'],
			\ [9, '\d', 'plain'], [10, '"not a string"', 'comment']]],
		\ ['html', [
			\ '<div class="card" data-label=''hello &amp; world'' tabindex=2>',
			\ '  Ordinary text &amp; more text.',
			\ '  <input title="" value="42">',
			\ '  <!-- TODO: "not a string" -->',
			\ '</div>'], [
			\ [1, 'div', 'keyword'], [1, 'class', 'plain'],
			\ [1, '"card"', 'string'], [1, 'data-label', 'plain'],
			\ [1, "'hello &amp; world'", 'string'],
			\ [1, 'tabindex', 'plain'], [1, '2>', 'string', 1],
			\ [2, 'Ordinary text &amp; more text.', 'plain'],
			\ [3, 'title', 'plain'], [3, '""', 'string'],
			\ [3, '"42"', 'string'], [4, 'TODO', 'comment'],
			\ [4, '"not a string"', 'comment']]],
		\ ['html', [
			\ '<STYLE>',
			\ '.card { content: "hello"; margin: 12px; }',
			\ '</STYLE>',
			\ '<script>',
			\ 'const count = value-2;',
			\ 'if (count) console.log("yes", true);',
			\ '</script>',
			\ '<div title="after">plain after</div>'], [
			\ [1, 'STYLE', 'keyword'], [2, '.card', 'plain'],
			\ [2, 'content', 'plain'], [2, '"hello"', 'string'],
			\ [2, '12px', 'number'], [3, 'STYLE', 'keyword'],
			\ [4, 'script', 'keyword'], [5, 'const', 'keyword'],
			\ [5, 'value', 'plain'], [5, '2', 'number'],
			\ [6, 'if', 'keyword'], [6, 'console', 'plain'],
			\ [6, '"yes"', 'string'], [6, 'true', 'constant'],
			\ [7, 'script', 'keyword'], [8, 'title', 'plain'],
			\ [8, '"after"', 'string'], [8, 'plain after', 'plain']]],
		\ ['html', [
			\ '<script>',
			\ 'if (a<b && c>2) console.log("yes");',
			\ '</script>'], [
			\ [1, 'script', 'keyword'], [2, 'if', 'keyword'],
			\ [2, 'b', 'plain'], [2, 'c>2', 'plain', 1],
			\ [2, '2', 'number'], [2, '"yes"', 'string'],
			\ [3, 'script', 'keyword']]],
		\ ['markdown', [
			\ '<div style="content: ''hello''; margin: 12px; color: #aabbcc;">text</div>',
			\ '<style>.card { content: "after"; }</style>'], [
			\ [1, 'style', 'plain'],
			\ [1, '"content: ''hello''; margin: 12px; color: #aabbcc;"', 'string'],
			\ [2, '"after"', 'string']]],
		\ ['markdown', [
			\ '# Heading',
			\ '## Smaller heading',
			\ 'Text with **bold** and *italic* and [link](https://example.com).',
			\ 'Use `if true 42` and ``a ` b``; escaped \* is plain.',
			\ 'snake_case stays plain.',
			\ '- list item',
			\ '> quoted text',
			\ '```unknown',
			\ '# not a heading; **not bold** <div title="plain">42</div> [[Hidden#Anchor]] [hidden](#hidden)',
			\ '````',
			\ '# After fence'], [
			\ [1, '# Heading', 'keyword'], [2, '## Smaller heading', 'keyword'],
			\ [3, 'bold', 'bold'], [3, 'italic', 'italic'], [3, 'link', 'link'],
			\ [3, 'https://example.com', 'link'],
			\ [4, 'if true 42', 'bold'], [4, '`if true 42`', 'plain', 1],
			\ [4, '` and', 'plain', 1], [4, 'a ` b', 'plain'], [4, '\*', 'plain'],
			\ [5, 'snake_case', 'plain'], [6, '-', 'keyword'], [7, '>', 'comment'],
			\ [9, '# not a heading; **not bold** <div title="plain">42</div>', 'plain'],
			\ [9, '[[Hidden#Anchor]]', 'plain'], [9, '[hidden](#hidden)', 'plain'],
			\ [11, '# After fence', 'keyword']]],
		\ ['markdown', [
			\ '---',
			\ 'title: hello world',
			\ '"key": "value"',
			\ 'count: 42',
			\ '---',
			\ 'Ordinary prose with 42 and true.'], [
			\ [2, 'title', 'plain'], [2, 'hello world', 'string'],
			\ [3, '"key"', 'plain'], [3, '"value"', 'string'],
			\ [4, 'count', 'plain'], [4, '42', 'number'],
			\ [6, '42', 'plain'], [6, 'true', 'plain']]],
		\ ['markdown', [
			\ '# First title',
			\ '## Second title',
			\ '### Third title with *italic* and **bold**',
			\ '#### Fourth title',
			\ '##### Fifth title',
			\ '###### Sixth title',
			\ 'Ordinary *italic* and _italic_ text.'], [
			\ [1, '# First title', 'keyword'], [2, '## Second title', 'keyword'],
			\ [3, '### Third title with', 'keyword'], [3, 'italic', 'headingItalic'],
			\ [3, 'bold', 'keyword'], [4, '#### Fourth title', 'keyword'],
			\ [5, '##### Fifth title', 'keyword'], [6, '###### Sixth title', 'keyword'],
			\ [7, '*italic*', 'italic'], [7, '_italic_', 'italic']]],
		\ ['markdown', [
			\ '# Literal \*stars\* text',
			\ 'Ordinary prose',
			\ '# Literal `*code*` text',
			\ '# Unfinished *title',
			\ 'Prose after unfinished title'], [
			\ [1, '# Literal \*stars\* text', 'keyword'], [2, 'Ordinary prose', 'plain'],
			\ [3, '# Literal', 'keyword'], [3, '*code*', 'keyword'],
			\ [3, '`*code*`', 'plain', 1], [3, '` text', 'plain', 1],
			\ [5, 'Prose after unfinished title', 'plain']]],
		\ ['markdown', [
			\ '[site](https://example.com/#section) and [local](#local-anchor).',
			\ '[[Page#Section|label]] and [[#Local anchor]].',
			\ '<https://example.com/#auto>',
			\ 'Use `if true 42` and ``a ` b``.',
			\ '### [Heading](#heading) and [[Page#Title|wiki]] and `code` and [*italic*](#italic)',
			\ '[**bold** *italic* `code`](#format)',
			\ '[ref]: https://example.com/#reference',
			\ '[reference][ref]'], [
			\ [1, 'site', 'link'], [1, 'https://example.com/#section', 'link'],
			\ [1, 'local', 'link'], [1, '#local-anchor', 'link'],
			\ [2, 'Page#Section|label', 'link'], [2, '#Local anchor', 'link'],
			\ [2, '[[Page', 'plain', 2], [2, ']] and', 'plain', 2],
			\ [3, 'https://example.com/#auto', 'link'],
			\ [4, 'if true 42', 'bold'], [4, '`if true 42`', 'plain', 1],
			\ [4, '` and', 'plain', 1], [4, '``a ` b``', 'plain'],
			\ [5, '###', 'keyword'], [5, 'Heading', 'linkBold'],
			\ [5, '#heading', 'linkBold'], [5, 'Page#Title|wiki', 'linkBold'],
			\ [5, 'code', 'keyword'], [5, '`code`', 'plain', 1],
			\ [5, '` and', 'plain', 1], [5, 'italic', 'linkBoldItalic'],
			\ [6, 'bold', 'linkBold'], [6, 'italic', 'linkItalic'],
			\ [6, 'code', 'linkBold'], [6, '`code`', 'plain', 1],
			\ [6, '`]', 'plain', 1], [6, '#format', 'link'],
			\ [7, 'ref', 'link'], [7, 'https://example.com/#reference', 'link'],
			\ [8, 'reference', 'link'], [8, 'ref]', 'link', 3]]],
		\ ['markdown', [
			\ '    **four spaces**',
			\ '        **eight spaces**',
			\ "\t**tab indent**",
			\ '   Ordinary **bold** prose'], [
			\ [1, '**four spaces**', 'plain'], [2, '**eight spaces**', 'plain'],
			\ [3, '**tab indent**', 'plain'], [4, 'Ordinary', 'plain'],
			\ [4, 'bold', 'bold']]],
		\ ['awk', [
			\ '$1 ~ /foo/ && /if 42/ { print $1 }',
			\ '$1 ~ /foo/ || /while 7/ { print $1 }',
			\ '{ print value / 2 }'], [
			\ [1, '/if 42/', 'plain'], [1, 'print', 'keyword'],
			\ [2, '/while 7/', 'plain'], [3, 'print', 'keyword'],
			\ [3, '2', 'number']]],
		\ ['perl', [
			\ '$line =~ /foo/ && /if 42/;',
			\ '$line =~ /foo/ || /while 7/;',
			\ 'print $value / 2;'], [
			\ [1, '/if 42/', 'plain'], [2, '/while 7/', 'plain'],
			\ [3, 'print', 'keyword'], [3, '2', 'number']]],
		\ ['css', [
			\ '.card[data-label="hello"] {',
			\ '  content: "hello\000026 world\"";',
			\ "  font-family: 'Demo Font';",
			\ '  margin: 12px; opacity: 0.5;',
			\ '  color: #aabbcc; display: block;',
			\ '  background-image: url("image.svg");',
			\ '  /* TODO: "not a string" */',
			\ '}',
			\ '.na\6de { content: "done"; }'], [
			\ [1, '.card', 'plain'], [1, 'data-label', 'plain'],
			\ [1, '"hello"', 'string'], [2, 'content', 'plain'],
			\ [2, '"hello', 'string'], [2, '\000026', 'string'],
			\ [2, 'world\""', 'string'], [3, 'font-family', 'plain'],
			\ [3, "'Demo Font'", 'string'], [4, 'margin', 'plain'],
			\ [4, '12px', 'number'], [4, '0.5', 'number'],
			\ [5, 'color', 'plain'], [5, '#aabbcc', 'constant'],
			\ [5, 'block', 'constant'], [6, 'background-image', 'plain'],
			\ [6, '"image.svg"', 'string'], [7, 'TODO', 'comment'],
			\ [7, '"not a string"', 'comment'],
			\ [9, '.na\6de', 'plain'], [9, '"done"', 'string']]],
		\ ['css', [
			\ '.card { content: "}"; color: red; }',
			\ '@media (min-width: 400px) { .card { padding: 2em; } }',
			\ '.other { content: "after"; }'], [
			\ [1, '"}"', 'string'], [1, 'color', 'plain'],
			\ [1, 'red', 'constant'], [2, 'padding', 'plain'],
			\ [2, '2em', 'number'], [3, '"after"', 'string']]],
		\ ['json', [
			\ '{',
			\ '  "name": "hello",',
			\ '  "escaped\"key": "line\n\u0041",',
			\ '  "empty": "",',
			\ '  "": "empty key",',
			\ '  "count": 42, "scale": -2.5e3,',
			\ '  "enabled": true, "nothing": null,',
			\ '  "items": ["one", "", {"nested": "two"}]',
			\ '}'], [
			\ [2, '"name"', 'plain'], [2, '"hello"', 'string'],
			\ [3, '"escaped\"key"', 'plain'], [3, '"line\n\u0041"', 'string'],
			\ [4, '"empty"', 'plain'], [4, '""', 'string'],
			\ [5, '""', 'plain'], [5, '"empty key"', 'string'],
			\ [6, '"count"', 'plain'], [6, '42', 'number'],
			\ [6, '"scale"', 'plain'], [6, '-2.5e3', 'number'],
			\ [7, '"enabled"', 'plain'], [7, 'true', 'constant'],
			\ [7, '"nothing"', 'plain'], [7, 'null', 'constant'],
			\ [8, '"items"', 'plain'], [8, '"one"', 'string'],
			\ [8, '""', 'string'], [8, '"nested"', 'plain'],
			\ [8, '"two"', 'string']]],
		\ ['yaml', [
			\ 'plain: hello world',
			\ 'double: "line\n\u0041"',
			\ "single: 'it''s text'",
			\ '"quoted key": "value"',
			\ '"escaped\"key": text',
			\ 'count: 42',
			\ 'enabled: true',
			\ 'nothing: null',
			\ 'flow: {name: "hello", "quoted": plain, count: 2}',
			\ 'items: ["one", two, 3]',
			\ 'sequence:',
			\ '  - name: item',
			\ '  - "quoted": "text"',
			\ 'literal: | # header comment',
			\ '  text: "not a key"',
			\ '  # literal text, not a comment',
			\ '  42 true',
			\ 'after: done',
			\ 'folded: >-',
			\ '  hello',
			\ '  world',
			\ 'last: end',
			\ 'true: value',
			\ '"123": "true"',
			\ 'jsonstyle: {"key":"value"}',
			\ '# TODO: "not a string"'], [
			\ [1, 'plain', 'plain'], [1, 'hello', 'string'],
			\ [1, 'world', 'string'],
			\ [2, 'double', 'plain'], [2, '"line\n\u0041"', 'string'],
			\ [3, 'single', 'plain'], [3, "'it''s text'", 'string'],
			\ [4, '"quoted key"', 'plain'], [4, '"value"', 'string'],
			\ [5, '"escaped\"key"', 'plain'], [5, 'text', 'string'],
			\ [6, 'count', 'plain'], [6, '42', 'number'],
			\ [7, 'enabled', 'plain'], [7, 'true', 'constant'],
			\ [8, 'nothing', 'plain'], [8, 'null', 'constant'],
			\ [9, 'name', 'plain'], [9, '"hello"', 'string'],
			\ [9, '"quoted"', 'plain'], [9, 'plain', 'string'],
			\ [9, 'count', 'plain'], [9, '2', 'number'],
			\ [10, 'items', 'plain'], [10, '"one"', 'string'],
			\ [10, 'two', 'string'], [10, '3', 'number'],
			\ [12, 'name', 'plain'], [12, 'item', 'string'],
			\ [13, '"quoted"', 'plain'], [13, '"text"', 'string'],
			\ [14, 'literal', 'plain'], [14, 'header comment', 'comment'],
			\ [15, 'text: "not a key"', 'string'],
			\ [16, '# literal text, not a comment', 'string'],
			\ [17, '42 true', 'string'], [18, 'after', 'plain'],
			\ [18, 'done', 'string'], [20, 'hello', 'string'],
			\ [21, 'world', 'string'], [22, 'last', 'plain'],
			\ [22, 'end', 'string'], [23, 'true', 'plain'],
			\ [24, '"123"', 'plain'], [24, '"true"', 'string'],
			\ [25, '"key"', 'plain'], [25, '"value"', 'string'],
			\ [26, 'TODO', 'comment'], [26, '"not a string"', 'comment']]],
		\ ['yaml', [
			\ 'empty: ""',
			\ '"": "empty key"',
			\ 'url: https://example.com/path#fragment',
			\ 'phrase: hello 42 true',
			\ 'numbers: [-2.5e3, 0x2a, 0o52, .inf]',
			\ 'flags: [false, null, ~]',
			\ 'nested: [{name: "one"}, {name: two}]',
			\ '- "list value"',
			\ '- bare text',
			\ 'root value',
			\ '  block: |+',
			\ '    hello',
			\ '',
			\ '    # block text',
			\ '  next: done',
			\ 'tail: value # inline comment'], [
			\ [1, 'empty', 'plain'], [1, '""', 'string'],
			\ [2, '""', 'plain'], [2, '"empty key"', 'string'],
			\ [3, 'url', 'plain'], [3, 'https://example.com/path#fragment', 'string'],
			\ [4, 'hello 42 true', 'string'],
			\ [5, '-2.5e3', 'number'], [5, '0x2a', 'number'],
			\ [5, '0o52', 'number'], [5, '.inf', 'number'],
			\ [6, 'false', 'constant'], [6, 'null', 'constant'],
			\ [6, '~', 'constant'], [7, 'name', 'plain'],
			\ [7, '"one"', 'string'], [7, 'two', 'string'],
			\ [8, '"list value"', 'string'], [9, 'bare text', 'string'],
			\ [10, 'root value', 'string'], [12, 'hello', 'string'],
			\ [14, '# block text', 'string'], [15, 'next', 'plain'],
			\ [15, 'done', 'string'], [16, 'value', 'string'],
			\ [16, 'inline comment', 'comment']]],
		\ ['conf', [
			\ 'name = "plain string"',
			\ "other = 'plain too'",
			\ '# TODO: "not a string"'], [
			\ [1, 'name', 'plain'], [1, '"plain string"', 'plain'],
			\ [2, "'plain too'", 'plain'], [3, 'TODO', 'comment']]],
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
		\ ['perl', [
			\ 'my $broken = "unfinished',
			\ 'print "done", 42;',
			\ 'my $broken = qq{unfinished',
			\ 'print "after", 2;'], [
			\ [1, 'unfinished', 'plain'], [2, 'print', 'keyword'],
			\ [2, '"done"', 'string'], [2, '42', 'number'],
			\ [3, 'unfinished', 'plain'], [4, 'print', 'keyword'],
			\ [4, '"after"', 'string'], [4, '2', 'number']]],
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
		if s:fixture[0] ==# 'yaml'
			call assert_equal('yaml', &syntax, 'YAML uses our standalone lexer')
		endif
		if index(['javascript', 'typescript'], s:fixture[0]) >= 0
			call assert_equal(s:fixture[0], &syntax)
			call assert_notmatch('\n\%(javaScriptNumber\|typescriptNumber\)\s',
				\ execute('syntax list'), 'Bundled JS/TS grammar must not be loaded')
		endif
		if index(['json', 'yaml'], s:fixture[0]) >= 0
			call assert_notmatch('\n\%(jsonNoQuotesError\|yamlFloat\)\s',
				\ execute('syntax list'), 'Bundled data grammar must not be loaded')
		endif
		if index(['html', 'css'], s:fixture[0]) >= 0
			call assert_notmatch('\n\%(htmlTagError\|cssTagName\)\s',
				\ execute('syntax list'), 'Bundled markup grammar must not be loaded')
		endif
		if index(['awk', 'perl', 'sh'], s:fixture[0]) >= 0
			call assert_notmatch('\n\%(awkOperator\|perlStatementInclude\|shFunctionTwo\)\s',
				\ execute('syntax list'), 'Bundled filter/shell grammar must not be loaded')
		endif
		if s:fixture[0] ==# 'markdown'
			call assert_notmatch('\n\%(markdownError\|markdownValid\)\s',
				\ execute('syntax list'), 'Bundled Markdown grammar must not be loaded')
		endif
		let s:native_syntax = b:current_syntax
		let s:syntax = &syntax
		for s:reload in range(3)
			if s:reload == 2
				execute 'set syntax=' . s:syntax
				call assert_equal(s:native_syntax, b:current_syntax)
			endif
			if s:reload
				colorscheme basic
			endif
			syntax sync fromstart
			if s:fixture[0] ==# 'markdown'
				for s:line in range(1, line('$'))
					if getline(s:line) =~# '^#\{1,6} '
						call assert_equal(0, synconcealed(s:line, 1)[0], 'Title markers must stay visible')
					endif
				endfor
			endif
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

" Perl synchronization must not escape a long shell-embedded program.
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

" Owned code fences work together without a test-specific language list.
let s:fences = [
	\ ['sh', 'if true; then echo "hello" 42; fi', [['if', 'keyword'], ['42', 'number']]],
	\ ['bash', 'if true; then echo "hello" 42; fi', [['if', 'keyword'], ['42', 'number']]],
	\ ['javascript', 'const type = 42;', [['const', 'keyword'], ['type', 'plain'], ['42', 'number']]],
	\ ['js', 'const value = 42;', [['const', 'keyword'], ['42', 'number']]],
	\ ['typescript', 'type Value = number;', [['type', 'keyword']]],
	\ ['ts', 'type Value = number;', [['type', 'keyword']]],
	\ ['json', '{"value": "text", "count": 42}', [['value', 'plain'], ['text', 'string'], ['42', 'number']]],
	\ ['yaml', 'value: "text"', [['value', 'plain'], ['text', 'string']]],
	\ ['yml', 'value: "text"', [['value', 'plain'], ['text', 'string']]],
	\ ['html', '<div title="text">hello</div>', [['text', 'string']]],
	\ ['css', 'body { width: 42px; }', [['42', 'number']]],
	\ ['awk', 'BEGIN { print "text", 42 }', [['BEGIN', 'keyword'], ['text', 'string'], ['42', 'number']]],
	\ ['perl', 'my $count = 42; print "text";', [['my', 'keyword'], ['42', 'number'], ['text', 'string']]]]
let s:fence_lines = []
for s:fence in s:fences
	call extend(s:fence_lines, ['```' . s:fence[0], s:fence[1], '```', 'if true'])
endfor
enew
call setline(1, s:fence_lines)
setfiletype markdown
for s:i in range(len(s:fences))
	let s:fence = s:fences[s:i]
	let s:line = 4 * s:i + 2
	for s:case in s:fence[2]
		call assert_equal(s:styles[s:case[1]], s:Style(synID(s:line, stridx(getline(s:line), s:case[0]) + 1, 1)),
			\ s:fence[0] . ' default fence ' . s:case[0])
	endfor
	call assert_equal(s:plain, s:Style(synID(s:line + 2, 1, 1)),
		\ s:fence[0] . ' fence syntax stays out of prose')
endfor
bwipeout!
unlet s:fences s:fence_lines

" Markdown aliases share lexers without changing another language's boundaries.
enew
call setline(1, ['```js', 'const count = value-2;', '```',
	\ '~~~bash', 'if true; then echo "$count"; fi', '~~~',
	\ '```{.js}', 'const title = "hello";', '```',
	\ '```md', '# plain', '```',
	\ '```js', 'const type = 42; const text = `${value as name}`;', '```',
	\ '```ts', 'const text = `${value as Name}`;', '```',
	\ '```json', '{"count": 42}', '```'])
let v:errmsg = ''
setfiletype markdown
call assert_equal('', v:errmsg, 'Markdown syntax imports must load without errors')
call assert_equal(s:keyword, s:Style(synID(2, 1, 1)))
call assert_equal(s:number, s:Style(synID(2, stridx(getline(2), '2') + 1, 1)))
call assert_equal(s:keyword, s:Style(synID(5, 1, 1)))
call assert_equal(s:string, s:Style(synID(8, stridx(getline(8), '"hello"') + 1, 1)))
call assert_equal(s:plain, s:Style(synID(11, 1, 1)))
call assert_equal(s:plain, s:Style(synID(14, stridx(getline(14), 'type') + 1, 1)))
call assert_equal(s:plain, s:Style(synID(14, stridx(getline(14), 'as name') + 1, 1)))
call assert_equal(s:keyword, s:Style(synID(17, stridx(getline(17), 'as Name') + 1, 1)))
call assert_equal(s:number, s:Style(synID(20, stridx(getline(20), '42') + 1, 1)))
call assert_notmatch('\n\%(typescriptNumber\|typescriptAliasKeyword\)\s',
	\ execute('syntax list'), 'TypeScript fences must not load the bundled grammar')
bwipeout!

" A long fence must work on the first query near the file's end.
let s:markdown_file = tempname() . '.md'
call writefile(['```javascript'] + repeat(['// filler'], 450) +
	\ ['const title = "done";', '```', '# After fence'], s:markdown_file)
execute 'edit' fnameescape(s:markdown_file)
call assert_equal(s:string, s:Style(synID(452, stridx(getline(452), '"done"') + 1, 1)))
call assert_equal(s:keyword, s:Style(synID(454, 1, 1)))
bwipeout!
call delete(s:markdown_file)

enew
let b:markdown_yaml_head = 0
call setline(1, ['---', 'title: hello', '...'])
setfiletype markdown
call assert_equal(s:plain, s:Style(synID(2, stridx(getline(2), 'hello') + 1, 1)))
bwipeout!

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
