#!/bin/bash
# Author: Auroot/BaSierl
# QQ： 2763833502
# Description： Arch Linux 安装脚本  V3.0
# URL Blog： https://basierl.github.io
# URL GitHub： https://github.com/BaSierL/arch_install.git
# URL Gitee ： https://gitee.com/auroot/arch_install.git

#====脚本颜色变量-------------#
r='\033[1;31m'	#---红
g='\033[1;32m'	#---绿
y='\033[1;33m'	#---黄
b='\033[1;36m'	#---蓝
w='\033[1;37m'	#---白
h='\033[0m'		#---后缀
#-----------------------------#
rw='\033[1;41m'    #--红白
wg='\033[1;42m'    #--白绿
ws='\033[1;43m'    #--白褐
wb='\033[1;44m'    #--白蓝
wq='\033[1;45m'    #--白紫
wa='\033[1;46m'    #--白青
wh='\033[1;46m'    #--白灰
bx='\033[1;4;36m'  #---蓝 下划线
#-----------------------------#
# 交互 蓝
JHB=$(echo -e "${b}-=>${h}")
# 交互 红
JHR=$(echo -e "${r}-=>${h}")
# 交互 绿
JHG=$(echo -e "${g}-=>${h}")
# 交互 黄
JHY=$(echo -e "${y}-=>${h}")
#-----------------------------
# 提示 蓝
PSB=$(echo -e "${b} ::==>${h}")
# 提示 红
PSR=$(echo -e "${r} ::==>${h}")
# 提示 绿
PSG=$(echo -e "${g} ::==>${h}")
# 提示 黄
PSY=$(echo -e "${y} ::==>${h}")
#-----------------------------
# 给予mirrorlist.sh执行权限，否则将我发导入源。
#--------检查当前目录有没有mirrorlist.sh文件，没有就下一个 
if [ ! -e mirrorlist.sh ]; then
    curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh  > mirrorlist.sh
    chmod +x mirrorlist.sh
fi 
null="/dev/null"
#========判断当前模式
#------因暂时还不知道怎么得知当前是否为Chroot模式，所以必须使用脚本分区后，才知道处于什么模式！
#------如果是以自行分区，也可以手动在 新系统根目录创建/mnt/diskName_root文件，文件上级目录必须为 /mnt
if [ -e /diskName_root ];then
    ChrootPattern=$(echo -e "${g}Chroot-ON${h}")
else
    ChrootPattern=$(echo -e "${r}Chroot-OFF${h}")
fi

#========变量
#------ArchLinux
clear;
ECHOA=$(echo -e "${w}    _             _       _     _                    ${h}") 
ECHOB=$(echo -e "${g}   / \   _ __ ___| |__   | |   (_)_ __  _   ___  _   ${h}")
ECHOC=$(echo -e "${b}  / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /  ${h}")
ECHOD=$(echo -e "${y} / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${h}")
ECHOE=$(echo -e "${r}/_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\  ${h}")
echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE" | lolcat 2> ${null} || echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE"

# 文件位置变量
tmps="$PWD/arch_tmp"
# mirrorlist.sh 脚本位置
MIRROR_SH="$PWD/mirrorlist.sh"
chmod +x $PWD/mirrorlist.sh 2&>${null}

# 位置
LIST_IN="$PWD/$0"
# 初始密码
PASS="123456"
#systemctl start dhcpcd &> ${null}

#========网络变量
#有线
ETHERNET=`ip link | grep 'enp[0-9]s[0-9]' |  grep -v 'grep' | awk '{print $2}' | cut -d":" -f1`  
#无线
WIFI=`ip link | grep 'wlp[0-9]s[0-9]' | grep -v 'grep' | awk '{print $2}' | cut -d":" -f1`   

#WIFI_IP=`ifconfig ${WIFI} &> $null || echo "--.--.--.--" && ifconfig ${WIFI} | grep ./a"inet " |  awk '{print $2}'`
#ETHERNET_IP=`ifconfig ${ETHERNET} &> $null || echo "--.--.--.--" && ifconfig ${ETHERNET} | grep "inet " |  awk '{print $2}'`

ETHERNET_IP=`ip route | grep "${ETHERNET}" &> ${null} && ip route list | grep "${ETHERNET}" | cut -d" " -f9 | sed -n '2,1p'`  
WIFI_IP=`ip route | grep ${WIFI} &> ${null} && ip route list | grep ${WIFI} |  cut -d" " -f9 | sed -n '2,1p'`

