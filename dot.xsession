. "$HOME/dotfiles/init.sh"

export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/13a/font
export FIXFONT=/mnt/font/GoMono/12a/font

# Adwaita ships scalable cursors; Xcursor.size comes from the display profile.
export XCURSOR_THEME=Adwaita

[ -d /usr/local/share/fonts/JetBrainsMono ] && {
	xset fp+ /usr/local/share/fonts/JetBrainsMono
	xset fp rehash
}

# Keep Qt fonts normal, then scale the UI explicitly.
export QT_FONT_DPI=96
export QT_SCALE_FACTOR=1.6

# Load X resources so GTK/Chromium pick up Xft.dpi (HiDPI scale) and colors.
xrdb -merge "$HOME/.Xdefaults"
# Themed, sized cursor on the root window (the desktop background).
xsetroot -cursor_name left_ptr

setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option '' -option compose:rctrl -option ctrl:nocaps
xinput set-prop /dev/wsmouse 'Device Accel Constant Deceleration' 1
"$HOME/dotfiles/fvwm/display" sync
xidle -timeout 600 &
# Warm the screen at night (19:00-07:00), cool during the day.
h=$(date +%H)
[ "$h" -ge 19 ] || [ "$h" -lt 7 ] && sct 3200 || sct 5600
xcompmgr &
xterm &
fvwm
