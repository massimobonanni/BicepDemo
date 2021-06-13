@minLength(3)
@maxLength(6)
param environmentName string

@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string
param location string = resourceGroup().location
param storageAccountId string
param appInsightInstrumentationKey string
param keyVaultName string
param sqlConnectionStringSecret string

var frontEndAppName = '${environmentName}-fe-${environmentType}-app'
var frontEndAppPlanName = '${environmentName}-fe-${environmentType}-plan'

var appPlanSku = {
  name: (environmentType == 'prod') ? 'P1' : 'F1'
  tier: (environmentType == 'prod') ? 'Premium' : 'Free'
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource appServiceKeyVaultAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('Key Vault Secret User', frontEndAppName, subscription().subscriptionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: frontEndAppService.identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    keyVault
  ]
}

resource frontEndAppService 'Microsoft.Web/sites@2021-01-01' = {
  name: frontEndAppName
  location: location
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: frontEndAppServicePlan.id
  }
  identity:{
    type: 'SystemAssigned'
  }
  resource appServiceConfiguration 'config'={
    name : 'appsettings'
    properties:{
      'StorageAccountKey' : listKeys(storageAccountId,'2019-04-01').keys[0].value
      'APPINSIGHTS_INSTRUMENTATIONKEY':(environmentType == 'prod') ? appInsightInstrumentationKey : ''
    }
  }

  resource connectionStrings 'config'={
    name : 'connectionstrings'
    properties:{
      'SqlConnectionString' : {
        type : 'SQLAzure'
        value : '@Microsoft.KeyVault(SecretUri=${sqlConnectionStringSecret})'
      } 
    }
  }
}

resource frontEndAppServicePlan 'Microsoft.Web/serverfarms@2021-01-01'={
  name : frontEndAppPlanName
  location: location
  sku : appPlanSku
}

output appServiceAppHostName string = frontEndAppService.properties.defaultHostName
