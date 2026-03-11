#!/bin/sh
# test.sh: test cases for dotfiles programs

: "${DOTFILES:=$HOME/dotfiles}"

case $PATH in
$DOTFILES/bin:*) ;;
*) PATH="$DOTFILES/bin:$PATH"; export PATH ;;
esac

echo '--- urlencode'
printf '\n' | ./bin/urlencode; echo
printf ' ' | ./bin/urlencode; echo
printf '!#$%%&'\''()*+,/:;=?@[]' | ./bin/urlencode; echo
printf 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' | ./bin/urlencode; echo
printf 'abcdefghijklmnopqrstuvwxyz' | ./bin/urlencode; echo
printf '0123456789-_.~' | ./bin/urlencode; echo
printf '€äöå…' | ./bin/urlencode; echo

echo '--- urldecode'
printf '%%21%%23%%24%%25%%26%%27%%28%%29%%2A%%2B%%2C%%2F%%3A%%3B%%3D%%3F%%40%%5B%%5D' |
	./bin/urldecode; echo
printf '%%21%%23%%24%%25%%26%%27%%28%%29%%2A%%2B%%2C%%2F%%3A%%3B%%3D%%3F%%40%%5B%%5D' |
	./bin/urlencode -d; echo
printf '!#$%%&'\''()*+,/:;=?@[]' | ./bin/urldecode; echo
printf 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' | ./bin/urldecode; echo
printf 'abcdefghijklmnopqrstuvwxyz' | ./bin/urldecode; echo
printf '0123456789-_.~' | ./bin/urldecode; echo
printf '%%E2%%82%%AC%%C3%%A4%%C3%%B6%%C3%%A5%%E2%%80%%A6' | ./bin/urldecode; echo
echo | ./bin/urlencode -l
echo 'line1: word1 word2 word3
line2: word1 word2 word3
line2: word1 word2 word3' | ./bin/urlencode -l
echo | ./bin/urldecode -l
echo 'line1%3A%20word1%20word2%20word3
line2%3A%20word1%20word2%20word3
line2%3A%20word1%20word2%20word3' | ./bin/urldecode -l

