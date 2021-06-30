#!/bin/bash
set -o errexit

WORKDIR=$(cd $(dirname $0); pwd)
USER_NAME=$(pwd | grep -oP "(?<=/home/)[^/]+")
if [ ! -n "$USER_NAME" ]; then
	USER_NAME="root"
fi

USER_PASSWORD=

function MainMenu() {
    print_title "https://wiki.archlinux.org/index.php/Arch_Install_Scripts"
    print_info "The Arch Install Scripts are a set of Bash scripts that simplify Arch installation."
    pause
    checklist=( 0 1 1 1 1 1 1 1 1 1 1 1 1 )
    while true; do
	print_title "ARCHLINUX ULTIMATE INSTALL - https://github.com/tinyRatP/archlinux_install"
	echo -e " ${BBlue}${WORKDIR}${Reset}"
	echo ""
	echo "  1) $(mainmenu_item "${checklist[1]}"	"config")"
	echo "  2) $(mainmenu_item "${checklist[2]}"	"fonts")"
	echo "  3) $(mainmenu_item "${checklist[3]}"	"fish")"
	echo "  4) $(mainmenu_item "${checklist[4]}"	"desktop")"
	echo "  5) $(mainmenu_item "${checklist[5]}"	"background")"
	echo "  6) $(mainmenu_item "${checklist[6]}"	"fcitx")"
	echo "  7) $(mainmenu_item "${checklist[7]}"	"fzf")"
	echo "  8) $(mainmenu_item "${checklist[8]}"	"neovim")"
	echo "  9) $(mainmenu_item "${checklist[9]}"	"shared_folder")"
	echo " 10) $(mainmenu_item "${checklist[10]}"	"git-delta")"
	echo " 11) $(mainmenu_item "${checklist[11]}"	"alacritty")"
	echo " 12) $(mainmenu_item "${checklist[12]}"	"tmux")"
	echo ""
	echo "  u) $(echo -e "user: ${BBlue}[ $USER_NAME/$USER_PASSWORD ]${Reset}")"
	echo "  i) install"
	echo "  q) quit"
	echo ""

	read_input_options
	for OPT in ${OPTIONS[@]}; do
	    case ${OPT} in
		1) checklist[1]=1;;
		2) checklist[2]=1;;
		3) checklist[3]=1;;
		4) checklist[4]=1;;
		5) checklist[5]=1;;
		6) checklist[6]=1;;
		7) checklist[7]=1;;
		8) checklist[8]=1;;
		9) checklist[9]=1;;
		10) checklist[10]=1;;
		11) checklist[11]=1;;
		12) checklist[12]=1;;
		"u") set_login_user;;
		"i") install;;
		"q") exit 0;;
		*) invalid_option;;
	    esac
	done
    done
}

function set_login_user {
    read -p "Input login user name[ex: ${USER}]: " user_name
    if [[ -z ${user_name} ]]; then 
	return 0
    fi
    if ! id -u $user_name >/dev/null 2>&1; then
	while true; do
	    read -s -p "Password for $user_name: " password1
	    echo
	    read -s -p "Confirm the password: " password2
	    echo
	    if [[ ${password1} == ${password2} ]]; then
		USER_PASSWORD=$password1
		break
	    fi
	    echo "Please try again"
	done 
    fi
    USER_NAME=$user_name
}

function configure_login_user() {
    if ! id -u $USER_NAME >/dev/null 2>&1; then
	useradd -m -G wheel $USER_NAME && echo "$USER_NAME:$USER_PASSWORD" | chpasswd
    fi
}

function configure_config {
    cp -r $WORKDIR/resources/config/inputrc /etc/.

    installer sudo

    cp $WORKDIR/resources/config/sudoers /etc/.
    cp $WORKDIR/resources/config/locale.conf /etc/.
    su - $USER_NAME -c "cp -rf $WORKDIR/resources/config/.ssh ."
}


