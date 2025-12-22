#!/bin/bash


# Aliases
alias cls='clear'
alias vi="nvim"
alias py='python3'
alias py='python'
alias ls="eza --color=always --long --icons=always --no-time --no-user --no-permissions -s type"
alias la="ls -a"
alias tree="ls --tree"
alias upd="upd.sh"

# env variables
export PATH=$PATH:$HOME/dotfiles/scripts/
export PATH=$PATH:$HOME/.local/bin/
export PATH=$PATH:$HOME/.cargo/bin/

export EDITOR=nvim
export TERM=xterm-256color


# open pdf files inside university folder
fzf_uni() {
    DIR="$HOME/OneDrive/master/"
    FILE=$(find "$DIR" -type f -name "*.pdf" | fzf)

    if [[ -n "$FILE" ]]; then
        nohup zathura "$FILE" &>/dev/null &
    fi
}

fzf_recordings() {
    DIR="$HOME/recordings/"
    FILE=$(find "$DIR" -type f -name "*.mp4" | fzf)

    if [[ -n "$FILE" ]]; then
        nohup mpv "$FILE" &>/dev/null &
    fi
}

alias uni="fzf_uni"
alias rec="fzf_recordings"

# FZF keybindings
source $HOME/dotfiles/scripts/fzf_keybindings.bash

# FZF SETUP
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--reverse --info=hidden"

# don't remember
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
