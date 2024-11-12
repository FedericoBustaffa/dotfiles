eval "$(starship init zsh)"

alias cls='clear'
alias py='python3'
alias nv='nvim'
alias ls="eza --color=always --long --icons=always --no-time --no-user --no-permissions"
alias bat="batcat"
alias jupyter="jupyter-lab . --no-browser"

export PATH=$PATH:$HOME/scripts/
export PATH=$PATH:$HOME/.local/bin/
export PATH=$PATH:$HOME/.cargo/bin/
export PATH=$PATH:$HOME/.tmux/plugins/tmuxifier/bin

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(tmuxifier init -)"
export EDITOR=nvim

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
