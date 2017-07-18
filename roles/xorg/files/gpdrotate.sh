#!/bin/sh

export XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')
export DISPLAY=${1}

# rotate display
sleep 5
xrandr --output DSI1 --rotate right >/dev/null 2>&1
