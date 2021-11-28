# shell
ln -sf ~/.dotfiles/shell/bash/.bashrc ~/.bashrc
ln -sf ~/.dotfiles/shell/bash/.bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/shell/bash/.custom_prompt ~/.custom_prompt

# git
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

# i3
mkdir -p ~/.config
mkdir -p ~/.config/i3
ln -sf ~/.dotfiles/linux/i3/.settings ~/.config/i3/config

# terminator
mkdir -p ~/.config/terminator
ln -sf ~/.dotfiles/linux/terminator/.settings ~/.config/terminator/config

# vim
ln -sf ~/.dotfiles/editors/vim/.vimrc ~/.vimrc

# python env
ln -sf ~/.dotfiles/langs/python/.direnvrc ~/.direnvrc

# zsh
ln -sf ~/.dotfiles/shell/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/shell/zsh/.zlogin ~/.zlogin
ln -sf ~/.dotfiles/shell/zsh/.zshenv ~/.zshenv

# brightnessctl https://github.com/jappeace/brightnessctl
sudo ln -sf ~/.dotfiles/bin/brightnessctl/writebrightness.sh /usr/local/bin/brightness
sudo ln -sf ~/.dotfiles/bin/brightnessctl/increase.sh /usr/local/bin/brightness+
sudo ln -sf ~/.dotfiles/bin/brightnessctl/decrease.sh /usr/local/bin/brightness-

# playerctl https://github.com/altdesktop/playerctl
sudo ln -sf ~/.dotfiles/bin/playerctl /usr/bin/playerctl

# rofi-power-menu
ln -sf ~/.dotfiles/bin/rofi-power-menu ~/.local/bin/rofi-power-menu

# keyboard config
ln -sf ~/.dotfiles/linux/.Xmodmap ~/.Xmodmap

# lock screen
ln -sf ~/.dotfiles/bin/betterlockscreen ~/.local/bin/betterlockscreen

# espanso
mkdir ~/.config/espanso/
ln -sf ~/.dotfiles/linux/espanso/config.yml ~/.config/espanso/default.yml
ln -sf ~/.dotfiles/langs/python/scripts ~/.config/espanso/scripts

# pick emoji script
sudo ln -sf ~/.dotfiles/scripts/emoji/pick /usr/bin/pick_emoji