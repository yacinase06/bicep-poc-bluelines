param adminusername string
param keyvault_name string 
param vmname string
param subnet1ref string
param githubPath string
@secure()
param adminPassword string = '${uniqueString(resourceGroup().id)}aA1!' // aA1! to meet complexity requirements

@description('Size of the virtual machine.')
param vmSize string 

@description('location for all resources')
param location string = resourceGroup().location

var storageAccountName = '${uniqueString(resourceGroup().id)}${vmname}sa'
var nicName = '${vmname}nic'

param publicIPAddressNameSuffix string = 'pip'
param deployPIP bool = false

var dnsLabelPrefix = 'dns-${uniqueString(resourceGroup().id, vmname)}-${publicIPAddressNameSuffix}'

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = if (deployPIP) {
  name: publicIPAddressNameSuffix
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}


resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = if (deployPIP) {
  name: '${nicName}pip'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnet1ref
          }
        }
      }
    ]
  }
}

resource nInternoIP 'Microsoft.Network/networkInterfaces@2020-06-01' = if (!(deployPIP)) {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet1ref
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminusername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {

        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-hirsute'
        sku: '21_04'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: deployPIP ? nInter.id : nInternoIP.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
  }
}

resource keyvaultname_secretname 'Microsoft.keyvault/vaults/secrets@2019-09-01' = {
  name: '${keyvault_name}/${vmname}-admin-password'
  properties: {
    contentType: 'securestring'
    value: adminPassword
    attributes: {
      enabled: true
    }
  }
}

resource cse 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  name: '${vmname}/cse'
  location: location
  dependsOn:[
    VM
  ]
   properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1' 
    autoUpgradeMinorVersion: false
    settings: {}
    protectedSettings: {
      fileUris: [
        '${githubPath}cse.sh'
      ]
      commandToExecute: 'sh cse.sh'
    }
    
   }
}

output onpremPip string = deployPIP ? pip.properties.dnsSettings.fqdn : ''
output onpremIP string =  deployPIP ? pip.properties.ipAddress : ''
