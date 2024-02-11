export LC_CTYPE=en_US.UTF-8
xsetroot -solid black &
setxkbmap -option 'ctrl:nocaps' &
xrandr --dpi 108
test -e .xprofile && sh .xprofile
feh --bg-fill bg.jpg
redshift -l 53:6 -t 5700:3600 &
xconsole -verbose -exitOnFail &
xterm &
cwm
