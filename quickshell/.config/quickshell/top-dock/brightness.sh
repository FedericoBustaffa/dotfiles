#!/usr/bin/env bash
# Set the display backlight and show the actual resulting percentage.
case "$1" in
    up) step='10%+' ;;
    down) step='10%-' ;;
    *) exit 2 ;;
esac

result=$(LC_ALL=C brightnessctl --class=backlight --min-value=1 --machine-readable set "$step") || exit $?
IFS=, read -r _ _ _ percent _ <<< "$result"
[[ $percent =~ ^[0-9]{1,3}%$ ]] || exit 1
quickshell ipc -p "$(dirname -- "$0")" call brightness display "${percent%\%}"
