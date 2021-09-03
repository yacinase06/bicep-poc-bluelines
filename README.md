# Cross Solution on-premises with VPN, Active Directory and Hub+Spoke

This will deploy various elements into your Azure environment to provide a lab\PoC for a hybrid environment, including: 

1. VNet acting as an on-premises environment with fully configured Active Directory domain controller and an Ubuntu VM with strongSwan to terminate a VPN tunnel. 
2. A Hub and spoke model with a spoke connected via vnet peer and the on-prem environment connected via Virtual Network Gateway and IPsec tunnel. 
3. Bastions deployed in on-prem VNet and Hub to allow full bastion access to all VMs
4. Keyvault which will store passwords for all VMs and the Pre-shared key for the IPsec VPN connection
5. A DNS server in the hub (yet to be configured with BIND) - the idea if that the DC will conditional forward to this DNS for private endpoints etc. 


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsdcscripts%2Fbicep-poc-bluelines%2Fmaster%2Fmain.json)
