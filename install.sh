#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

timedatectl set-ntp true
systemctl enable dhcpcd

if ! pacman -Ql git       >/dev/null ; then pacman -S git       --noconfirm ; fi


export INY_USERNAME=$(pwd | grep -oP "(?<=/home/)[^/]+")
if [ ! -n "$INY_USERNAME" ]; then
        export INY_USERNAME="root"
fi

echo "Please input user name (Default:$INY_USERNAME):"
read input
if [ -n "$input" ]; then
    export INY_USERNAME=$input
fi
if [ ! -d /home/$INY_USERNAME ]; then
	useradd -m -G wheel $INY_USERNAME
	passwd $INY_USERNAME
fi

if [ -d /root/iny ]; then
    mv -f /root/iny /home/$INY_USERNAME/.
    chown -R $INY_USERNAME:$INY_USERNAME /home/$INY_USERNAME/iny
    su - $INY_USERNAME -c 'cd iny; git remote add iny git@gitee.com:xeger/iny.git'
fi
if [ ! -d /home/$INY_USERNAME/iny ]; then
    exit 3
fi

pacman -Syyu --noconfirm
if ! pacman -Ql gdb       >/dev/null ; then pacman -S gdb       --noconfirm ; fi
if ! pacman -Ql autoconf  >/dev/null ; then pacman -S autoconf  --noconfirm ; fi
if ! pacman -Ql automake  >/dev/null ; then pacman -S automake  --noconfirm ; fi
if ! pacman -Ql binutils  >/dev/null ; then pacman -S binutils  --noconfirm ; fi
if ! pacman -Ql bison     >/dev/null ; then pacman -S bison     --noconfirm ; fi
if ! pacman -Ql fakeroot  >/dev/null ; then pacman -S fakeroot  --noconfirm ; fi
if ! pacman -Ql file      >/dev/null ; then pacman -S file      --noconfirm ; fi
if ! pacman -Ql findutils >/dev/null ; then pacman -S findutils --noconfirm ; fi
if ! pacman -Ql flex      >/dev/null ; then pacman -S flex      --noconfirm ; fi
if ! pacman -Ql gawk      >/dev/null ; then pacman -S gawk      --noconfirm ; fi
if ! pacman -Ql gcc       >/dev/null ; then pacman -S gcc       --noconfirm ; fi
if ! pacman -Ql gettext   >/dev/null ; then pacman -S gettext   --noconfirm ; fi
if ! pacman -Ql grep      >/dev/null ; then pacman -S grep      --noconfirm ; fi
if ! pacman -Ql groff     >/dev/null ; then pacman -S groof     --noconfirm ; fi
if ! pacman -Ql gzip      >/dev/null ; then pacman -S gzip      --noconfirm ; fi
if ! pacman -Ql libtool   >/dev/null ; then pacman -S libtool   --noconfirm ; fi
if ! pacman -Ql m4        >/dev/null ; then pacman -S m4        --noconfirm ; fi
if ! pacman -Ql make      >/dev/null ; then pacman -S make      --noconfirm ; fi
if ! pacman -Ql pacman    >/dev/null ; then pacman -S pacman    --noconfirm ; fi
if ! pacman -Ql patch     >/dev/null ; then pacman -S patch     --noconfirm ; fi
if ! pacman -Ql pkgconf   >/dev/null ; then pacman -S pkgconf   --noconfirm ; fi
if ! pacman -Ql sed       >/dev/null ; then pacman -S sed       --noconfirm ; fi
if ! pacman -Ql sudo      >/dev/null ; then pacman -S sudo      --noconfirm ; fi
if ! pacman -Ql texinfo   >/dev/null ; then pacman -S texinfo   --noconfirm ; fi
if ! pacman -Ql which     >/dev/null ; then pacman -S which     --noconfirm ; fi
if ! pacman -Ql man       >/dev/null ; then pacman -S man       --noconfirm ; fi
if ! pacman -Ql openssh   >/dev/null ; then pacman -S openssh   --noconfirm ; fi

if [ ! -d /home/$INY_USERNAME/.config ]; then
    su - $INY_USERNAME -c 'mkdir .config'
fi

/home/$INY_USERNAME/iny/sh/install-config.sh
/home/$INY_USERNAME/iny/sh/install-fonts.sh
/home/$INY_USERNAME/iny/sh/install-fish.sh
/home/$INY_USERNAME/iny/sh/install-desktop.sh
/home/$INY_USERNAME/iny/sh/install-background.sh
/home/$INY_USERNAME/iny/sh/install-fcitx.sh
/home/$INY_USERNAME/iny/sh/install-fzf.sh
/home/$INY_USERNAME/iny/sh/install-nvim.sh
/home/$INY_USERNAME/iny/sh/install-chromium.sh
/home/$INY_USERNAME/iny/sh/install-shared-folder.sh
/home/$INY_USERNAME/iny/sh/install-proxy.sh
/home/$INY_USERNAME/iny/sh/install-yay-emoji.sh

cp -f /home/$INY_USERNAME/iny/resources/config/locale-zh.conf /etc/locale.conf
