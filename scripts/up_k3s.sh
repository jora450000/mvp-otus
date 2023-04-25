#!/bin/bash -x

#check root access for script
if [ "$EUID" -ne 0 ]
  then echo "Please run with 'sudo ./up_k3s.sh'"
  exit 1001
fi



grep  -i   "alpine"  /etc/os-release

if [ $? == 0 ] ; then

  echo "Sorry!!! Not supported OS!!!"
  exit 1
fi

#Uninstall k3s if installed
export STATUS_K3S=$(systemctl  is-active k3s)
if [ $STATUS_K3S == "active"  ];  then
   sudo     /usr/local/bin/k3s-uninstall.sh || echo Not installed
fi


# install packages for RH or Debian/Ubuntu only

grep -E -i   "(centos|rhel|fedora)"  /etc/os-release
if [ $? == 0 ];  then
   sudo	yum update
   yum install git  curl wget
else 
   sudo apt update
   apt -y install git curl wget
fi 

#install k3s
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


#install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /bin/kubectl
ln -s  /bin/k /bin/kubectl



#install helm and plugin
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm plugin install https://github.com/databus23/helm-diff


#install helmfile
HELMFILE_URL="https://github.com/helmfile/helmfile/releases/download/v0.153.1/helmfile_0.153.1_linux_amd64.tar.gz"
wget $HELMFILE_URL
tar -xf helmfile*linux_amd64.tar.gz
rm -f helmfile*linux_amd64.tar.gz
mv -f  helmfile /bin/helmfile
rm -f LICENSE READM* kubectl



#deploy watchn
export KUBECTL=/etc/rancher/k3s/k3s.yaml

cd ../deploy/kubernetes
NODE_PORT=1 helmfile apply




