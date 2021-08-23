param secretLen int
param sourceName string

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueString('stg', resourceGroup().name)
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
resource dScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${sourceName}dScript'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.0'
    retentionInterval: 'PT1H'
    storageAccountSettings:{
      storageAccountName: stg.name
      storageAccountKey: stg.listKeys().keys[0].value
    }
    scriptContent: loadTextContent('../scripts/passgen.sh')
    arguments: '${secretLen}'
  }
}

output secretVal string = dScript.properties.outputs.secretVal