function configure_fonts {
    #nerd-fonts-source-code-pro字体需要。
    installer xorg-mkfontscale

    installer noto-fonts      
    installer noto-fonts-cjk  
    installer noto-fonts-emoji
    installer adobe-source-han-sans-cn-fonts 
    installer adobe-source-han-serif-cn-fonts

    if ! pacman -Ql ttf-twemoji-color >/dev/null 2>&1 ; then
	su - $USER_NAME -c "cd $WORKDIR/resources/fonts/ttf-twemoji-color; yes ' ' | makepkg -si"
    fi

    #nerd-fonts-source-code-pro字体需要。
    installer xorg-mkfontscale
    if ! pacman -Ql nerd-fonts-source-code-pro >/dev/null 2>&1 ; then
	#coc-explorer需要的字体。
	su - $USER_NAME -c "cd $WORKDIR/resources/fonts/nerd-fonts-source-code-pro; yes ' ' | makepkg -si"
    fi

    cp -rf $WORKDIR/resources/fonts/windows /usr/share/fonts/.
    #解决airline三角箭头有缝隙问题。
    cp -f $WORKDIR/resources/fonts/Sauce\ Code\ Pro\ Nerd\ Font\ Complete\ Mono.ttf /usr/share/fonts/TTF/.
    installer fontconfig
    fc-cache -f
}

function configure_fish {
    installer fish
    chsh $USER_NAME -s /usr/bin/fish >/dev/null 2>&1

    su - $USER_NAME -c "cp -f $WORKDIR/resources/fish/fish_variables .config/fish/."
    su - $USER_NAME -c "cp -f $WORKDIR/resources/fish/config.fish .config/fish/."
    su - $USER_NAME -c "cp -rf $WORKDIR/resources/fish/functions .config/fish/."
}


function configure_desktop {
    installer fish
    chsh $USER_NAME -s /usr/bin/fish >/dev/null 2>&1
    installer numlockx     

    installer alsa-utils   
    installer pulseaudio   
    installer pulsemixer   
		installer pulseaudio-alsa
		installer pavucontrol
		installer paprefs

    installer xorg-server  
    installer xorg-xinit   
    installer xorg-xrandr  
    installer xorg-xsetroot

    #nerd-fonts-source-code-pro字体需要。
    installer xorg-mkfontscale
    #

    installer lightdm		      		
    installer lightdm-gtk-greeter	  
    installer lightdm-gtk-greeter-settings

    su - $USER_NAME -c "cd $WORKDIR/resources/desktop/dwm; sudo make clean install"
    su - $USER_NAME -c "cd $WORKDIR/resources/desktop/dwmblocks; sudo make clean install"
    su - $USER_NAME -c "cd $WORKDIR/resources/desktop/dmenu; sudo make clean install"
    su - $USER_NAME -c "cd $WORKDIR/resources/desktop/st; sudo make clean install"
    su - $USER_NAME -c "cp -rf $WORKDIR/resources/desktop/scripts .config/."
    if ! pacman -Ql xf86-video-vmware >/dev/null 2>&1; then
	su - $USER_NAME -c "cp -f iny/resources/desktop/.xinitrc ."
    else
	su - $USER_NAME -c "cp -f iny/resources/desktop/.xinitrc_vmware .xinitrc"
    fi
    su - $USER_NAME -c "cp -f $WORKDIR/resources/desktop/.Xmodmap ."
    su - $USER_NAME -c "cp -rf $WORKDIR/resources/desktop/alsa-config .config/."

    if [ -f /home/$USER_NAME/.config/fish/config.fish ]; then
	if ! grep /home/$USER_NAME/.config/fish/config.fish -e "startx"; then
	    su - $USER_NAME -c "cat $WORKDIR/resources/desktop/config.fish >> .config/fish/config.fish"
	fi
    else
	su - $USER_NAME -c "cp $WORKDIR/resources/desktop/config.fish .config/fish/."
    fi

    if [ ! -d /etc/systemd/system/getty@tty1.service.d ]; then
	mkdir /etc/systemd/system/getty@tty1.service.d
	touch /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I \$TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf
	#su - $USER_NAME -c "cp $WORKDIR/resources/desktop/config.fish .config/fish/."
    fi

	installer bpytop		      		
	su - $USER_NAME -c "cd $WORKDIR/resources/desktop/rainbarf-git; yes 'y' | makepkg -si"
#修复使用emoji，dwm崩溃的问题。
	su - $USER_NAME -c "cd $WORKDIR/resources/libxft-bgra; yes 'y' | makepkg -si"


  #在DWM中嵌入KDE plasma，启动相关直接写入在dwm.c里。
  if ! which startplasma-x11 1>/dev/null 2>&1; then
    installer kde-applications
    installer plasma
    installer xorg-server-xephyr
  fi

  #KDE常用软件
  installer latte-dock
  #split -a 2 -d -b 1M app.log.10 child

  if [ ! -d /home/$USER_NAME/Downloads ]; then
    su - $USER_NAME -c "mkdir Downloads"
  fi

  #网易云
  if [ ! -d /home/$USER_NAME/Downloads/netease-cloud-music ]; then
    su - $USER_NAME -c "git clone https://gitee.com/xeger/netease-cloud-music.git ~/Downloads/netease-cloud-music --depth 1"
    /home/$USER_NAME/Downloads/netease-cloud-music/install.sh
  fi

  installer cmake
  installer qt5-websockets
  installer python-docopt
  installer python-numpy
  installer python-pyaudio
  installer python-cffi
  installer python-websockets
  if [ ! -d /home/$USER_NAME/Downloads/panon ]; then
    su - $USER_NAME -c "cd ~/Downloads; tar -zxvf $WORKDIR/resources/panon/panon.tar.gz"
    su - $USER_NAME -c "cd ~/Downloads/panon;  mkdir build;cd build;cmake ../translations;make install DESTDIR=../plasmoid/contents/locale;cd ..; kpackagetool5 -t Plasma/Applet --install plasmoid;kpackagetool5 -t Plasma/Applet --upgrade plasmoid"
    su - $USER_NAME -c "cd $WORKDIR/resources/panon; cp -rf panon ~/.local/share/plasma/plasmoids/."
    su - $USER_NAME -c "cd $WORKDIR/resources/kde; cp -rf * ~/.config/."
  fi
  
}

