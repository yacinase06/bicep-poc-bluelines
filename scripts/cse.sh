#!/bin/sh 
# This is to install required components to stand up VPN and other services 
# setup of tunnel reference - https://sysadmins.co.za/setup-a-site-to-site-ipsec-vpn-with-strongswan-on-ubuntu/   and  https://www.tecmint.com/setup-ipsec-vpn-with-strongswan-on-debian-ubuntu/
sudo apt-get update
sudo apt install strongswan --yes
