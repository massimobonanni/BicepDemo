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
var frontEndAppInsightName = 'BicepFrontEnd${environmentType}-AI'
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

var appPlanSku = {
  name: (environmentType == 'prod') ? 'P1' : 'F1'
  tier: (environmentType == 'prod') ? 'Premium' : 'Free'
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
      'APPINSIGHTS_INSTRUMENTATIONKEY':(environmentType == 'prod') ? frontEndAppInsight.properties.InstrumentationKey:''
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
}

resource frontEndAppInsight 'Microsoft.Insights/components@2015-05-01' = if (environmentType == 'prod') {
  name: frontEndAppInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output appServiceAppHostName string = frontEndAppService.properties.defaultHostName
