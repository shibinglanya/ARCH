#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
	echo "root permission required"
	exit 1;
fi

if [ ! -n "$INY_USERNAME" ]; then
    exit 2
fi

if ! pacman -Ql open-vm-tools >/dev/null ; then pacman -S open-vm-tools --noconfirm ; fi
if ! pacman -Ql gtkmm3 >/dev/null ; then pacman -S gtkmm3 --noconfirm ; fi
systemctl enable vmtoolsd.service
systemctl enable vmware-vmblock-fuse.service
systemctl start vmtoolsd.service
systemctl start vmware-vmblock-fuse.service

if [ ! -d /home/$INY_USERNAME/shared-folder ]; then
    su - $INY_USERNAME -c 'mkdir -p shared-folder'
fi

cp /home/$INY_USERNAME/iny/resources/shared-folder/shared-folder.service /etc/systemd/system/. 
if [ -f /etc/systemd/system/shared-folder.service ]; then
    if ! grep /etc/systemd/system/shared-folder.service -e "$INY_USERNAME/shared-folder"; then
        echo  "ExecStart=/usr/bin/vmhgfs-fuse -o allow_other -o auto_unmount .host:/ /home/$INY_USERNAME/shared-folder" >> /etc/systemd/system/shared-folder.service
    fi
fi

systemctl enable shared-folder.service
if ! ps -ef | grep shared-folder.service | egrep -v grep >/dev/null
then
    systemctl start shared-folder.service
fi