function configure_background {
    installer picom
    su - $USER_NAME -c "cp -f $WORKDIR/resources/background/picom.conf .config/."

    installer mplayer
    su - $USER_NAME -c "cd $WORKDIR/resources/background/xwinwrap; make; sudo make install; make clean"
    if [ ! -d /home/$USER_NAME/.config/wallpapers ]; then
	su - $USER_NAME -c 'mkdir .config/wallpapers'
	su - $USER_NAME -c "cd $WORKDIR/resources/background/wallpapers; cp background.mp4 ~/.config/wallpapers/background.mp4"
    fi

    if [ -f /home/$USER_NAME/.config/scripts/autostart.sh ]; then
	if ! grep /home/$USER_NAME/.config/scripts/autostart.sh -e "picom"; then
	    su - $USER_NAME -c 'echo "picom -b &" >> ~/.config/scripts/autostart.sh'
	fi
	if ! grep /home/$USER_NAME/.config/scripts/autostart.sh -e "xwinwrap"; then
	    su - $USER_NAME -c 'echo "xwinwrap -fs -nf -ov -- mplayer -fps 24 -shuffle -loop 0 -wid WID -nolirc ~/.config/wallpapers/background.mp4 &" >> ~/.config/scripts/autostart.sh'
	fi
    fi
}


function configure_fcitx {
    installer fcitx       
    installer fcitx-qt5  
    installer fcitx-configtool
    installer fcitx-googlepinyin

    if [ ! -d /home/$USER_NAME/.config/fcitx ]; then
	sudo su - $USER_NAME -c 'mkdir ~/.config/fcitx'
    fi
    sudo su - $USER_NAME -c "cp $WORKDIR/resources/fcitx-googlepinyin/config ~/.config/fcitx/."
    sudo su - $USER_NAME -c "cp $WORKDIR/resources/fcitx-googlepinyin/profile ~/.config/fcitx/."
    sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/fcitx-googlepinyin/conf ~/.config/fcitx/."
}


function configure_fzf {
    installer fish
    chsh $USER_NAME -s /usr/bin/fish >/dev/null 2>&1
    installer fzf
    installer fd
    installer highlight

    if [ ! -d /home/$USER_NAME/.config/fish/functions ]; then
	sudo su - $USER_NAME -c 'mkdir ~/.config/fish/functions'
    fi

    sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/fzf/fzf.fish ~/.config/fish/functions/."
    sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/fzf/fish_user_key_bindings.fish ~/.config/fish/functions/."
}


