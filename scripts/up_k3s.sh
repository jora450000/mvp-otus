#!/bin/bash -x

#Uninstall k3s if installed
export STATUS_K3S=$(systemctl  is-active k3s)
if [ $STATUS_K3S == "active"  ];  then
   sudo     /usr/local/bin/k3s-uninstall.sh || echo Not installed
fi


grep -E -i   "(centos|rhel|fedora)"  /etc/os-release
if [ $? == 0 ];  then
   sudo	yum update
   yum install git  
else 
   sudo apt update
   apt install git
fi 

#sudo sh -c "curl -sfL https://get.k3s.io | sh -"

sudo bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -"


fgrep   "flannel-backend=host-gw" /etc/systemd/system/k3s.service

if [ $? != 0 ] ; then
	sed -i '$d'  /etc/systemd/system/k3s.service

	echo -n "--flannel-backend=host-gw" >> /etc/systemd/system/k3s.service 

	cat  /etc/systemd/system/k3s.service
	systemctl daemon-reload
	systemctl stop k3s
        systemctl start k3s

fi