#========选项
Tips1=$(echo -e "${b}||====================================================================||${h}")
Tips2=$(echo -e "${b}|| Script Name:        Arch Linux system installation script.           ${h}") 
Tips3=$(echo -e "${b}|| Author:             Auroot                                           ${h}")
Tips4=$(echo -e "${b}|| GitHub:	       ${bx}https://gitee.com/auroot/Arch_install${h}        ${h}")  
Tips5=$(echo -e "${g}|| Pattern:            ${ChrootPattern}                                 ${h}")
Tips6=$(echo -e "${g}|| Ethernet:           ${ETHERNET_IP:-No_network..}                     ${h}")
Tips7=$(echo -e "${g}|| WIFI:	       ${WIFI_IP:-No_network.}                               ${h}")
Tips8=$(echo -e "${g}|| SSH:                ssh $USER@${ETHERNET_IP:-IP_Addess.}             ${h}")
Tips9=$(echo -e "${g}|| SSH:                ssh $USER@${WIFI_IP:-IP_Addess.}                 ${h}")
Tips0=$(echo -e "${g}||====================================================================||${h}")
echo -e "$Tips1\n$Tips2\n$Tips3\n$Tips4\n$Tips5\n$Tips6\n$Tips7\n$Tips8\n$Tips9\n$Tips0" | lolcat 2> ${null} || echo -e "$Tips1\n$Tips2\n$Tips3\n$Tips4\n$Tips5\n$Tips6\n$Tips7\n$Tips8\n$Tips9\n$Tips0"
echo;
echo -e "${PSB} ${g}Configure Mirrorlist   [1]${h}"
echo -e "${PSB} ${g}Configure Network      [2]${h}"
echo -e "${PSG} ${g}Configure SSH          [3]${h}"
echo -e "${PSY} ${g}Install System         [4]${h}"
echo -e "${PSG} ${g}Exit Script            [Q]${h}"
echo;
READS_A=$(echo -e "${PSG} ${y}What are the tasks[1,2,3..]${h} ${JHB} ")
read -p "${READS_A}" principal_variable

#
#========ArchLinux Mirrorlist 配置镜像源  1 

PACMANCONF_FILE="/etc/pacman.conf"
MIRRORLIST_FILE="/etc/pacman.d/mirrorlist"
if [[ ${principal_variable} = 1 ]]; then
    echo ;
    # 检查"/etc/pacman.d/mirrorlist"文件是否存在
    if [ -e ${MIRRORLIST_FILE}  ] ; then      
        # 如果存在
        sh ${MIRROR_SH} || sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh)" 
    else
        # 如果不存在
        touch ${MIRRORLIST_FILE} && sh ${MIRROR_SH} || sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh)" 
    fi
    bash ${0}
fi

#========检查网络  2
if [[ ${principal_variable} = 2 ]]; then
    echo;
    echo ":: Checking the currently available network."
    sleep 2
    echo -e ":: Ethernet: ${r}${ETHERNET}${h}" 2> $null
    echo -e ":: Wifi:   ${r}${WIFI}${h}" 2> $null 

    READS_B=$(echo -e "${PSG} ${y}Query Network: Ethernet[1] Wifi[2] Exit[3]? ${h}${JHB} ")
    read -p "${READS_B}" wlink
        case $wlink in
            1) 
                echo ":: One moment please............"
                ls /usr/bin/ifconfig &> $null && echo ":: Install net-tools" ||  echo "y" |  pacman -S ifconfig
                ip link set ${ETHERNET} up
                ifconfig ${ETHERNET} up
                systemctl restart dhcpcd  &&  ping -c 3 14.215.177.38 
                sleep 1
                bash ${0}    
            ;;
            2) 
                echo;
                wifi-menu &&  ping  -c 3 14.215.177.38
                sleep 1 
                bash ${0}
                #echo ":: The following WiFi is available: "
                #iwlist ${WIFI} scan | grep "ESSID:"
            ;;
            3) 
                bash ${0}
            ;;
        esac
fi
#
##========开启SSH 3
if [[ ${principal_variable} = 3 ]]; then
    clear
    echo
    echo -e "${y}:: Setting Username / password.${h}"
    echo ${USER}:${PASS} | chpasswd &> $null

    echo -e "${g} ||=================================||${h}"
    echo -e "${g} || $ ssh $USER@${ETHERNET_IP:-IP_Addess..}          ||${h}"
    echo -e "${g} || $ ssh $USER@${WIFI_IP:-IP_Addess..}          ||${h}"
    echo -e "${g} || Username --=>  $USER             ||${h}"
    echo -e "${g} || Password --=>  $PASS           ||${h}"
    echo -e "${g} ||=================================||${h}"

        systemctl start sshd.service
        netstat -antp | grep sshd

