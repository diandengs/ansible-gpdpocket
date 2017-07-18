#!/bin/sh

# wait for xorg to start properly
sleep 5

# determine necessary variables
DISPLAY=:${1}
XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')
export DISPLAY XAUTHORITY

# rotate display
xrandr --output DSI1 --rotate right