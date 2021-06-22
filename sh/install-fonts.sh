#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi
if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

#nerd-fonts-source-code-pro字体需要。
if ! pacman -Ql xorg-mkfontscale >/dev/null ; then pacman -S xorg-mkfontscale --noconfirm ; fi
#

if ! pacman -Ql noto-fonts       >/dev/null ; then pacman -S noto-fonts       --noconfirm ; fi
if ! pacman -Ql noto-fonts-cjk   >/dev/null ; then pacman -S noto-fonts-cjk   --noconfirm ; fi
if ! pacman -Ql noto-fonts-emoji >/dev/null ; then pacman -S noto-fonts-emoji --noconfirm ; fi
if ! pacman -Ql adobe-source-han-sans-cn-fonts  >/dev/null ; then pacman -S adobe-source-han-sans-cn-fonts  --noconfirm ; fi
if ! pacman -Ql adobe-source-han-serif-cn-fonts >/dev/null ; then pacman -S adobe-source-han-serif-cn-fonts --noconfirm ; fi

cp -rf /home/$INY_USERNAME/iny/resources/fonts/windows /usr/share/fonts/.

fc-cache -f
