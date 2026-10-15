. "$HOME/dotfiles/init.sh"

# locale
export LC_CTYPE=en_US.UTF-8

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
[ -d /usr/local/share/fonts/spleen ] && {
	xset fp+ /usr/local/share/fonts/spleen
	xset fp rehash
}

# x resources: hidpi dpi and colours for gtk/chromium
xrdb -merge "$HOME/.Xdefaults"
xsetroot -cursor_name left_ptr

setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option '' -option compose:rctrl -option ctrl:nocaps
xinput set-prop /dev/wsmouse 'Device Accel Constant Deceleration' 1
"$HOME/dotfiles/t490/fvwm/display" sync

# Use the active profile for applications started before FVWM.
. "$HOME/dotfiles/t490/fvwm/profile"
profile
export QT_FONT_DPI=96
export QT_SCALE_FACTOR=$qt

# screen saver: blank and lock at 10m, dpms off 10s later
lock=/usr/X11R6/bin/xlock
opts='-mode blank -dpmsoff 10'
xidle -timeout 600 -program "$lock $opts" &

# tone and keyboard backlight follow the time of day
/usr/local/ws/bin/nightlight

xterm &
fvwm
