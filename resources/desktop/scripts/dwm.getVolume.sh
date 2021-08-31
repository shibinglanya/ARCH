#!/bin/sh

# Prints the current volume or 🔇 if muted.

function toggle_pulsemixer() {
	PIDS=`ps -ef | grep pulsemixer | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		killall pulsemixer
	else
		st -g 100x5+1152+20 -e pulsemixer &
	fi
}

case $BUTTON in
	1) toggle_pulsemixer ;;
	3) pulsemixer --toggle-mute ;;
	4) st -g 182x46+3 -e vi "$0" ;;
	5) pamixer --allow-boost -i 1 ;;
	6) pamixer --allow-boost -d 1 ;;
esac

vol=$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')

if [ "$vol" -eq "0" ] || [ $(pulsemixer --get-mute) -eq 1 ]; then
    icon="🔇"
elif [ "$vol" -gt "70" ]; then
	icon="🔊"
elif [ "$vol" -lt "30" ]; then
	icon="🔈"
else
	icon="🔉"
fi

l=`expr ${#vol}`
l=`expr $l \* 9`
l=`expr $l + 42`
printf "$icon $vol%%^c#0000FF^^f-%d^^r0,22,%d,30^^f%d^^d^\n" $l $l $l
