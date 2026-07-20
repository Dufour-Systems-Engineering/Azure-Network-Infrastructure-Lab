@description('Specified the shared gallery image unique id for vm deployment. This can be fetched from shared gallery image GET call.')
param sharedGalleryImageId string = '/subscriptions/<subscription-id>/resourceGroups/TestGroup1/providers/Microsoft.Compute/galleries/BatchTestGallery2/images/BatchTestImage2/versions/1.0.0'

@description('Admin username for the VM')
param adminUserName string = '<admin-username>'

@secure()
@description('Admin password for the VM')
param adminPassword string

@description('The ID of the subnet where the WireGuard VM will be deployed.')
param BatchWireGuardSN1 string

@description('SSH public key for the VM. This is used for secure access to the virtual machine.')
param sshPublicKey string 

@description('Deployment location')
param location string = resourceGroup().location

@description('Name of the virtual machine to be created.')
param virtualMachines_BatchWireGuardVM1_name string = 'BatchWireGuardVM1'

@description('Name of the network interface to be created for the virtual machine.')
param networkInterfaceName string = 'BatchWireGuardVM1-nic'


// Public IP Address for the WireGuard VM
resource publicIPAddressResource 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: 'BatchWireGuardVM1-ip'
  location: location
  sku: {
      name: 'Standard'
      tier: 'Regional'
  }
  properties: {  
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: 'batchwireguardvm1'
    }
  }
}

// Network Interface for the WireGuard VM
resource networkInterfaceResource 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.10.0.40'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIPAddressResource.id
          }
          subnet: {
            id: BatchWireGuardSN1
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: true
    disableTcpStateTracking: false
  }
}

// Virtual Machine for WireGuard
resource virtualMachines_BatchWireGuardVM1_name_resource 'Microsoft.Compute/virtualMachines@2025-11-01' = {
  name: virtualMachines_BatchWireGuardVM1_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        id: sharedGalleryImageId
      }
      osDisk: {
        osType: 'Linux'
        name: 'BatchWireGuardVM1-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: 'BatchWireGuardVM1'
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUserName}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    securityProfile: {
      securityType: 'Standard'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceResource.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}
