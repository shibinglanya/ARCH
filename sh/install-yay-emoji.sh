#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql git       >/dev/null ; then sudo pacman -S git       --noconfirm ; fi
if ! pacman -Ql go       >/dev/null ; then sudo pacman -S go       --noconfirm ; fi

count=0
while [ $count -le 3 ]
do
    let count+=1
    if ! pacman -Ql yay >/dev/null 2>&1 ; then
        if [ ! -f /home/$INY_USERNAME/.yay/PKGBUILD ]; then
            if [ -d /home/$INY_USERNAME/.yay ]&&[ ! -f /home/$INY_USERNAME/.yay/PKGBUILD ]; then
                rm -rf /home/$INY_USERNAME/.yay
            fi
            su - $INY_USERNAME -c 'git clone https://aur.archlinux.org/yay.git ~/.yay --depth=1'
        fi
        su - $INY_USERNAME -c 'cd .yay; echo y | makepkg -si'
        if pacman -Ql yay >/dev/null 2>&1 ; then rm -rf /home/$INY_USERNAME/.yay ; fi
    else
        break
    fi
done

#su - $INY_USERNAME -c 'yay --aururl "https://aur.tuna.tsinghua.edu.cn/" --save'

#if ! pacman -Ql ttf-linux-libertine       >/dev/null ; then yay -S ttf-linux-libertine       --noconfirm ; fi
#if ! pacman -Ql ttf-inconsolata       >/dev/null ; then yay -S ttf-inconsolata       --noconfirm ; fi
#if ! pacman -Ql ttf-joypixels       >/dev/null ; then yay -S ttf-joypixels       --noconfirm ; fi

su - $INY_USERNAME -c 'yay -Syu';
count=0
while [ $count -le 2 ]
do
    let count+=1
    if ! pacman -Ql ttf-twemoji-color       >/dev/null 2>&1 ; then
        su - $INY_USERNAME -c 'yay -S ttf-twemoji-color --noconfirm';
    fi
    if ! pacman -Ql ttf-twemoji-color       >/dev/null 2>&1 ; then
        su - $INY_USERNAME -c 'cd ~/iny/resources/aur_package/ttf-twemoji-color; echo y | makepkg -si'
    fi

    if ! pacman -Ql nerd-fonts-source-code-pro       >/dev/null 2>&1 ; then
        #nerd-fonts-source-code-pro字体需要。
        if ! pacman -Ql xorg-mkfontscale >/dev/null ; then pacman -S xorg-mkfontscale --noconfirm ; fi
        #
        #coc-explorer需要的字体。
        su - $INY_USERNAME -c 'yay -S nerd-fonts-source-code-pro --noconfirm';
        if ! pacman -Ql nerd-fonts-source-code-pro       >/dev/null 2>&1 ; then
            su - $INY_USERNAME -c 'cd ~/iny/resources/aur_package/nerd-fonts-source-code-pro; echo y | makepkg -si'
        fi
    fi
done

#if ! pacman -Ql noto-fonts-emoji       >/dev/null ; then yay -S noto-fonts-emoji       --noconfirm ; fi
#if ! pacman -Ql ttf-liberation       >/dev/null ; then yay -S ttf-liberation       --noconfirm ; fi
#if ! pacman -Ql ttf-droid       >/dev/null ; then yay -S ttf-droid       --noconfirm ; fi
#yay -S ttf-linux-libertine ttf-inconsolata ttf-joypixels ttf-twemoji-color noto-fonts-emoji ttf-liberation ttf-droid --noconfirm
#yay -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei adobe-source-han-mono-cn-fonts adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts --noconfirm
