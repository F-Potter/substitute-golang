param managedIdentityPrincipalId string
param roleId string
param roleName string

resource AssignContributorToAksMi 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id, managedIdentityPrincipalId, roleName)       // want consistent GUID on each run
  properties: {
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }
}
