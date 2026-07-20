#  Phase 2 Batch Deployment — Client VM Module

## Overview

Phase 2 extended the Batch Deployment RD Bicep project by adding a reusable client virtual machine deployment module to the network foundation completed in Phase 1. The parent deployment created the virtual network, subnets, and Network Security Groups first, then passed the client subnet resource ID to a downstream module that deployed six Linux client virtual machines with static private IP addresses.

The deployment used an Azure Compute Gallery image version as the operating system source and validated the complete parent-child module chain through Azure CLI validation, what-if analysis, deployment, portal review, command-line inventory, and resource cleanup.

This document represents the Phase 2 endpoint. Later additions, including the WireGuard VM module and SSH public-key configuration, are outside the scope of this phase and are not presented as part of the Phase 2 implementation.

## Purpose

The purpose of Phase 2 was to establish a repeatable Bicep pattern for deploying a small Linux client fleet without duplicating individual VM resource blocks.

The implementation was designed to:

- Extend the Phase 1 network module through module chaining.
- Deploy six Linux client VMs from a common Azure Compute Gallery image.
- Assign predictable static private IP addresses to the client fleet.
- Create one network interface for each VM through a Bicep loop.
- Preserve a secure runtime parameter for the administrative password.
- Associate VM creation with the client subnet output instead of hardcoding a subnet resource ID in the parent deployment.
- Configure VM-associated NICs and operating system disks for deletion with their parent VMs.
- Validate the deployment through both Azure CLI and Azure portal evidence.
- Establish a troubleshooting record for failures encountered during module development.

## Prerequisites

The following resources and tools were required before Phase 2 deployment work began:

- Azure subscription access with permission to create Compute, Network, and Resource Manager deployment resources.
- Resource group `BatchTestResGroup2` in `centralus`.
- Azure CLI installed and authenticated on the administrator workstation.
- PowerShell available for variable handling and session capture.
- Bicep support available through Azure CLI and Visual Studio Code.
- Phase 1 network module capable of creating the VNet, subnets, and NSGs.
- Sufficient regional VM quota for six `Standard_B1s` virtual machines.
- Azure Compute Gallery image version replicated to Central US.
- A runtime administrative password that satisfies Azure VM password requirements.

The inherited Phase 1 network design was:

| Resource | Configuration |
| --- | --- |
| Resource group | `BatchTestResGroup2` |
| Deployment region | `centralus` |
| Virtual network | `BatchTestVNet1` |
| VNet address space | `10.10.0.0/24` |
| Client subnet | `BatchClientSN1` — `10.10.0.0/28` |
| WireGuard subnet | `BatchWireGuardSN1` — `10.10.0.32/28` |
| Client NSG | `BatchClientNSG1` |
| WireGuard NSG | `BatchWireGuardNSG1` |

The Azure Compute Gallery source was:

| Setting | Value |
| --- | --- |
| Gallery | `BatchTestGallery2` |
| Image definition | `BatchTestImage2` |
| Image version | `1.0.0` |
| Source image | `Golden-Base-1.2-image-20251103141303` |
| Source resource group | `TestGroup1` |
| Operating system | Linux |
| OS state | Generalized |
| Hyper-V generation | V2 |
| Architecture | x64 |
| Target regions | West US and Central US |

## Deployment Procedure

### 1. Reset the deployment environment

Previous test resources were removed from `BatchTestResGroup2` before the module was validated again. During the reset, NSGs were detached from their subnets where required so that dependent network resources could be removed in the correct order.

Example reset commands included:

```powershell
az network vnet subnet update `
  --resource-group BatchTestResGroup2 `
  --vnet-name BatchTestVNet1 `
  --name BatchClientSN1 `
  --nsg null

az network vnet subnet update `
  --resource-group BatchTestResGroup2 `
  --vnet-name BatchTestVNet1 `
  --name BatchWireGuardSN1 `
  --nsg null
```

A PowerShell transcript was started to preserve the working session:

