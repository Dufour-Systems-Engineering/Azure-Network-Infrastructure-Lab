# Phase 1 Batch Deployment Network Foundation Module

## Overview

Phase 1 established and tested the network deployment layer for the Bicep batch deployment project. A parent `main.bicep` file called a dedicated `network-module.bicep` child module to deploy the shared network foundation required by the later client virtual machine and WireGuard virtual machine phases.

The phase created a Central US test environment containing one Virtual Network, two subnets, and two Network Security Groups. The deployment was validated, reviewed with Azure What-If, deployed, inspected through Azure CLI and the Azure Portal, and then removed without deleting the resource group.

The original Phase 1 parent file was retained through screenshot evidence rather than as a separate source file. The final `network-module.bicep` is the authoritative published module. It preserves the Phase 1 network design and includes subnet ID outputs added to support module chaining in later phases.

## Purpose

The network foundation was created to:

- Separate client workloads from the internet-facing WireGuard gateway.
- Apply subnet-specific Network Security Group controls.
- Provide stable network resource identifiers to later Bicep modules.
- Validate the parent-to-child Bicep module structure before adding compute resources.
- Confirm that the network layer could be deployed and removed independently.

## Prerequisites

The following requirements were used during Phase 1:

- Azure subscription access with permissions to create and delete resource groups, Virtual Networks, subnets, and Network Security Groups.
- Azure CLI authenticated to the intended subscription.
- Azure CLI with Bicep support available from Windows PowerShell or Azure Cloud Shell.
- A local deployment directory containing `main.bicep` and `modules/network-module.bicep`.
- An administrator public IP address available for the restricted WireGuard SSH rule.
- A test resource group named `BatchTestResGroup2` in Central US.

## Deployment Procedure

### 1. Create the test resource group

The Phase 1 resources were deployed into a dedicated resource group so the network layer could be tested without affecting the existing lab environment.

```powershell
az group create --location centralus --name BatchTestResGroup2
```

The command returned a successful provisioning state for `BatchTestResGroup2`.

*See Evidence:* [01-create-batch-resource-group.png](../../screenshots/deployment/batch-deployment-phase-one/01-create-batch-resource-group.png)

### 2. Connect the parent file to the network module

The Phase 1 `main.bicep` file targeted the resource group scope and called the child module through the relative path `modules/network-module.bicep`.

The parent file passed the names of:

- `BatchTestVNet1`
- `BatchClientNSG1`
- `BatchWireGuardNSG1`

The child module contained the network resource definitions, while the parent file acted as the deployment entry point.

*See Evidence:* [02-parent-bicep-network-module-call.png](../../screenshots/deployment/batch-deployment-phase-one/02-parent-bicep-network-module-call.png)

### 3. Validate the Bicep deployment

The deployment was validated before resource creation.

```powershell
az deployment group validate `
    --resource-group BatchTestResGroup2 `
    --template-file ./main.bicep
```

The first validation attempt was run from the wrong working directory. Azure CLI could not locate `main.bicep` at the supplied relative path. After changing to the deployment directory, the same validation command completed successfully.

*See Evidence:* [03-bicep-validation-path-error-and-correction.png](../../screenshots/deployment/batch-deployment-phase-one/03-bicep-validation-path-error-and-correction.png)

The validation output reported `provisioningState` as `Succeeded` and identified the expected network resources and nested module deployment.

*See Evidence:* [04-bicep-validation-succeeded-continued.png](../../screenshots/deployment/batch-deployment-phase-one/04-bicep-validation-succeeded-continued.png)

*See Evidence:* [05-bicep-validated-network-resources.png](../../screenshots/deployment/batch-deployment-phase-one/05-bicep-validated-network-resources.png)

### 4. Review the planned changes

Azure What-If was used to inspect the planned deployment before execution.

```powershell
az deployment group what-if `
    --resource-group BatchTestResGroup2 `
    --template-file ./main.bicep
```

The captured What-If result showed the Virtual Network as a create operation and the two Network Security Groups as unchanged because the NSGs already existed at that point in the test cycle. The preview also displayed the intended subnet prefixes and NSG associations.

*See Evidence:* [06-what-if-summary-and-deployment-start.png](../../screenshots/deployment/batch-deployment-phase-one/06-what-if-summary-and-deployment-start.png)

### 5. Deploy the network foundation

The validated parent file was deployed at resource group scope.

```powershell
az deployment group create `
    --resource-group BatchTestResGroup2 `
    --template-file ./main.bicep
```

The deployment completed successfully and returned the two Network Security Groups and Virtual Network as output resources.

*See Evidence:* [07-network-deployment-succeeded.png](../../screenshots/deployment/batch-deployment-phase-one/07-network-deployment-succeeded.png)

## Configuration Procedure

No manual post-deployment configuration was required. The network layout, subnet associations, and custom security rules were declared in the Bicep module.

The deployed network configuration was:

