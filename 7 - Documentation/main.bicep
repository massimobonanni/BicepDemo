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
    environmentType: environmentType
    storageAccountId:dataLayer.outputs.storageAccountId
    appInsightInstrumentationKey: (environmentType == 'prod') ? monitoringLayer.outputs.frontEndPpInsightKey : ''
    sqlConnectionString : dataLayer.outputs.sqlConnectionString
  }
}

module dataLayer 'modules/dataLayer.bicep' = {
  name: 'dataLayer'
  params: {
    location: location
    environmentType: environmentType 
    sqlAdminPwd : sqlAdminPwd
    sqlAdminUser: sqlAdminUser
  }
}

module monitoringLayer 'modules/monitoringLayer.bicep' = {
  name: 'monitoringLayer'
  params: {
    location: location
    environmentType: environmentType 
  }
}

output appServiceAppHostName string =  frontEndLayer.outputs.appServiceAppHostName
