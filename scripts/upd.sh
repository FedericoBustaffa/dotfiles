#!/usr/bin/env bash

sudo pacman -Syu
paru -Syu

flatpak update

"${HOME}"/dotfiles/scripts/dotsync.sh
