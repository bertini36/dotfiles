export EDITOR=vim

# Required to write accents using Intellij IDE
export XMODIFIERS=""

# Binary locations
paths=(
    "$HOME/.local/bin"
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
    "/usr/games"
    "/usr/local/games"
    "/snap/bin"
    "$HOME/.fzf/bin"
    "$HOME/.nvm/versions/node/v13.11.0/bin"
    "$HOME/.dotfiles/bin"
)
PATH=$(
    IFS=":"
    echo "${paths[*]}"
)
export PATH

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Dropbox
export DROPBOX_PATH=$HOME/Dropbox