```powershell
Start-Transcript -Path ".phase-2-client-vm-module-session.txt"
```

The reset output also showed `ResourceNotFound` responses for resources that had already been removed. These responses were treated as confirmation of the current environment state rather than successful deletion events.

*See Evidence:* [Environment cleanup and transcript start](../../screenshots/deployment/batch-deployment-phase-two/01-environment-cleanup-and-transcript-start.png)

### 2. Confirm the managed image source

The available managed images in `TestGroup1` were reviewed before the gallery image version was prepared.

```powershell
az image list --resource-group TestGroup1
```

An earlier `az image show` attempt omitted the required image name. The inventory command was used instead to confirm the available generalized Linux image resources.

*See Evidence:* [Source managed image inventory](../../screenshots/deployment/batch-deployment-phase-two/02-source-managed-image-inventory.png)

### 3. Create the gallery image version

The selected managed image was used to create version `1.0.0` under `BatchTestGallery2` and `BatchTestImage2`.

```powershell
$sourceImageId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/TestGroup1/providers/Microsoft.Compute/images/Golden-Base-1.2-image-20251103141303"

az sig image-version create `
  --resource-group TestGroup1 `
  --gallery-name BatchTestGallery2 `
  --gallery-image-definition BatchTestImage2 `
  --gallery-image-version 1.0.0 `
  --managed-image $sourceImageId
```

The resulting image version reached a successful provisioning state.

*See Evidence:* [Gallery image version created](../../screenshots/deployment/batch-deployment-phase-two/03-gallery-image-version-created.png)

### 4. Replicate the image version to Central US

The image version initially targeted West US. Central US was added because the Phase 2 resource group and virtual machines were deployed in `centralus`.

```powershell
az sig image-version update `
  --resource-group TestGroup1 `
  --gallery-name BatchTestGallery2 `
  --gallery-image-definition BatchTestImage2 `
  --gallery-image-version 1.0.0 `
  --target-regions westus=1 centralus
```

The update output confirmed both target regions and a successful provisioning state.

*See Evidence:* [Gallery image version replicated](../../screenshots/deployment/batch-deployment-phase-two/04-gallery-image-version-replicated.png)

### 5. Refactor the exported VM template

An Azure-exported VM Bicep file was reviewed as source material. The export contained hardcoded single-VM names and generated references to external NIC, disk, and image resources. Those references did not form a reusable module and were not retained as the final implementation.

*See Evidence:* [Exported VM Bicep source](../../screenshots/deployment/batch-deployment-phase-two/05-exported-vm-bicep-source.png)

A new `vm-batch-deployment.bicep` module was created with explicit parameters and an array describing the six client VMs.

*See Evidence:* [Client VM module initial draft](../../screenshots/deployment/batch-deployment-phase-two/06-client-vm-module-initial-draft.png)

### 6. Add subnet outputs to the network module

The Phase 1 network module was updated to expose both subnet IDs as outputs. The client VM module required the client subnet output; the WireGuard output was preserved for a later phase.

```bicep
output clientSubnetId string = virtualNetworks_BatchTestVNet1_name_resource.properties.subnets[0].id
output wireGuardSubnetId string = virtualNetworks_BatchTestVNet1_name_resource.properties.subnets[1].id
```

This established an explicit module contract and removed the need to reconstruct subnet resource IDs in PowerShell.

*See Evidence:* [Network module subnet outputs](../../screenshots/deployment/batch-deployment-phase-two/07-network-module-subnet-outputs.png)

### 7. Define the client address plan

The client VM module defined six VM, NIC, and private IP combinations in a single array.

