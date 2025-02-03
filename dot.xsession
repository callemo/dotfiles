export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/14a/font
export FIXFONT=/mnt/font/GoMono/14a/font

dpi="$(sed -En 's/^Xft\.dpi:[     ]*([0-9]+)/\1/p' "$HOME/.Xdefaults")"
if [ -n "$dpi" ]
then
	export QT_FONT_DPI="$dpi"
fi

xsetroot -fg '#6f6f6f' -bg '#bfbfbf' \
	-bitmap /usr/X11R6/include/X11/bitmaps/gray
setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option compose:rctrl -option ctrl:nocaps -option altwin:alt_win
xidle -timeout 600 &
sct 5500 &
xcompmgr &
xterm &
fvwm
