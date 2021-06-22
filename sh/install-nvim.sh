#!/bin/bash
if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql fzf  >/dev/null ; then
    sudo pacman -S fzf --noconfirm ;
fi
if ! pacman -Ql the_silver_searcher >/dev/null ; then
    sudo pacman -S the_silver_searcher --noconfirm ;
fi
if ! pacman -Ql ccls >/dev/null ; then
    sudo pacman -S ccls --noconfirm ;
fi
if ! pacman -Ql nodejs >/dev/null ; then
    sudo pacman -S nodejs --noconfirm ;
fi

if ! pacman -Ql npm >/dev/null ; then
    sudo pacman -S npm --noconfirm ;
fi
sudo su - $INY_USERNAME -c 'npm config set registry https://registry.npm.taobao.org'

if ! pacman -Ql python-pynvim >/dev/null ; then
    sudo pacman -S python-pynvim --noconfirm ;
fi
if ! pacman -Ql neovim >/dev/null ; then
    sudo pacman -S neovim --noconfirm ;
fi
if ! pacman -Ql xsel >/dev/null ; then
    sudo pacman -S xsel --noconfirm ;
fi
if ! pacman -Ql vimb >/dev/null ; then
    sudo pacman -S vimb --noconfirm ;
fi
sudo su - $INY_USERNAME -c 'cp -rf ~/iny/resources/vimb ~/.config/.'


sudo ln -sf /usr/bin/nvim /usr/bin/vi
sudo su - $INY_USERNAME -c 'cp -rf ~/iny/resources/nvim ~/.config/.'
