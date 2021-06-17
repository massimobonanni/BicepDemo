
param keyVaultName string 
@secure()
param sqlAdminPassword string

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: resourceGroup().location
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
    value : sqlAdminPassword
    attributes: {
      enabled: true
    }
  }
}

