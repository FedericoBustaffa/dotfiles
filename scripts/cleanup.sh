#!/usr/bin/env bash

sudo paccache -r
sudo pacman -Rns $(pacman -Qtdq)

yay -Scc
yay -Yc
