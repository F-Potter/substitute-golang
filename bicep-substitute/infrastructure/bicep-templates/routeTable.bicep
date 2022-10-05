param environmentName string
param location string

resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'aks-agentpool-k8s-${environmentName}-routetable'
  location: location
}
