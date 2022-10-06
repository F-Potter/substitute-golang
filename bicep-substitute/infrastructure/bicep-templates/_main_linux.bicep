targetScope = 'subscription'

// environment
@allowed([
  'substitute'
])
param environmentName string

// location
@allowed([
  'westeurope'
  'northeurope'
])
param location string

param resourceGroupName string
param defaultSubnetId string

param clusterName string
param kubernetesVersion string
param networkPlugin string

param systemPoolMinCount int
param systemPoolMaxCount int

param autoScalerProfileUnneededTime string

// tags object needs to be a param, because utcNow() can't be used as variable
param tags object = {
  creationDateUTC: utcNow('yyyy-MM-dd HH:mm:ss')
  createdBy: 'Frank'
}

var managedIdentityName = 'id-${clusterName}'
var acrName = 'AgentsTas'
var acrRepoSubscriptionId = '0cea37a3-6bdc-43cb-be5f-e6d390b05a3c' // sub-prd-eu-tas
var acrRepoResourceGroup = 'reg-tas-containerRegistry'
var resourceGroupCreatedByAKS = '${resourceGroupName}-MC'
var networkPolicy = 'calico'

// resourcegroup
resource clusterResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// managed identity
module clusterManagedIdentityModule './UserAssignedManagedIdentity.bicep' = {
  name: 'managedIdentityDeployment'
  scope: clusterResourceGroup
  params: {
    location: location
    managedIdentityName: managedIdentityName
  }
}

// create cluster
module aksClusterModule './kubernetes.bicep' = {
  name: 'clusterDeployment'
  scope: clusterResourceGroup
  dependsOn: [
    clusterManagedIdentityModule
  ]
  params:{
    location: location
    clusterName: clusterName
    tags: tags
    kubernetesVersion: kubernetesVersion
    networkPolicy: networkPolicy
    networkPlugin: networkPlugin
    subnetId: defaultSubnetId
    logAnalyticsWorkspaceResourceID: '/subscriptions/4b077329-ea41-4ab7-a8d3-460431da91f4/resourceGroups/DefaultResourceGroup-WEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-4b077329-ea41-4ab7-a8d3-460431da91f4-WEU'
    managedIdentityId: clusterManagedIdentityModule.outputs.managedIdentityResourceId
    resourceGroupName: resourceGroupName
    systemPoolMinCount: systemPoolMinCount
    systemPoolMaxCount: systemPoolMaxCount
    autoScalerProfileUnneededTime: autoScalerProfileUnneededTime
  }
}

// Azure CNI doesn't automatically create a route table
module createRouteTableModule './routeTable.bicep' =  if (networkPlugin == 'azure'){
  name: 'routeTableDeployment'
  scope: resourceGroup(resourceGroupCreatedByAKS)
  dependsOn: [
    aksClusterModule
  ]
  params: {
    environmentName: environmentName
    location: location
  }
}

// grant network contributor access for AKS managed identity so it can modify the route table
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7' // Network Contributor
module roleAssignmentModule './assignRole.bicep' = {
  name: 'assignRole-AKS-networkcontributor-vnet'
  scope: resourceGroup(resourceGroupCreatedByAKS)
  dependsOn: [
    clusterManagedIdentityModule
    aksClusterModule
  ]
  params: {
    managedIdentityPrincipalId: clusterManagedIdentityModule.outputs.managedIdentityPrincipalId
    roleId: networkContributorRoleId
    roleName: 'Network Contributor'
  }
}

// grant ACR-pull rights to cluster principal managed identity so that images can be pulled
module attachACR './attachACR.bicep' = {
  name: 'attachACR'
  scope: resourceGroup(acrRepoSubscriptionId, acrRepoResourceGroup)
  dependsOn: [
    aksClusterModule
  ]
  params: {
     acrName: acrName
     aksPrincipalId: aksClusterModule.outputs.PrincipalIdFromAKS
  }
}
