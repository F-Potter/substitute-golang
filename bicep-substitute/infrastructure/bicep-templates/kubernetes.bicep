param location string
param clusterName string
param tags object
param subnetId string
param kubernetesVersion string
param networkPolicy string
param networkPlugin string
param logAnalyticsWorkspaceResourceID string
param managedIdentityId string
param resourceGroupName string
param systemPoolMinCount int
param systemPoolMaxCount int
param autoScalerProfileUnneededTime string

var systemPool = {
  name: 'linuxsyspool'
  vmSize: 'Standard_DS2_v2'
  count: systemPoolMinCount
  minCount: systemPoolMinCount
  maxCount: systemPoolMaxCount
  osDiskSizeGB: 50
  osDiskType: 'Ephemeral'
  availabilityZones: [
    '1'
    '2'
    '3'
  ]
  vnetSubnetID: subnetId
  osType: 'Linux'
  enableAutoScaling: true
  type: 'VirtualMachineScaleSets'
  mode: 'System'
  orchestratorVersion: null
//  nodeTaints: [
//    'CriticalAddonsOnly=true:NoSchedule'
//  ]
}

// Managed Cluster (AKS) creates two resource groups for more information see
// https://docs.microsoft.com/en-us/azure/aks/faq#why-are-two-resource-groups-created-with-aks
// https://docs.microsoft.com/en-us/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group
resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: 'dnsprefix'
    enableRBAC: true
    agentPoolProfiles: [
      systemPool
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
      networkPolicy: networkPolicy
    }
    addonProfiles: {
      azurepolicy: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
        }
      }
    }
    autoScalerProfile: {
      'scale-down-unneeded-time': autoScalerProfileUnneededTime
    }
    nodeResourceGroup: '${resourceGroupName}-MC'
  }
}

output PrincipalIdFromAKS string = reference('Microsoft.ContainerService/managedClusters/${clusterName}', '2022-04-01').identityProfile.kubeletidentity.objectId
