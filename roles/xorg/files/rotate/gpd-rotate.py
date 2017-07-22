#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

from time import sleep
import argparse
import os
import subprocess

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--display', type=int, help='Should we rotate display?', default=1)
parser.add_argument('--touchscreen', type=int, help='Should we rotate touchscreen?', default=1)
parser.add_argument('--wait', type=int, help='Wait time between tasks', default=5)
args = parser.parse_args()

# check if display rotation is enabled
if args.display == 1:
    # wait before starting task
    sleep(args.wait)

    # Create local environment variable
    local_env = os.environ.copy()

    # Set DISPLAY environment variable
    if int(subprocess.check_output(['pgrep', 'Xorg', '-c'])) == 1:
        local_env['DISPLAY'] = ':0'
    else:
        local_env['DISPLAY'] = ':1'

    # Set XAUTHORITY environment variable
    xorg_proc = subprocess.check_output(['pgrep', 'Xorg', '-a', '-n'])
    local_env['XAUTHORITY'] = xorg_proc.split('-auth ')[1].split(' ')[0]

    # rotate display
    subprocess.call(['xrandr', '--output', 'DSI1', '--rotate', 'right'], env=local_env)

# check if touchscreen rotation is enabled
if args.touchscreen == 1:
    # wait before starting task
    sleep(args.wait)

    # determine touchscreen ID
    touchscreen_id = subprocess.check_output(['xinput', 'list', '--id-only', 'pointer:"Goodix Capacitive TouchScreen"'])

    # rotate touchscreen
    subprocess.call(['xinput', 'set-prop', touchscreen_id, '"Coordinate Transformation Matrix"', '0', '1', '0', '-1', '0', '1', '0', '0', '1'], env=local_env)