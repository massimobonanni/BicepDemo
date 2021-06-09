@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

param location string = resourceGroup().location

var frontEndAppName = 'BicepFrontEnd${environmentType}'
var frontEndAppPlanName = 'BicepFrontEndPlan${environmentType}'
var storageAccountName = 'fe${environmentType}${uniqueString(resourceGroup().id)}'

var storageAccountSkuName ='Standard_GRS'

var appPlanSku = {
  name:'F1'
  tier:'Free'
}

resource frontEndAppService 'Microsoft.Web/sites@2021-01-01' = {
  name: frontEndAppName
  location: location
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: frontEndAppServicePlan.id
  }

  resource appServiceConfiguration 'config'={
    name : 'appsettings'
    properties:{
      'StorageAccountKey' : listKeys(storageAccount.id,'2019-04-01').keys[0].value
    }
 }
}

resource frontEndAppServicePlan 'Microsoft.Web/serverfarms@2021-01-01'={
  name : frontEndAppPlanName
  location: location
  sku : appPlanSku
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  tags:{
    'Demo':'Bicep'
  }
}
