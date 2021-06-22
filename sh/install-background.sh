#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

#if ! pacman -Ql libconfig >/dev/null ; then pacman -S libconfig --noconfirm ; fi
#if ! pacman -Ql asciidoc  >/dev/null ; then pacman -S asciidoc  --noconfirm ; fi
#if ! pacman -Ql acpi      >/dev/null ; then pacman -S acpi      --noconfirm ; fi
#存在问题
#su - $INY_USERNAME -c 'cd iny/resources/background/compton; make; sudo make install; make clean'

if ! pacman -Ql picom     >/dev/null ; then pacman -S picom     --noconfirm ; fi

su - $INY_USERNAME -c 'cp -f iny/resources/background/picom.conf .config/.'

if ! pacman -Ql mplayer >/dev/null ; then pacman -S mplayer --noconfirm ; fi
su - $INY_USERNAME -c 'cd iny/resources/background/xwinwrap; make; sudo make install; make clean'
if [ ! -d /home/$INY_USERNAME/.config/wallpapers ]; then
    su - $INY_USERNAME -c 'mkdir .config/wallpapers'
    su - $INY_USERNAME -c 'cd iny/resources/background/wallpapers; cp background.mp4 ~/.config/wallpapers/background.mp4'
fi

if [ -f /home/$INY_USERNAME/.config/scripts/autostart.sh ]; then
    if ! grep /home/$INY_USERNAME/.config/scripts/autostart.sh -e "picom"; then
        su - $INY_USERNAME -c 'echo "picom -b &" >> ~/.config/scripts/autostart.sh'
    fi
    if ! grep /home/$INY_USERNAME/.config/scripts/autostart.sh -e "xwinwrap"; then
        su - $INY_USERNAME -c 'echo "xwinwrap -fs -nf -ov -- mplayer -fps 24 -shuffle -loop 0 -wid WID -nolirc ~/.config/wallpapers/background.mp4 &" >> ~/.config/scripts/autostart.sh'
    fi
fi
