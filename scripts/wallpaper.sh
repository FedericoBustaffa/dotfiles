#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
wall_dir="$repo/wallpapers"

selected=$(cd -- "$wall_dir" && find . -maxdepth 1 -type f -printf '%f\0' | fzf --read0) || exit 0
[[ -n "$selected" ]] || exit 0

exec bash "$repo/scripts/hyprpaper-state.sh" apply "$wall_dir/$selected"
