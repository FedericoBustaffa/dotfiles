#!/bin/bash

status=$(rfkill list bluetooth | grep -i "Soft blocked" | awk '{print $3}')

if [[ $1 == "toggle" ]]; then
    if [[ "$status" == "yes" ]]; then
        rfkill unblock bluetooth
    else
        rfkill block bluetooth
    fi
    exit 0
fi

if [[ "$status" == "no" ]]; then
    echo "ON"
else
    echo "OFF"
fi
