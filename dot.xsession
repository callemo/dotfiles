export LC_CTYPE=en_US.UTF-8
setxkbmap -option 'ctrl:nocaps' &
test -e .xprofile && sh .xprofile
redshift -l 53:6 -t 5700:3600 &
xconsole -verbose -exitOnFail &
xterm &
fvwm
