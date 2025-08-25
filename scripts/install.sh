#!/bin/bash


# ---------- PACMAN packages ----------
sudo pacman -Syuuu

cli_pkgs=(
    # General CLI
    openssh
    fastfetch
    btop
    npm
    nodejs
    bat
    wl-clipboard
    fzf
    gettext
    neovim
    git
    htop
    tmux
    tree
    hwloc
    pandoc
    stow
    ripgrep
    fd-find
    fswatch
    curl
    inkscape
    onedrive
    eza
    tree-sitter-cli
    unzip
    # C/C++
    gcc
    clangd
    clang-format
    bear
    valgrind
    make
    cmake
    libomp
    libomp-devel
    openmpi
    openmpi-devel
    # Python
    python3-pip
    python3-pygments
    python3-nbconvert
    python3-numpy
    python3-matplotlib
    python3-pandas
    python3-scipy
    # LaTeX
    texlive
)

media_pkgs=(
    bluez
    bluez-tools
    pipewire
    pipewire-alsa
    pipewire-pulse
    wireplumber
)

gui_pkgs=(
    blueman
    gnome-tweaks
    kitty
    vlc
    zathura
)

sway_pkgs=(
    sway
    swaylock
    swayidle
    swaybg
    sway-notification-center
    waybar
    wofi
    wlsunset
    wlogout
)

# PACMAN
sudo pacman -S ${cli_pkgs[@]}

# Media
read -p "do you want to install media packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S ${media_pkgs[@]}
fi

# GUI
read -p "do you want to install GUI packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S ${gui_pkgs[@]}
fi

# Sway
read -p "do you want to install Sway packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S ${sway_pkgs[@]}
fi

# NPM packages
read -p "do you want to install npm packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo npm install --global neovim yarn
    npm fund
fi

# Install tmux TPM
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
    read -p "do you want to install tmux tpm? [y/N]: " choice
    choice=${choice:-n}
    choice=${choice,,}
    if [ $choice == "y" ]; then
        git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
    fi
fi

# Starship
read -p "do you want to install starship? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    curl -sS https://starship.rs/install.sh | sh
fi

# Nerd Font
read -p "do you want to install a nerd font? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
    mkdir ${HOME}/.local/share/fonts/
    unzip JetBrainsMono.zip -d ${HOME}/.local/share/fonts/
    rm -rf ${HOME}/.local/share/fonts/OFL.txt ${HOME}/.local/share/fonts/README.md
    fc-cache -v
    rm -rf JetBrainsMono.zip
fi

# Install dotfiles
read -p "do you want to bootstrap dotfiles? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    cd ${HOME}/dotfiles/
    ./scripts/bootstrap.sh
fi
