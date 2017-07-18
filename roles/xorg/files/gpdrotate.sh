#!/bin/sh

# wait for xorg to start properly
sleep 5

# determine necessary variables
XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')
DISPLAY=${1}
export DISPLAY XAUTHORITY

# rotate display
xrandr --output DSI1 --rotate right >/dev/null 2>&1
