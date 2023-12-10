export LC_CTYPE=en_US.UTF-8
xsetroot -solid black &
xconsole -geometry 460x60+0+0 -verbose -saveLines 1000 -exitOnFail &
setxkbmap -option 'ctrl:nocaps' &
xterm &
feh --bg-fill bg.jpg
redshift -l 53:6 -t 6500:3700 &
cwm