```bicep
param clientVMs array = [
  { vmName: 'BatchTestClientVM1', nicName: 'BatchTestClientVM1-nic', privateIP: '10.10.0.5' }
  { vmName: 'BatchTestClientVM2', nicName: 'BatchTestClientVM2-nic', privateIP: '10.10.0.6' }
  { vmName: 'BatchTestClientVM3', nicName: 'BatchTestClientVM3-nic', privateIP: '10.10.0.7' }
  { vmName: 'BatchTestClientVM4', nicName: 'BatchTestClientVM4-nic', privateIP: '10.10.0.8' }
  { vmName: 'BatchTestClientVM5', nicName: 'BatchTestClientVM5-nic', privateIP: '10.10.0.9' }
  { vmName: 'BatchTestClientVM6', nicName: 'BatchTestClientVM6-nic', privateIP: '10.10.0.10' }
]
```

*See Evidence:* [Client VM parameters and address plan](../../screenshots/deployment/batch-deployment-phase-two/08-client-vm-parameters-and-address-plan.png)

### 8. Implement NIC and VM loops

The module created one NIC for each array entry and assigned the configured static private IP address within `BatchClientSN1`.

The VM loop used the array index to associate each VM with the corresponding NIC resource.

*See Evidence:* [Client NIC and VM resource loops](../../screenshots/deployment/batch-deployment-phase-two/09-client-nic-and-vm-resource-loops.png)

The VM resource block configured the operating system disk, Linux profile, gallery image reference, VM size, and NIC lifecycle behavior. The initial configuration also contained `requireGuestProvisionSignal`, which was later removed after Azure rejected the property.

*See Evidence:* [Client VM resource configuration](../../screenshots/deployment/batch-deployment-phase-two/10-client-vm-resource-configuration.png)

### 9. Integrate the client module into the parent deployment

The Phase 2 parent template first called the network module.

*See Evidence:* [Parent template network module baseline](../../screenshots/deployment/batch-deployment-phase-two/11-parent-template-network-module-baseline.png)

The client module was then added with a dependency created through the network output reference:

```bicep
module vmBatchDeployment '../modules/vm-batch-deployment.bicep' = {
  name: 'vmBatchDeployment'
  params: {
    adminUserName: adminUserName
    adminPassword: adminPassword
    clientSubnetId: networkModule.outputs.clientSubnetId
    location: location
  }
}
```

Because `clientSubnetId` came from `networkModule.outputs.clientSubnetId`, Resource Manager could determine that the network deployment had to complete before the client VM module could run.

*See Evidence:* [Parent template client module integration](../../screenshots/deployment/batch-deployment-phase-two/12-parent-template-client-module-integration.png)

### 10. Correct the local template path and validate

The PowerShell session was already running from the `deployment` directory. An initial command incorrectly referenced `./deployment/main.bicep`, which resolved to a duplicate `deployment\deployment` path.

The corrected path was:

```powershell
./main.bicep
```

The gallery image version ID was also retrieved using the corrected `--resource-group` argument spelling:

```powershell
$sharedGalleryImageId = az sig image-version show `
  --resource-group TestGroup1 `
  --gallery-name BatchTestGallery2 `
  --gallery-image-definition BatchTestImage2 `
  --gallery-image-version 1.0.0 `
  --query id `
  --output tsv
```

The parent template was then validated with explicit key-value parameter syntax.

*See Evidence:* [Template path correction and validation](../../screenshots/deployment/batch-deployment-phase-two/13-template-path-correction-and-validation.png)

### 11. Run the initial what-if analysis

PowerShell variables were established for the resource group and local template path before running what-if.

```powershell
$resourceGroup = "BatchTestResGroup2"
$templateFile = "./main.bicep"

az deployment group what-if `
  --resource-group $resourceGroup `
  --template-file $templateFile `
  --parameters sharedGalleryImageId=$sharedGalleryImageId adminPassword=$adminPassword
