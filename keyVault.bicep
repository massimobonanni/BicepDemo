param keyVaultName string 

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: 'northeurope'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
  }
}

resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value : 'Password1234'
    attributes: {
      enabled: true
    }
  }
}

resource sqlAdminUserSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  parent: keyVault
  name: 'sqlAdminUser'
  properties: {
    value : 'azureuser'
    attributes: {
      enabled: true
    }
  }
}
