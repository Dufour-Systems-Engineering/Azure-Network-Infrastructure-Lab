# Batch Deployment Phase 3 â€” WireGuard VM Module

## Overview

Phase 3 extended the Batch Deployment Bicep project by adding a dedicated WireGuard virtual machine module to the network and client virtual machine modules completed in Phases 1 and 2. The parent `main.bicep` file deployed the shared network foundation first, then passed the client and WireGuard subnet resource IDs to the two downstream virtual machine modules.

The Phase 3 module deployed one Linux virtual machine intended to serve as the later WireGuard VPN gateway and administrative jumpbox. The Azure resource layer included a Standard public IP address, a network interface with a static private IP address, Azure NIC IP forwarding, an operating system disk created from the existing Azure Compute Gallery image version, and shared SSH public-key configuration.

The complete parent deployment created the Phase 1 network resources, the six Phase 2 client virtual machines, and the Phase 3 WireGuard virtual machine in one module chain. The deployment was reviewed through Azure CLI validation and What-If, corrected through several failed deployment attempts, completed successfully, verified in the Azure portal, and then removed from the test resource group.

The original live PowerShell screen showing the successful create operation was not captured. The successful deployment output was preserved in a PowerShell session log. Screenshots `20` through `23` show that saved log displayed in PowerShell for evidence capture; they do not represent a second execution. The preserved output records the parent deployment as `Succeeded`, and the post-deployment portal screenshots independently confirm the resulting resource state.

This phase covers Azure infrastructure deployment only. Installation of WireGuard inside the Linux guest, creation of `wg0.conf`, Linux IP forwarding, NAT or forwarding rules, peer configuration, tunnel establishment, and private-VM access testing were completed separately and are outside the Phase 3 boundary.

## Purpose

The purpose of Phase 3 was to extend the existing modular deployment so the complete batch environment included an Azure-ready WireGuard gateway virtual machine.

The implementation was designed to:

- Add a reusable WireGuard VM child module to the parent Bicep deployment.
- Preserve the Phase 1 network-first module dependency pattern.
- Place the WireGuard VM in `BatchWireGuardSN1` through the network module output.
- Assign the gateway a predictable static private IP address.
- Attach a public IP address for later SSH administration and WireGuard tunnel ingress.
- Enable Azure NIC IP forwarding for the later routing role.
- Reuse the Azure Compute Gallery image version established during Phase 2.
- Pass one SSH public key through the parent deployment to both VM modules.
- Retain the secure runtime password parameter used by the lab deployment.
- Confirm that the complete seven-VM environment could be deployed and removed as one test cycle.
- Preserve deployment failures and corrections as part of the engineering evidence record.

## Prerequisites

The following resources and tools were required before Phase 3 deployment work began:

- Azure subscription access with permission to create Compute, Network, Public IP, and Resource Manager deployment resources.
- Resource group `BatchTestResGroup2` in `centralus`.
- Azure CLI installed and authenticated on the administrator workstation.
- PowerShell available for parameter handling, SSH key generation, and session capture.
- Bicep support available through Azure CLI and Visual Studio Code.
- The completed Phase 1 `network-module.bicep` file.
- The completed Phase 2 `vm-batch-deployment.bicep` file.
- An Azure Compute Gallery image version replicated to Central US.
- Sufficient regional quota for seven `Standard_B1s` virtual machines.
- Availability of a Standard regional public IP address.
- A runtime administrative password satisfying Azure VM password requirements.
- An RSA SSH key pair whose public key was available as a valid single-line OpenSSH value.

The inherited network configuration was:

| Resource | Configuration |
| --- | --- |
| Resource group | `BatchTestResGroup2` |
| Deployment region | `centralus` |
| Virtual network | `BatchTestVNet1` |
| VNet address space | `10.10.0.0/24` |
| Client subnet | `BatchClientSN1` â€” `10.10.0.0/28` |
| WireGuard subnet | `BatchWireGuardSN1` â€” `10.10.0.32/28` |
| Client NSG | `BatchClientNSG1` |
| WireGuard NSG | `BatchWireGuardNSG1` |

The inherited Azure Compute Gallery source was:

| Setting | Value |
| --- | --- |
| Gallery | `BatchTestGallery2` |
| Image definition | `BatchTestImage2` |
| Image version | `1.0.0` |
| Operating system | Linux |
| OS state | Generalized |
| Hyper-V generation | V2 |
| Architecture | x64 |
| Target region used by this phase | Central US |

