#!/bin/sh
set -e

echo ">>> Enabling root user. Your root password is: eneco"
sed -i -e "s/^root:DISABLED:/root:RWSq9sBXBJm0E:/" /etc/passwd

if [[ ! -f /etc/default/iptables.conf.preroot ]]; then
  cp /etc/default/iptables.conf /etc/default/iptables.conf.preroot
fi
sed -i -e "s/^# These are all closed for Quby\/Toon:/# ADDED WHILE ROOTING\n\
-A HCB-INPUT -p tcp -m tcp --dport 22 --tcp-flags SYN,RST,ACK SYN -j ACCEPT\n\
-A HCB-INPUT -p tcp -m tcp --dport 10080 --tcp-flags SYN,RST,ACK SYN -j ACCEPT\n\
-A HCB-INPUT -p tcp -m tcp --dport 80 --tcp-flags SYN,RST,ACK SYN -j ACCEPT\n\
-A HCB-INPUT -p tcp -m tcp --dport 5900 --tcp-flags SYN,RST,ACK SYN -j ACCEPT\n\
# END/" /etc/default/iptables.conf

set +e
echo ">>> Copy webmobile login file"
wget -q http://www.wickedmaster.nl/toon/lighttpd.user -O /qmf/etc/lighttpd/lighttpd.user
set -e

set +e
echo ">>> Installing dropbear"
cd /tmp
wget http://files.domoticaforum.eu/uploads/Toon/ipk/qb2/dropbear_2015.71-r0_qb2.ipk
opkg install dropbear_2015.71-r0_qb2.ipk
if [[ $? == 255 ]] ; then
  set -e
  sh /usr/lib/opkg/info/dropbear.postinst
fi
set -e

set +e
echo ">>> Installing openssh-sftp-server"
wget http://files.domoticaforum.eu/uploads/Toon/ipk/qb2/openssh-sftp-server_7.3p1-r10.0_qb2.ipk
opkg install --nodeps openssh-sftp-server_7.3p1-r10.0_qb2.ipk
if [[ $? == 255 ]] ; then
  set -e
  sh /usr/lib/opkg/info/dropbear.postinst
fi
set -e

printf "\nDe volgende versie staat geinstalleerd op deze Toon:\n"
grep -A 3 base-qb2 /usr/lib/opkg/status | grep Version

printf "\nHet IP-adres van deze Toon is:\n"
/sbin/ifconfig eth0 2>/dev/null | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'
