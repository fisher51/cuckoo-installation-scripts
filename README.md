# cuckoo-installation-scripts
This is PoC in it's early stage. Tested on Ubuntu 20.04.3 inside virtualbox with windows 7 ultimate as sandbox machine for cuckoo(inside virtualbox installed in guest)

#### This setup configured to be runned from /tmp/cuckooinstall directory with step1.sh, step2.sh and win7ultimate.iso inside. 

## Pre-requirments:
- Both scripts and ISO image should be located at the same directory
- chmod 750 step1.sh (for step2.sh it will be applied automatically)
- Each section commented so it should be easier to make modification if any changes required


### Some required manual actions after scripts completion:
- Enable mongodb in ~/.cuckoo/conf/reporting.conf
- Change network interface to system external interface name if needed in ~/.cuckoo/conf/routing.conf  
"internet = none" to "internet = enp0s3"

## To start cuckoo:
- Enable rooter service  
sudo cuckoo rooter --sudo --group cuckoo #from user with sudo rights
- Switch to virtualenv via  
. ~/cuckoo/bin/activate
- Start cuckoo inside virtualenv  
cuckoo
- Start WebGUI  
cuckoo web --host 127.0.0.1 --port 8080

## TODO:
- Automate everything(with user interaction)
- Add additional tools
