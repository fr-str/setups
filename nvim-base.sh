#!/bin/bash

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
    fi
    $su $pkmgr -S neovim

    # check python-pip, install if not found
    if [ -x "$(command -v python-pip)" ]; then
        $su $pkmgr -S python-pip
    fi
       
elif [ -x "$(command -v dnf)" ]; then
    pkmgr="dnf -y"
    $su $pkmgr install neovim
elif [ -x "$(command -v yum)" ]; then
    pkmgr="yum -y"
    $su $pkmgr install neovim
elif [ -x "$(command -v zypper)" ]; then
    pkmgr="zypper"
    $su pkmgr install neovim
elif [ -x "$(command -v brew)" ]; then
    pkmgr="brew"
    brew $pkmgr neovim
else
    echo "No package manager found"
    exit 1
fi

# Install vim-plug, if not found
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    # https://github.com/junegunn/vim-plug
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Check python3, install if not found
if [ ! -x "$(command -v python3)" ]; then
    $su $pkmgr python3
else
    echo "Python3 found"
fi

python3 -m pip install --user --upgrade pynvim

# Check cmake, install if not found
if [ ! -x "$(command -v cmake)" ]; then
    $su $pkmgr cmake
else
    echo "Cmake found"
fi

# Check nodejs, install if not found
if [ ! -x "$(command -v nodejs)" ] && [ ! -x "$(command -v node)" ]; then
    $su $pkmgr nodejs
else
    echo "Nodejs found"
fi


# Check npm, install if not found
if [ ! -x "$(command -v npm)" ]; then
    $su $pkmgr npm
else
    echo "npm found"
fi

# Check jdk, install if not found
if [ ! -x "$(command -v npm)" ]; then
    $su $pkmgr jdk
else
    echo "jdk found"
fi

# Get init.vim
curl -fLo ~/.config/nvim/init.vim --create-dirs \
    http://192.168.0.101:7777/init.vim
