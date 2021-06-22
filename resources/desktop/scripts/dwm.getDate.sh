#!/bin/sh

case $BUTTON in
	4) st vi "$0" ;;
esac

clock=$(date '+%I')

case "$clock" in
	"00") clock_icon="🕛" ;;
	"01") clock_icon="🕐" ;;
	"02") clock_icon="🕑" ;;
	"03") clock_icon="🕒" ;;
	"04") clock_icon="🕓" ;;
	"05") clock_icon="🕔" ;;
	"06") clock_icon="🕕" ;;
	"07") clock_icon="🕖" ;;
	"08") clock_icon="🕗" ;;
	"09") clock_icon="🕘" ;;
	"10") clock_icon="🕙" ;;
	"11") clock_icon="🕚" ;;
	"12") clock_icon="🕛" ;;
esac
LOCALTIME=$(date +"📆%m-%d(%a) ${clock_icon}%H:%M")

l=`expr ${#LOCALTIME}`
l=`expr $l \* 9`
case "$(date +'%a')" in
	"Mon") l=`expr $l + 18` ;;
	"Tue") l=`expr $l + 10` ;;
	"Wed") l=`expr $l + 17` ;;
	"Thu") l=`expr $l + 11` ;;
	"Fri") l=`expr $l + 1` ;;
	"Sat") l=`expr $l + 6` ;;
	"Sun") l=`expr $l + 11` ;;
esac

printf "%s %s^c#800080^^f-%d^^r0,22,%d,30^^f%d^^d^\n" ${LOCALTIME} $l $l $l
