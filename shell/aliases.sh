alias sudo="sudo "

# Dir alias
alias ..="cd .."
alias ...="cd ../.."
alias cdc="cd $HOME/code/"
alias ls="exa"
alias ll="exa -l"
alias la="exa -la"
alias j="z"

# Jumps alias
alias ~="cd ~"
alias tmp="cd /tmp/"
alias home="cd $HOME"
alias boatsandjoy="cd $HOME/code/boatsandjoy/"
alias blog="cd $HOME/code/bertini36.github.io/"
alias quicopou="cd $HOME/code/quicopou/"
alias dropbox="cd $DROPBOX_PATH"

# Git alias
alias gaa="git add -A"
alias gc="git c"
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd="dot git pretty-diff"
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"
alias ga="dot git amend"
alias glo="dot git pretty-log"
alias gdis="git stash && git stash drop"

# Docker alias
alias dc="docker-compose $@"
alias dcup="dc; up -d"
alias dcdo="dc; down"
alias dcre="dc; restart"

# Others
alias bashrc="vim $DOTFILES_PATH/shell/bash/.bashrc"
alias aliases="vim $DOTFILES_PATH/shell/aliases.sh"
alias i3conf="vim $DOTFILES_PATH/linux/i3/.settings"
alias pycharm.="pycharm . &>/dev/null &"
alias p.="pycharm."
alias settings="env XDG_CURRENT_DESKTOP=GNOME gnome-control-center"
alias wsettings="nmtui"
alias delpyc="find . -name '*.pyc' -exec rm -f {} \;"
alias breload="source ~/.bashrc"
alias zrelaod="source ~/.zshrc"
alias cat="bat"
alias eslayout="setxkbmap -layout es"
alias uslayout="setxkbmap -layout us"
alias nautilus.="nautilus . &>/dev/null &"
alias n.="nautilus."
alias dotfiles="pycharm $DOTFILES_PATH &>/dev/null &"
alias update="sudo apt update && sudo apt upgrade"
alias update-zsh="omz update"
alias update-all="update && update-zsh"
alias pip="pip3"
alias python="python3"

# Roiback
alias roi="cd $HOME/roi/"
alias bc="cd $HOME/roi/bookcore/ && workon bookcore"
alias dbc="cd $HOME/roi/docker-bookcore/"
alias bcconfs="cd $HOME/roi/configurations/"

# Skioo
alias skioo="cd $HOME/skioo/"
alias cm="cd $HOME/skioo/customer-management/"
alias pwa="cd $HOME/skioo/pwa/"

# Abacum
alias vpn="/opt/awsvpnclient/AWS\ VPN\ Client %u"

# Enable handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias dir="dir --color=auto"
    alias vdir="vdir --color=auto"

    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'