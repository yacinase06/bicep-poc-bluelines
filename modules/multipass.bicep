param secretName string
param secretLen int

module passgen '../modules/passgen.bicep' = {
  name: secretName
  params: {
    secretName: secretName
    secretLen : secretLen
  }
}

output pwd string = passgen.outputs.secretVal
