param vnetName string
param subnetName string
param subnetIPRange string
resource vnetResource 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: subnetName
  parent: vnetResource
  properties: {
    addressPrefix: subnetIPRange
  }
}

output subnetId string = subnet.id
