#!/bin/bash


# ---------- PACMAN packages ----------
sudo pacman -Syuuu


cli_pkgs=(
    # General CLI
    pacman-contrib
    base-devel
    reflector
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
    lazygit
    tmux
    ttf-jetbrains-mono-nerd
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
    cpio
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
    uv
    ty
    ruff
    python-pip
    python-pygments
    python-numpy
    python-matplotlib
    python-pandas
    python-scipy
    # LaTeX
    texlive
    texlab
    # Typst
    typst
    typstyle
    tinymist
    prettier
    pyright
    quickshell
    marksman
    biome
    stylua
    lua-language-server
    bash-language-server
)

sudo pacman -S --noconfirm --needed "${cli_pkgs[@]}"

if [[ ! -d "${HOME}/yay/" ]]; then
    git clone https://aur.archlinux.org/yay.git "${HOME}/yay/"
    cd "${HOME}/yay" || exit
    makepkg -si
fi

yay_pkgs=(
    onedrive-abraunegg
    fswatch
    neocmakelsp
)

# PACMAN and yay
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

read -rp "do you want to install media packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ "$choice" == "y" ]; then
    sudo pacman -S --noconfirm --needed "${media_pkgs[@]}"
fi

# GUI
gui_pkgs=(
    bluetui
    impala
    gnome-tweaks
    kitty
    obsidian
    mpv
    grim
    slurp
    zed
    zathura
    zathura-pdf-mupdf
)

gui_yay_pkgs=(
    zen-browser-bin
    visual-studio-code-bin
    overskride-bin
    sioyek-git
)

read -rp "do you want to install GUI packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ "$choice" == "y" ]; then
    sudo pacman -S --noconfirm --needed "${gui_pkgs[@]}"
    yay -S --noconfirm --needed "${gui_yay_pkgs[@]}"
fi

# Hyprland
hypr_pkgs=(
    hyprland
    hyprpaper
    hyprsunset
    hyprlock
    hypridle
    waybar
    hyprlauncher
    hyprtoolkit
)

hypr_yay_pkgs=(
    wlogout
)

read -rp "do you want to install Hyprland packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ "$choice" == "y" ]; then
    sudo pacman -S --noconfirm --needed "${hypr_pkgs[@]}"
    yay -S --noconfirm --needed "${hypr_yay_pkgs[@]}"
fi

# NPM packages
read -rp "do you want to install npm packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ "$choice" == "y" ]; then
    sudo npm install --global neovim
    npm fund
fi

# Install tmux TPM
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
    read -rp "do you want to install tmux tpm? [y/N]: " choice
    choice=${choice:-n}
    choice=${choice,,}
    if [ "$choice" == "y" ]; then
        git clone https://github.com/tmux-plugins/tpm "${HOME}"/.tmux/plugins/tpm
    fi
fi

# Install dotfiles
read -rp "do you want to bootstrap dotfiles? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ "$choice" == "y" ]; then
    rm -rf ~/.gitconfig ~/.bash ~/.config/gtk-3.0
    cd "${HOME}"/dotfiles/ || exit
    ./scripts/bootstrap.sh
fi
