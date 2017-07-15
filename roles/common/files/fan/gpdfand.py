#!/usr/bin/env python2.7

# Full credit goes to efluffy at https://github.com/efluffy/gpdfand
# This script is simply re-written in python to avoid perl dependencies

from glob import glob
from time import sleep
import argparse
import io
import os.path
import signal
import sys

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--time', type=int, help='Time between temperature checks', default=10)
parser.add_argument('--min', type=int, help='Temperature required for minimum fan speed', default=45)
parser.add_argument('--med', type=int, help='Temperature required for medium fan speed', default=55)
parser.add_argument('--max', type=int, help='Temperature required for maximum fan speed', default=65)
args = parser.parse_args()

# Exit function
def exit(*args):
    set_fans(0,0)
    sys.exit(0)

# Get temperature function
def get_temp():
    temps = []
    for hwmon in glob('/sys/devices/platform/coretemp.0/hwmon/hwmon*'):
        for temp_input_dev in glob(hwmon + '/temp*_input'):
            with io.open(temp_input_dev, 'r') as core_temp:
                temp = int(core_temp.read()) / 1000
                temps.append(temp)
    return sum(temps) / float(len(temps))

# Set fans function
def set_fans(a,b):
    with io.open('/sys/class/gpio/gpio397/value', 'w') as gpio:
        gpio.write(unicode(a))
    with io.open('/sys/class/gpio/gpio398/value', 'w') as gpio:
        gpio.write(unicode(b))

# Initialization function
def init():
    for id in [397,398]:
        if not os.path.isfile('/sys/class/gpio/gpio' + str(id) + '/value'):
            with io.open('/sys/class/gpio/export', 'w') as gpio_export:
                gpio_export.write(unicode(id))

# Perform initialization
init()

# Setup exit handler
signal.signal(signal.SIGTERM, exit)

# Rinse, repeat.
while True:
    temp = get_temp()

    if temp >= args.max:
        print "Temperature: " + str(temp) + ", Fan Speed: Max"
        set_fans(1,1)
    elif temp >= args.med:
        print "Temperature: " + str(temp) + ", Fan Speed: Med"
        set_fans(0,1)
    elif temp >= args.min:
        print "Temperature: " + str(temp) + ", Fan Speed: Min"
        set_fans(1,0)
    else:
        print "Temperature: " + str(temp) + ", Fan Speed: Off"
        set_fans(0,0)

    sleep(args.time)