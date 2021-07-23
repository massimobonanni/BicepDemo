// --------------
// - Parameters -
// --------------
@minLength(3)
@maxLength(6)
@description('The name of the environment. You can use a string from 3 to 6 character lenght.')
param environmentName string

@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment type. Choose one of the dev, test or prod value.')
param environmentType string

@description('Location for the environment')
param location string = resourceGroup().location

@description('Username for the SQL admin')
param sqlAdminUser string

@description('Name of the Key vault contains the SQL admin password')
param keyVaultName string

// -------------
// - Resources -
// -------------
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = { // The keyvault must exist in the same resource group
  name: keyVaultName
}

// -----------
// - Modules -
// -----------
module frontEndLayer 'modules/frontEndLayer.bicep' = {
  name: 'frontEndLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType
    storageAccountId:dataLayer.outputs.storageAccountId
    appInsightInstrumentationKey: (environmentType == 'prod') ? monitoringLayer.outputs.frontEndInsightKey : ''
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

// -----------
// - Outputs -
// -----------
output appServiceAppHostName string =  frontEndLayer.outputs.appServiceAppHostName
