#!/bin/bash

hyprctl reload

pkill waybar
waybar &

pkill swaync
swaync &

pkill hyprpaper
hyprpaper &
