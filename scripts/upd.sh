#!/usr/bin/env bash

sudo pacman -Syu
yay -Syu
rustup update

"${HOME}"/dotfiles/scripts/dotsync.sh
