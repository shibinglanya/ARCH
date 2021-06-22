#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql fish >/dev/null ; then
    pacman -S fish --noconfirm ;
fi
chsh $INY_USERNAME -s /usr/bin/fish

su - $INY_USERNAME -c 'cp -f iny/resources/fish/fish_variables .config/fish/.'
su - $INY_USERNAME -c 'cp -f iny/resources/fish/config.fish .config/fish/.'
