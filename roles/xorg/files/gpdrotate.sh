#!/bin/sh

# wait for xorg to start properly
sleep 5

# set necessary variables
DISPLAY=:${1}
DISPLAY_OUTPUT='DSI1'
TOUCHSCREEN_ID=$(xinput list --id-only pointer:'Goodix Capacitive TouchScreen')
XAUTHORITY=$(ps aux |grep -e Xorg | head -n1 | awk '{ split($0, a, "-auth "); split(a[2], b, " "); print b[1] }')
export DISPLAY XAUTHORITY

# rotate display
xrandr --output ${DISPLAY_OUTPUT} --rotate right

# wait for rotation to complete
sleep 5

# rotate touchscreen
xinput set-prop ${TOUCHSCREEN_ID} 'Coordinate Transformation Matrix' 0 1 0 -1 0 1 0 0 1