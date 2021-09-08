#!/bin/bash

echo Starting DHCP Server...

#set the server ip address in case it is not set elsewhere.
#for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html.
sudo ifconfig eth0 192.168.1.1

#check the installation status of isc-dhcp-server:
#(1) if it is missing, install it. (2) if the default dhcp server is enabled, stop and disable it to prevent conflicts. 
#(3) if the isc-dhcp-server service is not enabled, enable and start it.
#for more information see: https://man7.org/linux/man-pages/man1/dpkg-query.1.html, https://www.man7.org/linux/man-pages/man1/systemctl.1.html,
#https://man7.org/linux/man-pages/man1/grep.1p.html, https://en.wikipedia.org/wiki/File_descriptor.
if [ ! "dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -c 'ok installed'" ]; then sudo bash -c "apt-get update && apt-get upgrade && apt-get install isc-dhcp-server"; fi
if [ ! "sudo systemctl list-units --type=service | grep 'dhcpcd.service'" ]; then sudo bash -c "systemctl stop dhcpcd.service && systemctl disable dhcpcd.service"; fi
if [ ! "sudo systemctl list-units --type=service | grep 'isc-dhcp-server.service'" ]; then sudo bash -c "systemctl enable isc-dhcp-server.service"; fi
sudo systemctl start isc-dhcp-server.service

echo Configuring NAT routes...

#configure the dhcp server to operate on eth0.
#configure ip forwarding, all traffic from wlan0 will be forwarded to eth0 and vice versa.
#for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html.
if [ "grep -c 'INTERFACESv4=""' /etc/default/isc-dhcp-server" ]; then sudo bash -c "sed -i 's/INTERFACESv4=\"\"/INTERFACESv4=\"eth0\"/g' /etc/default/isc-dhcp-server"; fi
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m STATE --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
cat "net.ipv4.ip_forward=1" >> ~/etc/sysctl.conf







#Because service discovery on LAN is unnecessary in this configuration avahi-damon can be disabled to free resources.
#For more information see: https://www.avahi.org, https://linux.die.net/man/8/avahi-daemon.
sudo systemctl disable avahi-daemon
