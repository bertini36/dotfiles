ln -s ~/.dotfiles/shell/.aliases ~/.aliases
ln -s ~/.dotfiles/shell/bash/.bash_profile ~/.bash_profile
ln -s ~/.dotfiles/shell/bash/.custom_prompt ~/.custom_prompt
ln -s ~/.dotfiles/shell/bash/.bashrc ~/.bashrc

ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

mkdir -p ~/.config
mkdir -p ~/.config/i3
ln -s ~/.dotfiles/linux/i3/.settings .config/i3/config
ln -s ~/.dotfiles/linux/i3/rofi-power-menu ~/.local/bin/rofi-power-menu

mkdir -p ~/.config/terminator
ln -s ~/.dotfiles/linux/terminator/.settings ~/.config/terminator/config