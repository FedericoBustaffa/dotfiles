#!/bin/bash


# ---------- DNF packages ----------
sudo dnf upgrade -y
sudo dnf autoremove -y

cli_pkgs=(
    # General CLI
    openssh-server
    fastfetch
    btop
    npm
    nodejs
    bat
    wl-clipboard
    fzf
    gettext
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
    clangd
    clang-format
    bear
    valgrind
    make
    cmake
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

# DNF
sudo dnf install ${cli_pkgs[@]}

# Media
read -p "do you want to install media packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo dnf install ${media_pkgs[@]}
fi

# GUI
read -p "do you want to install GUI packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo dnf install ${gui_pkgs[@]}
fi

# Sway
read -p "do you want to install Sway packages? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo dnf install ${sway_pkgs[@]}
fi

# # Zen Browser
# if [ ! -d "${HOME}/.local/zen/" ]; then
#     read -p "do you want to install zen browser? [y/N]: " choice
#     choice=${choice:-n}
#     choice=${choice,,}
#     if [ $choice == "y" ]; then
#         curl -L https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz -o /home/federico/zen.linux-x86_64.tar.xz
#         tar xvf ${HOME}/zen.linux-x86_64.tar.xz
#         rm ${HOME}/zen.linux-x86_64.tar.xz
#         mv zen ${HOME}/.local/
#     fi
# fi

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

# LazyGit
read -p "do you want to install lazygit? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm ./lazygit ./lazygit.tar.gz
fi

# Install dotfiles
read -p "do you want to bootstrap dotfiles? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    cd ${HOME}/dotfiles/
    ./scripts/bootstrap.sh
fi
