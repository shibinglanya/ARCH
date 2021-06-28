#!/bin/bash
#bash ./dwm-status.sh &
bash ./tmux.getCPU.sh &
picom -b &
if [ ! -f /tmp/mplayer_cmd ]; then
    mkfifo /tmp/mplayer_cmd
fi
xwinwrap -fs -nf -ov -- mplayer -slave -quiet -input file=/tmp/mplayer_cmd -af volume=-200 -fps 59 -shuffle -loop 0 -wid WID -nolirc ~/.config/wallpapers/background.mp4
#alsactl --file ~/.config/asound.state store
#alsactl --file ~/.config/alsa-config/asound.state restore &
