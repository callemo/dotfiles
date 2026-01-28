#!/bin/sh
# test.sh: test cases for dotfiles programs

: "${DOTFILES:=$HOME/dotfiles}"

case "$PATH" in
$DOTFILES/bin:*) ;;
*)               PATH="$DOTFILES/bin:$PATH"; export PATH;;
esac

echo 'urlencode:'
printf '\n' | ./bin/urlencode; echo
printf ' ' | ./bin/urlencode; echo
printf '!#$%%&'\''()*+,/:;=?@[]' | ./bin/urlencode; echo
printf 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' | ./bin/urlencode; echo
printf 'abcdefghijklmnopqrstuvwxyz' | ./bin/urlencode; echo
printf '0123456789-_.~' | ./bin/urlencode; echo
printf '€äöå…' | ./bin/urlencode; echo

echo 'urldecode:'
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

echo
echo 'noco:'
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
echo
echo 'tabfmt:'
echo "$tsv" | tabfmt
echo "$tsv" | tabfmt -p | sed 's/$/$/'
echo "$tsv" | tabfmt -p -d' | ' | sed 's/^/| /; s/$/ |/'
echo 'v_1_1 v_1_2 v_1_3' | tabfmt -d' | '
echo 'v_1_1 v_1_2 v_1_3' | tabfmt -F'[ \t][ \t]*' -d' | '

echo
echo 'tabmd:'
printf 'c_1	c__2	c___3\n%s\n' "$tsv" | tabmd
echo 'c0 | c_1,c__2,c___3
v_1_1,v_1__2,v_1___3
v_2___3,v_2_1,v_2__2
v_3__2,v_3___3,v_3_1' | tabmd -F,

echo
echo 'csvtab:'
echo 'one,two,three
one,"two ,","three "","""' | csvtab

echo
echo '--- template:'
tmpl=/tmp/test1.$$
trap 'rm -r $tmpl' 0
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

echo '--- fsg:'
fsg '/(fsg|fts)$' | sort
echo $?

echo
echo '--- rgsub:'
testdir=/tmp/rgsub_test.$$
mkdir -p "$testdir"
trap 'rm -rf "$testdir"' EXIT

cat >"$testdir/test1.txt" <<-'END'
foo bar
foo baz
END
(cd "$testdir" && rgsub 'foo' 'REPLACED')
cat "$testdir/test1.txt"

cat >"$testdir/test2.txt" <<-'END'
path/to/file.txt
another/path/here
END
(cd "$testdir" && rgsub 'path/to' 'new/location')
cat "$testdir/test2.txt"

cat >"$testdir/test3.txt" <<-'END'
line before
line with pattern
line after
END
echo 'Dry-run test:'
(cd "$testdir" && rgsub -n 'pattern' 'CHANGED' >/dev/null 2>&1)
echo $?
cat "$testdir/test3.txt"

(cd "$testdir" && rgsub 'NOTFOUND' 'anything' >/dev/null 2>&1)
echo $?

cat >"$testdir/test5.txt" <<-'END'
version 1.2.3
version 4.5.6
END
(cd "$testdir" && rgsub 'version [0-9.]+' 'version X.Y.Z')
cat "$testdir/test5.txt"

before=$(ls /tmp/rgsub.* 2>/dev/null | wc -l | tr -d ' ')
cat >"$testdir/test6.txt" <<-'END'
test data
END
(cd "$testdir" && rgsub -n 'test' 'changed' >/dev/null 2>&1)
after=$(ls /tmp/rgsub.* 2>/dev/null | wc -l | tr -d ' ')
echo "Temp files: $before -> $after"

mkdir "$testdir/sub1" "$testdir/sub2"
echo "target text" > "$testdir/sub1/file.txt"
echo "target text" > "$testdir/sub2/file.txt"
echo "target text" > "$testdir/file.txt"
(cd "$testdir" && rgsub 'target' 'FOUND' sub1)
cat "$testdir"/*/file.txt "$testdir/file.txt"

echo
echo '--- snake:'
echo 'fooBar' | snake
echo 'FooBarBaz' | snake
echo 'alreadySnake' | snake
echo 'XMLParser' | snake

echo
echo '--- camel:'
echo 'foo_bar' | camel
echo 'foo_bar_baz' | camel
echo 'SCREAMING_SNAKE' | camel

echo
echo '--- pareto:'
printf '100\tapples\n50\toranges\n30\tbananas\n20\tgrapes\n' | pareto
printf 'apples\t100\noranges\t50\nbananas\t30\ngrapes\t20\n' | pareto -n 2

echo
echo '--- overwrite:'
owtest="$testdir/overwrite_test.txt"
echo 'original content' >"$owtest"
cat "$owtest" | overwrite "$owtest" tr a-z A-Z
cat "$owtest"
echo 'line1
line2
line3' >"$owtest"
cat "$owtest" | overwrite "$owtest" sort -r
cat "$owtest"
