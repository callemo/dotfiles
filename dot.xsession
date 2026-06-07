export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/13a/font
export FIXFONT=/mnt/font/GoMono/12a/font

# Enlarge the mouse pointer for HiDPI (Adwaita ships scalable cursors).
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=32

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

[ -f "$HOME/bg.png" ] && feh --bg-tile "$HOME/bg.png" || feh --bg-tile "$HOME/dotfiles/fvwm/bg.png"
setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option compose:rctrl -option ctrl:nocaps
xidle -timeout 600 &
# Warm the screen at night (19:00-07:00), cool during the day.
h=$(date +%H)
[ "$h" -ge 19 ] || [ "$h" -lt 7 ] && sct 3200 || sct 5600
xcompmgr &
xterm &
fvwm
