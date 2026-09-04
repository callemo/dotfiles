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
cp "$DOTFILES/lib/install" "$repo/lib/install"
cp "$DOTFILES/vim/get" "$repo/vim/get"
cp -R "$DOTFILES/t490" "$repo/t490"
printf '%s\n' 't490 vim' >"$repo/t490/dot.vimrc"
mkdir -p "$repo/dot.config/picom"
cp "$DOTFILES/dot.config/picom/picom.conf" "$repo/dot.config/picom/"
cp -R "$repo" "$future"
rm -rf "$future/t490"
mkdir -p "$future/x270/dot.config/picom"
printf '%s\n' 'future x270 defaults' >"$future/x270/dot.Xdefaults"
printf '%s\n' 'future x270 picom' \
	>"$future/x270/dot.config/picom/picom.conf"

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
cat >"$mock/available" <<'EOF'
#!/bin/sh
exit 0
EOF
for command in pkg_info feh lowdown mousepad mupdf-gl picom thunar \
	xsel xwallpaper; do
	ln -s available "$mock/$command"
done
cat >"$mock/gsettings" <<'EOF'
#!/bin/sh
printf 'gsettings' >>"${TEST_COMMAND_LOG:?}"
printf ' %s' "$@" >>"$TEST_COMMAND_LOG"
printf '\n' >>"$TEST_COMMAND_LOG"
EOF
cat >"$mock/xdg-mime" <<'EOF'
#!/bin/sh
printf 'xdg-mime' >>"${TEST_COMMAND_LOG:?}"
printf ' %s' "$@" >>"$TEST_COMMAND_LOG"
printf '\n' >>"$TEST_COMMAND_LOG"
[ "${1-}" != query ]
EOF
cat >"$mock/xfconf-query" <<'EOF'
#!/bin/sh
printf 'xfconf-query' >>"${TEST_COMMAND_LOG:?}"
printf ' %s' "$@" >>"$TEST_COMMAND_LOG"
printf '\n' >>"$TEST_COMMAND_LOG"
[ "$#" -ne 4 ]
EOF
cat >"$mock/update-desktop-database" <<'EOF'
#!/bin/sh
printf 'update-desktop-database' >>"${TEST_COMMAND_LOG:?}"
printf ' %s' "$@" >>"$TEST_COMMAND_LOG"
printf '\n' >>"$TEST_COMMAND_LOG"
EOF
cat >"$mock/doas" <<'EOF'
#!/bin/sh
printf 'doas' >>"${TEST_COMMAND_LOG:?}"
printf ' %s' "$@" >>"$TEST_COMMAND_LOG"
printf '\n' >>"$TEST_COMMAND_LOG"
exit 99
EOF
chmod +x "$mock"/*

die() {
	printf '%s\n' "test_install: $*" >&2
	exit 1
}

seedhome() {
	local home
	home=$1
	mkdir -p "$home/.local/share/applications"
	printf '%s\n' 'manual vim override' >"$home/.vimrc.local"
	printf '%s\n' 'manual tmux override' >"$home/.tmux.conf.local"
	printf '%s\n' 'manual desktop entry' \
		>"$home/.local/share/applications/manual.desktop"
	printf '%s\n' 'gtk-color-scheme="old"' >"$home/.gtkrc-2.0"
	cp "$home/.vimrc.local" "$home/vimrc.before"
	cp "$home/.tmux.conf.local" "$home/tmux.before"
	cp "$home/.local/share/applications/manual.desktop" \
		"$home/manual.desktop.before"
	: >"$home/commands.log"
}

runenv() {
	local src host home
	src=$1
	host=$2
	home=$3
	shift 3
	TEST_HOST=$host TEST_COMMAND_LOG=$home/commands.log \
	HOME=$home PATH=$mock:/bin:/usr/bin \
	XDG_CONFIG_HOME=$home/.config \
	XDG_DATA_HOME=$home/.local/share \
	DBUS_SESSION_BUS_ADDRESS='' \
		"$@"
}

install() {
	local src host home
	src=$1
	host=$2
	home=$3
	runenv "$src" "$host" "$home" "$src/install" >/dev/null 2>&1
}

setup() {
	local src home
	src=$1
	home=$2
	runenv "$src" t490 "$home" "$src/t490/setup.sh" >/dev/null 2>&1
}

newhome() {
	local src host home
	src=$1
	host=$2
	home=$(mktemp -d "$td/home.XXXXXX")
	seedhome "$home"
	install "$src" "$host" "$home"
	printf '%s\n' "$home"
}

hostlinks() {
	local home f n
	home=$1
	n=0
	for f in .Xdefaults .fvwmrc .xsession .vimrc \
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
	got=$(hostlinks "$home")
	[ "$got" -eq "$want" ] ||
		die "$host: got $got host links, want $want"
}

testlink() {
	local link want got
	link=$1
	want=$2
	got=$(readlink "$link") || die "$link is not a symlink"
	[ "$got" = "$want" ] || die "$link points to $got, want $want"
}

checkstate() {
	local home
	home=$1
	cmp "$home/vimrc.before" "$home/.vimrc.local" \
		|| die '.vimrc.local changed'
	cmp "$home/tmux.before" "$home/.tmux.conf.local" \
		|| die '.tmux.conf.local changed'
	cmp "$home/manual.desktop.before" \
		"$home/.local/share/applications/manual.desktop" \
		|| die 'unrelated desktop entry changed'
	[ "$(grep -c '^gtk-color-scheme=' "$home/.gtkrc-2.0")" -eq 1 ] \
		|| die 'GTK color scheme was duplicated'
	grep -qF '\ntext_color:#d4be98' "$home/.gtkrc-2.0" \
		|| die 'GTK color scheme lost literal backslash-n separators'
	grep -q '^include ".*/\.gtkrc-2\.0-items"$' "$home/.gtkrc-2.0" \
		|| die 'GTK 2 include missing'
	grep -q '^gsettings ' "$home/commands.log" \
		|| die 'gsettings was not called'
	grep -q '^xdg-mime ' "$home/commands.log" \
		|| die 'xdg-mime was not called'
	grep -q '^xfconf-query ' "$home/commands.log" \
		|| die 'xfconf-query was not called'
	grep -q '^update-desktop-database ' "$home/commands.log" \
		|| die 'desktop database was not refreshed'
	if grep -q '^doas ' "$home/commands.log"; then
		die 'T490 setup called doas'
	fi
}

