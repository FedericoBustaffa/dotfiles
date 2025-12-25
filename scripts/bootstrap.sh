#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_TARGET="$HOME"
PACKAGES=(
    bash
    dunst
    clang
    fastfetch
    git
    gtk
    kitty
    nvim
    obsidian
    rofi
    spotify
    starship
    hyprland
    tmux
    vscode
    waybar
    zed
    wlogout
)

echo "stowing dotfiles from: $DOTFILES_DIR"
cd "$DOTFILES_DIR" || { echo "cannot find $DOTFILES_DIR"; exit 1; }

for pkg in "${PACKAGES[@]}"; do
    echo "stowing $pkg..."
    stow --target="$STOW_TARGET" --restow "$pkg"
done

echo "dotfiles stowed successfully."

