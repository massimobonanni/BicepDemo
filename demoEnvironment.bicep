targetScope = 'subscription'

param resourceGroupName string
param keyVaultName string
@secure()
param sqlAdminPassword string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: deployment().location
}

module keyVaultsModule 'keyVault.bicep' = {
  scope: resourceGroup
  name: 'keyVault'
  params: {
    keyVaultName:keyVaultName
    sqlAdminPassword:sqlAdminPassword
  }
}