fi
##======== 安装ArchLinux    选项4 ==========================================
# 函数：设置root密码 用户  判断/etc/passwd文件中最后一个用户是否大于等于1000的普通用户，如果没有请先创建用户
    ConfigurePassworld(){
        PasswdFile="/etc/passwd"
        if [ -e /Archin/UserName ]; then   #  设定一个文件匹配，这个文件在不在都无所谓
            for ((Number=1;Number<=50;Number++))  # 设置变量Number 等于1 ；小于等于50 ； Number 1+1直到50
            do
            Query=$(tail -n ${Number} ${PasswdFile} | head -n 1 | cut -d":" -f3)
                for Contrast in {1000..1100}
                do
                    if [[ $Query == $Contrast ]]; then
                        CheckingUsers=$(cat ${PasswdFile} | grep "$Query" | cut -d":" -f1)
                        CheckingID=$(cat ${PasswdFile} | grep "$Query" | cut -d":" -f3)
                    fi
                done 
            done
            echo "$CheckingUsers" > /Archin/UserName  
            CheckingUsers=$(cat /Archin/UserName)
            echo -e "${PSG} ${g}A normal user already exists, The UserName:${h} ${b}${CheckingUsers}${h} ${g}ID: ${b}${CheckingID}${h}."
            sleep 2;
        else
            sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/useradd.sh)"
            CheckingUsers=$(cat /Archin/UserName)
            echo -e "${PSG} ${g}A normal user already exists, The UserName:${h} ${b}${CheckingUsers}${h}."
            sleep 2;
        fi
}

if [[ ${principal_variable} == 4 ]];then
#
    echo
    echo -e "     ${w}***${h} ${r}Install System Modular${h} ${w}***${h}  "
    echo "---------------------------------------------"
    echo -e "${PSY} ${g}   Disk partition.         ${h}${r}**${h}  ${w}[1]${h}"
    echo -e "${PSY} ${g}   Install System Files.   ${h}${r}**${h}  ${w}[2]${h}"
    echo -e "${PSG} ${g}   Installation Drive.     ${h}${b}*${h}   ${w}[21]${h}"    
    echo -e "${PSG} ${g}   Installation Desktop.   ${h}${b}*${h}   ${w}[22]${h}"  
    echo -e "${PSY} ${g}   Configurt System.       ${h}${r}**${h}  ${w}[23]${h}"
    echo -e "${PSY} ${g}   arch-chroot /mnt.       ${h}${r}**${h}  ${w}[0]${h}"
    echo "---------------------------------------------"
    echo;
    READS_C=$(echo -e "${PSG} ${y} What are the tasks[1,2,3..] Exit [Q] ${h}${JHB} ")
    read -p "${READS_C}" tasks
#
    if [[ ${tasks} == 0 ]];then
    cat $0 > /mnt/Arch_install.sh  && chmod +x /mnt/Arch_install.sh
    arch-chroot /mnt /bin/bash /Arch_install.sh
    fi
