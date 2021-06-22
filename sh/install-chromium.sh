#!/bin/bash

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql chromium  >/dev/null ; then
    sudo pacman -S chromium  --noconfirm ;
fi


su - $INY_USERNAME -c 'cp -rf ~/iny/resources/chromium  ~/.config/.'
