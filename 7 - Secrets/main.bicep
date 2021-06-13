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
param sqlAdminUser string

param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

module frontEndLayer 'modules/frontEndLayer.bicep' = {
  name: 'frontEndLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType
    storageAccountId:dataLayer.outputs.storageAccountId
    appInsightInstrumentationKey: (environmentType == 'prod') ? monitoringLayer.outputs.frontEndPpInsightKey : ''
    keyVaultName: keyVaultName
    sqlConnectionStringSecret : dataLayer.outputs.sqlConnectionStringSecretUri
  }
}

module dataLayer 'modules/dataLayer.bicep' = {
  name: 'dataLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType
    keyVaultName: keyVaultName
    sqlAdminPwd : keyVault.getSecret('sqlAdminPassword')
    sqlAdminUser: sqlAdminUser
  }
}

module monitoringLayer 'modules/monitoringLayer.bicep' = {
  name: 'monitoringLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType 
  }
}

output appServiceAppHostName string =  frontEndLayer.outputs.appServiceAppHostName
