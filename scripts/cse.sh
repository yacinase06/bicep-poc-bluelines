#!/bin/sh
# This is to install required components to stand up VPN and other services 
# setup of tunnel reference - https://sysadmins.co.za/setup-a-site-to-site-ipsec-vpn-with-strongswan-on-ubuntu/   and  https://www.tecmint.com/setup-ipsec-vpn-with-strongswan-on-debian-ubuntu/
sudo apt-get update
sudo apt install strongswan --yes
sudo sed -i '/'net.ipv4.conf.all.accept_redirects'/s/^#//g' /etc/sysctl.conf 
sudo sed -i '/'net.ipv4.conf.all.send_redirects'/s/^#//g' /etc/sysctl.conf 
sudo sed -i '/'net.ipv4.ip_forward'/s/^#//g' /etc/sysctl.conf 

echo "$1" >> /etc/ipsec.conf
echo "$2" >> /etc/ipsec.conf
echo "$3" >> /etc/ipsec.conf
echo "$4" >> /etc/ipsec.conf