function configure_nvim {
    installer fzf
    installer the_silver_searcher
    installer ccls
    installer nodejs
    installer npm
    sudo su - $USER_NAME -c 'npm config set registry https://registry.npm.taobao.org'

    installer python-pynvim
    installer neovim
    installer xsel
    #installer vimb
    #sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/vimb ~/.config/."

    installer gcr
    installer webkit2gtk
    su - $USER_NAME -c "cd $WORKDIR/resources/desktop/surf; sudo make clean install"

    sudo ln -sf /usr/bin/nvim /usr/bin/vi
    sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/nvim ~/.config/."

    installer ranger
    installer ueberzug
    installer ffmpegthumbnailer
    sudo su - $USER_NAME -c "cp -rf $WORKDIR/resources/ranger ~/.config/."
}


function configure_chromium {
    installer chromium
    su - $USER_NAME -c "cp -rf $WORKDIR/resources/chromium  ~/.config/."
}


function configure_shared_folder {
    installer open-vm-tools
    installer gtkmm3
    systemctl enable vmtoolsd.service
    systemctl enable vmware-vmblock-fuse.service
    systemctl start vmtoolsd.service
    systemctl start vmware-vmblock-fuse.service

    if [ ! -d /home/$INY_USERNAME/shared-folder ]; then
	su - $USER_NAME -c 'mkdir -p shared-folder'
    fi

    cp $WORKDIR/resources/shared-folder/shared-folder.service /etc/systemd/system/. 
    if [ -f /etc/systemd/system/shared-folder.service ]; then
	if ! grep /etc/systemd/system/shared-folder.service -e "/home/$USER_NAME/shared-folder"; then
	    echo  "ExecStart=/usr/bin/vmhgfs-fuse -o allow_other -o auto_unmount .host:/ /home/$USER_NAME/shared-folder" >> /etc/systemd/system/shared-folder.service
	fi
    fi

    systemctl enable shared-folder.service
    if ! ps -ef | grep shared-folder.service | egrep -v grep >/dev/null
    then
	systemctl start shared-folder.service
    fi
}


function configure_git_delta {
	if ! pacman -Ql git-delta >/dev/null 2>&1; then
		su - $USER_NAME -c "cd $WORKDIR/resources/git-delta; yes ' ' | makepkg -csri"

		if ! grep "/home/$USER_NAME/.gitconfig" -e "\[delta\]"; then
			su - $USER_NAME -c "cd $WORKDIR/resources/git-delta; cat gitconfig >> ~/.gitconfig"
		fi
		if ! grep "/home/$USER_NAME/.config/fish/config.fish" -e "alias diff "; then
			su - $USER_NAME -c "cd /home/$USER_NAME/.config/fish; echo 'alias dif \"delta --features=my_side-by-side\"' >> config.fish"
			su - $USER_NAME -c "cd /home/$USER_NAME/.config/fish; echo 'alias diff \"delta\"' >> config.fish"
		fi
	fi
	su - $USER_NAME -c "git config --global core.pager 'delta'"
}

function configure_alacritty {
	if ! pacman -Ql alacritty >/dev/null 2>&1; then
		installer alacritty
	fi
	su - $USER_NAME -c "cp -rf $WORKDIR/resources/alacritty  ~/.config/."
}

function configure_tmux {
  installer tmux
	su - $USER_NAME -c "cp -rf $WORKDIR/resources/tmux/.tmux.conf  ~/."
	su - $USER_NAME -c "cp -rf $WORKDIR/resources/tmux/.tmux.conf.local  ~/."
  cp $WORKDIR/resources/tmux/tmux@shibinglanya.service /etc/systemd/system/.
  systemctl enable /etc/systemd/system/tmux@shibinglanya.service
}


# COLORS {{{
    Bold=$(tput bold)
    Reset=$(tput sgr0)

    Blue=$(tput setaf 2)
    Red=$(tput setaf 1)
    Yellow=$(tput setaf 3)

    BBlue=${Bold}${Blue}
    BRed=${Bold}${Red}
    BYellow=${Bold}${Yellow}
#}}}
# PROMPTS {{{
    PROMPT_2="Enter n° of options (ex: 1 2 3 or 1-3): "
#}}}

function print_line() {
    printf "%$(tput cols)s\n" | tr ' ' '-'
}

function print_error() { 
    T_COLS=`tput cols`
    echo -e "\n\n${BRed}$1${Reset}\n" | fold -sw $(( $T_COLS - 1 ))
    sleep 3
    return 1
}

