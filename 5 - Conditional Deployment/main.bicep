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

var frontEndAppName = 'BicepFrontEnd${environmentType}'
var frontEndAppPlanName = 'BicepFrontEndPlan${environmentType}'
var storageAccountName = 'fe${environmentType}${uniqueString(resourceGroup().id)}'
var frontEndAppInsightName = 'BicepFrontEnd${environmentType}-AI'
var sqlServerName = 'sql${environmentType}${uniqueString(resourceGroup().id)}'
var sqlDbName = 'db${environmentType}${uniqueString(resourceGroup().id)}'
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

  resource connectionStrings 'config'={
    name : 'connectionstrings'
    properties:{
      'SqlConnectionString' : {
        type : 'SQLAzure'
        value : 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Database=${sqlDbName};User Id=${sqlAdminUser};Password=${sqlAdminPwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      } 
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

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location:location
  properties:{
    administratorLogin: sqlAdminUser
    administratorLoginPassword:sqlAdminPwd
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: sqlDbName
  location: location
  parent: sqlServer
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
