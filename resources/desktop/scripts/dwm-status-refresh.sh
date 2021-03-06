#!/bin/bash

mplayer_state=0

while true
do

if [ -f ~/shared-folder/ArchFiles/background ]; then
    if [ $mplayer_state == 0 ]; then
        echo "pause" > /tmp/mplayer_cmd
        mplayer_state=1
    fi
else
    if [ $mplayer_state == 1 ]; then
        echo "pause" > /tmp/mplayer_cmd
        mplayer_state=0
    fi
fi

hddN="/dev/mapper/control" # 显示磁盘剩余容量的磁盘

# 计算CPU使用率(上一秒)
# CPU使用率计算公式：CPU_USAGE=(IDLE2-IDLE1) / (CPU_TIME2-CPU_TIME1) * 100
# CPU_TIME计算公式 ：CPU_TIME=user + system + nice + idle + iowait + irq + softirq
PRE_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
IDLE1=$(echo $PRE_CPU_INFO | awk '{print $4}')
CPU_TIME1=$(echo $PRE_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')

# 计算上传下载的速率(上一秒)
# 获取所有网卡的接收速率
PRE_RX=$(cat /proc/net/dev | sed 's/:/ /g' | awk '{print $2}' | grep -v [^0-9])
PRE_RX_SUM=0
for i in ${PRE_RX}
do
# 计算所有网卡的接收速率的总和
PRE_RX_SUM=$(expr ${PRE_RX_SUM} + ${i})
done
# 获取所有网卡的发送速率
PRE_TX=$(cat /proc/net/dev | sed 's/:/ /g' | awk '{print $10}' | grep -v [^0-9])
PRE_TX_SUM=0
for i in ${PRE_TX}
do
# 计算所有网卡的发送速率的总和
PRE_TX_SUM=$(expr ${PRE_TX_SUM} + ${i})
done

sleep 1
# 计算CPU使用率(下一秒)
NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
IDLE2=$(echo $NEXT_CPU_INFO | awk '{print $4}')
CPU_TIME2=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
# (IDLE2 - IDLE1)
SYSTEM_IDLE=`echo ${IDLE2} ${IDLE1} | awk '{print $1-$2}'`
# (CPU_TIME2 - CPU_TIME1)
TOTAL_TIME=`echo ${CPU_TIME2} ${CPU_TIME1} | awk '{print $1-$2}'`
# (IDLE2-IDLE1) / (CPU_TIME2-CPU_TIME1) * 100
CPU_USAGE=`echo ${SYSTEM_IDLE} ${TOTAL_TIME} | awk '{printf "%.2f", 100-$1/$2*100}'`

# 计算上传下载的速率(下一秒)
# 获取所有网卡的接收速率
NEXT_RX=$(cat /proc/net/dev | sed 's/:/ /g' | awk '{print $2}' | grep -v [^0-9])
NEXT_RX_SUM=0
for i in ${NEXT_RX}
do
# 计算所有网卡的接收速率的总和
NEXT_RX_SUM=$(expr ${NEXT_RX_SUM} + ${i})
done
# 获取所有网卡的发送速率
NEXT_TX=$(cat /proc/net/dev | sed 's/:/ /g' | awk '{print $10}' | grep -v [^0-9])
NEXT_TX_SUM=0
for i in ${NEXT_TX}
do
# 计算所有网卡的发送速率的总和
NEXT_TX_SUM=$(expr ${NEXT_TX_SUM} + ${i})
done

# 计算两次的差,这就是一秒内发送和接收的速率
RX=$((${NEXT_RX_SUM}-${PRE_RX_SUM}))
TX=$((${NEXT_TX_SUM}-${PRE_TX_SUM}))

# 换算单位
if [[ $RX -eq 0 ]];then
# 如果接收速率于0,则单位为0KB/s
RX=$(echo $RX | awk '{printf "%dKB/s",0}')
elif [[ $RX -lt 1024 ]];then
# 如果接收速率小于1024,则单位为1KB/s
RX=$(echo $RX | awk '{printf "%dKB/s",1}')
elif [[ $RX -gt 1048576 ]];then
# 否则如果接收速率大于 1048576,则改变单位为MB/s
RX=$(echo $RX | awk '{printf "%.2fMB/s",$1/1048576}')
else
# 否则如果接收速率大于1024但小于1048576,则单位为KB/s
RX=$(echo $RX | awk '{printf "%.2fKB/s",$1/1024}')
fi

# 换算单位
if [[ $TX -eq 0 ]];then
# 如果接收速率于0,则单位为0KB/s
TX=$(echo $RX | awk '{printf "%dKB/s",0}')
elif [[ $TX -lt 1024 ]];then
# 如果发送速率小于1024,则单位为1KB/s
TX=$(echo $RX | awk '{printf "%dKB/s",1}')
elif [[ $TX -gt 1048576 ]];then
# 否则如果发送速率大于 1048576,则改变单位为MB/s
TX=$(echo $TX | awk '{printf "%.2fMB/s",$1/1048576}')
else
# 否则如果发送速率大于1024但小于1048576,则单位为KB/s
TX=$(echo $TX | awk '{printf "%.2fKB/s",$1/1024}')
fi


LOCALTIME=$(date +'Time:%Y-%m-%d %H:%M')
IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1) # can get confused if you use vmware
BAT="$( acpi -b | awk '{ print $4 }' | tr -d ',' )"
HDDFREE=$(df -Ph / | awk '$3 ~ /[0-9]+/ {print $4}')
MEMFREE=$(free -h|awk '{print $7}'|awk 'NR==2')

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
    if [[ $memfree -gt 1024 ]];then
        memfree=$(echo $memfree | awk '{printf "Mem:%5.2fG",$1/1024}')
    else
        memfree=$(echo $memfree | awk '{printf "Mem:%5dM",$1}')
    fi
	echo -e "$memfree"
}

xsetroot -name " D:$RX U:$TX Cpu:$CPU_USAGE% $(print_mem) Disk:$HDDFREE Ip:$IP $LOCALTIME"

done
