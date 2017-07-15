#!/usr/bin/env python2.7

# Full credit goes to efluffy at https://github.com/efluffy/gpdfand
# This script is simply re-written in python to avoid perl dependencies

from glob import glob
from time import sleep
import argparse
import atexit
import os

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--min', type=int, help='Temperature required for minimum fan speed', default=45)
parser.add_argument('--med', type=int, help='Temperature required for medium fan speed', default=55)
parser.add_argument('--max', type=int, help='Temperature required for maximum fan speed', default=65)
args = parser.parse_args()

# Setup exit handler
atexit.register(exit)

# Exit function
def exit():
    set_fans(0,0)

# Get temperature function
def get_temp():
    temps = []
    for hwmon in ('/sys/class/hwmon/hwmon*'):
        if open(hwmon + '/name').read() == 'coretemp':
            for temp_input in glob(hwmon + '/temp*_input'):
                temp = int(open(temp_input).read()) / 1000.0
                temps.append(temp)
    return sum(temps) / len(temps)

# Set fans function
def set_fans(a,b):
    with io.open('/sys/class/gpio/gpio368/value', 'w') as gpio:
        gpio.write(a)
    with io.open('/sys/class/gpio/gpio369/value', 'w') as gpio:
        gpio.write(b)

# Initialization function
def init():
    for id in [368,369]:
        if not os.path.isfile('/sys/class/gpio/gpio' + str(id) + '/value'):
            with io.open('/sys/class/gpio/export', 'w') as gpio_export:
                gpio_export.write(id)

# Perform initialization
init()

# Rinse, repeat.
while True:
    temp = get_temp()

    if temp >= args['max']:
        set_fans(1,1)
    elif temp >= args['med']:
        set_fans(0,1)
    elif temp >= args['min']:
        set_fans(1,0)
    else:
        set_fans(0,0)

    sleep(10)