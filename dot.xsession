export LC_CTYPE=en_US.UTF-8
xsetroot -solid black &
xconsole -verbose -exitOnFail &
setxkbmap -option 'ctrl:nocaps' &
xterm &
xrandr --dpi 108
feh --bg-fill bg.jpg
redshift -l 53:6 -t 6500:3700 &
cwm
