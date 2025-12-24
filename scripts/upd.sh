#!/usr/bin/env bash

sudo pacman -Syu
yay -Syu

flatpak update

${HOME}/dotfiles/scripts/dotsync.sh