# list1==========磁盘分区==========11111111111
    if [[ ${tasks} == 1 ]];then
        clear;
            echo;   # 显示磁盘
            lsblk | grep -E "sda|sdb|sdc|sdd|sdg|nvme"
            echo;
            #---AAAA 20----------------磁盘分区-------------------A---#
           # 选择磁盘 #parted /dev/sdb mklabel gpt   转换格式 GPT
            READDISK_A=$(echo -e "${PSY} ${y} Select disk: ${g}/dev/sdX | sdX ${h}${JHB} ")
            read -p "${READDISK_A}"  DISKS_ID  #给用户输入接口
                DISK_NAMEL_A=$(echo "${DISKS_ID}" |  cut -d"/" -f3)   #设置输入”/dev/sda” 或 “sda” 都输出为 sda
                if echo $DISK_NAMEL_A |  grep -E "^[a-z]" &> ${null} ; then
                    cfdisk /dev/${DISK_NAMEL_A}  && echo "/dev/${DISK_NAMEL_A}" > /tmp/diskName_root
                else
                    clear;
                    echo;
                    echo;
                    echo -e "${r} ==>> Error code [20] Please input: /dev/sdX | sdX? !!! ${h}"
                    exit 20    # 分区时输入错误，退出码。
                fi
                clear;
                #-------------------分区步骤结束，进入下一个阶段 格式和与挂载分区----------------B------#
                #---BBBB 21----------------root [/]----------------B------#
                echo;
                lsblk | grep -E "sda|sdb|sdc|sdd|sdg|nvme"
                echo;
                READDISK_B=$(echo -e "${y}:: ==>> Choose your root[/] partition: ${g}/dev/sdX[0-9] | sdX[0-9] ${h}${JHB} ")
                read -p "${READDISK_B}"  DISK_LIST_ROOT   #给用户输入接口
                    DISK_NAMEL_B=$(echo "${DISK_LIST_ROOT}" |  cut -d"/" -f3)   #设置输入”/dev/sda” 或 “sda” 都输出为 sda
                    if echo ${DISK_NAMEL_B} | grep -E "^sd[a-z][0-9]$" &> ${null} ; then
                        mkfs.ext4 /dev/${DISK_NAMEL_B}
                        mount /dev/${DISK_NAMEL_B} /mnt
                        ls /sys/firmware/efi/efivars &> ${null} && mkdir -p /mnt/boot/efi || mkdir -p /mnt/boot
                        mkdir /mnt/Archin 2&> /dev/null 
                        cat /tmp/diskName_root > /mnt/diskName_root
                    else
                        clear;
                        echo;
                        echo -e "${r} ==>> Error code [21] Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${h}"
                        exit 21    # 分区时输入错误，退出码。
                    fi
                #---CCCC 22----------------EFI / boot----------------C------#
                echo;
                lsblk | grep -E "sda|sdb|sdc|sdd|sdg|nvme"
                echo;
                READDISK_C=$(echo -e "${y}:: ==>> Choose your EFI / BOOT partition: ${g}/dev/sdX[0-9] | sdX[0-9] ${h}${JHB} ")
                read -p "${READDISK_C}"  DISK_LIST_GRUB   #给用户输入接口
                    DISK_NAMEL_C=$(echo "${DISK_LIST_GRUB}" |  cut -d"/" -f3)   #设置输入”/dev/sda” 或 “sda” 都输出为 sda
                    if echo ${DISK_NAMEL_C} | grep -E "^sd[a-z][0-9]$" &> ${null} ; then
                        mkfs.vfat /dev/${DISK_NAMEL_C}
                        ls /sys/firmware/efi/efivars &> ${null} && mount /dev/${DISK_NAMEL_C} /mnt/boot/efi || mount /dev/${DISK_NAMEL_C} /mnt/boot
                    else
                        clear;
                        echo;
                        echo -e "${r} ==>> Error code [22] Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${h}"
                        exit 22    # 分区时输入错误，退出码。
                    fi
                #---DDDD 23-----------SWAP file 虚拟文件(类似与win里的虚拟文件) 对于swap分区我更推荐这个，后期灵活更变---------------#
                echo
                lsblk | grep -E "sda|sdb|sdc|sdd|sdg|nvme"
                echo;
                READDISK_D=$(echo -e "${y}:: ==>> Please select the size of swapfile: ${g}[example:512M-4G ~] ${h}${JHB} ")
                read -p "${READDISK_D}"  DISK_LIST_SWAP     #给用户输入接口
                    DISK_NAMEL_D=$(echo "${DISK_LIST_SWAP}" |  cut -d"/" -f3)   #设置输入”/dev/sda” 或 “sda” 都输出为 sda
                    if echo ${DISK_NAMEL_D} | grep -E "^[0-9]*[A-Z]$" &> ${null} ; then
                        echo -e ""
                        fallocate -l ${DISK_NAMEL_D} /mnt/swapfile
                        chmod 600 /mnt/swapfile
                        mkswap /mnt/swapfile
                        swapon /mnt/swapfile
                    else
                        clear;
                        echo;
                        echo -e "${r} ==>> Error code [23] Please input size: [example:512M-4G ~] !!! ${h}"
                        exit 23    # 分区时输入错误，退出码。
                    fi
            echo -e "${wg} ::==>> Partition complete. ${h}"
            bash ${0} 
        fi 