echo '--- noco'
cat <<'END' | ./bin/noco
[30mBlack[0m
[31mRed[0m
[32mGreen[0m
[33mYellow[0m
[34mBlue[0m
[35mMagenta[0m
[36mCyan[0m
[37mWhite[0m
[90mBright black[0m
[91mBright red[0m
[92mBright green[0m
[93mBright yellow[0m
[94mBright blue[0m
[95mBright magenta[0m
[96mBright cyan[0m
[97mBright white[0m
END

tsv='v_1_1	v_1__2	v_1___3
v_2___3	v_2_1	v_2__2
v_3__2	v_3___3	v_3_1'
echo '--- tabfmt'
echo "$tsv" | tabfmt
echo "$tsv" | tabfmt -p | sed 's/$/$/'
echo "$tsv" | tabfmt -p -d' | ' | sed 's/^/| /; s/$/ |/'
echo 'v_1_1 v_1_2 v_1_3' | tabfmt -d' | '
echo 'v_1_1 v_1_2 v_1_3' | tabfmt -F'[ \t][ \t]*' -d' | '

echo '--- tabmd'
printf 'c_1	c__2	c___3\n%s\n' "$tsv" | tabmd
echo 'c0 | c_1,c__2,c___3
v_1_1,v_1__2,v_1___3
v_2___3,v_2_1,v_2__2
v_3__2,v_3___3,v_3_1' | tabmd -F,

echo '--- csvtab'
echo 'one,two,three
one,"two ,","three "","""' | csvtab

echo '--- template'
tmpl=/tmp/test1.$$
cat <<-'END' >$tmpl
{
  "lang": "{{1}}"
  1: "{{ 2}}",
  2: "{{3 }}",
  3: "{{ 4 }}"
}
END
cat <<-'END' | template -F ' ' $tmpl
en one two three
es uno dos tres
it uno due tre
END
echo $?
cat <<-'END' | template $tmpl
en	twenty one	twenty two	twenty three
END
echo $?

echo '--- fsg'
fsg '/(fsg|fts)$' | sort
echo $?

echo '--- rgsub'
td=/tmp/rgsub_test.$$
mkdir -p "$td"
trap 'rm -f "$tmpl"; rm -rf "$td"' EXIT

cat >"$td/test1.txt" <<-'END'
foo bar
foo baz
END
(cd "$td" && rgsub 'foo' 'REPLACED')
cat "$td/test1.txt"

cat >"$td/test2.txt" <<-'END'
path/to/file.txt
another/path/here
END
(cd "$td" && rgsub 'path/to' 'new/location')
cat "$td/test2.txt"

cat >"$td/test3.txt" <<-'END'
line before
line with pattern
line after
END
echo 'Dry-run test:'
(cd "$td" && rgsub -n 'pattern' 'CHANGED' >/dev/null 2>&1)
echo $?
cat "$td/test3.txt"

(cd "$td" && rgsub 'NOTFOUND' 'anything' >/dev/null 2>&1)
echo $?

cat >"$td/test5.txt" <<-'END'
version 1.2.3
version 4.5.6
END
(cd "$td" && rgsub 'version [0-9.]+' 'version X.Y.Z')
cat "$td/test5.txt"

n0=$(set -- /tmp/rgsub.*; [ -e "$1" ] && echo "$#" || echo 0)
cat >"$td/test6.txt" <<-'END'
test data
END
(cd "$td" && rgsub -n 'test' 'changed' >/dev/null 2>&1)
n1=$(set -- /tmp/rgsub.*; [ -e "$1" ] && echo "$#" || echo 0)
echo "Temp files: $n0 -> $n1"

mkdir "$td/sub1" "$td/sub2"
echo "target text" >"$td/sub1/file.txt"
echo "target text" >"$td/sub2/file.txt"
echo "target text" >"$td/file.txt"
(cd "$td" && rgsub 'target' 'FOUND' sub1)
cat "$td"/*/file.txt "$td/file.txt"

cat >"$td/test7.txt" <<-'END'
email@example.com
END
(cd "$td" && rgsub '@example' '@test')
cat "$td/test7.txt"

echo '--- n'
nd="$td/notes"
cp -R "$DOTFILES/testdata/n/tag" "$nd"

NROOT="$nd" ./bin/n -h
NROOT="$nd" ./bin/n garbage 2>&1; echo $?
NROOT="$nd" ./bin/n tag -h
NROOT="$nd" ./bin/n tag
NROOT="$nd" ./bin/n tag business safari
NROOT="$nd" ./bin/n tag BUSINESS safari
NROOT="$nd" ./bin/n tag business business safari
NROOT="$nd" ./bin/n tag writing safari
NROOT="$nd" ./bin/n tag nonexistent

echo '--- n look'
ld="$td/look"
cp -R "$DOTFILES/testdata/n/xref" "$ld"
NROOT="$ld" ./bin/n look alpha | sed "s|$ld/||"
NROOT="$ld" ./bin/n look 202603111200 | sed "s|$ld/||"
NROOT="$ld" ./bin/n look nonexistent | sed "s|$ld/||"
NROOT="$ld" ./bin/n look v1.2-release | sed "s|$ld/||"

echo '--- n xref'
xd="$td/xref"
cp -R "$DOTFILES/testdata/n/xref" "$xd"
NROOT="$xd" ./bin/n xref
for f in \
	202603111200-target-note.md \
	alpha.md \
	bravo.md \
	charlie.md \
	echo.md \
	golf.md \
	hotel.md \
	Z/R/n/subdir-src.md \
	202603111300-apple.md \
	202603111300-apricot.md \
	v1.2-release.md \
	v1-2-release.md \
	202603111158-short-source.txt \
	202603111201-source-note.md \
	202603111298-apricot-src.md \
	202603111299-ambig-src.md \
	delta.md \
	dot-source.md \
	foxtrot.md \
	sub/target.md \
	full-path-src.md \
	short-name-src.md
do
	sed -n '1,4p' "$xd/$f"
done

echo '--- snake'
echo 'fooBar' | snake
echo 'FooBarBaz' | snake
echo 'alreadySnake' | snake
echo 'XMLParser' | snake

echo '--- camel'
echo 'foo_bar' | camel
echo 'foo_bar_baz' | camel
echo 'SCREAMING_SNAKE' | camel

echo '--- pareto'
printf '100\tapples\n50\toranges\n30\tbananas\n20\tgrapes\n' | pareto
printf 'apples\t100\noranges\t50\nbananas\t30\ngrapes\t20\n' | pareto -n 2

echo '--- fivenum'
printf '1\n2\n3\n4\n5\n' | fivenum
printf '1\n2\n3\n4\n5\n6\n' | fivenum
printf '42\n' | fivenum
printf '10\n20\n' | fivenum
printf '3\n1\n4\n1\n5\n9\n2\n6\n' | fivenum
printf '1.5\n2.7\n3.3\n4.1\n5.9\n' | fivenum

echo '--- overwrite'
f="$td/overwrite_test.txt"
echo 'original content' >"$f"
cat "$f" | overwrite "$f" tr a-z A-Z
cat "$f"
echo 'line1
line2
line3' >"$f"
cat "$f" | overwrite "$f" sort -r
cat "$f"
