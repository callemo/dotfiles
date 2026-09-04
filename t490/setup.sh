#!/bin/sh
# Unprivileged T490 desktop setup.

prog=${0##*/}
root="$(CDPATH='' cd "${0%/*}" && pwd -P)" || exit 1
repo=${root%/*}
PATH="$repo/bin:$PATH"
export PATH

log() { printf '%s: %s\n' "$prog" "$*" >&2; }

. "$repo/lib/install" || exit 1

copyfile() (
	src=$1
	dst=$2
	mkdir -p "${dst%/*}" || {
		log "$dst: creating parent failed"
		return 1
	}
	[ ! -L "$dst" ] || rm -f "$dst" || return 1
	if [ -f "$dst" ]; then
		cmp -s "$src" "$dst" && return 0
		overwrite "$dst" cat "$src" || return 1
	else
		cp "$src" "$dst" || return 1
	fi
	log "$dst: copied"
)

mime() (
	desktop=$1
	shift
	command -v xdg-mime >/dev/null 2>&1 || {
		log 'MIME defaults unavailable (pkg_add xdg-utils)'
		return 0
	}
	status=0
	for type; do
		[ "$(xdg-mime query default "$type" 2>/dev/null)" = "$desktop" ] \
			&& continue
		xdg-mime default "$desktop" "$type" || {
			log "$type: setting $desktop failed"
			status=1
		}
	done
	return "$status"
)

gtksettings() (
	settings=$1
	theme=$2
	icons=$3
	mkdir -p "${settings%/*}" || return 1
	[ -f "$settings" ] || printf '[Settings]\n' >"$settings" || return 1
	fileline '^gtk-cursor-theme-name=' \
		'gtk-cursor-theme-name=Adwaita' "$settings" || return
	fileline '^gtk-cursor-theme-size=' \
		'gtk-cursor-theme-size=32' "$settings" || return
	fileline '^gtk-application-prefer-dark-theme=' \
		'gtk-application-prefer-dark-theme=1' "$settings" || return
	fileline '^gtk-theme-name=' "gtk-theme-name=$theme" "$settings" || return
	fileline '^gtk-icon-theme-name=' \
		"gtk-icon-theme-name=$icons" "$settings"
)

appearance() (
	config=${XDG_CONFIG_HOME:-"$HOME/.config"}
	mkdir -p "$HOME/.icons/default" || return 1
	cat >"$HOME/.icons/default/index.theme" <<-'EOF'
	[Icon Theme]
	Inherits=Adwaita
	EOF
	if command -v pkg_info >/dev/null 2>&1 \
		&& pkg_info -q -e 'yaru-*' >/dev/null 2>&1
	then
		theme=Yaru-wartybrown-dark
		icons=Yaru-wartybrown
	else
		theme=Adwaita
		icons=Adwaita
		log 'Gruvbox GTK support missing (pkg_add yaru)'
	fi
	gtk2=$HOME/.gtkrc-2.0
	fileline '^gtk-cursor-theme-name=' \
		'gtk-cursor-theme-name="Adwaita"' "$gtk2" || return
	fileline '^gtk-cursor-theme-size=' \
		'gtk-cursor-theme-size=32' "$gtk2" || return
	fileline '^gtk-theme-name=' "gtk-theme-name=\"$theme\"" "$gtk2" || return
	fileline '^gtk-icon-theme-name=' \
		"gtk-icon-theme-name=\"$icons\"" "$gtk2" || return
	scheme='gtk-color-scheme="fg_color:#d4be98'
	scheme=$scheme'\ntext_color:#d4be98'
	scheme=$scheme'\nmenubar_fg:#d4be98'
	scheme=$scheme'\ntooltip_fg_color:#d4be98'
	scheme=$scheme'\ninsensitive_fg_color:#928374'
	scheme=$scheme'\nmenubar_insensitive_fg:#928374'
	scheme=$scheme'\nlink_color:#7daea3'
	scheme=$scheme'\nvisited_link_color:#d3869b'
	scheme=$scheme'\nselected_fg_color:#f7f7f7"'
	fileline '^gtk-color-scheme=' "$scheme" "$gtk2" || return
	fileline '^include ".*\.gtkrc-2\.0-items"' \
		"include \"$HOME/.gtkrc-2.0-items\"" "$gtk2" || return
	gtksettings "$config/gtk-3.0/settings.ini" "$theme" "$icons" || return
	gtksettings "$config/gtk-4.0/settings.ini" "$theme" "$icons"
)

filechooser() (
	command -v gsettings >/dev/null 2>&1 || {
		log 'GTK file chooser settings unavailable (pkg_add glib2)'
		return 0
	}
	gsettings set org.gtk.Settings.FileChooser window-size '(900, 600)' || {
		log 'GTK file chooser size failed'
		return 1
	}
	gsettings set org.gtk.Settings.FileChooser window-position '(-1, -1)' || {
		log 'GTK file chooser position failed'
		return 1
	}
	log 'GTK file chooser: 900x600'
)

fehsetup() (
	command -v feh >/dev/null 2>&1 || {
		log 'image viewer missing (pkg_add feh)'
		return 0
	}
	mime feh.desktop image/jpeg image/png image/tiff \
		&& log 'Feh: image defaults and controls installed'
)

mupdf() (
	data=${XDG_DATA_HOME:-"$HOME/.local/share"}
	appdir=$data/applications
	copyfile "$root/applications/mupdf.desktop" "$appdir/mupdf.desktop" \
		|| return
	command -v mupdf-gl >/dev/null 2>&1 || {
		log 'MuPDF GL missing (pkg_add mupdf)'
		return 0
	}
	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database "$appdir" || return 1
	fi
	mime mupdf.desktop \
		application/pdf application/x-pdf application/x-cbz \
		application/oxps application/vnd.ms-xpsdocument \
		application/epub+zip \
		&& log 'MuPDF GL: document defaults installed'
)

viewers() (
	status=0
	if command -v mousepad >/dev/null 2>&1; then
		if mime org.xfce.mousepad.desktop text/plain text/markdown; then
			log 'Mousepad: prose defaults installed'
		else
			status=1
		fi
	else
		log 'prose editor missing (pkg_add mousepad)'
	fi
	fehsetup || status=1
	return "$status"
)

thunar() (
	config=${XDG_CONFIG_HOME:-"$HOME/.config"}
	command -v thunar >/dev/null 2>&1 || {
		log 'Thunar missing (pkg_add thunar)'
		return 0
	}
	command -v lowdown >/dev/null 2>&1 \
		|| log 'Markdown preview renderer missing (pkg_add lowdown)'
	[ -x /usr/X11R6/bin/xterm ] \
		|| log 'XTerm missing from the base X installation'
	accels=$config/Thunar/accels.scm
	mkdir -p "${accels%/*}" || return 1
	[ -f "$accels" ] || : >"$accels" || return 1
	fileline 'uca-action-1787491956597106-2' \
		'(gtk_accel_path "<Actions>/ThunarActions/uca-action-1787491956597106-2" "space")' \
		"$accels" || return
	log 'Thunar: bookmarks, Markdown preview, and XTerm action installed'

	command -v xfconf-query >/dev/null 2>&1 || {
		log 'xfconf-query missing; Thunar sidebar unchanged'
		return 0
	}
	pane=THUNAR_SIDEPANE_TYPE_SHORTCUTS
	[ "$(xfconf-query -c thunar -p /last-side-pane 2>/dev/null)" = "$pane" ] \
		&& return 0
	xfconf-query -c thunar -p /last-side-pane -s "$pane" 2>/dev/null \
		|| xfconf-query -c thunar -p /last-side-pane \
			-n -t string -s "$pane" \
		|| {
			log 'Thunar: setting shortcuts sidebar failed'
			return 1
		}
	log 'Thunar: shortcuts sidebar enabled'
)

dependencies() (
	command -v xsel >/dev/null 2>&1 \
		|| log 'xsel missing; tmux and Vim copy disabled (pkg_add xsel)'
	command -v picom >/dev/null 2>&1 \
		|| log 'Picom missing; xcompmgr fallback active (pkg_add picom)'
	command -v xwallpaper >/dev/null 2>&1 \
		|| log 'wallpaper support missing (pkg_add xwallpaper)'
	[ -f "$root/fvwm/bg.png" ] \
		|| log 'Gruvbox wallpaper missing from t490/fvwm/bg.png'
	for helper in md-preview xterm-here; do
		[ -x "$root/bin/$helper" ] \
			|| log "$root/bin/$helper: missing or not executable"
	done
)

status=0
appearance || status=1
filechooser || status=1
mupdf || status=1
viewers || status=1
thunar || status=1
dependencies || status=1
exit "$status"
