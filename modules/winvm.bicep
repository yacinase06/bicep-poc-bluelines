@secure()
@description('Size of the virtual machine.')
param vmSize string 

@description('location for all resources')
param location string = resourceGroup().location

param adminusername string
param keyvault_name string 
param vmname string
param subnetRef string
param adminPassword string = '${uniqueString(resourceGroup().id)}aA1!' // aA1! to meet complexity requirements
param domainName string = 'contoso.local' // this has a default so that module calls do not need to supply a domain name when deployDC is set to false, as to-do-so is misleading.
param deployDC bool
param githubPath string

var storageAccountName = '${uniqueString(resourceGroup().id)}${vmname}sa'
var nicName = '${vmname}nic'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource nInter 'Microsoft.Network/networkInterfaces@2021-02-01' = {
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

resource VM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
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
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [                  
        {
          diskSizeGB: 20
          lun: 0
          createOption: 'Empty'
        }
      ] 
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

// Will need to take a look at https://github.com/dsccommunity/DnsServerDsc to add DNS conditional forwarder through DSC
// More info on DSC extension with ARM templates - https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
resource cse 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = if (deployDC) {
  parent: VM
  name: 'CreateADForest'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: uri(githubPath, 'CreateADPDC.zip')
      ConfigurationFunction: 'CreateADPDC.ps1\\CreateADPDC'
      Properties: {
        DomainName: domainName
        AdminCreds: {
          UserName: adminusername
          Password: 'PrivateSettingsRef:AdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        AdminPassword: adminPassword
      } 
    }
  }
}
