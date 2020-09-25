# Dir alias
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"

# Jumps alias
alias ~="cd ~"
alias tmp="cd /tmp/"
alias projects="cd ~/Dropbox/projects/"
alias dropbox="cd ~/Dropbox/"
alias blog="cd ~/Dropbox/projects/bertini36.github.io/ && workon blog"
alias dotfiles="cd ~/.dotfiles/"
alias boatsandjoy="cd ~/Dropbox/projects/boatsandjoy/ && workon boatsandjoy"
alias home="cd $HOME"

# Git alias
alias gaa="git add -A"
alias gc="git c"
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd="git diff --color"
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"

# Docker alias
alias dc="docker-compose $@"
alias dcup="dc; up -d"
alias dcdo="dc; down"
alias dcre="dc; restart"

# Others
alias bashrc="vim ~/.dotfiles/bashrc"
alias aliases="vim ~/.dotfiles/.bash_aliases"
alias i3conf="vim ~/.dotfiles/.config/i3/config"

# Roiback
alias roi="cd ~/roi/"
alias bc="cd ~/roi/bookcore/ && workon bookcore"
alias dbc="cd ~/roi/docker-bookcore/"
alias bcconfs="cd ~/roi/configurations/"

# Skitude
alias skitude="cd ~/skitude/"
