#!/bin/bash

# ---------- APT packages ----------
apt_packages=(
    openssh-server
    btop
    code
    npm
    snapd
    gnome-tweaks
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh
    clangd
    libstdc++-12-dev
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
    neovim
    unzip
    python3-pip
    python3-venv
    python3-pygments
    neofetch
    build-essential
    stow
    texlive-full
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

# --------- Repositories ---------
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# chsh -s $(which zsh)

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# source ~/.zshrc
