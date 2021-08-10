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

@description('Set the size for the VM')
@minLength(6)
param HostVmSize string = 'Standard_D2_v3'

@description('Set a username to log in to the hosts')
@minLength(3)
param VmAdminUsername string = 'localadmin'

@description('Set the path to the github directory that has the custom script extension scripts')
@minLength(10)
param githubPath string = 'https://raw.githubusercontent.com/sdcscripts/bicep-poc-bluelines/master/scripts/'

@description('Set the name of the domain eg contoso.local')
@minLength(3)
param domainName string = 'contoso.local'

var hubVmName       = 'hubjump'
var hubSubnetRef    = '${virtualnetwork[0].outputs.vnid}/subnets/${virtualnetwork[0].outputs.subnets[0].name}'

var spokeVmName     = 'spokejump'
var SpokeSubnetRef  = '${virtualnetwork[1].outputs.vnid}/subnets/${virtualnetwork[1].outputs.subnets[0].name}'

var dcVmName        = 'dc1'
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
    prefix: '192.168.199.0/24'
  }
]

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
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
// It is not possible to create a loop through the vm var because the 'subnetref' which is an output only known at runtime is not calculated until after deployment. It is not possible therefore to use it in a loop.
module hubJumpServer './modules/winvm.bicep' = {
  params: {
    adminusername: VmAdminUsername
    keyvault_name: kv.outputs.keyvaultname
    vmname       : hubVmName
    subnetRef    : hubSubnetRef
    vmSize       : HostVmSize
    githubPath   : githubPath
    deployDC     : false

  }
  name: 'hubjump'
  scope: rg
}  

module spokeJumpServer './modules/winvm.bicep' = {
  params: {
    adminusername: VmAdminUsername
    keyvault_name: kv.outputs.keyvaultname
    vmname       : spokeVmName
    subnetRef    : SpokeSubnetRef
    vmSize       : HostVmSize
    githubPath   : githubPath
    deployDC     : false
  }
  name: 'spokejump'
  scope: rg
}  

module dc './modules/winvm.bicep' = {
  params: {
    adminusername: VmAdminUsername
    keyvault_name: kv.outputs.keyvaultname
    vmname       : dcVmName
    subnetRef    : onpremSubnetRef
    vmSize       : HostVmSize
    githubPath   : githubPath
    domainName   : domainName
    deployDC     : true
  }
  name: 'OnpremDC'
  scope: rg
} 
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

module vnetPeering './modules/vnetpeering.bicep' = {
  params:{
    hubVnetId    : virtualnetwork[0].outputs.vnid
    spokeVnetId  : virtualnetwork[1].outputs.vnid
    hubVnetName  : virtualnetwork[0].outputs.vnName
    spokeVnetName: virtualnetwork[1].outputs.vnName
  }
  scope: rg
  name: 'vNetpeering'
}

/* Deployment using bicep (via az cli)

The first command retrieves the signed-in usr object ID to use for setting Keyvault permissions, you need to add this ObjectID to the adUserId parameter at the top of this file.
All other parameters have defaults set. 

Command:   az ad signed-in-user show --query objectId -o tsv

The second command deploys this main.bicep 

Command: az deployment sub create --name bluelines --template-file .\main.bicep --location uksouth

 */
