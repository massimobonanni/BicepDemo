@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

param location string = resourceGroup().location

module frontEndLayer 'modules/frontEndLayer.bicep' = {
  name: 'frontEndLayer'
  params: {
    location: location
    environmentType: environmentType
    storageAccountId:dataLayer.outputs.storageAccountId
    appInsightInstrumentationKey: (environmentType == 'prod') ? monitoringLayer.outputs.frontEndPpInsightKey : ''
  }
}

module dataLayer 'modules/dataLayer.bicep' = {
  name: 'dataLayer'
  params: {
    location: location
    environmentType: environmentType 
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
