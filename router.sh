#!/bin/bash

echo Starting DHCP Server...

#set the server ip address in case it is not set elsewhere.
#for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html.

sudo ifconfig eth0 192.168.1.1

#check the installation status of isc-dhcp-server, install it if it is missing, then start it.
#for more information see: https://man7.org/linux/man-pages/man1/dpkg-query.1.html, https://man7.org/linux/man-pages/man1/grep.1p.html.

if [ ! "dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -c 'ok installed'" ]; then sudo apt-get install isc-dhcp-server; fi
sudo service isc-dhcp-server start

echo Configuring NAT routes...

#configure IP forwarding, all traffic from wlan0 will be forwarded to eth0 and vice versa.
#for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html.

sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m STATE --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
cat "net.ipv4.ip_forward=1" >> ~/etc/sysctl.conf
