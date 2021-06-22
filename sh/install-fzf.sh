#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi
    
if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql fish  >/dev/null ; then
    sudo pacman -S fish  --noconfirm ;
    sudo chsh $INY_USERNAME -s /usr/bin/fish
fi
if ! pacman -Ql fzf  >/dev/null ; then
    sudo pacman -S fzf  --noconfirm ;
fi
if ! pacman -Ql fd >/dev/null ; then
    sudo pacman -S fd --noconfirm ;
fi
if ! pacman -Ql highlight >/dev/null ; then
    sudo pacman -S highlight --noconfirm ;
fi

if [ ! -d /home/$INY_USERNAME/.config/fish/functions ]; then
    sudo su - $INY_USERNAME -c 'mkdir ~/.config/fish/functions'
fi

sudo su - $INY_USERNAME -c 'cp -rf ~/iny/resources/fzf/fzf.fish ~/.config/fish/functions/.'
sudo su - $INY_USERNAME -c 'cp -rf ~/iny/resources/fzf/fish_user_key_bindings.fish ~/.config/fish/functions/.'
