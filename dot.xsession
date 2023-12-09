export LC_CTYPE=en_US.UTF-8
xsetroot -solid black &
xterm &
xconsole -geometry 500x100+0+0 -verbose -exitOnFail &
setxkbmap -option 'ctrl:nocaps' &
feh --bg-fill bg.jpg
redshift -l 53:6 -t 6500:3700 &
cwm
