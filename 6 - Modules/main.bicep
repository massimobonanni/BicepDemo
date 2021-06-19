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

@secure()
param sqlAdminPwd string

module frontEndLayer 'modules/frontEndLayer.bicep' = {
  name: 'frontEndLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType
    storageAccountId:dataLayer.outputs.storageAccountId
    appInsightInstrumentationKey: (environmentType == 'prod') ? monitoringLayer.outputs.frontEndInsightKey : ''
    sqlConnectionString : dataLayer.outputs.sqlConnectionString
  }
}

module dataLayer 'modules/dataLayer.bicep' = {
  name: 'dataLayer'
  params: {
    location: location
    environmentName: environmentName
    environmentType: environmentType 
    sqlAdminPwd : sqlAdminPwd
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