for host in t490 t490.home.arpa; do
	testhost "$repo" "$host" 5
done
for host in x270 x270.home.arpa laptop myt490 t490x node.t490 \
	myx270 x270-old node.x270; do
	testhost "$repo" "$host" 1
done

home=$(newhome "$repo" t490)
testlink "$home/.vimrc" "$repo/t490/dot.vimrc"
testlink "$home/.config/picom/picom.conf" \
	"$repo/dot.config/picom/picom.conf"
for path in \
	.config/feh/buttons \
	.config/feh/keys \
	.config/feh/themes \
	.config/gtk-3.0/bookmarks \
	.config/gtk-3.0/gtk.css \
	.config/gtk-4.0/gtk.css \
	.config/gtk-colors.css \
	.config/Thunar/uca.xml \
	.config/tmux/host.conf \
	.config/vim/host.vim
do
	testlink "$home/$path" "$repo/t490/dot.${path#.}"
done
testlink "$home/.gtkrc-2.0-items" "$repo/t490/dot.gtkrc-2.0-items"
[ ! -L "$home/.local/share/applications/mupdf.desktop" ] \
	|| die 'MuPDF entry is a symlink'
cmp "$repo/t490/applications/mupdf.desktop" \
	"$home/.local/share/applications/mupdf.desktop" \
	|| die 'MuPDF entry differs from its managed source'
[ ! -e "$home/bin/md-preview" ] && [ ! -L "$home/bin/md-preview" ] \
	|| die 'setup retained ~/bin/md-preview'
[ ! -e "$home/bin/xterm-here" ] && [ ! -L "$home/bin/xterm-here" ] \
	|| die 'setup retained ~/bin/xterm-here'
checkstate "$home"
install "$repo" t490.home.arpa "$home"
checkstate "$home"

# Exercise setup directly so its failure cannot be hidden by the main installer.
home=$(mktemp -d "$td/setup.XXXXXX")
seedhome "$home"
setup "$repo" "$home"
setup "$repo" "$home"
checkstate "$home"

for host in x270 x270.home.arpa; do
	testhost "$future" "$host" 2
done
for host in myx270 x270-old node.x270; do
	testhost "$future" "$host" 1
done

home=$(newhome "$future" x270.home.arpa)
testlink "$home/.Xdefaults" "$future/x270/dot.Xdefaults"
testlink "$home/.config/picom/picom.conf" \
	"$future/x270/dot.config/picom/picom.conf"

home=$td/stale
mkdir -p "$home/.config/tmux" "$home/.local/share/applications"
for path in t490/dot.Xdefaults t490/dot.fvwmrc t490/dot.xsession \
	t490/dot.vimrc; do
	ln -s "$repo/$path" "$home/${path##*/dot}"
done
ln -s "$repo/t490/dot.config/tmux/host.conf" \
	"$home/.config/tmux/host.conf"
ln -s "$repo/t490/applications/mupdf.desktop" \
	"$home/.local/share/applications/mupdf.desktop"
install "$repo" x270 "$home"
[ "$(hostlinks "$home")" -eq 1 ] || die 'x270 retained obsolete host links'
[ ! -L "$home/.config/tmux/host.conf" ] \
	|| die 'x270 retained T490 tmux config'
[ ! -L "$home/.local/share/applications/mupdf.desktop" ] \
	|| die 'x270 retained T490 MuPDF entry'
testlink "$home/.config/picom/picom.conf" \
	"$repo/dot.config/picom/picom.conf"

home=$td/legacy
mkdir -p "$home"
for path in dot.Xdefaults dot.fvwmrc dot.xsession; do
	ln -s "$repo/$path" "$home/${path#dot}"
done
install "$repo" x270 "$home"
[ "$(hostlinks "$home")" -eq 1 ] || die 'install kept pre-scoping links'

home=$td/preserve
mkdir -p "$home"
printf '%s\n' native-defaults >"$home/.Xdefaults"
printf '%s\n' user-fvwm >"$td/user-fvwmrc"
ln -s "$td/user-fvwmrc" "$home/.fvwmrc"
ln -s "$td/missing-xsession" "$home/.xsession"
install "$repo" x270 "$home"
[ "$(cat "$home/.Xdefaults")" = native-defaults ] \
	|| die 'native X defaults changed'
testlink "$home/.fvwmrc" "$td/user-fvwmrc"
testlink "$home/.xsession" "$td/missing-xsession"
