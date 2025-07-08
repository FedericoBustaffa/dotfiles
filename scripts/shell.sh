#!/bin/bash


# Aliases
alias cls='clear'
alias vi="nvim"
alias py='python3'
alias ls="eza --color=always --long --icons=always --no-time --no-user --no-permissions -s type"
alias la="ls -a"
alias tree="ls --tree"
alias upd="upd.sh"

# env variables
export PATH=$PATH:$HOME/dotfiles/scripts/
export PATH=$PATH:$HOME/.local/bin/
export PATH=$PATH:$HOME/.cargo/bin/
export PATH=$PATH:$HOME/.tmux/plugins/tmuxifier/bin


export EDITOR=nvim
export TERM=xterm-256color

# tmuxifier completions
eval "$(tmuxifier init -)"

# open pdf files inside university folder
fzf_uni() {
    DIR="$HOME/OneDrive/Master/"
    FILE=$(find "$DIR" -type f | fzf --preview="pdftotext {} - | head -n 30")

    if [[ -n "$FILE" ]]; then
        zathura "$FILE" &
    fi
}

# FZF keybindings
source /usr/share/doc/fzf/examples/key-bindings.bash

# FZF SETUP
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--reverse --info=hidden"

# don't remember
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
