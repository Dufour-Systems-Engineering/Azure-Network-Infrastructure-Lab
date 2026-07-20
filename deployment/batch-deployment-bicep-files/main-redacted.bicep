targetScope = 'resourceGroup'

@description('The name of the virtual network to create.')
param virtualNetworks_BatchTestVNet1_name string = 'BatchTestVNet1'

@description('The name of the network security group for the client subnet.')
param networkSecurityGroups_BatchClientNSG1_name string = 'BatchClientNSG1'

@description('The name of the network security group for the WireGuard subnet.')
param networkSecurityGroups_BatchWireGuardNSG1_name string = 'BatchWireGuardNSG1'

@description('Deployment location')
param location string = resourceGroup().location

@description('Admin username for the Client VMs')
param adminUserName string = '<admin-username>'

@secure()
@description('Admin password for the Client VMs')
param adminPassword string

@description('SSH public key for all VMs. This is used for secure access to all virtual machines.')
param sshPublicKey string

// Adjusted module path in case module is organized under a subfolder
module networkModule '../modules/network-module.bicep' = {
  name: 'networkModuleDeployment'
  params: {
    virtualNetworks_BatchTestVNet1_name: virtualNetworks_BatchTestVNet1_name
    networkSecurityGroups_BatchClientNSG1_name: networkSecurityGroups_BatchClientNSG1_name
    networkSecurityGroups_BatchWireGuardNSG1_name: networkSecurityGroups_BatchWireGuardNSG1_name
  }
}

module vmBatchDeployment '../modules/vm-batch-deployment.bicep' = {
  name: 'vmBatchDeployment'
  params: {
    adminUserName: adminUserName
    adminPassword: adminPassword
    clientSubnetId: networkModule.outputs.clientSubnetId
    location: location
    sshPublicKey: sshPublicKey
  }
}

module wireguardVMModule '../modules/wireguard-vm-module.bicep' = {
  name: 'wireguardVMModuleDeployment'
  params: {
    adminUserName: adminUserName
    adminPassword: adminPassword
    BatchWireGuardSN1: networkModule.outputs.wireGuardSubnetId
    location: location
    sshPublicKey: sshPublicKey
  }
}