```

*See Evidence:* [Deployment variables and what-if start](../../screenshots/deployment/batch-deployment-phase-two/14-deployment-variables-and-what-if-start.png)

The output showed the planned client VM configuration, including masked password data, the selected gallery image, `Standard_B1s` sizing, NIC association, and operating system disk settings.

*See Evidence:* [What-if client VM resource plan](../../screenshots/deployment/batch-deployment-phase-two/15-what-if-client-vm-resource-plan.png)

The initial what-if completed with 15 planned resources:

- Six virtual machines.
- Six network interfaces.
- Two Network Security Groups.
- One virtual network containing two subnets.

*See Evidence:* [What-if summary showing 15 resources](../../screenshots/deployment/batch-deployment-phase-two/16-what-if-summary-15-resources.png)

### 12. Correct the gallery image reference design

The initial create attempt failed because Azure rejected the supplied Azure Compute Gallery image version ID as invalid.

*See Evidence:* [Deployment failure caused by invalid image reference](../../screenshots/deployment/batch-deployment-phase-two/17-deployment-failure-invalid-image-reference.png)

The image reference was corrected in the VM module and retained as a typed string parameter with a known image version value for this lab deployment.

```bicep
@description('Azure Compute Gallery image version resource ID used for VM deployment.')
param sharedGalleryImageId string = '/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/TestGroup1/providers/Microsoft.Compute/galleries/BatchTestGallery2/images/BatchTestImage2/versions/1.0.0'
```

The VM resource referenced the parameter directly:

```bicep
imageReference: {
  id: sharedGalleryImageId
}
```

*See Evidence:* [Gallery image reference correction](../../screenshots/deployment/batch-deployment-phase-two/18-gallery-image-reference-correction.png)

### 13. Reset the environment after failed deployment attempts

Resource IDs were collected to support deletion of the partially deployed test environment.

```powershell
$resourceIds = az resource list `
  --resource-group BatchTestResGroup2 `
  --query "[].id" `
  --output tsv
```

The Azure CLI help output was reviewed after a mistyped `--helo` argument.

*See Evidence:* [Resource ID collection for environment reset](../../screenshots/deployment/batch-deployment-phase-two/19-resource-id-collection-for-environment-reset.png)

Resources were deleted by ID after required network dependencies were removed.

```powershell
az resource delete --ids $resourceIds
```

*See Evidence:* [Environment reset deletion verification](../../screenshots/deployment/batch-deployment-phase-two/20-environment-reset-deletion-verification.png)

The Azure portal was then used to confirm that the resource group no longer contained the Phase 2 test resources.

*See Evidence:* [Portal environment reset verification](../../screenshots/deployment/batch-deployment-phase-two/21-portal-environment-reset-verification.png)

### 14. Perform final validation and what-if review

The final validation command supplied the runtime password parameter and used the corrected local template path:

```powershell
az deployment group validate `
  --resource-group BatchTestResGroup2 `
  --template-file ./main.bicep `
  --parameters adminPassword=$adminPassword
```

Validation returned `error: null`. It also returned a `NestedDeploymentShortCircuited` warning because the nested client deployment depended on a subnet ID that could not be fully evaluated until the network module was deployed. The warning did not prevent subsequent what-if or create operations.

*See Evidence:* [Corrected template validation succeeded](../../screenshots/deployment/batch-deployment-phase-two/22-corrected-template-validation-succeeded.png)

The final what-if showed the six planned client VMs with the expected gallery image, VM size, masked password, NIC references, and delete settings.

*See Evidence:* [Final what-if client VM plan](../../screenshots/deployment/batch-deployment-phase-two/23-final-what-if-client-vm-plan.png)

The final summary again reported 15 resources to create.

*See Evidence:* [Final what-if summary showing 15 resources](../../screenshots/deployment/batch-deployment-phase-two/24-final-what-if-summary-15-resources.png)

### 15. Remove the unsupported guest provisioning property

The next deployment attempt failed for each VM because the module contained:

```bicep
requireGuestProvisionSignal: true
```

Azure reported that `osProfile.requireGuestProvisionSignal` required the `Microsoft.Compute/Agentless` subscription feature, which was not enabled for the lab subscription.

*See Evidence:* [Deployment failure caused by guest provision signal](../../screenshots/deployment/batch-deployment-phase-two/25-deployment-failure-guest-provision-signal.png)

The property was identified in the VM resource block and removed because it was not required for the intended Linux VM deployment.

*See Evidence:* [Guest provision signal property identified before removal](../../screenshots/deployment/batch-deployment-phase-two/26-guest-provision-signal-property-removed.png)

The corrected module retained `provisionVMAgent: true` and no longer included `requireGuestProvisionSignal`.

*See Evidence:* [Corrected VM module after property removal](../../screenshots/deployment/batch-deployment-phase-two/27-successful-deployment-output-part-01.png)

## Configuration Procedure

### Parent module chain

The Phase 2 parent template used `targetScope = 'resourceGroup'` and accepted the network names, deployment location, administrative username, and secure password as parameters.

The phase-specific module chain was:

```bicep
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Admin username for the Client VMs')
param adminUserName string = '<ADMIN_USERNAME>'

