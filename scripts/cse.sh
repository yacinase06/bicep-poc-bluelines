#!/bin/sh
# This is to install required components to stand up VPN and other services 
sudo apt-get update -y
sleep 5 
sudo apt-get install strongswan --yes
sleep 5
sudo sed -i '/'net.ipv4.conf.all.accept_redirects'/s/^#//g' /etc/sysctl.conf 
sudo sed -i '/'net.ipv4.conf.all.send_redirects'/s/^#//g' /etc/sysctl.conf 
sudo sed -i '/'net.ipv4.ip_forward'/s/^#//g' /etc/sysctl.conf 

# configure ipsec.conf
rm /etc/ipsec.conf

echo "config setup" >> /etc/ipsec.conf
echo "        # strictcrlpolicy=yes" >> /etc/ipsec.conf
echo "        # uniqueids = no" >> /etc/ipsec.conf
echo " " >> /etc/ipsec.conf
echo "conn azure" >> /etc/ipsec.conf
echo "      type=tunnel" >> /etc/ipsec.conf
echo "      authby=secret" >> /etc/ipsec.conf
echo "      keyexchange=ikev2" >> /etc/ipsec.conf
echo "      ike=aes256-sha1-modp1024" >> /etc/ipsec.conf
echo "      esp=aes256-sha1-modp1024!" >> /etc/ipsec.conf
echo "      left=$1" >> /etc/ipsec.conf
echo "      leftsubnet=$6" >> /etc/ipsec.conf
echo "      right=$3" >> /etc/ipsec.conf
echo "      rightsubnet=$4" >> /etc/ipsec.conf
echo "      auto=add" >> /etc/ipsec.conf

# Edit secrets file add psk
echo "$2 $3 : PSK \"$5\" " >> /etc/ipsec.secrets

# edit charon to increase retries (to allow time for Virtual Network Gateway to deploy)

sed -i 's/    # retransmit_tries = 5/retransmit_tries = 100/' /etc/strongswan.d/charon.conf
sed -i 's/    # install_routes = yes/install_routes = yes/' /etc/strongswan.d/charon.conf

# start strongSwan 
ipsec restart
ipsec up azure