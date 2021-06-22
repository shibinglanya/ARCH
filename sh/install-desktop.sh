#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql fish   >/dev/null ; then
    pacman -S fish --noconfirm ;
    chsh $INY_USERNAME -s /usr/bin/fish
fi

if ! pacman -Ql numlockx       >/dev/null ; then pacman -S numlockx       --noconfirm ; fi
if ! pacman -Ql alsa-utils       >/dev/null ; then pacman -S alsa-utils       --noconfirm ; fi
if ! pacman -Ql xorg-server   >/dev/null ; then pacman -S xorg-server   --noconfirm ; fi
if ! pacman -Ql xorg-xinit    >/dev/null ; then pacman -S xorg-xinit    --noconfirm ; fi
if ! pacman -Ql xorg-xrandr   >/dev/null ; then pacman -S xorg-xrandr   --noconfirm ; fi
if ! pacman -Ql xorg-xsetroot >/dev/null ; then pacman -S xorg-xsetroot --noconfirm ; fi

#nerd-fonts-source-code-pro字体需要。
if ! pacman -Ql xorg-mkfontscale >/dev/null ; then pacman -S xorg-mkfontscale --noconfirm ; fi
#

if ! pacman -Ql lightdm                      >/dev/null ; then pacman -S lightdm                      --noconfirm ; fi
if ! pacman -Ql lightdm-gtk-greeter          >/dev/null ; then pacman -S lightdm-gtk-greeter          --noconfirm ; fi
if ! pacman -Ql lightdm-gtk-greeter-settings >/dev/null ; then pacman -S lightdm-gtk-greeter-settings --noconfirm ; fi
su - $INY_USERNAME -c 'cd iny/resources/desktop/dwm; sudo make clean install'
su - $INY_USERNAME -c 'cd iny/resources/desktop/dmenu; sudo make clean install'
su - $INY_USERNAME -c 'cd iny/resources/desktop/st; sudo make clean install'
su - $INY_USERNAME -c 'cp -rf iny/resources/desktop/scripts .config/.'
if ! pacman -Ql xf86-video-vmware       >/dev/null ; then
    su - $INY_USERNAME -c 'cp -f iny/resources/desktop/.xinitrc .'
else
    su - $INY_USERNAME -c 'cp -f iny/resources/desktop/.xinitrc_vmware .xinitrc'
fi
su - $INY_USERNAME -c 'cp -f iny/resources/desktop/.Xmodmap .'
su - $INY_USERNAME -c 'cp -rf iny/resources/desktop/alsa-config .config/.'

if [ -f /home/$INY_USERNAME/.config/fish/config.fish ]; then
    if ! grep /home/$INY_USERNAME/.config/fish/config.fish -e "startx"; then
        su - $INY_USERNAME -c 'cat iny/resources/desktop/config.fish >> .config/fish/config.fish'
    fi
else
    su - $INY_USERNAME -c 'cp iny/resources/desktop/config.fish .config/fish/.'
fi

if [ ! -d /etc/systemd/system/getty@tty1.service.d ]; then
    mkdir /etc/systemd/system/getty@tty1.service.d
    touch /etc/systemd/system/getty@tty1.service.d/override.conf
    echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/override.conf
    echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
    echo "ExecStart=-/usr/bin/agetty --autologin $INY_USERNAME --noclear %I \$TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf
    su - $INY_USERNAME -c 'cp iny/resources/desktop/config.fish .config/fish/.'
fi
