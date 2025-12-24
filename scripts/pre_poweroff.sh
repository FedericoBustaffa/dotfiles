#!/usr/bin/env bash


~/dotfiles/scripts/dotsync.sh

sleep 1

notify-send "Power Off"
systemctl poweroff
