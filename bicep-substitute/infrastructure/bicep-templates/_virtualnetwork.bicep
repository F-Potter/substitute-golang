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

param resourceGroupOfSubnet string
param vnetName string
param vnetIPRange string
param subnetIPRangeLinux string

// tags object needs to be a param, because utcNow() can't be used as variable
param tags object = {
  creationDateUTC: utcNow('yyyy-MM-dd HH:mm:ss')
  createdBy: 'Frank'
}

// resourcegroup
resource vnetResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupOfSubnet
}

// create vnet and subnets
module vnetModule './vnet.bicep' = {
  name: 'vnetDeployment-${environmentName}'
  scope: vnetResourceGroup
  params:{
    location: location
    vnetName: vnetName
    vnetIPRange: vnetIPRange
    subnetIPRangeLinux: subnetIPRangeLinux
    tags: tags
    environmentName: environmentName
  }
}
