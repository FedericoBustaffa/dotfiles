# !/bin/bash

sudo apt update
sudo apt upgrade
sudo apt autoremove

sudo snap refresh

git -C ~/dotfiles/ pull
cd ~/dotfiles/
./scripts/bootstrap.sh
