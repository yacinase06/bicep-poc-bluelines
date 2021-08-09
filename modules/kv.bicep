param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param keyvaultname string = '${resourceGroup().name}-${uniqueString(resourceGroup().id)}' // to help create globally unique string for the Keyvault
// param secretName string = 'testsecret'
param adUserId string

//@secure()
//param secretValue string = '${uniqueString(keyvaultname)}'

resource keyvaultname_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultname
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableSoftDelete: false
    accessPolicies: [
      {
        objectId: adUserId
        tenantId: tenantId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
        }
      }
    ]
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

/* resource keyvaultname_secretName 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvaultname_resource.name}/${secretName}'
  properties: {
    contentType: 'securestring'
    value: secretValue
    attributes: {
      enabled: true
    }
  }
} */

output keyvaultid string = keyvaultname_resource.id
output keyvaultname string = keyvaultname_resource.name
