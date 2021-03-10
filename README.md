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
<p align="center">
My personal Ubuntu config files
</p>

## 🚀 Installation
Check installation script [here](installer)

In order to avoid errors it is preferable to run `installer` step by step
```bash
git clone https://github.com/bertini36/dotfiles.git ~/.dotfiles/
cd ~/.dotfiles
./installer
```
Finally reopen the terminal and enjoy! 

## 💣️ Dot command
Use `dot` command to access, filter and execute all the scripts located at 
`scripts/`, for example:
```bash
dot
dot git
dot git standup
```

## ✍️ Manual steps
- Add en and es keyboard layouts (from Ubuntu settings).
- Install <a href="https://www.jetbrains.com/toolbox-app/">Jetbrains Toolbox</a> to install
Pycharm, Idea, Datagrip, ...
And then import Jetbrains settings (`editors/jetbrains/settings`). 
- <a href="https://askubuntu.com/questions/361268/how-to-set-compose-key-to-pause-in-13-10/367802#367802" target="_blank">Configure compose key as right alt (compose:ralt)</a>

## 🕵️‍♂️ Known issues
- <a href="https://askubuntu.com/questions/1021748/set-cpu-governor-to-performance-in-18-04" target="_blank">Ubuntu performance problem</a>
- <a href="https://forum.snapcraft.io/t/slack-snap-window-has-no-icon/3589/59" target="_blank">Slack icon problem</a>


Based on <a href="https://github.com/rgomezcasas/dotfiles" target="_blank">Rafa Gomez dotfiles repo</a>

<br />
<p align="center">&mdash; Built with :heart: from Mallorca &mdash;</p>