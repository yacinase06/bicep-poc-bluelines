#!/bin/sh
# This is to install required components to stand up VPN and other services 
# setup of tunnel reference - https://sysadmins.co.za/setup-a-site-to-site-ipsec-vpn-with-strongswan-on-ubuntu/   and  https://www.tecmint.com/setup-ipsec-vpn-with-strongswan-on-debian-ubuntu/
sudo apt-get update
sudo apt install strongswan --yes
cat >> /etc/sysctl.conf << EOF
echo net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF