#!/bin/bash

read -p "are you sure you want to uninstall all the packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "n" ]; then
    exit 0
fi

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
    eza
    tree-sitter-cli
    ripgrep
    fd-find
    fswatch
    cmake
    curl
    libsystemd-dev
    inkscape
)

sudo apt purge ${apt_packages[@]}

sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean
