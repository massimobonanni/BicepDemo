
resource frontEndAppService 'Microsoft.Web/sites@2021-01-01' = {
  name: 'BicepFrontEndDev'
  location: 'northeurope'
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: frontEndAppServicePlan.id
  }
}

resource frontEndAppServicePlan 'Microsoft.Web/serverfarms@2021-01-01'={
  name:'BicepFrontEndPlanDev'
  location:'northeurope'
  sku:{
    name:'F1'
    tier:'Free'
  }
}
