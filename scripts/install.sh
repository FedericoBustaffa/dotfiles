#!/bin/bash


# ---------- PACMAN packages ----------
sudo pacman -Syuuu

cli_pkgs=(
    # General CLI
    bash-completion
    openssh
    fastfetch
    btop
    power-profiles-daemon
    npm
    nodejs
    less
    yarn
    bat
    wl-clipboard
    fzf
    gettext
    neovim
    git
    htop
    webkit2gtk
    deno
    lazygit
    tmux
    tree
    hwloc
    pandoc
    stow
    ripgrep
    fd
    starship
    curl
    inkscape
    jdk-openjdk
    eza
    tree-sitter-cli
    unzip
    # C/C++
    gcc
    clang
    bear
    valgrind
    make
    cmake
    openmp
    openmpi
    # Python
    python-pip
    python-pygments
    python-numpy
    python-matplotlib
    python-pandas
    python-scipy
    # LaTeX
    texlive
    # Typst
    typst
)

yay_pkgs=(
    onedrive-abraunegg
    fswatch
)

# PACMAN and YAY
sudo pacman -S --noconfirm --needed "${cli_pkgs[@]}"
yay -S --noconfirm --needed "${yay_pkgs[@]}"


# Media
media_pkgs=(
    swaync
    bluez
    bluez-tools
    pipewire
    pipewire-alsa
    pipewire-pulse
    wireplumber
)

read -p "do you want to install media packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S --noconfirm --needed ${media_pkgs[@]}
fi

# GUI
gui_pkgs=(
    blueberry
    gnome-tweaks
    kitty
    telegram-desktop
    obsidian
    mpv
    zathura
    zathura-pdf-mupdf
    zed
)

gui_yay_pkgs=(
    zen-browser-bin
    visual-studio-code-bin
    notion-app-electron
)

read -p "do you want to install GUI packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S --noconfirm --needed ${gui_pkgs[@]}
    yay -S --noconfirm --needed ${gui_yay_pkgs[@]}
fi

# Hyprland
hypr_pkgs=(
    hyprpaper
    hyprshot
    hyprsunset
    hyprlock
    hypridle
    waybar
    rofi
)

hypr_yay_pkgs=(
    wlogout
    hyprprop-git
)

read -p "do you want to install Hyprland packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo pacman -S --noconfirm --needed ${hypr_pkgs[@]}
    yay -S --noconfirm --needed ${hypr_yay_pkgs[@]}
fi

# NPM packages
read -p "do you want to install npm packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo npm install --global neovim
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
