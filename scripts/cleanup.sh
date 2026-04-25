#!/usr/bin/env bash

sudo paccache -r
sudo pacman -Rns $(pacman -Qtdq)

paru -Scc
paru -Yc