function print_title() {
    clear
    print_line
    echo -e "# ${Bold}$1${Reset}"
    print_line
    echo ""
}

function pause() {
    print_line
    read -e -sn 1 -p "Press enter to continue..."
}

function print_info() {
    T_COLS=`tput cols`
    echo -e "${Bold}$1${Reset}\n" | fold -sw $(( $T_COLS - 18)) | sed 's/^/\t/'
}

function checkbox() { 
    #display [X] or [ ]
    [[ "$1" -eq 1 ]] && echo -e "${BBlue}[*]${Reset}" || echo -e "[ ]${Reset}";
}

function mainmenu_item() { 
    echo -e "$(checkbox "$1") ${Bold}$2${Reset} ${state}"
} 

function invalid_option() {
    print_line
    echo "${BRed}Invalid option, Try another one.${Reset}"
    pause
}

function read_input_options() {
    local line
    local packages

    if [[ ! $@ ]]; then
        read -p "${PROMPT_2}" OPTION
    else
        OPTION=$@
    fi
    array=(${OPTION})

    for line in ${array[@]/,/ }; do
        if [[ ${line/-/} != ${line} ]]; then
            for (( i=${line%-*}; i <= ${line#*-}; i++ )); do
                packages+={$i};
            done
        else
            packages+=($line)
        fi
    done

    OPTIONS=(${packages[@]})
}

function contains_element() {
    for e in in "${@:2}"; do [[ ${e} == ${1} ]] && break; done;
}

function unique_elements() {
    RESULT_UNIQUE_ELEMENTS=($(echo $@ | tr ' ' '\n' | sort -u | tr '\n' ' '))
}

function confirm_operation() {
    read -p "${BYellow}$1 [y/N]: ${Reset}" OPTION
    OPTION=`echo "${OPTION}" | tr '[:upper:]' '[:lower:]'`    
}


function desktop_install() {
	configure_config
	configure_fonts
	configure_fish
	configure_desktop
	configure_background
	configure_fcitx
	configure_fzf
	configure_nvim
	configure_chromium
	configure_shared_folder
	configure_git_delta
	configure_alacritty
	configure_tmux
}

function install() {
    confirm_operation "Operation is irreversible, Are you sure?"
    if [[ ${OPTION} = "y" ]]; then
	configure_login_user
	install_basis
        desktop_install

        print_line
        confirm_operation "Do you want to reboot system?"
        if [[ ${OPTION} == "y" ]]; then
           reboot 
        fi
        exit 0
    else
        return
    fi
}

function installer() {
    if ! pacman -Ql $1 >/dev/null 2>&1; then
	pacman -S $1 --noconfirm
    fi
    return 0
}

function install_basis {
    installer git

    if [ -d /root/iny ]; then
	mv -f /root/iny /home/$USER_NAME/.
	WORKDIR=/home/$USER_NAME/iny
	chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/iny
    fi

    if [ -z "$(cd $WORKDIR;git config --list | grep 'remote\.iny')" ]; then
	su - $USER_NAME -c "cd $WORKDIR; git remote add iny git@gitee.com:xeger/iny.git"
    fi
	su - $USER_NAME -c "git config --global core.pager 'less -x0,2'"

    pacman -Syyu --noconfirm

    installer gdb       
    installer autoconf  
    installer automake  
    installer binutils  
    installer bison     
    installer fakeroot  
    installer file      
    installer findutils 
    installer flex      
    installer gawk      
    installer gcc       
    installer gettext   
    installer grep      
    installer groff     
    installer gzip      
    installer libtool   
    installer m4        
    installer make      
    installer pacman    
    installer patch     
    installer pkgconf   
    installer sed       
    installer sudo      
    installer texinfo   
    installer which     
    installer man       
    installer openssh   

    if [ ! -d /home/$USER_NAME/.config ]; then
	su - $USER_NAME -c 'mkdir .config'
    fi
}

if [ "$(whoami)" != 'root' ]; then
    T_COLS=`tput cols`
    echo -e "error:${BRed}root permission required!${Reset}\n" | fold -sw $(( $T_COLS - 1 ))
    exit 1;
fi

if [ $1 = '--noconfirm' ]; then
    configure_login_user
    install_basis
    desktop_install

    print_line
    exit 0
else
    MainMenu
fi
