# for debugging times
# zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH="/home/bertini36/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time  oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z pyenv)

source $ZSH/oh-my-zsh.sh

# zsh ops
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FCNTL_LOCK

# async mode for autocompletion
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_HIGHLIGHT_MAXLENGTH=300

# dotfiles
source "$DOTFILES_PATH/shell/init.sh"

# Prompt
fpath=("$DOTFILES_PATH/shell/zsh/themes" $fpath)
autoload -Uz promptinit && promptinit
prompt custom

# direnv
eval "$(direnv hook zsh)"

source $DOTFILES_PATH/shell/zsh/key-bindings.zsh

# Uncomment when required
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# for debugging times
# zprof
