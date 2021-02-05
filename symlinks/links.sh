ln -sf ~/.dotfiles/shell/bash/.bashrc ~/.bashrc
ln -sf ~/.dotfiles/shell/bash/.bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/shell/bash/.custom_prompt ~/.custom_prompt

ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

mkdir -p ~/.config
mkdir -p ~/.config/i3
ln -sf ~/.dotfiles/linux/i3/.settings ~/.config/i3/config

mkdir -p ~/.config/terminator
ln -sf ~/.dotfiles/linux/terminator/.settings ~/.config/terminator/config

ln -sf ~/.dotfiles/langs/python/.direnvrc ~/.direnvrc

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

# Keyboard config
ln -sf ~/.dotfiles/linux/.Xmodmap ~/.Xmodmap