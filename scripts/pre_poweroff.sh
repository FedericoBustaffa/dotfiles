#!/usr/bin/env bash


notify-send "Dotfiles Sync"
~/dotfiles/scripts/dotsync.sh

sleep 1

notify-send "Power Off"
systemctl poweroff
