#!/bin/bash

# dhcpcd is unnecessary in this configuration, if it has not been done already stop and disable it
if [ ! "sudo systemctl list-units --type=service | grep 'dhcpcd.service'" ]; then sudo bash -c "systemctl stop dhcpcd.service && systemctl disable dhcpcd.service"; fi

# service discovery on lan is unnecessary in this configuration, if it has not been done already stop and disable it.
if [ ! "systemctl is-active avahi-daemon.service | grep -c 'inactive'"]; then sudo bash -c "systemctl stop avahi-daemon && systemctl disable avahi-daemon"; fi

# bluetooth is unnecessary in this configuration, if it has not been done already disable it
if [ ! "grep -c "dtoverlay=disable-bt" /boot/config.txt" ]; then "echo 'dtoverlay=disable-bt' | sudo tee -a /boot/config.txt"; fi

echo Starting DHCP Server...

# if not set, set the static interface and ip address.
# copy configured files to overwrite their default counterparts.
# set the server ip address in case it is not set elsewhere.
# for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html, https://www.gnu.org/software/sed/manual/sed.html.
if [ "grep -ec '\#interface eth0' /etc/dhcpcd.conf" ]; then sudo bash -c "sed -i 's/\#interface eth0/interface eth0/g' /etc/dhcpcd.conf"; fi
if [ "grep -ec '\#static ip_address' /etc/dhcpcd.conf" ]; then sudo bash -c "sed -i 's/\#static ip_address=192.168.0.10\/24/static ip_address=192.168.1.1/g' /etc/dhcpcd.conf"; fi
sudo curl -L https://raw.githubusercontent.com/rinebergc/raspi-bridge/main/etc/dhcp/dhcpd.conf -o /etc/dhcp/dhcpd.conf
sudo curl -L https://raw.githubusercontent.com/rinebergc/raspi-bridge/main/etc/network/interfaces -o /etc/network/interfaces
sudo ifconfig eth0 192.168.1.1

# check the installation status of isc-dhcp-server:
# (1) if it is missing, install it. (2) if the isc-dhcp-server service is not enabled, enable and start it.
# for more information see: https://man7.org/linux/man-pages/man1/dpkg-query.1.html, https://www.man7.org/linux/man-pages/man1/systemctl.1.html,
# https://man7.org/linux/man-pages/man1/grep.1p.html, https://en.wikipedia.org/wiki/File_descriptor.
if [ "dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -c 'no packages found'" ]; then sudo bash -c "apt-get -y update && apt-get -y upgrade && apt-get -y install isc-dhcp-server"; fi
if [ ! "sudo systemctl list-units --type=service | grep 'isc-dhcp-server.service'" ]; then sudo bash -c "systemctl enable isc-dhcp-server.service"; fi
#sudo systemctl start isc-dhcp-server.service

echo Configuring NAT routes...

# configure the dhcp server to operate on eth0.
# configure ip forwarding, all traffic from wlan0 will be forwarded to eth0 and vice versa.
# for more information see: https://man7.org/linux/man-pages/man8/ifconfig.8.html.
if [ "grep -c 'INTERFACESv4=""' /etc/default/isc-dhcp-server" ]; then sudo bash -c "sed -i 's/INTERFACESv4=\"\"/INTERFACESv4=\"eth0\"/g' /etc/default/isc-dhcp-server"; fi
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
if [ "grep -ec '\#net.ipv4.ip_forward=1' /etc/sysctl.conf" ]; then sudo bash -c "sed -i 's/\#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf"; fi

# if the default interface entry in the IP routing table is wlan0, nothing will happen; otherwise, wlan0 will be set as such.
# for more information see: https://gist.github.com/Konamiman/110adcc485b372f1aff000b4180e2e10#step-3-set-the-wifi-network-as-the-main-route.
DEFAULT_IFACE=`route -n | grep -E "^0.0.0.0 .+UG" | awk '{print $8}'`
if [ "$DEFAULT_IFACE" != "wlan0" ]; then
  GW=`route -n | grep -E "^0.0.0.0 .+UG .+wlan0$" | awk '{print $2}'`
  sudo route del default $DEFAULT_IFACE
  sudo route add default gw $GW wlan0; fi
