#!/bin/bash

#switch to virtual env
virtualenv ~/cuckoo
. ~/cuckoo/bin/activate

#create virtualbox network
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1

#first start cuckoo
cuckoo

#select vbox adapter for VMs
vmcloak-vboxnet0

#create image for sandbox
vmcloak init --verbose --win7x64 win7x64base --cpus 4 --ramsize 4096

#create drive image from base image
vmcloak clone win7x64base win7x64cuckoo

#create snapshot for cuckoo
#Create temp VM to enable multiattach parameter(fix for VirtualBox v. 6.0+)
vboxmanage createvm --name multiattfix --register
vboxmanage storagectl multiattfix --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach multiattfix --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /home/$USER/.vmcloak/image/win7x64cuckoo.vdi
vboxmanage storageattach multiattfix --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium none
vboxmanage unregistervm multiattfix -delete
vboxmanage modifyhd /home/$USER/.vmcloak/image/win7x64cuckoo.vdi --type multiattach

#create snapshot for cuckoo
vmcloak snapshot win7x64cuckoo cuckoo1 192.168.56.101

#add images to virtualbox config in cuckoo
while read -r vm ip; do cuckoo machine --add $vm $ip; done < <(vmcloak list vms)

#update signatures
cuckoo community --force

### MANUAL ACTIONS

#enable mongodb in ~/.cuckoo/conf/reporting.conf

#change network interface to system external interface name if needed in ~/.cuckoo/conf/routing.conf "internet = none" to "internet = enp0s3"

#enable rooter service 
#sudo -u <user with sudo rights> cuckoo rooter --sudo --group cuckoo
##switch to virtualenv via . ~/cuckoo/bin/activate
#start cuckoo
#cuckoo
#start webgui
#cuckoo web --host 127.0.0.1 --port 8080
