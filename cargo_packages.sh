#!/bin/bash

# --------- CARGO packages ---------
cargo_packages=(
    tree-sitter-cli
    eza
    alacritty
)

cargo install ${cargo_packages[@]}
