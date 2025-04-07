#!/bin/bash

# Install script for most used packages
# on Debian based distros

# ---------- APT packages ----------
apt_packages=(
    openssh-server
    btop
    # code
    npm
    snapd
    gnome-tweaks
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh
    clangd
    clang-format
    libstdc++-12-dev
    bear
    valgrind
    xclip
    fzf
    pipx
    cmake-format
    luarocks
    composer
    git
    htop
    zoxide
    cargo
    tmux
    unzip
    python3-pip
    python3-venv
    python3-pygments
    neofetch
    build-essential
    stow
    # texlive-full
    # eza
    # tree-sitter-cli
    ripgrep
    fd-find
    fswatch
    cmake
    curl
    libsystemd-dev
    inkscape
)

sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

sudo apt install ${apt_packages[@]}

# --------- NPM packages -----------
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.zshrc
nvm install lts/iron
npm install -g neovim
npm fund

# --------- Repositories ---------
# Install tmux TPM
read -p "do you want to install tmux tpm? [y/N]: " install
install=${install:-n}
install=${install,,}
if [ $install == "y" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Neovim from source
read -p "do you want to install neovim from source? [y/N]: " install
install=${install:-n}
install=${install,,}
if [ $install == "y" ]; then
    git clone -b v0.11.0 https://github.com/neovim/neovim.git ~/neovim/
    cd neovim
    make -j CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    cd
fi

# ZSH stuff
read -p "do you want to install zsh as default shell? [y/N]: " install
install=${install:-n}
install=${install,,}
if [ $install == "y" ]; then
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
fi