| Component | Configuration |
| --- | --- |
| Resource Group | `BatchTestResGroup2` |
| Region | Central US |
| Virtual Network | `BatchTestVNet1` |
| Virtual Network address space | `10.10.0.0/24` |
| Client subnet | `BatchClientSN1` — `10.10.0.0/28` |
| WireGuard subnet | `BatchWireGuardSN1` — `10.10.0.32/28` |
| Client NSG | `BatchClientNSG1` |
| WireGuard NSG | `BatchWireGuardNSG1` |

The client subnet NSG permitted:

- SSH over TCP 22 from the `VirtualNetwork` service tag.
- ICMP from the `VirtualNetwork` service tag.

The WireGuard subnet NSG permitted:

- WireGuard tunnel traffic over UDP 51820.
- SSH over TCP 22 from the administrator public IP address used during the test.

The final published network module also outputs `clientSubnetId` and `wireGuardSubnetId`. These values allow later modules to consume the deployed subnet resource IDs without rebuilding the network resource paths manually.

## Verification

### Resource deployment verification

The resource group inventory showed all three top-level network resources in a successful provisioning state:

- `BatchClientNSG1`
- `BatchWireGuardNSG1`
- `BatchTestVNet1`

*See Evidence:* [08-network-resource-inventory-succeeded.png](../../screenshots/deployment/batch-deployment-phase-one/08-network-resource-inventory-succeeded.png)

The Azure Portal independently confirmed that `BatchTestVNet1` existed in `BatchTestResGroup2` after deployment.

*See Evidence:* [09-vnet-deployed-portal.png](../../screenshots/deployment/batch-deployment-phase-one/09-vnet-deployed-portal.png)

### Subnet verification

The subnet configuration was inspected through Azure CLI.

```powershell
az network vnet subnet list `
    --resource-group BatchTestResGroup2 `
    --vnet-name BatchTestVNet1 `
    --output table
```

The output confirmed both subnet names, address prefixes, provisioning states, and resource group placement.

*See Evidence:* [10-network-and-subnet-cli-verification.png](../../screenshots/deployment/batch-deployment-phase-one/10-network-and-subnet-cli-verification.png)

### Security rule verification

The Azure Portal confirmed that `BatchClientNSG1` contained the expected custom inbound SSH and ICMP rules and was associated with one subnet.

*See Evidence:* [11-client-nsg-security-rules.png](../../screenshots/deployment/batch-deployment-phase-one/11-client-nsg-security-rules.png)

The Azure Portal also confirmed that `BatchWireGuardNSG1` contained the restricted SSH rule and the UDP 51820 WireGuard tunnel rule and was associated with one subnet.

*See Evidence:* [12-wireguard-nsg-security-rules.png](../../screenshots/deployment/batch-deployment-phase-one/12-wireguard-nsg-security-rules.png)

### Teardown verification

The Phase 1 teardown test began by listing the deployed resource IDs.

```powershell
az resource list `
    --resource-group BatchTestResGroup2 `
    --query "[].id" `
    --output table
```

An initial attempt to delete `BatchClientNSG1` failed because the NSG was still associated with `BatchClientSN1`. The subnet-to-NSG associations were removed before deletion.

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

After dissociation, the two NSGs and the Virtual Network were deleted. Portal verification confirmed that the Phase 1 VNet and NSGs no longer appeared, while the resource group remained available for later project phases.

*See Evidence:* [13-vnet-deletion-verified.png](../../screenshots/deployment/batch-deployment-phase-one/13-vnet-deletion-verified.png)

*See Evidence:* [14-nsg-deletion-verified.png](../../screenshots/deployment/batch-deployment-phase-one/14-nsg-deletion-verified.png)

## Common Issues

### Template file not found

The first validation command failed because `./main.bicep` was resolved relative to the current PowerShell directory rather than the deployment directory.

The issue was corrected by changing to the directory containing `main.bicep` before rerunning validation.

```powershell
Set-Location "C:\Path\To\Deployment"
```

### Incorrect subnet command group

The command group `az network subnet` was not valid for the required operation. Azure CLI subnet management commands were available under:

```text
az network vnet subnet
```

Azure CLI help was used to confirm the correct `list` and `update` command structure.

### Network Security Group deletion blocked by association

Azure rejected the initial NSG deletion because the NSG was still attached to a subnet. The dependency was resolved by updating each subnet with `--nsg null` before deleting the NSGs.

### Administrator IP embedded in the module

The working network module restricted WireGuard SSH access to the administrator public IP address used during the test. The published module should parameterize this value rather than retaining a personal public IP address in source control.

## Lessons Learned

- Separating the network layer into a child module made the deployment easier to validate and extend.
- The parent file and child module path must be evaluated from the correct deployment directory.
- Validation and What-If exposed errors before the final deployment command was run.
- Azure resource dependencies affect teardown order even in a small test environment.
- Network Security Groups must be dissociated from subnets before the NSGs can be deleted independently.
- Module outputs provide a reliable way to pass subnet resource IDs into later deployment phases.
- Combining command logs, Azure CLI output, and Portal screenshots created a stronger evidence record than relying on one evidence type alone.

## Related Documents

- [VNet and Subnet Design](../../network/vnet-subnet-design.md)
- [NSG and ASG Implementation](../../network/nsg-asg-implementation.md)
- [Security Model](../../architecture/security-model.md)