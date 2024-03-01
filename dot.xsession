export LC_CTYPE=en_US.UTF-8
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1
setxkbmap -option 'ctrl:nocaps' &
test -e .xprofile && sh .xprofile
redshift -l 53:6 -t 5700:3600 &
xterm &
fvwm
