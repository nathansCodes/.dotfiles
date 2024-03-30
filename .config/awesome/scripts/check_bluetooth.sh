#!/bin/sh
if ! bluetoothctl show | grep -qs "Powered: yes"; then
    echo "off"
elif bluetoothctl info | grep -qs "Connected: yes"; then
    echo "connected"
else
    echo "on"
fi
