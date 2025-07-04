#!/bin/bash

# Install script for most used packages
# on Debian based distros

# ---------- APT/NALA packages ----------
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch

sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean


apt_cli_packages=(
    # General CLI
    openssh-server
    fastfetch
    btop
    npm
    nodejs
    snapd
    zsh
    bat
    zoxide
    neofetch
    xclip
    wl-clipboard
    fzf
    luarocks
    lua5.1
    liblua5.1-0-dev
    gettext
    composer
    git
    htop
    cargo
    tmux
    tree
    zathura
    hwloc
    libfmt-dev
    pandoc
    stow
    ripgrep
    fd-find
    fswatch
    curl
    libsystemd-dev
    inkscape
    onedrive
    eza
    tree-sitter-cli
    unzip
    bluez
    bluez-tools
    pulseaudio
    # C/C++
    build-essential
    clangd
    clang-format
    bear
    valgrind
    cmake-format
    make
    cmake
    libomp-dev
    libopenmpi-dev
    # Python
    python3-pip
    python3-venv
    python3-pygments
    python3-tk
    python3-nbconvert
    python3-numpy
    python3-matplotlib
    python3-pandas
    python3-scipy
)

apt_gui_packages=(
    gnome-tweaks
    kitty
    vlc
)

sway_packages=(
    sway
    swaylock
    swayidle
    swaybg
    waybar
    wofi
    wlsunset
    wlogout
)

# APT
sudo apt install ${apt_cli_packages[@]}

# LaTeX
read -p "do you want to install the LaTeX suite? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sudo apt install texlive-full
fi

# GUI
sudo apt install ${apt_gui_packages[@]}

# Sway
sudo apt install ${sway_packages[@]}

# Snap packages
sudo snap refresh
snap_packages=(
    code
    obsidian
    spotify
)

for pkg in ${snap_packages[@]}; do
    sudo snap install $pkg --classic
done

# NPM packages
sudo npm install --global neovim yarn
npm fund

# Install tmux TPM
if [ ! -d "~/.tmux/plugins/tpm" ]; then
    read -p "do you want to install tmux tpm? [y/N]: " choice
    choice=${choice:-n}
    choice=${choice,,}
    if [ $choice == "y" ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
fi

# Install Neovim from source
read -p "do you want to install neovim from source? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    git clone -b v0.11.2 https://github.com/neovim/neovim.git ~/neovim/
    cd ~/neovim
    make -j CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    cd
fi

# Oh-My-Zsh
read -p "do you want to install Oh My Zsh for zsh? [y/N]: " choice
choice=${choice:-n}
choice=${choice,,}
if [ $choice == "y" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
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
    mkdir ~/.local/share/fonts/
    unzip JetBrainsMono.zip -d ~/.local/share/fonts/
    rm -rf ~/.local/share/fonts/OFL.txt ~/.local/share/fonts/README.md
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
