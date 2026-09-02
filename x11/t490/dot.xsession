. "$HOME/dotfiles/init.sh"

# locale and default fonts
export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/13a/font
export FIXFONT=/mnt/font/GoMono/12a/font

# scalable cursors; size comes from the display profile
export XCURSOR_THEME=Adwaita

# one dbus session for gvfs and other desktop services
if command -v dbus-launch >/dev/null 2>&1 &&
	[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
	eval "$(dbus-launch --sh-syntax --exit-with-x11)"
fi

[ -d /usr/local/share/fonts/JetBrainsMono ] && {
	xset fp+ /usr/local/share/fonts/JetBrainsMono
	xset fp rehash
}

# keep qt fonts native; scale the ui explicitly
export QT_FONT_DPI=96
export QT_SCALE_FACTOR=1.6

# x resources: hidpi dpi and colours for gtk/chromium
xrdb -merge "$HOME/.Xdefaults"
xsetroot -cursor_name left_ptr

setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option '' -option compose:rctrl -option ctrl:nocaps
xinput set-prop /dev/wsmouse 'Device Accel Constant Deceleration' 1
"$HOME/dotfiles/x11/t490/fvwm/display" sync

# screen saver: blank and lock at 10m, dpms off 10s later
lock=/usr/X11R6/bin/xlock
opts='-mode blank -dpmsoff 10'
xidle -timeout 600 -program "$lock $opts" &

# warm the screen at night, cool by day
h=$(date +%H)
[ "$h" -ge 19 ] || [ "$h" -lt 7 ] && sct 3200 || sct 5600

# compositor: prefer picom, fall back to xcompmgr
if command -v picom >/dev/null 2>&1; then
	picom &
else
	xcompmgr &
fi

xterm &
fvwm
