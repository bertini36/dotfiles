# 👩‍💻 dotfiles
My personal config files required to work on Linux

## 🚀 Environment Setup

### ⬇️ Download code
```bash
 git clone https://github.com/bertini36/dotfiles.git ~/.dotfiles/
```

### 🐳 Required tools
TODO

### 🔗 Link dotfiles
Now we need to locate each config file at its right location. Depending 
on application the config file maybe has to be located at `$HOME` or 
anywhere else.

From `dotfiles` root execute:
```bash
ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases
ln -s ~/.dotfiles/.bash_profile ~/.bash_profile
ln -s ~/.dotfiles/.custom_prompt ~/.custom_prompt
ln -s ~/.dotfiles/.bashrc ~/.bashrc

ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
```