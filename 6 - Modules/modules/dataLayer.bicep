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

var storageAccountName = toLower('${environmentName}${environmentType}${uniqueString(resourceGroup().id,environmentName)}')
var sqlServerName = toLower('${environmentName}-${environmentType}-sql')
var sqlDbName = toLower('${environmentName}-${environmentType}-db')

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

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

output storageAccountId string = storageAccount.id
output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Database=${sqlDbName};User Id=${sqlAdminUser};Password=${sqlAdminPwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
