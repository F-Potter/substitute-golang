param location string
param managedIdentityName string

resource UserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

@description('The resource ID of the user-assigned managed identity.')
output managedIdentityResourceId string = UserAssignedManagedIdentity.id

@description('The ID of the Azure AD application associated with the managed identity.')
output managedIdentityClientId string = UserAssignedManagedIdentity.properties.clientId

@description('The ID of the Azure AD service principal associated with the managed identity.')
output managedIdentityPrincipalId string = UserAssignedManagedIdentity.properties.principalId
