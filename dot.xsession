export LC_CTYPE=en_US.UTF-8
xsetroot -solid gray25 &
xterm -geometry 120x36 &
xclock -geometry 128x128+0+0 &
xconsole -geometry 800x128+129+0 -verbose -exitOnFail &
setxkbmap -option 'ctrl:nocaps' &
cwm
