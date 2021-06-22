#!/bin/sh

# Displays todays precipication chance (☔) and daily low (🥶) and high (🌞).
# Usually intended for the statusbar.

# If we have internet, get a weather report from wttr.in and store it locally.
# You could set up a shell alias to view the full file in a pager in the
# terminal if desired. This function will only be run once a day when needed.
weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weatherreport"
getforecast() { curl -sf "wttr.in/Qingdao" > "$weatherreport" || return 1 ;}

# Some very particular and terse stream manipulation. We get the maximum
# precipication chance and the daily high and low from the downloaded file and
# display them with coresponding emojis.
showweather() { printf "%s" "$(sed '16q;d' "$weatherreport" |
	grep -wo "[0-9]*%" | sort -rn | sed "s/^/☔/g;1q" | tr -d '\n')"
sed '13q;d' "$weatherreport" | grep -o "m\\([-+]\\)*[0-9]\\+" | sed 's/+//g' | sort -n -t 'm' -k 2n | sed -e 1b -e '$!d' | tr '\n|m' ' ' | awk '{print " 🥶" $1 "°","🌞" $2 "°"}' ;}

function toggle_weather() {
	PIDS=`ps -ef | grep "less -Srf $weatherreport" | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		for PID in $PIDS ; do
			kill $PID
		done
	else
		st -g 126x40+790+20 -e less -Srf "$weatherreport"
	fi
}
case $BUTTON in
	1) getforecast && showweather && pkill -RTMIN+13 dwmblocks ;;
	3) toggle_weather ;;
	4) st vi "$0" ;;
esac

# The test if our forcecast is updated to the day. If it isn't download a new
# weather report from wttr.in with the above function.
[ "$(stat -c %y "$weatherreport" 2>/dev/null | cut -d':' -f1)" = "$(date '+%Y-%m-%d %H')" ] || getforecast

if [[ ! -f "$weatherreport" ]] || [[ "$(cat $weatherreport | wc -c)" = 0 ]]; then
	getforecast
	exit 0
fi

info=$(showweather)

l=`expr ${#info}`
l=`expr $l \* 9`
l=`expr $l + 36`

printf "%s %s %s^c#00FFFF^^f-%d^^r0,22,%d,30^^f%d^^d^\n" $info $l $l $l
