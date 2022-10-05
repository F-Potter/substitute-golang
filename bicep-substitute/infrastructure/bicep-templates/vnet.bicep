param location string
param vnetName string
param vnetIPRange string
param subnetIPRangeLinux string
param tags object
param environmentName string

var vnetNameCloudOnly = (contains(environmentName, 'cloudonly')) ? vnetName : 'unusedVnetDeployment'
var vnetNameDefault = (!contains(environmentName, 'cloudonly')) ? vnetName : 'unusedVnetDeployment'

resource virtualNetworkCloudOnly 'Microsoft.Network/virtualNetworks@2021-05-01' = if (contains(environmentName, 'cloudonly')) {
  name: vnetNameCloudOnly
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPRange
      ]
    }
    subnets: [
      {
        name: 'snet-mixed'
        properties: {
          addressPrefix: vnetIPRange
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = if (!contains(environmentName, 'cloudonly')) {
  name: vnetNameDefault
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPRange
      ]
    }
    subnets: [
      {
        name: 'snet-linux'
        properties: {
          addressPrefix: subnetIPRangeLinux
        }
      }
    ]
  }
}

// this will be snet-mixed for cloud only and snet-linux for non-cloudonly
output defaultSubnetId string = (contains(environmentName, 'cloudonly')) ? virtualNetworkCloudOnly.properties.subnets[0].id : virtualNetwork.properties.subnets[0].id

// linux subnet values set to string.empty for cloudonly deployments
// otherwise subnet id will be returned
output linuxSubnetId string = (contains(environmentName, 'cloudonly')) ? '' : virtualNetwork.properties.subnets[0].id
