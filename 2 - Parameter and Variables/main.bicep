@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

param location string = resourceGroup().location

var frontEndAppName = 'BicepFrontEnd${environmentType}'
var frontEndAppPlanName = 'BicepFrontEndPlan${environmentType}'

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
}

resource frontEndAppServicePlan 'Microsoft.Web/serverfarms@2021-01-01'={
  name : frontEndAppPlanName
  location: location
  sku : appPlanSku
}
