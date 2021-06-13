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

var frontEndAppName = '${environmentName}-fe-${environmentType}-app'
var frontEndAppPlanName = '${environmentName}-fe-${environmentType}-plan'
var storageAccountName = '${environmentName}${environmentType}${uniqueString(resourceGroup().id,environmentName)}'
var sqlServerName = '${environmentName}-${environmentType}-sql'
var sqlDbName = '${environmentName}-${environmentType}-db'

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
  tags:{
    'Demo':'Bicep'
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

output appServiceAppHostName string = frontEndAppService.properties.defaultHostName
