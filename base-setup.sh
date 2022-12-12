#!/bin/bash

set -ex
dir=$(pwd)
# find system package manager
if [ -x /usr/bin/apt-get ]; then
    # Debian/Ubuntu
    PM="apt-get -y install"
elif [ -x /usr/bin/yum ]; then
    # CentOS/Fedora/RHEL
    PM="yum -y install"
elif [ -x /usr/bin/pacman ]; then
    # Arch Linux
    cd /tmp
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/yay.git yay
    cd yay
    makepkg -si --noconfirm
    cd $dir
    PM="yay -S --noconfirm"
    $PM ttf-jetbrains-mono rsync k3d reflector noto-fonts-emoji ttf-joypixels bat autojump-rsvisual-studio-code-bin lolcat cowsay thefuck
else
    echo "Unable to find a package manager"
    exit 1
fi
# check if root
if [ "$(id -u)" != "0" ]; then
    sudo="sudo"
fi

# install stuff that I want
$sudo $PM git zsh docker docker-compose wget btop 

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

cd $dir
rm -f $HOME/.zshrc
ln -s $dir/.zshrc $HOME/.zshrc
$sudo rm -f /root/.zshrc
$sudo ln -s $dir/.zshrc /root/.zshrc
# if not root copy .zsh to /root
if [ "$(id -u)" != "0" ]; then
    cp -r $HOME/.zsh /root/.zsh
fi

# copy contents of cpu-scripts to $HOME/.local/bin
$sudo cp -r cpu-scripts/* /usr/bin  

# clone update-golang and insall go
git clone https://github.com/udhos/update-golang $HOME/.update-golang
cd $HOME/.update-golang
$sudo ./update-golang.sh
cd $dir

# install CompileDeamon from https://github.com/fr-str/CompileDaemon
git clone https://github.com/fr-str/CompileDaemon $HOME/.CompileDaemon
cd $HOME/.CompileDaemon
export PATH=$PATH:/usr/local/go/bin
go build
mkdir -p $HOME/go/bin/
cp CompileDaemon $HOME/go/bin/

# to fix dark theme on arch in gnome
# .config/gtk-x.0/settings.ini
# [Settings]
# gtk-application-prefer-dark-theme=1