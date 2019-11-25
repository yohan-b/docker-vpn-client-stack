#!/bin/bash
# The commands below fix iptables -j MARK not working:
#type=AVC msg=audit(1546362201.768:148429): avc:  denied  { module_request } for  pid=11415 comm="iptables" kmod="ipt_MARK" scontext=system_u:system_r:container_t:s0:c283,c766 tcontext=system_u:system_r:kernel_t:s0 tclass=system
#
#       Was caused by:
#       The boolean domain_kernel_load_modules was set incorrectly. 
#       Description:
#       Allow domain to kernel load modules
#
#       Allow access by executing:
#       # setsebool -P domain_kernel_load_modules 1

sudo modprobe ipt_MARK
sudo modprobe l2tp_ppp
MODULE_FILE=/etc/modules-load.d/docker.conf
sudo bash -c "test -f $MODULE_FILE || touch $MODULE_FILE"
sudo bash -c "grep -q ipt_MARK $MODULE_FILE \
|| { echo '# Loading ipt_MARK at boot is needed to use iptables -j MARK in docker containers' >> $MODULE_FILE; \
     echo 'ipt_MARK' >> $MODULE_FILE; }"
sudo bash -c "grep -q l2tp_ppp $MODULE_FILE \
|| { echo '# Loading l2tp_ppp at boot is needed to use xl2tpd with kernel drivers in docker containers' >> $MODULE_FILE; \
     echo 'l2tp_ppp' >> $MODULE_FILE; }"

sudo chown root:13 users
sudo chown root:root entrypoint.sh
sudo chmod +x entrypoint.sh
sudo chown -R root. client_privateinternetaccess_FR.conf keys_privateinternetaccess

# --force-recreate is used to recreate container when crontab file has changed
unset VERSION_PROXY VERSION_VPN_CLIENT VERSION_L2TP_CLIENT
VERSION_PROXY=$(git ls-remote ssh://git@git.scimetis.net:2222/yohan/docker-proxy.git| head -1 | cut -f 1|cut -c -10) \
VERSION_VPN_CLIENT=$(git ls-remote ssh://git@git.scimetis.net:2222/yohan/docker-VPN-client.git| head -1 | cut -f 1|cut -c -10) \
VERSION_L2TP_CLIENT=$(git ls-remote ssh://git@git.scimetis.net:2222/yohan/docker-l2tp-client.git| head -1 | cut -f 1|cut -c -10) \
 sudo -E bash -c 'docker-compose up -d --force-recreate'

