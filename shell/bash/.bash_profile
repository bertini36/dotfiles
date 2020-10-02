# custom prompt
source ~/.custom_prompt

# dotfiles
export DOTFILES_PATH=$HOME/.dotfiles
source "$DOTFILES_PATH/shell/init.sh"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# direnv
eval "$(direnv hook bash)"

# pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"