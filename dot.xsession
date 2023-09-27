xsetroot -solid gray25 &
xidle -timeout 300 &
xterm -geometry 100x30 &
xclock -geometry 128x128+0+0 &
xconsole -geometry 600x128+129+0 -verbose -exitOnFail &
setxkbmap -option 'ctrl:nocaps' &
cwm
