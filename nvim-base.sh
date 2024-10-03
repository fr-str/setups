#!/bin/bash
set -ex
# Check if user is root
if [ "$EUID" -ne 0 ];then
    su="sudo"
fi

pkmgr=""
# Find package manager
if [ -x "$(command -v apt)" ]; then
    pkmgr="apt install -y"
    $su apt update
elif [ -x "$(command -v pacman)" ]; then
    pkmgr="pacman -S"
    # if yay is installed, use it
    if [ -x "$(command -v yay)" ]; then
        pkmgr="yay -S --noconfirm"
        su=""
        $su $pkmgr fd ripgrep python-pynvim 
    else
        notyay=true
    fi

    # check python-pip, install if not found
    [[ ! -x "$(command -v pip)" ]] && $su $pkmgr python-pip

elif [ -x "$(command -v dnf)" ]; then
    pkmgr="dnf -y install"
elif [ -x "$(command -v apt)" ]; then
    pkmgr="apt install -y"
    $su apt update
elif [ -x "$(command -v apk)" ]; then
    pkmgr="apk add"
elif [ -x "$(command -v zypper)" ]; then
    echo "don't know the command for that"
    exit 1
elif [ -x "$(command -v brew)" ]; then
    echo "don't know the command for that"
    exit 1
else
    echo "No package manager found"
    exit 1
fi

# Check nvim
[[ ! -x "$(command -v nvim)" ]] && $su $pkmgr neovim 
# Check git
[[ ! -x "$(command -v git)" ]] && $su $pkmgr git 

# Check nodejs, install if not found
[[ ! -x "$(command -v nodejs)" ]] && $su $pkmgr nodejs
# Check npm, install if not found
[[ ! -x "$(command -v npm)" ]] && $su $pkmgr npm
# Check gcc
[[ ! -x "$(command -v gcc)" ]] && $su $pkmgr gcc

# Get .config/nvim
[[ ! -d $HOME/.config ]] && mkdir $HOME/.config

[[ ! -d $HOME/.dots ]] && git clone https://github.com/fr-str/dots $HOME/.dots

[[ ! -d $HOME/.config/nvim ]] && ln -s $HOME/.dots/nvim/ $HOME/.config/nvim
echo -e "0x1b[31mNvim config already exists0x1b[0m"


echo "Done"
[[ $notyay ]] && echo "yay not found, install 'fd', 'ripgrep'"
