export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/13a/font
export FIXFONT=/mnt/font/GoMono/12a/font

# Enlarge the mouse pointer for HiDPI (Adwaita ships scalable cursors).
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=32

dpi="$(sed -En 's/^Xft\.dpi:[     ]*([0-9]+)/\1/p' "$HOME/.Xdefaults")"
if [ -n "$dpi" ]
then
	export QT_FONT_DPI="$dpi"
fi

# Load X resources so GTK/Chromium pick up Xft.dpi (HiDPI scale) and colors.
xrdb -merge "$HOME/.Xdefaults"
# Themed, sized cursor on the root window (the desktop background).
xsetroot -cursor_name left_ptr

[ -f "$HOME/bg.png" ] && xwallpaper --tile "$HOME/bg.png"
setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option compose:rctrl -option ctrl:nocaps
xidle -timeout 600 &
# Warm the screen at night (19:00-07:00), cool during the day.
h=$(date +%H)
[ "$h" -ge 19 ] || [ "$h" -lt 7 ] && sct 3200 || sct 5600
xcompmgr &
xterm &
fvwm