@secure()
@description('Admin password for the Client VMs')
param adminPassword string

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
  }
}
```

The later WireGuard module call and SSH public-key parameter were not part of the Phase 2 endpoint.

### Client VM address plan

The final client fleet used the following deterministic addressing:

| Virtual machine | Network interface | Static private IP |
| --- | --- | --- |
| `BatchTestClientVM1` | `BatchTestClientVM1-nic` | `10.10.0.5` |
| `BatchTestClientVM2` | `BatchTestClientVM2-nic` | `10.10.0.6` |
| `BatchTestClientVM3` | `BatchTestClientVM3-nic` | `10.10.0.7` |
| `BatchTestClientVM4` | `BatchTestClientVM4-nic` | `10.10.0.8` |
| `BatchTestClientVM5` | `BatchTestClientVM5-nic` | `10.10.0.9` |
| `BatchTestClientVM6` | `BatchTestClientVM6-nic` | `10.10.0.10` |

### Network interface configuration

The NIC loop created one NIC for each client entry and assigned it to the subnet supplied by the network module.

```bicep
resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = [for vm in clientVMs: {
  name: vm.nicName
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
```

### Virtual machine configuration

Each VM was deployed with the following core settings:

| Setting | Configuration |
| --- | --- |
| VM size | `Standard_B1s` |
| Operating system | Linux |
| Image source | `BatchTestImage2/1.0.0` |
| OS disk creation | `FromImage` |
| OS disk caching | `ReadWrite` |
| OS disk type | `Standard_LRS` |
| Disk controller | `SCSI` |
| Security type | `Standard` |
| Password authentication | Enabled for this lab phase |
| VM agent | Enabled |
| Patch mode | `ImageDefault` |
| Assessment mode | `ImageDefault` |

The VM loop associated each VM with the corresponding NIC by array index:

```bicep
resource virtualMachines 'Microsoft.Compute/virtualMachines@2025-11-01' = [for (vm, i) in clientVMs: {
  name: vm.vmName
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
      computerName: vm.vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
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
}]
```

### Resource lifecycle settings

The module applied `deleteOption: 'Delete'` to both the operating system disk and the NIC attachment. This allowed those VM-associated resources to be removed when the VM was deleted through a supported VM deletion workflow.

The final cleanup still used explicit resource inventory and portal verification because the phase removed the complete test environment, including shared network resources that were not children of an individual VM.

## Verification

### Confirm the password variable is populated

The administrative password was requested in the active PowerShell session and checked before the final create operation.

```powershell
$adminPassword = Read-Host "Enter VM admin password"
[string]::IsNullOrWhiteSpace($adminPassword)
```

Expected result:

```text
False
```

The deployment was then started:

```powershell
az deployment group create `
  --resource-group BatchTestResGroup2 `
  --template-file ./main.bicep `
  --parameters adminPassword=$adminPassword
```

The first successful output segment showed the parent deployment, nested module dependencies, and VM resources returned by the deployment operation.

*See Evidence:* [Successful deployment output begins](../../screenshots/deployment/batch-deployment-phase-two/28-successful-deployment-output-part-02.png)

The next output segment showed additional NIC and deployment resource data.

*See Evidence:* [Successful deployment output continues](../../screenshots/deployment/batch-deployment-phase-two/29-successful-deployment-output-part-03.png)

The final output reported:

```text
provisioningState: Succeeded
```

*See Evidence:* [Deployment provisioning succeeded](../../screenshots/deployment/batch-deployment-phase-two/30-deployment-provisioning-succeeded.png)

### Confirm resources in the Azure portal

The Azure portal displayed 21 resources in `BatchTestResGroup2` after deployment.

The first portal view showed the client NSG and the first portion of the VM, NIC, and disk inventory.

*See Evidence:* [Deployed resources portal verification, part 1](../../screenshots/deployment/batch-deployment-phase-two/31-deployed-resources-portal-part-01.png)

The second portal view showed the remaining client resources, `BatchTestVNet1`, and `BatchWireGuardNSG1`.

*See Evidence:* [Deployed resources portal verification, part 2](../../screenshots/deployment/batch-deployment-phase-two/32-deployed-resources-portal-part-02.png)

The 21 resources consisted of:

- Six virtual machines.
- Six network interfaces.
- Six operating system disks.
- Two Network Security Groups.
- One virtual network containing the two configured subnets.

The portal count exceeded the what-if count of 15 because the six managed OS disks appeared as separate deployed resources after VM creation.

### Confirm resources through Azure CLI

The deployed resource IDs were listed through Azure CLI:

```powershell
$resourceIds = az resource list `
  --resource-group BatchTestResGroup2 `
  --query "[].id" `
  --output tsv

az resource list `
  --resource-group BatchTestResGroup2 `
  --query "[].id" `
  --output tsv
```

The output included the VNet, both NSGs, six NICs, six VMs, and six OS disks.

*See Evidence:* [Deployed resource ID inventory](../../screenshots/deployment/batch-deployment-phase-two/33-deployed-resource-id-inventory.png)

### Verify final cleanup

After deployment verification, the collected resource IDs were deleted:

```powershell
az resource delete --ids $resourceIds
```

The command returned null entries rather than resource bodies. The null output alone was not treated as complete proof of deletion; it was followed by portal verification.

*See Evidence:* [Final resource deletion output](../../screenshots/deployment/batch-deployment-phase-two/34-final-resource-deletion-output.png)

The final Azure portal view showed no remaining resources in the resource group view.

*See Evidence:* [Final portal cleanup verification](../../screenshots/deployment/batch-deployment-phase-two/35-final-portal-cleanup-verification.png)

## Common Issues

### Exported Bicep contained unusable external references

The Azure-exported source contained generated names and references tied to the original VM, NIC, disk, and image resources. Copying the export directly into a module produced unresolved references and a single-VM design.

The source was refactored into explicit parameters, a six-entry array, a NIC loop, and a VM loop. Exported templates should be treated as source material until their dependencies and generated names have been reviewed.

### Local template path resolved to the wrong directory

The PowerShell session was already located in the deployment directory. Using:

```powershell
--template-file ./deployment/main.bicep
```

caused Azure CLI to search for a duplicated directory path.

The correct local path from that working directory was:

```powershell
--template-file ./main.bicep
```

Template paths must be evaluated relative to the current shell location, not relative to the project root assumed during editing.

### Gallery image parameter parsing failed

An early validation attempt passed `sharedGalleryImageId` without a complete key-value expression. Azure CLI could not parse the parameter.

The corrected syntax was:

```powershell
--parameters sharedGalleryImageId=$sharedGalleryImageId adminPassword=$adminPassword
```

The final lab design reduced this runtime dependency by assigning the known image version resource ID as the module parameter default.

### Azure rejected the gallery image reference

The first create operation returned a `BadRequest` stating that the shared gallery image reference ID was invalid.

The correction included:

- Confirming the exact image version resource ID.
- Ensuring the ID referenced the image version rather than only the gallery or image definition.
- Declaring the Bicep parameter with the required `string` type.
- Referencing the parameter directly in `storageProfile.imageReference.id`.

### Bicep parameter declaration omitted a type

The following declaration was invalid:

```bicep
param sharedGalleryImageId = '/subscriptions/...'
```

Bicep parameters require an explicit type. The corrected declaration was:

```bicep
param sharedGalleryImageId string = '/subscriptions/...'
```

### `requireGuestProvisionSignal` required an unavailable feature

The deployment failed with an `InvalidParameter` response for:

```text
osProfile.requireGuestProvisionSignal
```

The property required the `Microsoft.Compute/Agentless` subscription feature, which was not enabled. It was not required for the intended VM deployment and was removed.

The final module retained:

```bicep
provisionVMAgent: true
```

but omitted `requireGuestProvisionSignal`.

### Administrative password variable was blank

A create operation failed when the required `adminPassword` value was null in the active PowerShell session.

The variable was repopulated and checked before deployment:

```powershell
$adminPassword = Read-Host "Enter VM admin password"
[string]::IsNullOrWhiteSpace($adminPassword)
```

A result of `False` confirmed that the variable contained a value.

Passwords must not be hardcoded into Bicep files, command history, screenshots, or published documentation.

### Incorrect PowerShell variable syntax

The following assignment was invalid:

```powershell
@adminPassword = Read-Host "Enter VM admin password"
```

PowerShell interpreted `@adminPassword` as splatting syntax. Standard variable assignment requires `$`:

```powershell
$adminPassword = Read-Host "Enter VM admin password"
```

### Validation returned `NestedDeploymentShortCircuited`

The final validation output contained a warning because the nested client module consumed a subnet ID produced by the network module. The value could not be fully resolved during static validation.

The warning did not indicate a failed deployment. What-if and create were still required to test the complete dependency chain.

### Network resources required dependency-aware cleanup

NSGs associated with subnets could not always be deleted before their associations were removed. The reset process detached NSGs from the subnets before deleting the VNet and NSGs.

Cleanup should be followed by an independent inventory or portal check. A command returning no resource object does not by itself prove that all dependent resources have been removed.

### PowerShell transcript did not capture every external command detail

`Start-Transcript` preserved much of the PowerShell session but did not consistently capture every Azure CLI error exactly as displayed. Azure CLI is an external executable and can write across multiple output streams.

Future deployment sessions should combine the transcript with per-command capture where detailed output is required:

```powershell
az deployment group create `
  --resource-group <RESOURCE_GROUP> `
  --template-file ./main.bicep `
  --parameters adminPassword=$adminPassword `
  2>&1 | Tee-Object -FilePath "../evidence/deployment-output.txt"
```

## Lessons Learned

- Module outputs provide a cleaner and more maintainable dependency contract than reconstructing Azure resource IDs in PowerShell.
- Bicep arrays and resource loops reduced six VM deployments to one data structure and two reusable resource definitions.
- Azure-exported Bicep was useful as technical source material but required substantial refactoring before it could function as a reusable module.
- Image replication to the deployment region was necessary but did not replace validation of the complete image version resource ID.
- A successful what-if did not detect every runtime or subscription-feature restriction.
- Secure Bicep parameters still require deliberate runtime variable handling in the calling shell.
- Checking a password variable for null or whitespace before deployment prevented repeated failures caused by session state.
- The Azure portal and Azure CLI provided complementary verification. The portal showed the complete deployed inventory, while CLI output provided resource IDs suitable for cleanup.
- What-if resource counts may differ from the final portal count when child or generated resources, such as managed OS disks, appear separately after deployment.
- VM-associated NIC and disk delete options improve lifecycle management, but complete environment teardown still requires verification of shared network resources.
- Evidence capture should be planned before execution and should combine screenshots, transcripts, and command-specific output files.

## Related Documents

- [Golden Image Management](../golden-image-management/golden-image-management.md)
- [VNet and Subnet Design](../../network/vnet-subnet-design.md)
- [IP Addressing Plan](../../architecture/ip-addressing-plan.md)
- [Cost Control Operations](../../operations/cost-control-operations.md)