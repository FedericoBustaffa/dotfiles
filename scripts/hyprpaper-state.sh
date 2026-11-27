#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyprpaper"

apply_wallpaper() {
    hyprctl hyprpaper wallpaper "$1,$2,cover"
}

restore_wallpapers() {
    local entry monitor path
    local -a pending=() next=() monitors=()
    [[ -d "$state_dir" ]] || return 0
    mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')
    for monitor in "${monitors[@]}"; do
        [[ "$monitor" =~ ^[[:alnum:]_.-]+$ && "$monitor" != .* ]] || continue
        entry="$state_dir/$monitor"
        if [[ -f "$entry" ]] && IFS= read -r path < "$entry" && [[ -f "$path" && "$path" != *,* ]]; then
            pending+=("$entry")
        fi
    done

    # The IPC socket may not be ready when Hyprland starts hyprpaper.
    for ((attempt = 0; attempt < 20 && ${#pending[@]} > 0; attempt++)); do
        next=()
        for entry in "${pending[@]}"; do
            IFS= read -r path < "$entry" || continue
            apply_wallpaper "${entry##*/}" "$path" >/dev/null 2>&1 || next+=("$entry")
        done
        pending=("${next[@]}")
        if ((${#pending[@]} > 0)); then sleep 0.2; fi
    done
}

case "${1:-}" in
    start)
        restore_wallpapers &
        exec hyprpaper
        ;;
    apply)
        monitor="${2:-}"
        path="${3:-}"
        if [[ ! "$monitor" =~ ^[[:alnum:]_.-]+$ || "$monitor" == .* || ! -f "$path" || "$path" == *,* || "$path" == *$'\n'* ]]; then
            echo "Invalid monitor or wallpaper path." >&2
            exit 1
        fi
        mkdir -p -- "$state_dir"
        tmp=$(mktemp "$state_dir/.wallpaper.XXXXXX")
        trap 'rm -f -- "$tmp"' EXIT
        printf '%s\n' "$path" > "$tmp"
        apply_wallpaper "$monitor" "$path"
        mv -f -- "$tmp" "$state_dir/$monitor"
        ;;
    *)
        echo "Usage: $0 start | apply MONITOR PATH" >&2
        exit 2
        ;;
esac
