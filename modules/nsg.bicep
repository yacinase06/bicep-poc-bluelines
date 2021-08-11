
  param location string
  
  resource sg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'allowSSH'
    location: location
    properties: {
      securityRules: [
        {
          name: 'default-allow-ssh'
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
      ]
    }
  }

  output onpremNsgId string = sg.id
