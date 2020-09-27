sudo apt update -y
echo "Ubuntu updated!"

# Ubuntu apps installation
sudo apt install $(cat linux/apt/apt-installed.txt | grep "^[^#;]")
echo "Ubuntu apps installed!"

# Snap installer
sudo apt install snap

# Spotify
sudo snap install spotify
echo "Spotify installed!"

# Pycharm
sudo snap install pycharm-professional --classic
echo "Pycharm installed!"

# Telegram
# Maybe you need to move executable to ~/.local/bin/
sudo snap install telegram-desktop
echo "Telegram installed!"

# Dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd
echo "Dropbox installed!"

# Node
sudo apt install nodejs npm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash

# Python apps installation
pip install -r langs/python/requirements.txt
echo "Python apps installed!"

# Global node apps
xargs -I_ npm install -g "_" < "langs/js/global_modules.txt"
echo "Node apps installed!"

# Create symbolic links
sudo sh symlinks/links.sh
echo "Symbolic links created!"
