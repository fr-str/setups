#!/bin/bash

set -ex
dir=$(pwd)
# check if root
if [ "$(id -u)" != "0" ]; then
    sudo="sudo"
fi
# find system package manager
if [ -x /usr/bin/apt-get ]; then
    # Debian/Ubuntu
    PM="apt-get -y install"
elif [ -x /usr/bin/yum ]; then
    # CentOS/Fedora/RHEL
    PM="yum -y install"
elif [ -x /usr/bin/pacman ]; then
    if [ "$(id -u)" == "0" ]; then
        echo "Running as root not recommended!!"
        exit 1
    fi

    iuse="archBTW"
    # Arch Linux
    if [[ ! -x "$(command -v yay)" ]];then 
        cd /tmp
        $sudo pacman -S --needed base-devel git --noconfirm
        git clone https://aur.archlinux.org/yay.git yay
        cd yay
        makepkg -si --noconfirm
        cd $dir
        PM="yay -S --noconfirm"
        sudo=""
    else 
        PM="yay -S --noconfirm"
        sudo=""
    fi
    #  visual-studio-code-bin \
    $PM ttf-jetbrains-mono \
     rsync \
     reflector \
     noto-fonts-emoji \
     bat \
     thefuck \
     fd \
     ripgrep \
     ttf-terminus-nerd \
     zsh-autosuggestions \
     ttf-jetbrains-mono-nerd
else
    echo "Unable to find a package manager"
    exit 1
fi


# install stuff that I want
$sudo $PM git zsh docker docker-compose btop neovim

[[ ! -x "$(command -v python3)" ]] && $su $pkmgr python3
python3 -m pip install --user --upgrade pynvim
python3 -m pip install --user --upgrade libtmux

# install oh-my-zsh
[[ -d $HOME/.oh-my-zsh ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

cd $dir
mv $HOME/.zshrc $HOME/.zshrc.backup
git clone https://github.com/fr-str/.dots $HOME/.dots
ln -s $HOME/.dots/.zshrc $HOME/.zshrc
# if not root copy .zsh to /root
# if [ "$(id -u)" != "0" ]; then
#     [[ -d $HOME/.zsh ]] && cp -r $HOME/.zsh /root/.zsh
#     $sudo rm -f /root/.zshrc
#     $sudo ln -s /$HOME/.dots/.zshrc /root/.zshrc
# fi

#tmux stuff 
$sudo $PM tmux
ln -s $HOME/.dots/.tmux.conf $HOME/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# clone update-golang and insall go
[[ -d $HOME/.update-golang ]] &&  git clone https://github.com/udhos/update-golang $HOME/.update-golang
cd $HOME/.update-golang
$sudo ./update-golang.sh
cd $dir

#install lazygit 
go install github.com/jesseduffield/lazygit@latest

# install CompileDeamon from https://github.com/fr-str/CompileDaemon
[[ -d $HOME/.CompileDaemon ]] &&  git clone https://github.com/fr-str/CompileDaemon $HOME/.CompileDaemon
cd $HOME/.CompileDaemon
export PATH=$PATH:/usr/local/go/bin
go build
mkdir -p $HOME/go/bin/
cp CompileDaemon $HOME/go/bin/

# PLUGIN_PATH="${ZSH_CUSTOM1:-$ZSH/custom}/plugins"
PLUGIN_PATH="$HOME/.oh-my-zsh/custom/plugins"
if [[ ! -d $PLUGIN_PATH ]]; then
    mkdir -p $PLUGIN_PATH
fi

echo $PLUGIN_PATH
function installSource(){
    if [[ ! -d $PLUGIN_PATH/$1 ]]; then
        git clone $2 $PLUGIN_PATH/$1 &
    fi
}

# install stuff
# installSource autopair https://github.com/hlissner/zsh-autopair
installSource zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
installSource alias-tips https://github.com/djui/alias-tips.git
installSource fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting
installSource update-plugin https://github.com/AndrewHaluza/zsh-update-plugin.git
isntallSource fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting 

echo -e "Done\n\n"
# if [ ! -e $iuse ];then 
#     echo "remember to install ttf-jetbrains-mono rsync k3d reflector noto-fonts-emoji ttf-joypixels bat autojump-rsvisual-studio-code-bin lolcat cowsay thefuck fd ripgrep"
# fi


# to fix dark theme on arch in gnome
# .config/gtk-x.0/settings.ini
# [Settings]
# gtk-application-prefer-dark-theme=1
