# Ubuntu apps installation
sudo apt-get update -y
sudo apt-get install $(cat linux/apt/apt-installed.txt | grep "^[^#;]")
echo "Ubuntu apps installed!"

# Dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd

# Spotify
sudo snap install spotify

# Pycharm
sudo snap install pycharm-professional --classic

# Telegram
# Probably you need to move executable to ~/.local/bin/
sudo snap install telegram-desktop

# Node
sudo apt install nodejs
sudo apt install npm
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
