
  param location string
  param sourceAddressPrefix string = '*'
  
  resource sg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'Allow-tunnel-traffic'
    location: location
    properties: {
      securityRules: [
        { // This rule to be removed - temporary to allow set up of IPsec tunnel
          name: 'temp-allow-ssh' 
          'properties': {
            priority: 1000
            access: 'Allow'
            direction: 'Inbound'
            destinationPortRange: '22'
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
          }
        }
        {
          name: 'default-allow-tunnel-comms'
          'properties': {
            priority: 1100
            access: 'Allow'
            direction: 'Inbound'
            destinationPortRange: '*'
            protocol: '*'
            sourcePortRange: '*'
            sourceAddressPrefix: sourceAddressPrefix
            destinationAddressPrefix: '*'
          }
        }
      ]
    }
  }

  output onpremNsgId string = sg.id
