export LC_CTYPE=en_US.UTF-8
export VARFONT=/mnt/font/GoRegular/14a/font
export FIXFONT=/mnt/font/GoMono/13a/font

dpi="$(sed -En 's/^Xft\.dpi:[     ]*([0-9]+)/\1/p' "$HOME/.Xdefaults")"
if [ -n "$dpi" ]
then
	export QT_FONT_DPI="$dpi"
fi

[ -f "$HOME/bg.png" ] && xwallpaper --tile "$HOME/bg.png"
setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option compose:rctrl -option ctrl:nocaps
xidle -timeout 600 &
sct 5500 &
xcompmgr &
xterm &
fvwm
