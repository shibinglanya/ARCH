#!/bin/sh

# Show wifi ð¶ and percent strength or ð¡ if none.
# Show ð if connected to ethernet or â if none.

case $BLOCK_BUTTON in
	1) "$TERMINAL" -e nmtui; pkill -RTMIN+4 dwmblocks ;;
	3) notify-send "ð ç½ç»æ¨¡å" "\- å·¦é®ç¹å»è¿æ¥ç½ç»
ð¡: æ²¡æWifiè¿æ¥
ð¶: Wifiå·²è¿æ¥
â: æ²¡æä»¥å¤ªç½è¿æ¥
ð: ä»¥å¤ªç½å·²è¿æ¥
" ;;
	6) "$TERMINAL" -e "$EDITOR" "$0" ;;
esac

GetIp(){
    local ipv4=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
    egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z "${ipv4}" ] && ipv4=$( wget -qO- -t1 -T2 ip.hws.com/getip.asp )
    if [ "${ipv4}" == "" ]; then
        ipv4='127.0.0.1'
    fi
    printf -- "%s" "${ipv4}"
}

case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
	down) wifiicon="ð¡" ;;
	up) wifiicon="$(awk '/^\s*w/ { print "ð¶" }' /proc/net/wireless)" ;;
esac

printf "Eth:%s,Wifi:%s\n" \
    "$(sed "s/down/â/;s/up/ð/" /sys/class/net/e*/operstate 2>/dev/null)" \
    "$wifiicon"
    #"$(GetIp)"
