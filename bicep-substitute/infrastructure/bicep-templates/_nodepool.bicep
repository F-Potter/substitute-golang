targetScope = 'resourceGroup'

param clusterName string
param subnetId string
param poolVmSize string
param poolOsSizeGb int
param poolOsType string
param poolMinCount int
param poolMaxCount int
param poolName string

resource cluster 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
  name: clusterName
}

resource test 'Microsoft.ContainerService/managedClusters/agentPools@2022-04-01' = {
  parent: cluster
  name: poolName
  properties: {
    vmSize: poolVmSize
    count: poolMinCount
    minCount: poolMinCount
    maxCount: poolMaxCount
    osDiskSizeGB: poolOsSizeGb
    osDiskType: 'Ephemeral'
    vnetSubnetID: subnetId
    osType: poolOsType
    enableAutoScaling: true
    type: 'VirtualMachineScaleSets'
    mode: 'User'
    orchestratorVersion: null
  }
}

