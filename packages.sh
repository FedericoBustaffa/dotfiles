#!/bin/bash

# --------- PIP packages -----------
pip_packages=(
	neovim
	virtualenv
	numpy
	matplotlib
	pandas
	scipy
	networkx
	bs4
	selenium
	ipykernel
	notebook
	jupyterlab
	pybind11
	requests
    neovim
    manim
)

pipx install ${pip_packages[@]}

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

