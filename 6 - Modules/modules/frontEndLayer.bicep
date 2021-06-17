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
param sqlConnectionString string

var frontEndAppName = toLower('${environmentName}-fe-${environmentType}-app')
var frontEndAppPlanName = toLower('${environmentName}-fe-${environmentType}-plan')

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
      'StorageAccountKey' : listKeys(storageAccountId,'2019-04-01').keys[0].value
      'APPINSIGHTS_INSTRUMENTATIONKEY':(environmentType == 'prod') ? appInsightInstrumentationKey : ''
    }
  }

  resource connectionStrings 'config'={
    name : 'connectionstrings'
    properties:{
      'SqlConnectionString' : {
        type : 'SQLAzure'
        value : sqlConnectionString
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
