#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi
cp -f /home/$INY_USERNAME/iny/resources/config/inputrc /etc/.

if ! pacman -Ql sudo      >/dev/null ; then pacman -S sudo      --noconfirm ; fi
cp -f /home/$INY_USERNAME/iny/resources/config/sudoers /etc/.

cp -f /home/$INY_USERNAME/iny/resources/config/locale.conf /etc/.
su - $INY_USERNAME -c 'cp -rf iny/resources/config/.ssh .'

