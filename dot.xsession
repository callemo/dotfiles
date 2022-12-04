xsetroot -solid gray20 &
xidle -program '/usr/X11R6/bin/xlock -mode lisa' -timeout 300 &
xclock -geometry 80x80-4+4 &
xload -nolabel -geometry 80x80-88+4 &
xterm -geometry 100x35 &
setxkbmap -option 'ctrl:nocaps' &
cwm
