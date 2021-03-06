export EDITOR=vim

# required to write accents using Intellij IDE
export XMODIFIERS=""

# binary locations
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
    "$HOME/.dotfiles/bin"
    "$HOME/.pyenv/bin"
    "$HOME/.cargo/bin"
)
PATH=$(
    IFS=":"
    echo "${paths[*]}"
)
export PATH

# dropbox
export DROPBOX_PATH=$HOME/Dropbox