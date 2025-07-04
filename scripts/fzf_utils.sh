#!/bin/bash


source /usr/share/doc/fzf/examples/completion.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh

fzf_uni() {
    DIR="$HOME/OneDrive/Master/"
    FILE=$(find "$DIR" -type f | fzf --preview="pdftotext {} - | head -n 30")

    if [[ -n "$FILE" ]]; then
        zathura "$FILE" &
    fi
}


export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--reverse --info=hidden"

bindkey -s "^U" "fzf_uni\n"
