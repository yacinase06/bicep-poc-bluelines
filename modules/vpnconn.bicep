param name string
param vnetgwid string
param lngid string
param keyvault_name string

var psk = '${uniqueString(resourceGroup().id,vnetgwid,lngid)}aA1!'

resource conn 'Microsoft.Network/connections@2021-02-01' = {
  location: resourceGroup().location
  name: name
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 0 
    sharedKey: psk
    enableBgp: false
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0 
    connectionMode: 'Default'
    virtualNetworkGateway1: {
      id: vnetgwid
      properties: {
      }
    }
     localNetworkGateway2: {
       id: lngid
       properties:{
       }
     }
  }
}

resource keyvaultname_secretname 'Microsoft.keyvault/vaults/secrets@2019-09-01' = {
  name: '${keyvault_name}/${name}-psk'
  properties: {
    contentType: 'securestring'
    value: psk
    attributes: {
      enabled: true
    }
  }
}
