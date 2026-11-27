#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyprpaper"
state_file="$state_dir/current"

valid_path() {
    [[ "$1" == /* && -f "$1" && "$1" != *,* && "$1" != *$'\n'* ]]
}

apply_wallpaper() {
    local path=$1 monitors monitor reply active failed=0
    monitors=$(hyprctl monitors | awk '$1 == "Monitor" { print $2 }') || return 1
    if [[ -z "$monitors" ]]; then
        echo 'No active Hyprland monitors found.' >&2
        return 1
    fi

    while IFS= read -r monitor; do
        if ! reply=$(hyprctl hyprpaper wallpaper "$monitor,$path,cover" 2>&1) || [[ -n "$reply" && "$reply" != ok ]]; then
            printf 'Wallpaper on %s: %s\n' "$monitor" "$reply" >&2
            failed=1
        fi
    done <<< "$monitors"
    (( failed == 0 )) || return 1

    # Some Hyprpaper versions return no text on success. Verify the actual outputs.
    active=$(hyprctl hyprpaper listactive) || return 1
    while IFS= read -r monitor; do
        if ! grep -Fxq -- "$monitor: $path" <<< "$active"; then
            printf 'Wallpaper was not applied on %s.\n' "$monitor" >&2
            failed=1
        fi
    done <<< "$monitors"
    return "$failed"
}

saved_wallpaper() {
    local path
    [[ -f "$state_file" ]] && IFS= read -r path < "$state_file" && valid_path "$path" || return 1
    printf '%s\n' "$path"
}

restore_wallpaper() {
    local path attempt
    path=$(saved_wallpaper) || return 0

    # Give hyprpaper time to open its IPC socket at login.
    for ((attempt = 0; attempt < 20; attempt++)); do
        apply_wallpaper "$path" 2>/dev/null && return 0
        sleep 0.2
    done
    echo 'Could not restore the saved wallpaper.' >&2
}

case "${1:-}" in
    start)
        restore_wallpaper &
        exec hyprpaper
        ;;
    lock)
        pidof hyprlock >/dev/null && exit 0
        unset HYPRLOCK_WALLPAPER
        if path=$(saved_wallpaper); then
            export HYPRLOCK_WALLPAPER="$path"
        fi
        exec hyprlock
        ;;
    apply)
        path="${2:-}"
        if [[ $# != 2 ]] || ! valid_path "$path"; then
            echo 'Expected an absolute path to an image, without commas or newlines.' >&2
            exit 1
        fi
        mkdir -p -- "$state_dir"
        tmp=$(mktemp "$state_dir/.wallpaper.XXXXXX")
        trap 'rm -f -- "$tmp"' EXIT
        printf '%s\n' "$path" > "$tmp"
        apply_wallpaper "$path"
        mv -f -- "$tmp" "$state_file"
        ;;
    *)
        echo "Usage: $0 start | apply PATH | lock" >&2
        exit 2
        ;;
esac
