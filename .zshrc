# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

alias cls='clear'
alias vi="nvim"
alias py='python3'
alias ls="eza --color=always --long --icons=always --no-time --no-user --no-permissions"
alias la="ls -a"
alias tree="ls --tree"
alias jupyter="jupyter-lab . --no-browser"
alias z="zoxide"
alias upd="bash ~/scripts/upd.bash"

export PATH=$PATH:$HOME/scripts/
export PATH=$PATH:$HOME/.local/bin/
export PATH=$PATH:$HOME/.cargo/bin/
export PATH=$PATH:$HOME/.tmux/plugins/tmuxifier/bin

# CUDA
# alias nvcc="nvcc -arch=sm_35 -ccbin /usr/bin/gcc-10 -Wno-deprecated-gpu-targets"
# export PATH=/usr/local/cuda-11.4/bin:$PATH
# export LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64:$LD_LIBRARY_PATH

eval "$(tmuxifier init -)"
export EDITOR=nvim
compdef _gnu_generic zed

export TERM=xterm-256color

# FZF
source ~/scripts/fzf_utils.bash

# Lazygit keybinding
bindkey -s "^G" "lazygit\n"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
