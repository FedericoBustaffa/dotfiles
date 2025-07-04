# !/bin/bash

sudo apt update
sudo apt upgrade
sudo apt autoremove

sudo snap refresh

git -C ~/scripts/ pull
git -C ~/dotfiles/ pull
