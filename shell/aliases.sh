# Dir alias
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -l"
alias la="ls -la"

# Jumps alias
alias ~="cd ~"
alias tmp="cd /tmp/"
alias dropbox="cd $DROPBOX_PATH"
alias projects="cd $DROPBOX_PATH/projects/"
alias blog="cd $DROPBOX_PATH/projects/bertini36.github.io/ && workon blog"
alias dotfiles="cd $DOTFILES_PATH"
alias boatsandjoy="cd $DROPBOX_PATH/projects/boatsandjoy/ && workon boatsandjoy"
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
alias bashrc="vim $DOTFILES_PATH/shell/bash/.bashrc"
alias aliases="vim $DOTFILES_PATH/shell/aliases.sh"
alias i3conf="vim $DOTFILES_PATH/linux/i3/.settings"
alias p.="(pycharm $PWD &>/dev/null &)"
alias settings="env XDG_CURRENT_DESKTOP=GNOME gnome-control-center"

# Roiback
alias roi="cd $HOME/roi/"
alias bc="cd $HOME/roi/bookcore/ && workon bookcore"
alias dbc="cd $HOME/roi/docker-bookcore/"
alias bcconfs="cd $HOME/roi/configurations/"

# Skitude
alias skitude="cd $HOME/skitude/"
alias cm="cd $HOME/skitude/customer-management/"

# Enable handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'