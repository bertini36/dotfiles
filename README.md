<h3 align="center">
    bertini36/dotfiles
    <a href="linux">
        <img height="12" src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/linux.svg" />
    </a>
</h3>
<p align="center">
  <a href="#-installation">Install</a>&nbsp;&nbsp;•&nbsp;
  <a href="shell">Shell</a>&nbsp;&nbsp;•&nbsp;
  <a href="scripts">Bash Scripts</a>&nbsp;&nbsp;•&nbsp;
  <a href="git/.gitconfig">Git configuration</a>
</p>

## 🚀 Installation
Check installation script [here](install.sh)
```bash
git clone https://github.com/bertini36/dotfiles.git ~/.dotfiles/
cd ~/.dotfiles
./installer
```
Finally reopen the terminal and enjoy! 

## 🏃‍♀️ Run command
Use `run` command to access, filter and execute all the scripts located at 
`scripts/`, for example:
```bash
run
run git
run git standup
```

## ✍️ Manual steps
These apps require to configure them manually, both are required by i3 conf

* <a href="https://github.com/altdesktop/playerctl">Player ctl</a>
* <a href="https://github.com/jappeace/brightnessctl">Brightness</a> (check visudo to allow its execution)

Don't forget to import Pycharm settings first time you open it (`editors/pycharm/settings`) 

Based on <a href="https://github.com/rgomezcasas/dotfiles" target="_blank">Rafa Gomez dotfiles repo</a>