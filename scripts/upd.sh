# !/bin/bash

sudo dnf upgrade -y
sudo dnf autoremove -y

flatpak update

git -C ~/dotfiles/ pull
cd ~/dotfiles/
./scripts/bootstrap.sh
