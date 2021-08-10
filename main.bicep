@minLength(36)
@maxLength(36)
@description('Used to set the Keyvault access policy - run this command using az cli to get your ObjectID : az ad signed-in-user show --query objectId -o tsv')
param adUserId string  = '31bc51c1-c74e-4d61-ae56-6061de35f3b8'

@description('Set the location for the resource group and all resources')
@minLength(3)
@maxLength(20)
param Location string = 'UK South'

@description('Set the resource group name, this will be created automatically')
@minLength(3)
@maxLength(10)
param ResourceGroupName string = 'bluelines'

@description('Set the prefix of the docker hosts')
@minLength(2)
@maxLength(8)
param VmHostname string = 'dc'

@description('Set the size for the VM')
@minLength(6)
param HostVmSize string = 'Standard_D2_v3'

@description('Set a username to log in to the hosts')
@minLength(3)
param VmAdminUsername string = 'localadmin'

@description('Set the path to the github directory that has the custom script extension scripts')
@minLength(10)
param githubPath string = 'https://raw.githubusercontent.com/sdcscripts/bicep-poc-bluelines/master/scripts/'

@description('Set the number of hosts to create')
@minValue(1)
@maxValue(1)
param numberOfHosts int = 1

@description('Set the name of the domain eg contoso.local')
@minLength(3)
param domainName string = 'contoso.local'


var onpremSubnetRef = '${virtualnetwork[2].outputs.vnid}/subnets/${virtualnetwork[2].outputs.subnets[0].name}'

var vnets = [
  {
    vnetName: 'hubVnet'
    vnetAddressPrefix: '172.15.0.0/16'
    subnets: hubSubnets
  }
  {
    vnetName: 'spokeVnet'
    vnetAddressPrefix: '172.16.0.0/16'
    subnets: spokeSubnets
  }
  {
    vnetName: 'onpremises'
    vnetAddressPrefix: '192.168.0.0/16'
    subnets: onpremisesSubnets
  }
]

var hubSubnets = [
  {
    name: 'main'
    prefix: '172.15.1.0/24'
  }
]

var spokeSubnets = [
  {
    name: 'main'
    prefix: '172.16.1.0/24'
  }
]

var onpremisesSubnets = [
  {
    name: 'main'
    prefix: '192.168.1.0/24'
  }
]

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: ResourceGroupName
  location: Location
}

 module kv './modules/kv.bicep' = {
  params: {
    adUserId: adUserId
  }
  name: 'kv'
  scope: rg
}

// The VM passwords are generated at run time and automatically stored in Keyvault. 
module dc './modules/dc.bicep' =[for i in range (1,numberOfHosts): {
  params: {
    adminusername: VmAdminUsername
    keyvault_name: kv.outputs.keyvaultname
    vmname       : '${VmHostname}${i}'
    subnetRef    : onpremSubnetRef
    vmSize       : HostVmSize
    githubPath   : githubPath
    domainName   : domainName
  }
  name: '${VmHostname}${i}'
  scope: rg
} ] 

module virtualnetwork './modules/vnet.bicep' = [for vnet in vnets: {
  params: {
    vnetName         : vnet.vnetName
    vnetAddressPrefix: vnet.vnetaddressprefix
    location         : Location
    subnets          : vnet.subnets
  }

  name: '${vnet.vnetName}'
  scope: rg
} ]

/* Deployment using bicep (via az cli)

The first command retrieves the signed-in usr object ID to use for setting Keyvault permissions, you need to add this ObjectID to the adUserId parameter at the top of this file.
All other parameters have defaults set. 

Command:   az ad signed-in-user show --query objectId -o tsv

The second command deploys this main.bicep 

Command: az deployment sub create --name docker-single-host --template-file .\main.bicep --location uksouth

 */
