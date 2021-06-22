#!/bin/sh

function toggle_bpytop() {
	PIDS=`ps -ef | grep "bpytop -b net" | grep -v grep | awk '{print $2}'`
	if [ "$PIDS" != "" ]; then
		for PID in $PIDS ; do
			kill $PID
		done
	else
		st -g 100x12+1152+20 -e bpytop -b net
	fi
}

case $BUTTON in
	1) toggle_bpytop ;;
	4) st vi "$0" ;;
esac

update() {
    sum=0
    for arg; do
        read -r i < "$arg"
        sum=$(( sum + i ))
    done
    cache=${XDG_CACHE_HOME:-$HOME/.cache}/${1##*/}
    [ -f "$cache" ] && read -r old < "$cache" || old=0
    printf %d\\n "$sum" > "$cache"
    printf %d\\n $(( sum - old ))
}

RX=$(update /sys/class/net/[ew]*/statistics/rx_bytes)
TX=$(update /sys/class/net/[ew]*/statistics/tx_bytes)

M1_size=0
# 换算单位
if [[ $RX -eq 0 ]];then
# 如果接收速率于0,则单位为0KB/s
RX=$(echo $RX | awk '{printf "%d.0KB/s",0}')
elif [[ $RX -lt 1024 ]];then
# 如果接收速率小于1024,则单位为1KB/s
RX=$(echo $RX | awk '{printf "%d.0KB/s",1}')
elif [[ $RX -gt 1048576 ]];then
# 否则如果接收速率大于 1048576,则改变单位为MB/s
RX=$(echo $RX | awk '{printf "%.2fMB/s",$1/1048576}')
M1_size=5
else
# 否则如果接收速率大于1024但小于1048576,则单位为KB/s
RX=$(echo $RX | awk '{printf "%.2fKB/s",$1/1024}')
fi

M2_size=0
# 换算单位
if [[ $TX -eq 0 ]];then
# 如果接收速率于0,则单位为0KB/s
TX=$(echo $RX | awk '{printf "%d.0KB/s",0}')
elif [[ $TX -lt 1024 ]];then
# 如果发送速率小于1024,则单位为1KB/s
TX=$(echo $RX | awk '{printf "%d.0KB/s",1}')
elif [[ $TX -gt 1048576 ]];then
# 否则如果发送速率大于 1048576,则改变单位为MB/s
TX=$(echo $TX | awk '{printf "%.2fMB/s",$1/1048576}')
M2_size=5
else
# 否则如果发送速率大于1024但小于1048576,则单位为KB/s
TX=$(echo $TX | awk '{printf "%.2fKB/s",$1/1024}')
fi

l=`expr ${#TX} + ${#RX}`
l=`expr $l \* 9`
l=`expr $l + 38`
l=`expr $l + $M1_size`
l=`expr $l + $M2_size`
printf "⏫$TX ⏬$RX^c#FF0000^^f-%d^^r0,22,%d,30^^f%d^^d^\n" $l $l $l
