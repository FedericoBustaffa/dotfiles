#!/bin/bash

# ---------- APT packages ----------
apt_packages=(
	spapd
	zsh
	clangd
	git
	htop
	tmux
	neovim
	python3-pip
	python3-venv
	python3-pygments
	neofetch
	build-essential
	stow
	# texlive-full
	# i3
	# polybar
	ripgrep
	fd-find
	fswatch
	cmake
	curl
	libdbus-1-dev
	libglib2.0-dev
	libcairo2-dev
	gobject-introspection
	libgirepository1.0-dev
	libsystemd-dev
	inkscape
)

sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

sudo apt install ${apt_packages[@]}

# --------- Repositories ---------
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# source ~/.zshrc

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
)

pip install ${pip_packages[@]}

# --------- NPM packages -----------
npm_packages=(
	neovim
	tree-sitter
)

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.zshrc
nvm install lts/iron

npm install -g ${npm_packages[@]}
npm fund

# --------- SNAP packages ----------
sudo snap install alacritty --classic
# code

