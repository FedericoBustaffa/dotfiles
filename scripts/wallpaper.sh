#!/usr/bin/env bash

WALL_DIR="$HOME/dotfiles/wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper"

[ -d "$WALL_DIR" ] || exit 1

selected=$(ls "$WALL_DIR" | fzf)

[ -z "$selected" ] && exit 0

WALL="$WALL_DIR/$selected"

# salva stato
echo "$WALL" > "$STATE_FILE"

# applica wallpaper (hyprpaper)
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper ",$WALL"

