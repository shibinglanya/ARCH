#!/bin/sh

# Module showing CPU load as a changing bars.
# Just like in polybar.
# Each bar represents amount of load on one core since
# last run.

# cache1 in tmpfs to improve speed and reduce SSD load
#cache1=/tmp/cpubarscache1
cache2=/tmp/cpubarscache2

function toggle_bpytop_cpu() {
	PIDS=`ps -ef | grep "bpytop -b cpu" | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		for PID in $PIDS ; do
			kill $PID
		done
	else
		st -g 100x12+1152+20 -e bpytop -b cpu
	fi
}

function toggle_bpytop_proc() {
	PIDS=`ps -ef | grep "bpytop -b proc" | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		for PID in $PIDS ; do
			kill $PID
		done
	else
		st -g 100x40+1152+30 -e bpytop -b proc
	fi
}

case $BUTTON in
	1) toggle_bpytop_cpu ;;
	3) toggle_bpytop_proc ;;
	4) st vi "$0" ;;
esac

NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
IDLE2=$(echo $NEXT_CPU_INFO | awk '{print $4}')
CPU_TIME2=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
[ ! -f $cache2 ] && echo "$NEXT_CPU_INFO" > "$cache2"
PRE_CPU_INFO=$(cat "$cache2")
IDLE1=$(echo $PRE_CPU_INFO | awk '{print $4}')
CPU_TIME1=$(echo $PRE_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')

# 计算CPU使用率(下一秒)
SYSTEM_IDLE=`echo ${IDLE2} ${IDLE1} | awk '{print $1-$2}'`
# (CPU_TIME2 - CPU_TIME1)
TOTAL_TIME=`echo ${CPU_TIME2} ${CPU_TIME1} | awk '{print $1-$2}'`
# (IDLE2-IDLE1) / (CPU_TIME2-CPU_TIME1) * 100
CPU_USAGE=`echo ${SYSTEM_IDLE} ${TOTAL_TIME} | awk '{printf "%.2f", 100-$1/$2*100}'`

l=`expr ${#CPU_USAGE}`
l=`expr $l \* 9`
l=`expr $l + 30`

printf "🚀$CPU_USAGE%%^c#FFA500^^f-%d^^r0,22,%d,30^^f%d^^d^\n" $l $l $l

## id total idle
#stats=$(awk '/cpu[0-9]+/ {printf "%d %d %d\n", substr($1,4), ($2 + $3 + $4 + $5), $5 }' /proc/stat)
#[ ! -f $cache1 ] && echo "$stats" > "$cache1"
#old=$(cat "$cache1")
#
#echo "$stats" | while read -r row; do
#	id=${row%% *}
#	rest=${row#* }
#	total=${rest%% *}
#	idle=${rest##* }
#
#	case "$(echo "$old" | awk '{if ($1 == id)
#		printf "%d\n", (1 - (idle - $3)  / (total - $2))*100 /12.5}' \
#		id="$id" total="$total" idle="$idle")" in
#
#		"0") printf "^c#7CFC00^▁^d^";;
#		"1") printf "^c#7CFC00^▂^d^";;
#		"2") printf "^c#7CFC00^▃^d^";;
#		"3") printf "^c#7CFC00^▄^d^";;
#		"4") printf "^c#7CFC00^▅^d^";;
#		"5") printf "^c#7CFC00^▆^d^";;
#		"6") printf "^c#FF0000^▇^d^";;
#		"7") printf "^c#FF0000^█^d^";;
#		"8") printf "^c#FF0000^█^d^";;
#	esac
#done;
#
#echo "$stats" > "$cache1"
echo "$NEXT_CPU_INFO" > "$cache2"