#
# list2========== 安装及配置系统文件 ==========222222222222222
    if [[ ${tasks} == 2 ]];then
            echo -e "${wg}Update the system clock.${h}"  #更新系统时间
            timedatectl set-ntp true
            sleep 4
            echo;
            echo -e "${PSG} ${g}Install the base packages.${h}"   #安装基本系统
            echo;
                pacstrap /mnt base base-devel linux  # 第一部分
                pacstrap /mnt linux-firmware linux-headers ntfs-3g networkmanager net-tools dhcpcd vim   # 第二部分 分开安装，避免可不必要的错误！
            echo;
	        sleep 3
            echo -e "${PSG}  ${g}Configure Fstab File.${h}" #配置Fstab文件
	            genfstab -U /mnt >> /mnt/etc/fstab && cat /tmp/diskName_root > /mnt/diskName_root
                echo;
            sleep 2
            clear;
            echo;
            echo;
            echo -e "${wg}#======================================================#${h}"
            echo -e "${wg}#::  System components installation completed.         #${h}"            
            echo -e "${wg}#::  Entering chroot mode.                             #${h}"
            echo -e "${wg}#::  Execute in 3 seconds.                             #${h}"
            echo -e "${wg}#::  Later operations are oriented to the new system.  #${h}"
            echo -e "${wg}#======================================================#${h}"
            sleep 3
            echo    # Chroot到新系统中完成基础配置，第一步配置
            rm -rf /mnt/etc/pacman.conf 2&>${null}
            rm -rf /mnt/etc/pacman.d/mirrorlist 2&>${null}
            cp -rf /etc/pacman.conf /mnt/etc/pacman.conf.bak 2&>${null}
            cp -rf /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.bak 2&>${null}
            mkdir /mnt/Archin 2&> /dev/null

            cat $0 > /mnt/Arch_install.sh  && chmod +x /mnt/Arch_install.sh
            arch-chroot /mnt /bin/bash /Arch_install.sh
            cp -rf /etc/pacman.conf.bak /mnt/etc/pacman.conf 2&>${null}
            cp -rf /etc/pacman.d/mirrorlist.bak /mnt/etc/pacman.d/mirrorlist 2&>${null}
    fi
# list21------------------------------------------------------------------------------------------------------#
#==========  Installation Drive. 驱动  ===========3333333333333
        if [[ ${tasks} == 21 ]];then
            #---------------------------------------------------------------------------#
            #  配置驱动
            #-------------------
            sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh)" 
            #安装声音软件包
            echo -e "${PSG} ${g}Installing Audio driver.${h}"
            pacman -Sy alsa-utils pulseaudio pulseaudio-bluetooth pulseaudio-alsa  
            echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
            echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa
            #触摸板驱动
            echo -e "${PSG} ${g}Installing input driver.${h}"
            pacman -Sy xf86-input-synaptics xf86-input-libinput create_ap  
            # 蓝牙驱动
            echo -e "${PSG} ${g}Installing Bluetooth driver.${h}"
            pacman -Sy bluez bluez-utils blueman bluedevil
            echo;
            READDRIVE_GPU=$(echo -e "${PSG} ${y}Please choose: Intel[1] AMD[2]${h} ${JHB} ")
            read -p "${READDRIVE_GPU}"  DRIVER_GPU_ID
                if  [[ `echo "${DRIVER_GPU_ID}" | grep -E "^1$"`  = "1" ]] ; then
                    pacman -Sy xf86-video-intel intel-ucode xf86-video-intel xf86-video-intel mesa-libgl libva-intel-driver libvdpau-va-gl
                elif [[ `echo "${DRIVER_GPU_ID}" | grep -E "^2$"`  = "2" ]] ; then
                    pacman -Sy xf86-video-ati amd-ucode
                fi
            lspci -k | grep -A 2 -E "(VGA|3D)"
            echo;
            READDRIVE_NVIDIA=$(echo -e "${PSG} ${y}Please choose: Nvidia[1] Exit[2]${h} ${JHB} ")
            read -p "${READDRIVE_NVIDIA}"  DRIVER_NVIDIA_ID
                if  [[ `echo "${DRIVER_GPU_ID}" | grep -E "^1$"`  = "1" ]] ; then
                    pacman -Sy nvidia nvidia-utils opencl-nvidia lib32-nvidia-utils lib32-opencl-nvidia mesa lib32-mesa-libgl  optimus-manager optimus-manager-qt 
                    systemctl enable optimus-manager.service
                    rm -f /etc/X11/xorg.conf 2&> ${null}
                    rm -f /etc/X11/xorg.conf.d/90-mhwd.conf 2&> ${null}

                    if [ -e "/usr/bin/gdm" ] ; then  # gdm管理器
                        pacman -Sy gdm-prime 
                        sed -i 's/#.*WaylandEnable=false/WaylandEnable=false/'  /etc/gdm/custom.conf
                    elif [ -e "/usr/bin/sddm" ] ; then
                        sed -i 's/DisplayCommand/# DisplayCommand/' /etc/sddm.conf
                        sed -i 's/DisplayStopCommand/# DisplayStopCommand/' /etc/sddm.conf
                    fi
                elif [[ `echo "${DRIVER_GPU_ID}" | grep -E "^2$"`  == "2" ]] ; then
                    bash $0
                fi      
        fi
