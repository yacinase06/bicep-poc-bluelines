param secretName string

module passgen '../modules/passgen.bicep' = {
  name: secretName
  params: {
    secretName: secretName
  }
}

output pwd string = passgen.outputs.secretVal
