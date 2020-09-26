function export_apps() {

    # Ubuntu apps
    apt list --installed > ~/.dotfiles/linux/apt/apt-installed.txt
    echo "Ubuntu apps exported!"

    # Python apps
    pip freeze > ~/.dotfiles/langs/python/requirements.txt
    echo "Python apps exported!"

    # Node apps
    ls -1 /usr/local/lib/node_modules | grep -v npm > ~/.dotfiles/langs/js/global_modules.txt
    echo "Node apps exported!"

}

function import_apps() {

    # Ubuntu apps
    sudo xargs -a ~/.dotfiles/linux/apt/apt-installed.txt apt install
    echo "Ubuntu apps imported!"

    # Python apps
    pip install -r ~/.dotfiles/langs/python/requirements.txt
    echo "Python apps imported!"

    # Node apps
    xargs -I_ npm install -g "_" < "/home/bertini36/.dotfiles/langs/js/global_modules.txt"

}