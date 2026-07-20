@description('Specified the shared gallery image unique id for vm deployment. This can be fetched from shared gallery image GET call.')
param sharedGalleryImageId string = '/subscriptions/<subscription-id>/resourceGroups/TestGroup1/providers/Microsoft.Compute/galleries/BatchTestGallery2/images/BatchTestImage2/versions/1.0.0'

@description('Admin username for the VM')
param adminUserName string = '<admin-username>'

@description('The ID of the client subnet where the Client VMs will be deployed.') 
param clientSubnetId string

@secure()
@description('Admin password for the VM')
param adminPassword string

@description('Deployment location')
param location string = resourceGroup().location

param sshPublicKey string

@description('List of client VM names, NIC names, and private IPs to be created in the client subnet.')
param clientVMs array = [
  {vmName: 'BatchTestClientVM1', nicName: 'BatchTestClientVM1-nic', privateIP: '10.10.0.5'}
  {vmName: 'BatchTestClientVM2', nicName: 'BatchTestClientVM2-nic', privateIP: '10.10.0.6'}
  {vmName: 'BatchTestClientVM3', nicName: 'BatchTestClientVM3-nic', privateIP: '10.10.0.7'}
  {vmName: 'BatchTestClientVM4', nicName: 'BatchTestClientVM4-nic', privateIP: '10.10.0.8'}
  {vmName: 'BatchTestClientVM5', nicName: 'BatchTestClientVM5-nic', privateIP: '10.10.0.9'}
  {vmName: 'BatchTestClientVM6', nicName: 'BatchTestClientVM6-nic', privateIP: '10.10.0.10'}
]

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = [for vm in clientVMs: {
  name: '${vm.nicName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vm.privateIP
          subnet: {
            id: clientSubnetId
          }
        }
      }
    ]
  }
}]
resource virtualMachines 'Microsoft.Compute/virtualMachines@2025-11-01' = [for (vm, i) in clientVMs: {
  name: '${vm.vmName}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        id: sharedGalleryImageId
      }
      osDisk: {
        osType: 'Linux'
        name: '${vm.vmName}-osdisk'
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
      computerName: '${vm.vmName}'
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
          id: nic[i].id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}
]
