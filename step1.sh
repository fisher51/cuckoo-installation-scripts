#!/bin/bash

# Add virtualbox repo to system
RELEASE=$(lsb_release -c | awk '{print $2}')
sudo echo deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian focal contrib | sudo tee -a /etc/apt/sources.list.d/virtualbox.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

# Update repos
sudo apt-get update && sudo apt-get upgrade -y

# Installing required packets
sudo apt-get install unzip python2.7 python-setuptools python-dev libffi-dev libssl-dev libjpeg-dev zlib1g-dev swig mongodb postgresql libpq-dev tcpdump apparmor-utils libcap2-bin git vim tmux curl virtualbox screen mlocate -y

#tryout of python3 virtualenv
sudo apt-get -y install python3-virtualenv python3-setuptools

# Install pip for python2.7
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
sudo python2.7 get-pip.py
sudo rm get-pip.py

# tcpdump specific configuration
sudo aa-disable /usr/sbin/tcpdump

# Configure necessary capabilities for tcpdump binary
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

#add env before user created to mitigate restart
sudo sed -e 's|PATH="\(.*\)"|PATH="/home/cuckoo/.local/bin:\1"|g' -i /etc/environment
# Add cucko user
sudo adduser --disabled-password --gecos "" cuckoo
sudo groupadd pcap
sudo usermod -a -G pcap cuckoo
sudo usermod -a -G vboxusers cuckoo

#MiTM proxy
wget https://snapshots.mitmproxy.org/6.0.2/mitmproxy-6.0.2-linux.tar.gz
gunzip -d mitmproxy-6.0.2-linux.tar.gz
tar -xvf mitmproxy-6.0.2-linux.tar
sudo mv mitmproxy /usr/bin/mitmproxy
sudo mv mitmweb /usr/bin/mitmweb
sudo mv mitmdump /usr/bin/mitmdump
sudo rm mitmproxy-6.0.2-linux.tar

#Volatility
wget http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip
unzip volatility_2.6_lin64_standalone.zip
sudo mv volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone /usr/bin/volatility
sudo rm -rf volatility_2.6_lin64_standalone*

#mount win7 iso(can be changed to different OS)
sudo mkdir /mnt/win7
sudo chown cuckoo:cuckoo /mnt/win7
sudo mount -o ro,loop win7ultimate.iso /mnt/win7

#install cuckoo and vmcloak
sudo pip install -U cuckoo vmcloak

#configure forwarders
sudo sysctl -w net.ipv4.conf.vboxnet0.forwarding=1
sudo sysctl -w net.ipv4.conf.enp0s3.forwarding=1

#configure IPTABLES
sudo iptables -t nat -A POSTROUTING -o eth0 -s 192.168.56.0/24 -j MASQUERADE
sudo iptables -P FORWARD DROP
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -s 192.168.56.0/24 -j ACCEPT

sudo chown cuckoo:cuckoo step2.sh
sudo chmod 750 step2.sh

#set full path to script
sudo -u cuckoo /tmp/cuckooinstall/step2.sh