#-----------------------------------------------------------------------------------------------------#
# list22==========  Installation Desktop. 桌面环境 ==========444444444444444444444444444
        if [[ ${tasks} == 22 ]];then
            ConfigurePassworld    # 引用函数：设置密码
            sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh)" 
            echo
            echo -e "     ${w}***${h} ${b}Install Desktop${h} ${w}***${h}  "
            echo "---------------------------------"
            echo -e "${PSB} ${g}   KDE plasma.     ${h}${w}[1]${h}  --sddm"
            echo -e "${PSB} ${g}   Gnome.          ${h}${w}[2]${h}  --gdm"
            echo -e "${PSB} ${g}   Deepin.         ${h}${w}[3]${h}  --lightdm"    
            echo -e "${PSB} ${g}   Xfce4.          ${h}${w}[4]${h}  --lightdm"  
            echo -e "${PSB} ${g}   i3wm.           ${h}${w}[5]${h}  --sddm"
            echo -e "${PSB} ${g}   lxde.           ${h}${w}[6]${h}  --lxdm"
            echo -e "${PSB} ${g}   Cinnamon.       ${h}${w}[7]${h}  --lightdm"
            echo "---------------------------------"                           
            echo;
# 定义 其他基本包函数
    Programs_Name(){
        sudo pacman -Sy  ttf-dejavu ttf-liberation thunar neofetch  unrar unzip p7zip \
            zsh vim git ttf-wps-fonts google-chrome mtpfs mtpaint libmtp kchmviewer file-roller flameshot 
}
# 定义 桌面环境配置函数
        Desktop_Env_Config(){
            systemctl enable ${DESKTOP_MANAGER}
            sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/setting_xinitrc.sh)"
            echo "exec ${DESKTOP_XINIT}" >> /etc/X11/xinit/xinitrc
            CheckingUser=$(cat /Archin/UserName)
            cp -rf /etc/X11/xinit/xinitrc  /home/${CheckingUser}/.xinitrc
            echo -e "${PSG} ${w}${DESKTOP_ENVS} ${g}Desktop environment configuration completed.${h}" 
            sleep 2;   # 以下是配置 ohmyzsh
            #sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/install_zsh.sh)"
}
# 函数 桌面管理选择
        Desktop_Manager(){
            if [ DESKTOP_MANAGER_ID = 1 ]; then
                DESKTOP_MANAGER_NAME="sddm" 
            elif [ DESKTOP_MANAGER_ID = 1 ]; then
                DESKTOP_MANAGER_NAME="gdm"
            elif [ DESKTOP_MANAGER_ID = 1 ]; then
                DESKTOP_MANAGER_NAME="lightdm"
            elif [ DESKTOP_MANAGER_ID = 1 ]; then
                DESKTOP_MANAGER_NAME="lxdm"
            else
                DESKTOP_MANAGER_NAME="sddm"
            fi
}
            #---------------------------------------------------------------------------#
            # 开始安装桌面环境
            DESKTOP_ID="0"   # 初始化变量
            #-----------------------------
            CHOICE_ITEM_DESKTOP=$(echo -e "${PSG} ${y} Please select desktop${h} ${JHB} ")
            read -p "${CHOICE_ITEM_DESKTOP}"  DESKTOP_ID
                if  [[ `echo "${DESKTOP_ID}" | grep -E "^1$"`  = "1" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1;
                    pacman -Sy xorg xorg-server xorg-xinit mesa sddm sddm-kcm plasma plasma-desktop konsole \
                    dolphin kate plasma-pa kio-extras powerdevil kcm-fcitx
                    Programs_Name
                    DESKTOP_ENVS="plasma"       # 桌面名
                    DESKTOP_MANAGER="sddm"      # 桌面管理器
                    DESKTOP_XINIT="startkde"    # 桌面环境启动
                    Desktop_Env_Config          # 环境配置
                    #-------------------------------------------------------------------------------# 
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^2$"`  = "2" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1;
                    pacman -Sy xorg xorg-server xorg-xinit mesa gnome gnome-extra gdm gnome-tweaks gnome-shell \
                    gnome-shell-extensions  gvfs-mtp gvfs gvfs-smb gnome-keyring 
                    Programs_Name
                    DESKTOP_ENVS="gnome"            # 桌面名
                    DESKTOP_MANAGER="gdm"           # 桌面管理器
                    DESKTOP_XINIT="gnome=session"   # 桌面环境启动
                    Desktop_Env_Config              # 环境配置
                    #-------------------------------------------------------------------------------#
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^3$"`  = "3" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1;
                    pacman -Sy xorg xorg-server xorg-xinit mesa deepin deepin-extra lightdm lightdm-deepin-greeter                             
                    Programs_Name
                    sed -i 's/greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/'  /etc/lightdm/lightdm.conf
                    DESKTOP_ENVS="deepin"      # 桌面名
                    DESKTOP_MANAGER="lightdm"  # 桌面管理器
                    DESKTOP_XINIT="startdde"   # 桌面环境启动
                    Desktop_Env_Config         # 环境配置
                    #-------------------------------------------------------------------------------#
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^4$"`  = "4" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1;
                    pacman -Sy xorg xorg-server xorg-xinit mesa xfce4 xfce4-goodies light-locker xfce4-power-manager \
                    libcanberra lightdm lightdm-gtk-greeter 
                    Programs_Name
                    DESKTOP_ENVS="xfce"         # 桌面名
                    DESKTOP_MANAGER="lightdm"   # 桌面管理器
                    DESKTOP_XINIT="startxfce4"  # 桌面环境启动
                    Desktop_Env_Config          # 环境配置
                    #-------------------------------------------------------------------------------#
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^5$"`  = "5" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1; 
                    Programs_Name
                    pacman -Sy xorg xorg-server xorg-xinit mesa i3 i3-gaps i3lock i3status compton dmenu feh \
                    picom nautilus polybar gvfs-mtp sddm  xfce4-terminal termite
                    sed -i 's/i3-sensible-terminal/--no-startup-id termite/g' /home/${CheckingUser}/.config/i3/config  # 更改终端
                    DESKTOP_ENVS="i3wm"     # 桌面名
                    DESKTOP_MANAGER="sddm"  # 桌面管理器
                    DESKTOP_XINIT="i3"      # 桌面环境启动
                    Desktop_Env_Config      # 环境配置
                    #-------------------------------------------------------------------------------#  
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^6$"`  = "6" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1; 
                    Programs_Name
                    pacman -Sy xorg xorg-server xorg-xinit lxdm lxde mesa
                    DESKTOP_ENVS="lxde"     # 桌面名
                    DESKTOP_MANAGER="lxdm"  # 桌面管理器
                    DESKTOP_XINIT="startlxde"      # 桌面环境启动
                    Desktop_Env_Config      # 环境配置
                #-------------------------------------------------------------------------------#  
                elif  [[ `echo "${DESKTOP_ID}" | grep -E "^7$"`  = "7" ]] ; then
                    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
                    sleep 1; 
                    Programs_Name   
                    pacman -Sy xorg xorg-server xorg-xinit mesa cinnamon blueberry gnome-screenshot lightdm lightdm-gtk-greeter \
                    gvfs gvfs-mtp gvfs-afc exfat-utils faenza-icon-theme accountsservice gnoem-terminal
                    DESKTOP_ENVS="Cinnamon"     # 桌面名
                    DESKTOP_MANAGER="lightdm"  # 桌面管理器
                    DESKTOP_XINIT="cinnamon-session"      # 桌面环境启动
                    Desktop_Env_Config      # 环境配置
                fi
            READDRIVE_CommonDrive=$(echo -e "${PSG} ${y}Whether to install Common Drivers: Install[y] On[*]${h} ${JHB} ")
            read -p "${READDRIVE_CommonDrive}" CommonDrive
            echo;
            case ${CommonDrive} in
            y | Y | yes | YES)
                #安装声音软件包
                echo -e "${PSG} ${g}Installing Audio driver.${h}"
                pacman -Sy alsa-utils pulseaudio pulseaudio-bluetooth pulseaudio-alsa  
                echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
                echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa
                #触摸板驱动
                echo -e "${PSG} ${g}Installing input driver.${h}"
                pacman -Sy xf86-input-synaptics xf86-input-libinput create_ap  
                # 蓝牙驱动
                echo -e "${PSG} ${g}Installing Bluetooth driver.${h}"
                pacman -Sy bluez bluez-utils blueman bluedevil
            ;;
            * )
                exit 0
            ;;
            esac
        fi
