#!/usr/bin/env bash


notify-send "Dotfiles Sync"

git -C ${HOME}/dotfiles pull
git -C ${HOME}/dotfiles add -A .
git -C ${HOME}/dotfiles commit -m "sync"
git -C ${HOME}/dotfiles push

${HOME}/dotfiles/scripts/bootstrap.sh
