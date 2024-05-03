#!/bin/bash

# --------- NPM packages -----------
npm_packages=(
   neovim
)

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# source ~/.zshrc
# nvm install lts/iron

# npm install -g ${npm_packages[@]}
# npm fund

# --------- CARGO packages ---------
# cargo install tree-sitter-cli

# --------- SNAP packages ----------
# sudo snap install alacritty --classic
# code

