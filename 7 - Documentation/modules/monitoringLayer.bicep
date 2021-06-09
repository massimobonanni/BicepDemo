@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

param location string = resourceGroup().location

var frontEndAppInsightName = 'BicepFrontEnd${environmentType}-AI'

resource frontEndAppInsight 'Microsoft.Insights/components@2015-05-01' = if (environmentType == 'prod') {
  name: frontEndAppInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output frontEndPpInsightKey string = (environmentType == 'prod') ? frontEndAppInsight.properties.InstrumentationKey : ''
