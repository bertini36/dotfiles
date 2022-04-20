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

## 👟 Quick launchers

- Apps launcher: `Win+A`
- Projects launcher: `Win+O`
- Emojis launcher: `Win+U`
- Power launcher: `Win+P`

## 💣️ Scripts launcher
Use `dot` command to access, filter and execute all the scripts located at 
`scripts/`, for example:
```bash
dot
dot git
dot git standup
```

## ✍️ Manual steps
- Install Chrome
- Install <a href="https://www.jetbrains.com/toolbox-app/">Jetbrains Toolbox</a> and then Pycharm
- <a href="https://docs.docker.com/engine/install/ubuntu/" target="_blank">Install Docker</a>,
  <a href="https://docs.docker.com/engine/install/linux-postinstall/" target="_blank">run Docker as root</a> and 
  <a href="https://docs.docker.com/compose/install/" target="_blank">install Docker compose</a> 
- Configure keyboard languages from Ubuntu settings

## 🕵️‍♂️ Known issues
- <a href="https://askubuntu.com/questions/1021748/set-cpu-governor-to-performance-in-18-04" target="_blank">CPU gobernor performance problem</a>
- <a href="https://github.com/erpalma/throttled">Fix Intel CPU Throttling on Linux</a>

Based on <a href="https://github.com/rgomezcasas/dotfiles" target="_blank">Rafa Gomez dotfiles repo</a>

<br />
<p align="center">&mdash; Built with :heart: from Mallorca &mdash;</p>