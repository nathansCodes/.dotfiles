#!/usr/bin/env bash
if (bluetoothctl info | grep 'Connected: yes') > /dev/null; then
    echo 'connected'
else
    bluetoothctl show | grep 'PowerState: .*' | awk '{print $2}'
fi