## Deployment Procedure

### 1. Create the WireGuard VM module parameters and public IP resource

A new `wireguard-vm-module.bicep` child module was created for the gateway resources. The module accepted the gallery image version ID, administrative credentials, WireGuard subnet resource ID, SSH public key, and deployment location.

The module also defined the WireGuard VM, NIC, and public IP resource names. The public IP resource used static IPv4 allocation and the DNS label `batchwireguardvm1`.

*See Evidence:* [WireGuard module parameters and public IP](../../screenshots/deployment/batch-deployment-phase-three/01-wireguard-module-parameters-and-public-ip.png)

### 2. Configure the WireGuard network interface

The WireGuard NIC was assigned the static private IP address `10.10.0.40` in `BatchWireGuardSN1`. Its primary IP configuration attached the public IP resource and consumed the subnet ID supplied by the parent module chain.

Azure NIC IP forwarding was enabled because the VM was intended to route traffic between the later WireGuard tunnel and the Azure Virtual Network.

```bicep
resource networkInterfaceResource 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: wireGuardNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.10.0.40'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          primary: true
          publicIPAddress: {
            id: publicIPAddressResource.id
          }
          subnet: {
            id: BatchWireGuardSN1
          }
        }
      }
    ]
    enableIPForwarding: true
    disableTcpStateTracking: false
  }
}
```

*See Evidence:* [WireGuard NIC static IP and IP forwarding](../../screenshots/deployment/batch-deployment-phase-three/02-wireguard-nic-static-ip-and-ip-forwarding.png)

### 3. Configure the WireGuard virtual machine resource

The VM resource used the existing Azure Compute Gallery image version and the `Standard_B1s` size. Its operating system disk used `Standard_LRS`, `ReadWrite` caching, SCSI, and `deleteOption: 'Delete'`.

*See Evidence:* [WireGuard VM image and OS disk configuration](../../screenshots/deployment/batch-deployment-phase-three/03-wireguard-vm-image-and-os-disk-configuration.png)

The Linux profile retained password authentication for this lab phase and also installed the supplied SSH public key at the administrator account's authorized-key path.

```bicep
linuxConfiguration: {
  disablePasswordAuthentication: false
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUserName}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ]
  }
  provisionVMAgent: true
  patchSettings: {
    patchMode: 'ImageDefault'
    assessmentMode: 'ImageDefault'
  }
}
```

*See Evidence:* [WireGuard VM authentication configuration](../../screenshots/deployment/batch-deployment-phase-three/04-wireguard-vm-authentication-configuration.png)

### 4. Add the WireGuard module to the parent deployment

The parent `main.bicep` file called three child modules:

1. `networkModule`
2. `vmBatchDeployment`
3. `wireguardVMModule`

The network module remained the first layer. The client module consumed `networkModule.outputs.clientSubnetId`, while the WireGuard module consumed `networkModule.outputs.wireGuardSubnetId`.

*See Evidence:* [Parent Bicep module chain](../../screenshots/deployment/batch-deployment-phase-three/05-parent-bicep-module-chain.png)

The parent file also defined a shared `sshPublicKey` parameter and passed the same public-key value into both VM modules.

```bicep
@description('SSH public key installed on the deployed Linux virtual machines.')
param sshPublicKey string = '<SSH_PUBLIC_KEY>'

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
```

The subnet output references created implicit deployment dependencies. Resource Manager had to complete the network deployment before it could resolve the subnet IDs required by either VM module.

*See Evidence:* [Shared SSH key and WireGuard subnet output](../../screenshots/deployment/batch-deployment-phase-three/06-shared-ssh-key-and-wireguard-subnet-output.png)

### 5. Validate the parent deployment

The complete parent deployment was validated from the directory containing `main.bicep`.

```powershell
az deployment group validate `
  --resource-group BatchTestResGroup2 `
  --template-file ./main.bicep
```

The parent validation returned without a top-level deployment error.

*See Evidence:* [Deployment validation output](../../screenshots/deployment/batch-deployment-phase-three/07-deployment-validation-output.png)

Validation also returned `NestedDeploymentShortCircuited` warnings for `vmBatchDeployment` and `wireguardVMModuleDeployment`. The nested module inputs depended on network module outputs that could not be fully evaluated during the validation pass.

