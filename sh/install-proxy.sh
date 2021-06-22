#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi
export INY_USERNAME=shibinglanya
if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

#proxy=$(cat .xinitrc | grep -oP "(?<=export http_proxy\=\")([0-9]+\.){3}[0-9]+:[0-9]+")
proxy="192.168.132.253:1080"
while true
do
    read -t 10 -p "Whether to set up a proxy server? (Default:$proxy):" input
    if [ ! -n "$input" ]; then
        input=$proxy
    fi

    if [ "$input" = "no" ]; then
        exit 0
    else
        http_proxy_tmp="$http_proxy"
        https_proxy_tmp="$https_proxy"
        all_proxy_tmp="$all_proxy"
        export http_proxy="$input"
        export https_proxy="$input"
        export all_proxy="$input"

        proxy=$input
        if echo $input | grep -E '^([0-9]+\.){3}[0-9]+:[0-9]+$' 1>&2>/dev/null; then
            if curl www.google.com --connect-timeout 10  1>&2>/dev/null; then
                break
            fi
        fi
        export http_proxy="$http_proxy_tmp"
        export http_proxy="$https_proxy_tmp"
        export all_proxy="$all_proxy_tmp"
    fi
done

#设置代理
su - $INY_USERNAME -c 'sed -i s/"\(export \w\+_proxy=\"\)[^\"]*\""/"\1'$proxy'\""/g ~/.xinitrc'
su - $INY_USERNAME -c "cd iny; git config --global http.https://gitee.com.proxy \"\""
su - $INY_USERNAME -c "cd iny; git config --global http.proxy http://$proxy"
su - $INY_USERNAME -c "cd iny; git config --global https.proxy https://$proxy"
