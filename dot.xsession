export LC_CTYPE=en_US.UTF-8
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1
setxkbmap -model pc105 -layout us -variant altgr-intl \
	-option compose:rctrl -option ctrl:nocaps -option altwin:alt_win
xidle -timeout 600 &
sct 5500 &
picom &
test -e .xprofile && sh .xprofile
xterm &
fvwm
