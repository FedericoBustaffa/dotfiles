# !/bin/bash

sudo dnf upgrade -y
sudo dnf autoremove -y

git -C ~/dotfiles/ pull
cd ~/dotfiles/
./scripts/bootstrap.sh
