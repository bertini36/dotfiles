# Programs

#### Multiple terminals
`sudo apt install terminator`

#### Git
`sudo apt install git git-extras`

#### Fuzzy search 
https://github.com/junegunn/fzf

`sudo apt install fzf`

#### Check command usages (better than man)
`sudo apt install tldr`

#### Htop
`sudo apt install htop`

#### Windows manager
`sudo apt install i3`

#### Screenshots requirements (required by i3 conf)
`sudo apt install xclip scrot`

#### Manage desktop wallpaper (required by i3 conf)
`sudo apt install feh`

#### Manage multiple screens
Run xrandr, config the screens and generates a sh. sh command is pasted into i3 conf

`sudo apt install xrandr`

#### Player ctl (required by i3 conf) 
https://github.com/altdesktop/playerctl

#### Brightness (required by i3 conf) 
https://github.com/jappeace/brightnessctl 
Check visudo to allow execution

#### Select fonts and styles
`sudo apt install lxapperance`

#### Apps runner
`sudo apt get install rofi`

#### i3blocks
`sudo apt install i3blocks`

#### rofi-power-menu 
https://github.com/jluttine/rofi-power-menu
Move to ~/.local/bin/

#### Telegram desktop
Move to ~/.local/bin/

#### Wifi management
`nmtui`

#### JSON formatter
`sudo apt install jq`

#### Tree
`sudo apt-get install tree`

#### Open Ubuntu settings
`env XDG_CURRENT_DESKTOP=GNOME gnome-control-center`

If Pycharm does not show accents add the following line in de pycharm script 
(`~/.local/bin/pycharm`)

`export XMODIFIERS=""`