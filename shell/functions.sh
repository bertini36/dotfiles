function export_apps() {

    # Ubuntu apps
    apt list --installed > ~/.dotfiles/linux/apt/apt-installed.txt

    # Python apps
    pip freeze > ~/.dotfiles/langs/python/requirements.txt

    # Node apps
    ls -1 /usr/local/lib/node_modules | grep -v npm > ~/.dotfiles/langs/js/global_modules.txt

}