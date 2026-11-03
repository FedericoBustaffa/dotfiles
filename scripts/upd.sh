#!/usr/bin/env bash

rustup update
sudo pacman -Syu
yay -Syu

"${HOME}"/dotfiles/scripts/dotsync.sh