The result confirmed the parent deployment structure but was not treated as complete validation of every nested VM resource.

*See Evidence:* [Nested deployment short-circuit warning](../../screenshots/deployment/batch-deployment-phase-three/08-nested-deployment-short-circuit-warning.png)

### 6. Correct the public IP SKU failure

The first create attempt failed inside `wireguardVMModuleDeployment` with:

```text
IPv4BasicSkuPublicIpCountLimitReached
```

The initial public IP resource did not declare an explicit SKU, so Azure attempted to use a Basic SKU public IP that was unavailable for the subscription and region.

*See Evidence:* [Basic public IP SKU deployment failure](../../screenshots/deployment/batch-deployment-phase-three/09-basic-public-ip-sku-deployment-failure.png)

A Standard SKU and Regional tier were added to the public IP resource.

*See Evidence:* [Standard public IP SKU added](../../screenshots/deployment/batch-deployment-phase-three/10-standard-public-ip-sku-added.png)

The first correction placed the `sku` block inside `properties`, which was not valid for the public IP resource schema.

*See Evidence:* [Public IP SKU placement error](../../screenshots/deployment/batch-deployment-phase-three/11-public-ip-sku-placement-error.png)

The block was moved outside `properties` and aligned with `name` and `location`.

*See Evidence:* [Public IP SKU block repositioning](../../screenshots/deployment/batch-deployment-phase-three/12-public-ip-sku-block-repositioning.png)

The corrected resource used:

```bicep
resource publicIPAddressResource 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: wireGuardPublicIpName
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
```

*See Evidence:* [Public IP SKU block corrected](../../screenshots/deployment/batch-deployment-phase-three/13-public-ip-sku-block-corrected.png)

### 7. Review the corrected deployment through What-If

Azure What-If was rerun after the public IP correction.

```powershell
az deployment group what-if `
  --resource-group BatchTestResGroup2 `
  --template-file ./main.bicep
```

The preview showed 18 resources to create:

- Seven virtual machines.
- Seven network interfaces.
- Two Network Security Groups.
- One Virtual Network containing both subnets.
- One Standard public IP address.

The WireGuard NIC was previewed with static private IP `10.10.0.40`, public IP association, the WireGuard subnet reference, and IP forwarding enabled.

*See Evidence:* [Corrected deployment What-If](../../screenshots/deployment/batch-deployment-phase-three/14-corrected-deployment-what-if.png)

### 8. Correct the SSH public-key data

A later create attempt reached the WireGuard VM resource but failed at:

```text
linuxConfiguration.ssh.publicKeys.keyData
```

The value passed into `keyData` was not accepted as a valid SSH public key. This confirmed that the Bicep property required the actual single-line contents of a public key rather than a local file path or incomplete value.

*See Evidence:* [SSH public-key data error](../../screenshots/deployment/batch-deployment-phase-three/15-ssh-public-key-data-error.png)

### 9. Generate and retrieve the shared SSH public key

An RSA 2048-bit key pair was created in PowerShell for the batch deployment.

```powershell
ssh-keygen -m PEM -t rsa -b 2048 -f "<SSH_KEY_PATH>"
```

*See Evidence:* [Batch SSH key pair created](../../screenshots/deployment/batch-deployment-phase-three/16-batch-ssh-key-pair-created.png)

The public key was then read from the `.pub` file so its complete one-line value could be supplied to the parent Bicep parameter.

```powershell
Get-Content "<SSH_KEY_PATH>.pub"
```

*See Evidence:* [Batch SSH public key retrieved](../../screenshots/deployment/batch-deployment-phase-three/17-batch-ssh-public-key-retrieved.png)

### 10. Correct the client VM authorized-key path

After the public-key value was corrected, the next deployment failed for the six client VMs because their SSH authorized-key path did not resolve to a valid absolute Linux path.

The corrected path was:

```bicep
path: '/home/${adminUserName}/.ssh/authorized_keys'
```

The failure target belonged to `vmBatchDeployment`, not the WireGuard VM module. The shared key design caused both VM modules to be evaluated during the complete parent deployment, so the client module also had to use a valid SSH configuration before the combined deployment could succeed.

*See Evidence:* [Client VM SSH authorized-key path error](../../screenshots/deployment/batch-deployment-phase-three/18-client-vm-ssh-authorized-key-path-error.png)