#------------------------------------------------------------------------------------------------------#
# list5==========  进入系统后的配置 ===========55555555555555555555

    if [[ ${tasks} == 23 ]];then
            sh -c "$(curl -fsSL https://gitee.com/auroot/Arch_install/raw/master/mirrorlist.sh)" 
            echo;
            echo -e "${wg}Installing grub tools.${h}"  #安装grub工具   UEFI与Boot传统模式判断方式：ls /sys/firmware/efi/efivars  Boot引导判断磁盘地址：cat /mnt/diskName_root
                if ls /sys/firmware/efi/efivars &> /dev/null ; then    # 判断文件是否存在，存在为真，执行EFI，否则执行 Boot
                    #-------------------------------------------------------------------------------#   
                    echo;
                    echo -e "${PSG} ${w}Your startup mode has been detected as ${g}UEFI${h}."
                    echo;  
                    pacman -Sy grub efibootmgr os-prober
                    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux   # 安装Grub引导
                    grub-mkconfig -o /boot/grub/grub.cfg                            # 生成配置文件
                    echo;
                    if efibootmgr | grep "Archlinux" &> ${null} ; then      #检验 并提示用户
                        echo -e "${g} Grub installed successfully -=> [Archlinux] ${h}"
                        echo -e "${g}     `efibootmgr | grep "Archlinux"`  ${h}" 
                        echo;   
                    else
                        echo -e "${r} Grub installed failed ${h}"       # 如果安装失败，提示用户，并列出引导列表
                        echo -e "${g}     `efibootmgr`  ${h}"   
                        echo; 
                    fi
                else   #-------------------------------------------------------------------------------#
                    echo;
                    echo -e "${PSG} ${w}Your startup mode has been detected as ${g}Boot Legacy${h}."
                    echo;
                    pacman -Sy grub os-prober
                    Disk_Boot=$(cat /diskName_root)
                    grub-install --target=i386-pc ${Disk_Boot}   # 安装Grub引导
                    grub-mkconfig -o /boot/grub/grub.cfg                        # 生成配置文件
                    echo;
                    if echo $? &> ${null} ; then      #检验 并提示用户
                            echo -e "${g} Grub installed successfully -=> [Archlinux] ${h}"
                            echo;   
                    else
                            echo -e "${r} Grub installed failed ${h}"       # 如果安装失败，提示用户，并列出引导列表
                            echo; 
                    fi
                        #-------------------------------------------------------------------------------#
                fi
                echo -e "${PSG} ${w}Configure enable Network.${h}"   
                systemctl enable NetworkManager         #配置网络 加入开机启动 NetworkManager
                systemctl enable dhcpcd         # 加入开机启动 dhcpcd
                #---------------------------------------------------------------------------#
                # 基础配置  时区 主机名 本地化 语言 安装语言包
                #-----------------------------
                    echo -e "${PSG} ${w}Time zone changed to 'Shanghai'. ${h}"
                ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc # 将时区更改为"上海" / 生成 /etc/adjtime
                    echo -e "${PSG} ${w}Localization language settings. ${h}"
                echo "Archlinux" > /etc/hostname        # 设置主机名
                sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen      # 本地化设置 "英文"
                sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen      # 本地化设置 "中文"
                locale-gen       # 生成 locale
                echo -e "${PSG} ${w}Configure local language defaults 'en_US.UTF-8'. ${h}"
                echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 系统语言 "英文" 默认为英文   
                # echo "LANG=zh_CN.UTF-8" > /etc/locale.conf     # 系统语言 "中文"
                echo -e "${PSG} ${w}Install Fonts. ${h}"
                pacman -Sy wqy-microhei wqy-zenhei ttf-dejavu ttf-ubuntu-font-family noto-fonts # 安装语言包
                #---------------------------------------------------------------------------#
                ConfigurePassworld    # 引用函数：设置密码
        echo -e "${ws}#======================================================#${h}" #本区块退出后的提示
        echo -e "${ws}#::                 Exit in 5/s                        #${h}"
        echo -e "${ws}#::  When finished, restart the computer.              #${h}"
        echo -e "${ws}#::  If there is a problem during the installation     #${h}"
        echo -e "${ws}#::  please contact me. QQ:2763833502                  #${h}"
        echo -e "${ws}#======================================================#${h}"
        sleep 3
    fi

fi  # 安装ArchLinux    选项4
##========退出 EXIT

case $principal_variable in
    q | Q | quit | QUIT)
    clear;
    echo;
    echo -e "${wg}#----------------------------------#${h}"
    echo -e "${wg}#------------Script Exit-----------#${h}"
    echo -e "${wg}#----------------------------------#${h}"
    exit 0
esac
#---------------------------------------------------------------------------------#