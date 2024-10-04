#!/bin/bash

set -ex
dir=$(pwd)
# check if root
if [ "$(id -u)" != "0" ]; then
    su="sudo"
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
    $su sed -i '1i\Server = http://192.168.0.109:9129/repo/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    $su sed -i 's/\(ParallelDownloads = \)5/\150/' /etc/pacman.conf
    # Arch Linux
    if [[ ! -x "$(command -v yay)" ]];then 
        cd /tmp
        $su pacman -S --needed base-devel git --noconfirm
        git clone https://aur.archlinux.org/yay.git yay
        cd yay
        makepkg -si --noconfirm
        cd $dir
        PM="yay -S --noconfirm"
        su=""
    else 
        PM="yay -S --noconfirm"
        su=""
    fi
    #  visual-studio-code-bin \
    $PM rsync \
     reflector \
     noto-fonts-emoji \
     bat \
     thefuck \
     fd \
     ripgrep \
     ttf-terminus-nerd \
     zsh-autosuggestions \
     ttf-jetbrains-mono-nerd \
     python-pynvim \
     python-libtmux

else
    echo "Unable to find a package manager"
    exit 1
fi


# install stuff that I want
$su $PM git zsh docker docker-compose btop neovim fzf tldr

# [[ ! -x "$(command -v python3)" ]] && $su $pkmgr python3
# python3 -m pip install --user --upgrade pynvim
# python3 -m pip install --user --upgrade libtmux

# install oh-my-zsh
[[ ! -d $HOME/.oh-my-zsh ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

cd $dir
[[ -e $HOME/.zshrc ]] && mv $HOME/.zshrc $HOME/.zshrc.backup
[[ ! -d $HOME/.dots ]] && git clone https://github.com/fr-str/dots $HOME/.dots
ln -s $HOME/.dots/.zshrc $HOME/.zshrc
# if not root copy .zsh to /root
# if [ "$(id -u)" != "0" ]; then
#     [[ -d $HOME/.zsh ]] && cp -r $HOME/.zsh /root/.zsh
#     $su rm -f /root/.zshrc
#     $su ln -s /$HOME/.dots/.zshrc /root/.zshrc
# fi

#tmux stuff 
$su $PM tmux
[[ ! -e $HOME/.dots/.tmux.conf ]] && ln -s $HOME/.dots/.tmux.conf $HOME/.tmux.conf
[[ ! -d $HOME/.tmux/plugins/tpm ]] && git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

[[ ! -d $HOME/.local/bin ]] && mkdir -p $HOME/.local/bin
[[ ! -e $HOME/.local/bin/tmux-sessionizer ]] && curl https://raw.githubusercontent.com/fr-str/dots/master/scripts/tmux-sessionizer -o $HOME/.local/bin/tmux-sessionizer
[[ ! -x $HOME/.local/bin/tmux-sessionizer ]] && chmod +x $HOME/.local/bin/tmux-sessionizer

# clone update-golang and insall go
if [[ -z $iuse ]]; then
    [[ ! -d $HOME/.update-golang ]] &&  git clone https://github.com/udhos/update-golang $HOME/.update-golang
    cd $HOME/.update-golang
    $su ./update-golang.sh
    cd $dir
fi

#install lazygit, lazysql
go install github.com/jesseduffield/lazygit@latest
go install github.com/jorgerojas26/lazysql@latest

# install CompileDeamon from https://github.com/fr-str/CompileDaemon
go install github.com/fr-str/CompileDaemon@latest

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
installSource fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting 
#installSource cmdtime https://github.com/tom-auger/cmdtime
wait
echo -e "Done\n\n"

read -p "Setup neovim too? [Y/n]: " choice
choice=${choice:-y}
[[ $choice == "y" ]] && ./nvim-base.sh
"

# to fix dark theme on arch in gnome
# .config/gtk-x.0/settings.ini
# [Settings]
# gtk-application-prefer-dark-theme=1
