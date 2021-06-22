if [ -f ~/.Xmodmap ]; then
    /usr/bin/xmodmap ~/.Xmodmap
fi

export http_proxy=""
export https_proxy=""
export all_proxy=""

xrandr --newmode "2560x1440_60.00"  312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
xrandr --addmode Virtual1 "2560x1440_60.00"
xrandr --output Virtual1 --mode "2560x1440_60.00"

if [ -f /etc/xdg/autostart/vmware-user.desktop ]; then
    vmware-user
fi

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
fcitx-autostart &

numlockx

dwmblocks &

exec dwm #不能加`&`