The failed deployment left a partial resource state in `BatchTestResGroup2`. The portal view was used to identify the resources that had been created before the nested VM failure stopped the deployment.

*See Evidence:* [Partial resource state after failed deployment](../../screenshots/deployment/batch-deployment-phase-three/19-partial-resource-state-after-failed-deployment.png)

### 11. Run the final parent deployment

After the public IP and SSH corrections, the complete parent deployment was executed again.

```powershell
az deployment group create `
  --resource-group BatchTestResGroup2 `
  --template-file ./main.bicep
```

The administrative password was supplied through the secure interactive parameter prompt.

The original live console screenshot was not captured. The deployment command shown in the evidence was later displayed from the preserved successful PowerShell session log and was not re-executed for documentation.

*See Evidence:* [Parent deployment command](../../screenshots/deployment/batch-deployment-phase-three/20-parent-deployment-command.png)

The preserved output showed both VM modules depending on `networkModuleDeployment`, confirming the expected module dependency chain.

*See Evidence:* [Deployment module dependencies](../../screenshots/deployment/batch-deployment-phase-three/21-deployment-module-dependencies.png)

The output resource list included the six client VMs, the WireGuard VM, seven NICs, both NSGs, the Virtual Network, and the WireGuard public IP address.

*See Evidence:* [Deployment output resources](../../screenshots/deployment/batch-deployment-phase-three/22-deployment-output-resources.png)

The final parent deployment output reported:

```text
error: null
provisioningState: Succeeded
timestamp: 2026-07-08T04:13:33.155728+00:00
```

*See Evidence:* [Provisioning state succeeded](../../screenshots/deployment/batch-deployment-phase-three/23-provisioning-state-succeeded.png)

### 12. Verify the complete deployed environment

The Azure portal showed the upper portion of the completed resource inventory, including client VM resources and their associated disks and NICs.

*See Evidence:* [Post-deployment resource inventory, top](../../screenshots/deployment/batch-deployment-phase-three/24-post-deployment-resource-inventory-top.png)

The lower portion of the inventory confirmed the WireGuard VM, WireGuard NIC, public IP, Virtual Network, and remaining shared resources.

*See Evidence:* [Post-deployment resource inventory, bottom](../../screenshots/deployment/batch-deployment-phase-three/25-post-deployment-resource-inventory-bottom.png)

### 13. Remove the Phase 3 test environment

Before cleanup, the deployed resource inventory was reviewed to confirm the scope of the deletion operation.

*See Evidence:* [Pre-cleanup resource inventory](../../screenshots/deployment/batch-deployment-phase-three/26-pre-cleanup-resource-inventory.png)

The resource IDs in `BatchTestResGroup2` were collected and passed to `az resource delete`.

```powershell
$resourceIds = az resource list `
  --resource-group BatchTestResGroup2 `
  --query "[].id" `
  --output tsv

az resource delete --ids $resourceIds
```

The deletion command returned null entries rather than deleted resource bodies. That output was treated as command completion evidence, not independent proof that every resource had been removed.

*See Evidence:* [Resource deletion PowerShell output](../../screenshots/deployment/batch-deployment-phase-three/27-resource-deletion-powershell-output.png)

The Azure portal was then used to confirm that the test resources were no longer present in the resource group view.

*See Evidence:* [Resource deletion portal verification](../../screenshots/deployment/batch-deployment-phase-three/28-resource-deletion-portal-verification.png)

## Configuration Procedure

### Parent module chain

The Phase 3 parent file targeted the resource group scope and coordinated all three implementation modules.

```bicep
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Administrative username for the Linux virtual machines.')
param adminUserName string = '<ADMIN_USERNAME>'

@secure()
@description('Administrative password for the Linux virtual machines.')
param adminPassword string

