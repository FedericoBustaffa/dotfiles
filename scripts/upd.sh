# !/bin/bash

sudo pacman -Syu
yay -Syu

flatpak update

git -C ~/dotfiles/ pull
cd ~/dotfiles/
./scripts/bootstrap.sh
