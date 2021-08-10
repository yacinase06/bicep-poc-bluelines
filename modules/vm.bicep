param adminusername string
param keyvault_name string 
param vmname string
param subnetRef string
param githubPath string
@secure()
param adminPassword string = '${uniqueString(resourceGroup().id)}aA1!' // aA1! to meet complexity requirements

@description('Size of the virtual machine.')
param vmSize string 

@description('location for all resources')
param location string = resourceGroup().location

var storageAccountName = '${uniqueString(resourceGroup().id)}${vmname}sa'
var nicName = '${vmname}nic'

//param publicIPAddressNameSuffix string

// var dnsLabelPrefix = 'dns-${uniqueString(resourceGroup().id)}-${publicIPAddressNameSuffix}'

/*resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressNameSuffix
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
} */

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}


resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
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

        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    /*  dataDisks: [                  // Uncomment to add data disk
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ] */
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nInter.id
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
  parent: VM
  name: 'Ext'
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

// output dockerhostfqdn string = pip.properties.dnsSettings.fqdn