@description('SSH public key installed on the deployed Linux virtual machines.')
param sshPublicKey string = '<SSH_PUBLIC_KEY>'

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
```

### WireGuard resource configuration

The final Azure resource configuration was:

| Setting | Configuration |
| --- | --- |
| VM | `BatchWireGuardVM1` |
| VM size | `Standard_B1s` |
| Operating system | Linux |
| Image source | `BatchTestImage2/1.0.0` |
| NIC | `BatchWireGuardVM1-nic` |
| Static private IP | `10.10.0.40` |
| Subnet | `BatchWireGuardSN1` |
| Public IP | `BatchWireGuardVM1-ip` |
| Public IP SKU | Standard, Regional |
| Public IP allocation | Static IPv4 |
| DNS label | `batchwireguardvm1` |
| Azure NIC IP forwarding | Enabled |
| OS disk | `BatchWireGuardVM1-osdisk` |
| OS disk type | `Standard_LRS` |
| OS disk caching | `ReadWrite` |
| Disk controller | SCSI |
| Security type | Standard |
| Password authentication | Enabled for this lab phase |
| SSH public key | Installed through `linuxConfiguration.ssh.publicKeys` |
| VM agent | Enabled |
| Patch mode | `ImageDefault` |
| Assessment mode | `ImageDefault` |
| OS disk delete option | Delete |
| NIC delete option | Delete |

### Network Security Group configuration

The final network module associated `BatchWireGuardNSG1` with `BatchWireGuardSN1` and declared two custom inbound rules:

| Rule | Protocol | Source | Destination port | Priority | Access |
| --- | --- | --- | --- | --- | --- |
| `Allow-SSH-MyIP` | TCP | `<ADMIN_PUBLIC_IP>` | `22` | `100` | Allow |
| `Allow-wireguard-vpn-tunnel-access` | UDP | Any | `51820` | `1002` | Allow |

The UDP rule prepared the Azure network boundary for the later WireGuard service configuration. It did not prove that a WireGuard service was installed, listening, or accepting peers during Phase 3.

### Shared SSH-key configuration

One parent `sshPublicKey` parameter was passed to both the six-client module and the WireGuard VM module. Each Linux VM installed the same public key under its administrative user profile.

The private key remained on the administrator workstation and was not included in Bicep, command output excerpts, or repository documentation.

The deployed phase retained mixed authentication:

- Secure runtime password parameter.
- Password authentication enabled.
- SSH public-key authentication configured.

This represented the tested Phase 3 implementation. A future reusable version may move to SSH-key-only authentication after that design is separately tested and approved.

### Phase boundary

The Phase 3 endpoint prepared the Azure resource layer but did not configure the Linux guest as an operational VPN server.

The following items were outside this phase:

- Installing the WireGuard package.
- Generating WireGuard server and peer keys.
- Creating `/etc/wireguard/wg0.conf`.
- Enabling Linux kernel IPv4 forwarding.
- Configuring iptables forwarding or NAT masquerade rules.
- Starting `wg-quick@wg0`.
- Importing a client tunnel configuration.
- Confirming a WireGuard handshake.
- Testing direct SSH access to the six client VMs through the VPN tunnel.

## Verification

### Validation and What-If review

The validation operation returned no top-level error, but the nested VM modules were short-circuited because their subnet parameters depended on runtime network module outputs. Validation was therefore treated as a parent-template check rather than complete proof of every nested resource.

The corrected What-If operation provided the stronger pre-deployment review. It showed 18 declared resources and confirmed the expected WireGuard NIC, public IP, VM, static private IP, subnet association, and IP-forwarding configuration.

### Successful deployment log

The preserved PowerShell session log recorded the final parent deployment with:

```text
Deployment name: main
Resource group: BatchTestResGroup2
Duration: PT1M12.3552807S
Error: null
Provisioning state: Succeeded
Timestamp: 2026-07-08T04:13:33.155728+00:00
Deployment type: Microsoft.Resources/deployments
```

The evidence screenshots showing that output were captured from the saved log after the fact. They are supported by the original text log and by the independent portal state captured after deployment.

### Resource inventory

The successful portal state showed 25 resources:

- Seven virtual machines.
- Seven network interfaces.
- Seven managed operating system disks.
- Two Network Security Groups.
- One Virtual Network containing both subnets.
- One Standard public IP address.

The portal count exceeded the What-If count of 18 because the seven managed operating system disks appeared as separate Azure resources after VM creation. The disks were configured within the VM resources and were not separate top-level Bicep resource declarations in the parent What-If total.

### Cleanup verification

The final deletion command completed against the collected resource IDs. Because the command returned null entries, the Azure portal was used as the authoritative follow-up check. The portal showed no remaining Phase 3 test resources in the resource group view.

## Common Issues

### Nested deployments were short-circuited during validation

`az deployment group validate` returned `NestedDeploymentShortCircuited` for both VM modules because the subnet resource IDs were supplied through network module outputs.

The warning did not mean the parent file was invalid. It meant the validator could not fully evaluate resources whose parameters depended on runtime output values. What-If and the actual deployment operation were still required.

### Basic public IP SKU was unavailable

The first WireGuard deployment attempted to create a Basic public IP because the resource did not declare a SKU. Azure returned `IPv4BasicSkuPublicIpCountLimitReached`.

The issue was resolved by explicitly declaring a Standard, Regional public IP.

### Public IP SKU block was placed under `properties`

The first Standard SKU correction placed `sku` inside the public IP `properties` block. The resource schema required `sku` at the top resource level.

Moving the block alongside `name`, `location`, and `properties` corrected the Bicep structure.

### SSH public-key data was invalid

The WireGuard VM failed when `linuxConfiguration.ssh.publicKeys.keyData` did not receive a complete valid public-key value.

The public key had to be supplied as the one-line contents of the `.pub` file. A local path to the key file was not a valid `keyData` value.

### Client VM authorized-key path was invalid

After correcting the public-key contents, the complete parent deployment exposed an SSH path error in the client VM module. All six client VM instances used the same invalid path pattern.

The path was corrected to the absolute Linux location:

```text
/home/<ADMIN_USERNAME>/.ssh/authorized_keys
```

### Failed nested deployments left partial resources

Several failed create operations deployed network resources, NICs, or other dependencies before the VM failure stopped the parent deployment.

The resource group had to be inventoried and reset before each clean retest. A failed parent deployment should not be assumed to have created nothing.

### Resource deletion returned null entries

`az resource delete --ids $resourceIds` returned a list of null values rather than deleted resource descriptions. The output indicated command processing but did not independently prove that the resource group view was empty.

Portal verification was required after the deletion command.

### Original live success screenshot was not captured

The successful deployment was preserved as a complete PowerShell session log, but the original live terminal view was not captured as an image.

The evidence gap was handled by:

- Preserving the original session text.
- Displaying the saved log in PowerShell without rerunning the deployment.
- Labeling the resulting screenshots as saved-log evidence.
- Confirming the deployed state through Azure portal screenshots.

The replay screenshots must not be described as a live execution.

## Lessons Learned

- Module output references provided a reliable dependency mechanism between the network, client VM, and WireGuard VM layers.
- Parent validation was necessary but insufficient when nested module parameters depended on runtime outputs.
- Azure What-If provided the most useful pre-deployment review of the complete nested resource plan.
- Public IP resources should declare the intended SKU explicitly rather than relying on a platform default.
- Bicep resource-level properties such as `sku` must be placed according to the resource schema rather than grouped under `properties` by assumption.
- SSH `keyData` requires public-key contents, while the private key remains outside Azure and outside the repository.
- A shared SSH public-key parameter reduced configuration divergence across the seven deployed Linux VMs.
- A combined parent deployment can expose defects in inherited modules even when the newly added module is configured correctly.
- Failed deployments can leave valid partial resources that must be inventoried before cleanup or another test.
- The difference between What-If resource counts and portal resource counts should be explained when VM-managed disks appear as separate deployed resources.
- Saved command logs and independent portal state can form a defensible evidence chain when an original terminal screenshot is unavailable.
- Azure NIC IP forwarding and UDP 51820 ingress only prepare the infrastructure for WireGuard; they do not establish a functional VPN by themselves.

Post-deployment improvements identified for future reuse include:

- Supplying the SSH public key at deployment time rather than retaining a literal default value.
- Removing identifying comments from published SSH public-key examples.
- Moving from mixed password and key authentication to a separately tested SSH-key-only model.
- Replacing fixed administrator values and source image IDs with deployment-specific parameters where greater portability is required.
- Renaming the WireGuard subnet parameter so its name clearly indicates that the value is a subnet resource ID.
- Parameterizing the administrator source IP used by the restricted SSH NSG rule.

These items are recorded as later maintainability and security improvements. They do not change the tested Phase 3 endpoint documented here.

## Related Documents

- [Batch Deployment Network Foundation](phase-1-batch-deployment-network-foundation-module.md)
- [Batch Deployment Phase 2 â€” Client VM Module](phase-2-batch-deployment-client-vm-module.md)
- [Golden Image Management](../golden-image-management/golden-image-management.md)
- [NSG and ASG Implementation](../../network/nsg-asg-implementation.md)
- [WireGuard VPN Gateway](../../remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
- [Security Model](../../architecture/security-model.md)
