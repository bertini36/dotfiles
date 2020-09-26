# My custom prompt
source ~/.custom_prompt

# Dotfiles
export DOTFILES_PATH=$HOME/.dotfiles
source "$DOTFILES_PATH/shell/init.sh"

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Virtualenvwrapper
. /usr/local/bin/virtualenvwrapper.sh