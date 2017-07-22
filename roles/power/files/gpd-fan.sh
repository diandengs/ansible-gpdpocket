#!/bin/bash

case $1 in
  pre)
    # stop fan control script
    systemctl stop gpdfand.service
    ;;
  post)
    # start fan control script
    systemctl start gpdfand.service
    ;;
esac
