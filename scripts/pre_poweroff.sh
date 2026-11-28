#!/usr/bin/env bash


# The graphical session service syncs dotfiles during shutdown.
notify-send -e "Power Off"
exec systemctl poweroff
