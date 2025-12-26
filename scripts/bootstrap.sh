#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_TARGET="$HOME"
PACKAGES=()

while IFS= read -r -d '' dir; do
    pkg="$(basename "$dir")"

    # escludi directories non-stow
    [[ "$pkg" == ".git" ]] && continue
    [[ "$pkg" == "scripts" ]] && continue
    [[ "$pkg" == "wallpapers" ]] && continue

    PACKAGES+=("$pkg")
done < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

echo "stowing dotfiles from: $DOTFILES_DIR"
cd "$DOTFILES_DIR" || { echo "cannot find $DOTFILES_DIR"; exit 1; }

for pkg in "${PACKAGES[@]}"; do
    echo "stowing $pkg..."
    stow --target="$STOW_TARGET" --restow "$pkg"
done

echo "dotfiles stowed successfully."

