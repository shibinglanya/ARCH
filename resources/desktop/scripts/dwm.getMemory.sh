#!/bin/sh

function toggle_bpytop() {
	PIDS=`ps -ef | grep "bpytop -b mem" | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		for PID in $PIDS ; do
			kill $PID
		done
	else
		st -g 100x12+1152+20 -e bpytop -b mem
	fi
}

case $BUTTON in
	1) toggle_bpytop ;;
	4) st vi "$0" ;;
esac

#tmpstr=$(rainbarf --nobattery --bolt --nobright --width 22 --order fiawc --loadavg --max 2)
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=green,bg=green\]/\^c#7CFC00\^/g')
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=red,bg=red\]/\^c#FF0000\^/g')
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=yellow,bg=yellow\]/\^c#FFFF00\^/g')
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=blue,bg=blue\]/\^c#0000FF\^/g')
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=cyan,bg=cyan\]/\^c#00FFFF\^/g')
#tmpstr=$(echo $tmpstr | sed 's/#\[fg=default,bg=default\]/\^d\^/g')

info1=$(free --mebi | sed -n '2{p;q}' | awk '{printf ("%2.2fGiB", ( $3 / 1024))}')" "

location=${1:-/}
[ -d "$location" ] || exit
case "$location" in
	"/home"* ) icon="🏠" ;;
	"/mnt"* ) icon="💾" ;;
	*) icon="🖥";;
esac
info2=$(df -h "$location" | awk ' /[0-9]/ {print $3}')


l=`expr ${#info1} \* 9`
l=`expr $l + 8`

printf "💟%s^c#FFFF00^^f-%d^^r0,22,%d,30^^f%d^^d^" $info1 $l $l $l

l=`expr ${#info2} \* 9`
l=`expr $l + 21`
printf " %s%s^c#008000^^f-%d^^r0,22,%d,30^^f%d^^d^\n" $icon $info2 $l $l $l
#printf " $tmpstr"

