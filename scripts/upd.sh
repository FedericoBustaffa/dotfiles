#!/usr/bin/env bash

sudo pacman -Syu
yay -Syu

"${HOME}"/dotfiles/scripts/dotsync.sh
