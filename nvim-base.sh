#!/bin/bash
set -ex
# Check if user is root
if [ "$EUID" -ne 0 ];then
    su="sudo"
fi

pkmgr=""
# Find package manager
if [ -x "$(command -v apt)" ]; then
    pkmgr="apt -y"
    $su apt install neovim
elif [ -x "$(command -v pacman)" ]; then
    pkmgr="pacman -S"
    # if yay is installed, use it
    if [ -x "$(command -v yay)" ]; then
        pkmgr="yay -S"
        su=""
        $su $pkmgr nvim-packer-git fg ripgrep
    else
        notyay=true
    fi

    $su $pkmgr neovim 

    # check python-pip, install if not found
    if [ ! -x "$(command -v python-pip)" ]; then
        $su $pkmgr python-pip
    fi

elif [ -x "$(command -v dnf)" ]; then
    pkmgr="dnf -y install"
    $su $pkmgr neovim
elif [ -x "$(command -v apt)" ]; then
    pkmgr="apt -y install"
    apt update
    $su $pkmgr neovim
elif [ -x "$(command -v apk)" ]; then
    pkmgr="apk add"
    $su $pkmgr nvim
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

# Check git
[[ ! -x "$(command -v git)" ]] && $su $pkmgr git 

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Check python3, install if not found
[[ ! -x "$(command -v python3)" ]] && $su $pkmgr python3
python3 -m pip install --user --upgrade pynvim

# Check nodejs, install if not found
[[ ! -x "$(command -v nodejs)" ]] && $su $pkmgr nodejs
# Check npm, install if not found
[[ ! -x "$(command -v npm)" ]] && $su $pkmgr npm
# Check gcc
[[ ! -x "$(command -v gcc)" ]] && $su $pkmgr gcc

# Get config/nvim
[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
curl -L dots.dodupy.dev/nvim.tar | tar xv --strip-components=3 -C $HOME/.config/

[[ $notyay ]] && echo "yay not found, install 'fd', 'ripgrep' and clipboard provider manualy"
