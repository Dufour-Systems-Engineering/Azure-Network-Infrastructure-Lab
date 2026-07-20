@description('The name of the virtual network to create.')
param virtualNetworks_BatchTestVNet1_name string = 'BatchTestVNet1'

@description('The name of the network security group for the client subnet.')
param networkSecurityGroups_BatchClientNSG1_name string = 'BatchClientNSG1'

@description('The name of the network security group for the WireGuard subnet.')
param networkSecurityGroups_BatchWireGuardNSG1_name string = 'BatchWireGuardNSG1'

resource virtualNetworks_BatchTestVNet1_name_resource 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: virtualNetworks_BatchTestVNet1_name
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'BatchClientSN1'
        properties: {
          addressPrefix: '10.10.0.0/28'
          networkSecurityGroup: {
            id: networkSecurityGroups_BatchClientNSG1_name_resource.id
          }
        }
      }
      {
        name: 'BatchWireGuardSN1'
        properties: {
          addressPrefix: '10.10.0.32/28'
          networkSecurityGroup: {
            id: networkSecurityGroups_BatchWireGuardNSG1_name_resource.id
          }
          delegations: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_BatchClientNSG1_name_resource 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: networkSecurityGroups_BatchClientNSG1_name
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH_from-Vnet'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-ICMP_from-Vnet'
        properties: {
          protocol: 'Icmp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}
resource networkSecurityGroups_BatchWireGuardNSG1_name_resource 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: networkSecurityGroups_BatchWireGuardNSG1_name
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
         name: 'Allow-wireguard-vpn-tunnel-access'
        properties: {
          protocol: 'UDP'
          sourcePortRange: '*'
          destinationPortRange: '51820'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1002
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-SSH-MyIP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '<trusted-public-ip>'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}
output clientSubnetId string = virtualNetworks_BatchTestVNet1_name_resource.properties.subnets[0].id
output wireGuardSubnetId string = virtualNetworks_BatchTestVNet1_name_resource.properties.subnets[1].id
