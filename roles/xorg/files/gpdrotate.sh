#!/bin/sh

export XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')

# rotate display
sleep 5
DISPLAY=:0 xrandr --output DSI1 --rotate right >/dev/null 2>&1
DISPLAY=:1 xrandr --output DSI1 --rotate right >/dev/null 2>&1

# rotate touchscreen
sleep 5
xinput set-prop 11 "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1