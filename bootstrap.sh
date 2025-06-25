#!/bin/bash

packages=(bash zsh nvim hypr waybar)

for pkg in "${packages[@]}"; do
    stow "$pkg"
done
