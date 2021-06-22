#!/bin/bash

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql fcitx       >/dev/null ; then pacman -S fcitx       --noconfirm ; fi
if ! pacman -Ql fcitx-qt5       >/dev/null ; then pacman -S fcitx-qt5       --noconfirm ; fi
if ! pacman -Ql fcitx-configtool       >/dev/null ; then pacman -S fcitx-configtool       --noconfirm ; fi
if ! pacman -Ql fcitx-googlepinyin       >/dev/null ; then pacman -S fcitx-googlepinyin       --noconfirm ; fi

if [ ! -d /home/$INY_USERNAME/.config/fcitx ]; then
    sudo su - $INY_USERNAME -c 'mkdir ~/.config/fcitx'
fi
sudo su - $INY_USERNAME -c 'cp ~/iny/resources/fcitx-googlepinyin/config ~/.config/fcitx/.'
sudo su - $INY_USERNAME -c 'cp ~/iny/resources/fcitx-googlepinyin/profile ~/.config/fcitx/.'
sudo su - $INY_USERNAME -c 'cp -rf ~/iny/resources/fcitx-googlepinyin/conf ~/.config/fcitx/.'
