#!/bin/sh
set -eu

: "${DOTFILES:=$(pwd)}"

td=$(mktemp -d "${TMPDIR:-/tmp}/test_install.XXXXXX")
trap 'rm -rf "$td"' EXIT HUP INT TERM
repo=$td/current
future=$td/future
mock=$td/bin
mkdir -p "$repo/bin" "$repo/vim" "$repo/lib" "$mock"
cp "$DOTFILES/install" "$repo/install"
cp "$DOTFILES/.gitignore" "$repo/.gitignore"
cp "$DOTFILES/bin/overwrite" "$repo/bin/overwrite"
cp "$DOTFILES/vim/get" "$repo/vim/get"
cp -R "$DOTFILES/x11" "$repo/x11"
cp -R "$repo" "$future"
rm -rf "$future/x11/t490"
mkdir -p "$future/x11/x270/dot.config/picom"
printf '%s\n' 'future x270 defaults' >"$future/x11/x270/dot.Xdefaults"
printf '%s\n' 'future x270 picom' \
	>"$future/x11/x270/dot.config/picom/picom.conf"

cat >"$mock/uname" <<'EOF'
#!/bin/sh
[ "$1" = -n ] || exit 2
printf '%s\n' "${TEST_HOST:?}"
EOF
cat >"$mock/git" <<'EOF'
#!/bin/sh
exit 0
EOF
cat >"$mock/btop" <<'EOF'
#!/bin/sh
printf '%s\n' 'color_theme = "TTY"' 'theme_background = false'
EOF
chmod +x "$mock/uname" "$mock/git" "$mock/btop"

die() {
	printf '%s\n' "test_install: $*" >&2
	exit 1
}

install() {
	local src host home
	src=$1
	host=$2
	home=$3
	TEST_HOST=$host HOME=$home PATH=$mock:/bin:/usr/bin \
		"$src/install" >/dev/null 2>&1
}

newhome() {
	local src host home
	src=$1
	host=$2
	home=$(mktemp -d "$td/home.XXXXXX")
	install "$src" "$host" "$home"
	printf '%s\n' "$home"
}

xlinks() {
	local home f n
	home=$1
	n=0
	for f in .Xdefaults .fvwmrc .xsession \
		.config/picom/picom.conf; do
		[ ! -L "$home/$f" ] || n=$((n + 1))
	done
	printf '%s\n' "$n"
}

testhost() {
	local src host want home got
	src=$1
	host=$2
	want=$3
	home=$(newhome "$src" "$host")
	got=$(xlinks "$home")
	[ "$got" -eq "$want" ] ||
		die "$host: got $got X11 links, want $want"
}

testlink() {
	local link want got
	link=$1
	want=$2
	got=$(readlink "$link") || die "$link is not a symlink"
	[ "$got" = "$want" ] || die "$link points to $got, want $want"
}

for host in t490 t490.home.arpa; do
	testhost "$repo" "$host" 4
done
for host in x270 x270.home.arpa laptop myt490 t490x node.t490 \
	myx270 x270-old node.x270; do
	testhost "$repo" "$host" 0
done

home=$(newhome "$repo" t490)
testlink "$home/.config/picom/picom.conf" \
	"$repo/x11/t490/dot.config/picom/picom.conf"

for host in x270 x270.home.arpa; do
	testhost "$future" "$host" 2
done
for host in myx270 x270-old node.x270; do
	testhost "$future" "$host" 0
done

home=$(newhome "$future" x270.home.arpa)
testlink "$home/.Xdefaults" "$future/x11/x270/dot.Xdefaults"
testlink "$home/.config/picom/picom.conf" \
	"$future/x11/x270/dot.config/picom/picom.conf"

home=$td/stale
mkdir -p "$home/.config/picom"
for path in dot.Xdefaults dot.fvwmrc dot.xsession \
	dot.config/picom/picom.conf; do
	case "$path" in
	dot.config/*) link=$home/.config/${path#dot.config/} ;;
	*) link=$home/${path#dot} ;;
	esac
	ln -s "$repo/$path" "$link"
done
install "$repo" x270 "$home"
[ "$(xlinks "$home")" -eq 0 ] || die 'x270 retained obsolete X11 links'

home=$td/preserve
mkdir -p "$home/.config/picom"
printf '%s\n' native-defaults >"$home/.Xdefaults"
printf '%s\n' native-picom >"$home/.config/picom/picom.conf"
printf '%s\n' user-fvwm >"$td/user-fvwmrc"
ln -s "$td/user-fvwmrc" "$home/.fvwmrc"
ln -s "$td/missing-xsession" "$home/.xsession"
install "$repo" x270 "$home"
[ "$(cat "$home/.Xdefaults")" = native-defaults ] ||
	die 'native X defaults changed'
[ "$(cat "$home/.config/picom/picom.conf")" = native-picom ] ||
	die 'native picom config changed'
testlink "$home/.fvwmrc" "$td/user-fvwmrc"
testlink "$home/.xsession" "$td/missing-xsession"
