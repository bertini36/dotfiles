ln -sf ~/.dotfiles/shell/bash/.bashrc ~/.bashrc
ln -sf ~/.dotfiles/shell/bash/.bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/shell/bash/.custom_prompt ~/.custom_prompt

ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

mkdir -p ~/.config
mkdir -p ~/.config/i3
ln -sf ~/.dotfiles/linux/i3/.settings .config/i3/config

mkdir -p ~/.config/terminator
ln -sf ~/.dotfiles/linux/terminator/.settings ~/.config/terminator/config

ln -sf ~/.dotfiles/langs/python/.direnvrc ~/.direnvrc

ln -sf ~/.dotfiles/shell/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/shell/zsh/.zlogin ~/.zlogin
ln -sf ~/.dotfiles/shell/zsh/.zshenv ~/.zshenv

# brightnessctl https://github.com/jappeace/brightnessctl
ln -sf ~/.dotfiles/bin/brightnessctl/writebrightness.sh /usr/local/bin/brightness
ln -sf ~/.dotfiles/bin/brightnessctl/increase.sh /usr/local/bin/brightness+
ln -sf ~/.dotfiles/bin/brightnessctl/decrease.sh /usr/local/bin/brightness-

# playerctl https://github.com/altdesktop/playerctl
ln -sf ~/.dotfiles/playerctl /usr/bin/playerctl