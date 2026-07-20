# Batch Deployment Phase 5 — Teardown and Cleanup

## Overview

Phase 5 completed the Central US batch-deployment lifecycle by removing the six temporary client virtual machines while preserving the reusable network foundation and the configured WireGuard VPN server. The teardown was intentionally selective because the client VMs and `BatchWireGuardVM1` shared `BatchTestResGroup2` but had different lifecycle requirements.

The client VMs had completed their purpose as deployment and connectivity-validation targets. Their resource IDs were discovered through NIC membership in `BatchClientSN1`, reviewed as a six-VM deletion allowlist, and checked to confirm that `BatchWireGuardVM1` was not included. Azure CLI then deleted only those six VM resource IDs.

The Phase 2 Bicep module had configured each client VM's primary NIC and managed OS disk with `deleteOption: 'Delete'`. Post-deletion queries confirmed that all six client VMs, all six client NICs, and all six client OS disks were removed without separate NIC or disk deletion commands.

The virtual network, network security groups, WireGuard VM, WireGuard public IP, WireGuard NIC, and WireGuard OS disk remained. The final resource-group inventory contained seven resources. `BatchWireGuardVM1` was then deallocated to stop compute allocation while retaining its configuration for later use.

This phase covers lifecycle planning, targeted client-compute deletion, dependent-resource cleanup verification, retained-resource verification, and WireGuard VM deallocation. It does not delete the reusable network foundation or the operational WireGuard gateway.

## Purpose

The purpose of Phase 5 was to close the batch-deployment project with a controlled, evidence-backed teardown that removed disposable compute without destroying infrastructure that retained operational value.

The implementation was designed to:

- Delete only `BatchTestClientVM1` through `BatchTestClientVM6`.
- Use client-subnet membership as the authoritative resource-selection boundary.
- Review the complete VM resource IDs before performing deletion.
- Explicitly confirm that `BatchWireGuardVM1` was absent from the target array.
- Use Azure CLI for Azure resource discovery, deletion, verification, and deallocation.
- Use Windows PowerShell only as the local command host and for storing and inspecting Azure CLI output.
- Rely on the deployed Bicep `deleteOption` settings for automatic client NIC and OS-disk cleanup.
- Verify the absence of all client VMs, NICs, and managed OS disks after deletion.
- Preserve the VNet, NSGs, WireGuard VM, public IP, NIC, and OS disk.
- Deallocate the retained WireGuard VM to reduce compute cost while preserving its configuration.
- Preserve milestone screenshots and session logs as the authoritative implementation record.

## Prerequisites

The following resources and tools were required before Phase 5 began:

- The completed Phase 4 WireGuard configuration and access validation.
- Azure CLI installed and authenticated to the correct Azure subscription.
- Windows PowerShell available as the local Azure CLI command host.
- Access to `BatchTestResGroup2` with permission to list and delete virtual machines.
- `BatchTestVNet1` with separate client and WireGuard subnets.
- Six client VMs attached through NICs in `BatchClientSN1`.
- `BatchWireGuardVM1` attached through its NIC in `BatchWireGuardSN1`.
- The deployed Phase 2 Bicep module showing `deleteOption: 'Delete'` for each client OS disk and primary NIC.
- A completed Phase 4 validation proving that the six client systems had fulfilled their test purpose.
- PowerShell transcript capture and redacted screenshots for pre-deletion and post-deletion validation.

The pre-teardown Azure configuration was:

| Resource | Configuration |
| --- | --- |
| Resource group | `BatchTestResGroup2` |
| Deployment region | Central US |
| Virtual network | `BatchTestVNet1` |
| Client subnet | `BatchClientSN1` — `10.10.0.0/28` |
| WireGuard subnet | `BatchWireGuardSN1` — `10.10.0.32/28` |
| Client NSG | `BatchClientNSG1` |
| WireGuard NSG | `BatchWireGuardNSG1` |
| Client VMs | `BatchTestClientVM1` through `BatchTestClientVM6` |
| Client NICs | `BatchTestClientVM1-nic` through `BatchTestClientVM6-nic` |
| Client OS disks | `BatchTestClientVM1-osdisk` through `BatchTestClientVM6-osdisk` |
| Protected VM | `BatchWireGuardVM1` |
| Protected public IP | `BatchWireGuardVM1-ip` |
| Protected NIC | `BatchWireGuardVM1-nic` |
| Protected OS disk | `BatchWireGuardVM1-osdisk` |

The intended Phase 5 lifecycle result was:

| Resource class | Lifecycle action |
| --- | --- |
| Six client VMs | Delete |
| Six client NICs | Delete automatically with their VMs |
| Six client OS disks | Delete automatically with their VMs |
| WireGuard VM and dependent resources | Retain |
| WireGuard VM compute allocation | Deallocate after verification |
| VNet, subnets, and NSGs | Retain as reusable infrastructure |

## Deployment Procedure

### 1. Confirm the pre-teardown resource inventory

The Azure portal resource-group view showed 25 resources before cleanup. The inventory included six client VMs, six client NICs, six client OS disks, the WireGuard VM and its dependent resources, the VNet, and both NSGs.

The two screenshots cover the upper and lower portions of the same resource-group inventory. Together they establish the pre-deletion state and show that the disposable client resources and retained WireGuard resources existed in the shared resource group.

*See Evidence:* [Pre-teardown resource inventory — part 1](../../screenshots/deployment/batch-deployment-phase-five-cleanup/01-pre-teardown-resource-inventory-part-1.png)

*See Evidence:* [Pre-teardown resource inventory — part 2](../../screenshots/deployment/batch-deployment-phase-five-cleanup/02-pre-teardown-resource-inventory-part-2.png)

### 2. Confirm automatic dependent-resource cleanup in Bicep

The client VM module defined automatic deletion for the managed OS disk:

```bicep
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
```

The same module defined automatic deletion for the attached primary NIC:

```bicep
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
```

The module declared `dataDisks: []` and did not associate public IP resources with the client NICs. Therefore, the expected cleanup scope was each client VM, its primary NIC, and its managed OS disk.

These settings established the expected behavior, but the post-deletion Azure queries remained necessary to prove that the deployed resources were actually removed.

### 3. Discover the client VM resource IDs through subnet membership

The subnet inventory showed six NIC IP-configuration references in `BatchClientSN1` and one separate WireGuard NIC reference in `BatchWireGuardSN1`. The client subnet therefore provided a clean selection boundary for the six disposable client systems.

The following publication-safe form represents the executed Azure CLI query. The live subscription identifier is replaced with a placeholder:

```powershell
az network nic list `
    --resource-group BatchTestResGroup2 `
    --query "[?contains(ipConfigurations[].subnet.id, '/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/BatchTestResGroup2/providers/Microsoft.Network/virtualNetworks/BatchTestVNet1/subnets/BatchClientSN1')].virtualMachine.id" `
    --output tsv
```

The command listed NICs in the resource group, retained only NICs associated with `BatchClientSN1`, and returned each attached VM's complete resource ID as tab-separated text.

The output contained `BatchTestClientVM1` through `BatchTestClientVM6` and did not contain the WireGuard VM.

*See Evidence:* [Select client VM IDs from the client subnet](../../screenshots/deployment/batch-deployment-phase-five-cleanup/03-client-vm-ids-selected-from-client-subnet.png)

### 4. Build and validate the deletion allowlist

The Azure CLI output was stored in a PowerShell array:

```powershell
$clientVmIds = @(
    az network nic list `
        --resource-group BatchTestResGroup2 `
        --query "[?contains(ipConfigurations[].subnet.id, '/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/BatchTestResGroup2/providers/Microsoft.Network/virtualNetworks/BatchTestVNet1/subnets/BatchClientSN1')].virtualMachine.id" `
        --output tsv
)
```

The array count was checked and the final path segment of every resource ID was displayed:

```powershell
$clientVmIds.Count

$clientVmIds | ForEach-Object {
    ($_ -split '/')[-1]
}
```

The count returned `6`, and the displayed names were exactly `BatchTestClientVM1` through `BatchTestClientVM6`.

The protected VM was then checked explicitly:

```powershell
$wireGuardVmFound = [bool](
    $clientVmIds -match '/virtualMachines/BatchWireGuardVM1$'
)

$wireGuardVmFound
```

The Boolean result was `False`, confirming that the WireGuard VM was outside the deletion allowlist.

*See Evidence:* [Exclude the WireGuard VM from deletion targets](../../screenshots/deployment/batch-deployment-phase-five-cleanup/04-wireguard-vm-excluded-from-deletion-targets.png)

### 5. Delete the six client VMs by resource ID

After validating the six-ID allowlist, Azure CLI deleted only those resources:

```powershell
az vm delete --ids $clientVmIds --yes
```

`--ids` supplied the six complete client VM resource IDs. Because each ID already contained the subscription, resource group, provider, and VM name, separate `--resource-group` and `--name` arguments were unnecessary.

`--yes` suppressed the interactive confirmation prompt without expanding the deletion scope. `--no-wait` was intentionally omitted so that the deletion operation completed before post-deletion validation began.

Azure CLI returned an array containing six `null` entries. The final resource queries, rather than that minimal response body, were used to determine whether the deletion and dependent-resource cleanup succeeded.

*See Evidence:* [Complete targeted client VM deletion](../../screenshots/deployment/batch-deployment-phase-five-cleanup/05-client-vm-targeted-deletion-completed.png)

### 6. Verify client VM, NIC, and OS-disk removal

The remaining VM, NIC, and managed-disk names were queried independently:

```powershell
az vm list `
    --resource-group BatchTestResGroup2 `
    --query "[].name" `
    --output table

az network nic list `
    --resource-group BatchTestResGroup2 `
    --query "[].name" `
    --output table

az disk list `
    --resource-group BatchTestResGroup2 `
    --query "[].name" `
    --output table
```

The results contained only:

- `BatchWireGuardVM1`
- `BatchWireGuardVM1-nic`
- `BatchWireGuardVM1-osdisk`

None of the six client VMs, NICs, or OS disks remained. This validated that the Bicep delete behavior was effective and that separate NIC or disk deletion commands were not required.

*See Evidence:* [Verify client VM, NIC, and disk removal](../../screenshots/deployment/batch-deployment-phase-five-cleanup/06-client-vm-nic-and-disk-removal-verified.png)

### 7. Verify the retained Azure resource inventory

The refreshed Azure portal view showed seven remaining resources:

- `BatchClientNSG1`
- `BatchTestVNet1`
- `BatchWireGuardNSG1`
- `BatchWireGuardVM1`
- `BatchWireGuardVM1-ip`
- `BatchWireGuardVM1-nic`
- `BatchWireGuardVM1-osdisk`

This reduced the resource group from 25 resources to seven while preserving the reusable network foundation and the WireGuard gateway resources.

*See Evidence:* [Post-teardown resource inventory in the Azure portal](../../screenshots/deployment/batch-deployment-phase-five-cleanup/07-post-teardown-resource-inventory-in-portal.png)

### 8. Confirm that the WireGuard VM remained provisioned

The retained VM was queried directly:

```powershell
az vm show `
    --resource-group BatchTestResGroup2 `
    --name BatchWireGuardVM1 `
    --query "{Name:name, ProvisioningState:provisioningState}" `
    --output table
```

The result returned `BatchWireGuardVM1` with provisioning state `Succeeded`. This explicitly proved that the targeted client deletion had not removed or damaged the protected VM resource.

*See Evidence:* [Verify WireGuard VM preservation](../../screenshots/deployment/batch-deployment-phase-five-cleanup/08-wireguard-vm-preservation-verified.png)

### 9. Deallocate the retained WireGuard VM

After teardown verification, the retained VM was deallocated:

```powershell
az vm deallocate `
    --resource-group BatchTestResGroup2 `
    --name BatchWireGuardVM1
```

Its power state was then queried:

```powershell
az vm show -d `
    --resource-group BatchTestResGroup2 `
    --name BatchWireGuardVM1 `
    --query powerState `
    --output tsv
```

The command returned `VM deallocated`. The Azure portal independently showed `BatchWireGuardVM1` as `Stopped (deallocated)`.

Deallocation released the VM's compute allocation while preserving the VM definition, OS disk, NIC, public IP association, and completed WireGuard configuration.

*See Evidence:* [Verify WireGuard VM deallocation with Azure CLI](../../screenshots/deployment/batch-deployment-phase-five-cleanup/09-wireguard-vm-deallocated-cli-verification.png)

*See Evidence:* [Verify WireGuard VM deallocation in the Azure portal](../../screenshots/deployment/batch-deployment-phase-five-cleanup/10-wireguard-vm-deallocated-portal-verification.png)

## Configuration Procedure

### Utility-based lifecycle model

The final resource state was selected according to continuing utility rather than treating every deployed resource identically.

The six client VMs were temporary validation systems. They had demonstrated Bicep-based batch creation, private addressing, WireGuard-routed connectivity, reachability, and SSH access. After those tests were complete, retaining them would continue compute and storage use without adding operational value.

The WireGuard VM provided continuing remote-access value. The VNet, subnets, and NSGs also represented a reusable network foundation. Those resources were retained rather than destroyed solely because the batch test had ended.

### Subnet-based resource selection

All seven VMs were located in the same resource group, so a resource-group-wide VM deletion would have violated the retention requirement. Name-prefix matching was possible, but subnet membership provided an infrastructure-derived boundary tied directly to the deployed architecture.

The selection process followed this chain:

1. List NICs in `BatchTestResGroup2`.
2. Filter NICs whose IP configurations referenced `BatchClientSN1`.
3. Return the attached `virtualMachine.id` values.
4. Store the six IDs in a PowerShell array.
5. Review the count and names.
6. Confirm that the protected WireGuard VM ID was absent.
7. Pass only the reviewed IDs to `az vm delete`.

This made the deletion scope explicit and auditable before the destructive operation was executed.

### Bicep-managed dependent-resource lifecycle

The client VM module associated the primary NIC and managed OS disk with the VM lifecycle through `deleteOption: 'Delete'`. The teardown therefore tested not only VM deletion but also whether the infrastructure definition correctly expressed cleanup behavior.

The post-deletion VM, NIC, and disk queries were essential. Bicep configuration expressed the intended dependency behavior; Azure resource inventory established the result.

### Retention and cost control

Preservation did not require the WireGuard VM to remain continuously allocated. Deallocation allowed the configured VM to remain available for later startup while stopping its compute allocation.

The retained managed disk and other persistent resources may continue to incur their own charges. The Phase 5 cost-control result is therefore specifically that VM compute allocation was released, not that all costs associated with the retained environment were eliminated.

### Source and assistance methodology

The primary implementation record consists of the executed Azure CLI commands, PowerShell transcript, copied session output, Bicep configuration, Azure portal screenshots, and post-deletion resource inventory.

Azure CLI help and Microsoft Learn documentation were used to confirm the VM deletion, VM listing, NIC listing, disk listing, VM inspection, and VM deallocation commands. Microsoft PowerShell documentation explains why comparison operators return matching elements when the left operand is a collection.

AI assistance supported lifecycle planning, evidence organization, command discovery, query formulation, explanation of command behavior, and troubleshooting of the PowerShell collection match. AI output was not used as evidence that deletion succeeded. The user's executed commands and captured Azure state established the final result.

### Phase boundary

Phase 5 includes:

- Pre-teardown inventory review.
- Client VM selection through `BatchClientSN1` membership.
- Deletion-allowlist validation.
- Targeted deletion of the six client VMs.
- Automatic NIC and OS-disk cleanup verification.
- Retained-resource verification.
- WireGuard VM deallocation and power-state verification.

Phase 5 excludes:

- Creation of the network foundation, completed in Phase 1.
- Deployment of the client VM module, completed in Phase 2.
- Deployment of the WireGuard VM, completed in Phase 3.
- WireGuard guest and client configuration, completed in Phase 4.
- Deletion of the retained VNet, subnets, NSGs, or WireGuard resources.

## Verification

### Deletion-scope verification

The client VM resource-ID array contained exactly six entries. Displaying their final path segments produced `BatchTestClientVM1` through `BatchTestClientVM6`. The explicit protected-resource test returned `False` for `BatchWireGuardVM1`.

### Client-resource removal verification

Post-deletion Azure CLI queries showed that the six client VMs, six client NICs, and six client OS disks were absent. Only the WireGuard VM, NIC, and OS disk remained in their respective resource lists.

### Retained-infrastructure verification

The Azure portal showed `BatchTestVNet1`, `BatchClientNSG1`, and `BatchWireGuardNSG1` still present alongside the four WireGuard resources. The final portal resource count was seven.

The subnets are child resources of the VNet and therefore do not appear as separate entries in the resource-group inventory. The pre-teardown subnet query confirmed both subnets and their NIC associations. A separate post-deletion subnet query was not captured, so the evidence directly verifies retention of the VNet and NSGs rather than presenting an independent post-teardown subnet inventory.

### WireGuard preservation verification

`az vm show` returned `BatchWireGuardVM1` with provisioning state `Succeeded`, confirming that the VM resource survived the targeted deletion operation.

### WireGuard deallocation verification

The CLI power-state query returned `VM deallocated`, and the portal displayed `Stopped (deallocated)`. These two independent views confirmed release of the WireGuard VM compute allocation while preserving the VM resource.

### Final state

| Category | Final verified state |
| --- | --- |
| Client VMs | Six removed |
| Client NICs | Six removed |
| Client OS disks | Six removed |
| WireGuard VM | Preserved |
| WireGuard VM provisioning state after deletion | `Succeeded` |
| WireGuard VM final power state | `Stopped (deallocated)` |
| WireGuard NIC | Preserved |
| WireGuard OS disk | Preserved |
| WireGuard public IP | Preserved |
| VNet | Preserved |
| NSGs | Both preserved |
| Resource-group count | Reduced from 25 to seven |

### Evidence limitations

- The final two deallocation screenshots were captured after the original teardown transcript ended. They independently document the later deallocation command and portal power state.
- The post-deletion portal inventory confirms the VNet and NSGs but does not display the VNet's child subnets as separate resource-group rows.
- The `az vm delete` response contained six `null` values and did not itself provide a human-readable success statement. The post-deletion resource queries and portal inventory provide the deletion proof.
- Subscription identifiers, account information, public endpoints, and other publication-sensitive values must remain redacted in the screenshot set.

## Common Issues

### The initial subnet command paths were invalid

The exploratory commands `az subnet --help` and `az network subnet --help` were not recognized. Azure CLI places subnet management under the VNet command group:

```powershell
az network vnet subnet list --help
```

This command path was then used to inspect `BatchTestVNet1` and confirm the client and WireGuard subnet membership.

### `az vm id` was not a valid command

The exploratory command `az vm id --help` was not recognized. The required VM IDs were instead obtained from each NIC's `virtualMachine.id` property through `az network nic list`.

This approach also allowed the subnet association and attached VM identity to be evaluated in the same query.

### The first WireGuard exclusion check displayed no output

The initial check was:

```powershell
$clientVmIds -match '/virtualMachines/BatchWireGuardVM1$'
```

With a collection on the left side, PowerShell's comparison operators return matching collection elements rather than a single Boolean value. Because no element matched, the command displayed nothing.

Casting the expression to Boolean produced the required explicit result:

```powershell
[bool]($clientVmIds -match '/virtualMachines/BatchWireGuardVM1$')
```

The result was `False`.

### Resource-group-wide VM deletion would have been unsafe

An unfiltered query for every VM ID in `BatchTestResGroup2` would have included `BatchWireGuardVM1`. Because the resource group contained both disposable and retained compute, resource-group membership alone was not a safe deletion boundary.

Filtering through `BatchClientSN1` and reviewing the six resulting IDs prevented the protected WireGuard VM from entering the deletion command.

### The deletion response contained `null` values

`az vm delete --ids $clientVmIds --yes` returned six `null` entries. That response was not treated as proof of either success or failure.

The remaining VM, NIC, and disk inventories were queried after the command completed. Their results established that all client compute and its dependent resources were removed.

### Provisioning state and power state answer different questions

The post-deletion `provisioningState: Succeeded` result proved that the WireGuard VM resource remained valid after targeted deletion. It did not prove that the VM had been deallocated.

A later detailed VM query returned `VM deallocated`, and the portal showed `Stopped (deallocated)`. Both checks were required to document preservation and compute deallocation accurately.

## Lessons Learned

- Teardown is part of infrastructure lifecycle engineering, not an afterthought to deployment.
- Resources sharing a resource group can still require different lifecycle actions.
- A destructive command should consume a reviewed allowlist rather than an unverified broad query.
- Subnet membership can provide a reliable selection boundary when it matches the deployed architecture.
- Displaying both the target count and resource names makes the deletion scope easier to audit.
- Protected resources should be checked explicitly before a destructive command runs.
- Bicep `deleteOption` settings can couple NIC and OS-disk cleanup to VM deletion.
- Declared cleanup behavior must still be verified against the actual post-deletion Azure inventory.
- A minimal or empty deletion response is not a substitute for final-state validation.
- PowerShell comparison operators behave differently when the left operand is a collection; explicit casting is useful when a Boolean result is required.
- Provisioning state and runtime power state must not be treated as interchangeable.
- Deallocation preserves a configured VM while releasing its compute allocation.
- Retaining a deallocated VM can still incur charges for persistent resources such as managed disks.
- Portal and CLI evidence provide stronger validation when they independently show the same final state.
- Milestone evidence can keep the published document focused while complete transcripts and supporting artifacts remain archived.
- Subscription identifiers, endpoints, and account details should be redacted before publication even when they are not authentication secrets.
- AI assistance should be disclosed by function, while executed commands and captured platform state remain the implementation authority.

## Related Documents

- [Batch Deployment Network Foundation](phase-1-batch-deployment-network-foundation-module.md)
- [Batch Deployment Phase 2 — Client VM Module](phase-2-batch-deployment-client-vm-module.md)
- [Batch Deployment Phase 3 — WireGuard VM Module](phase-3-batch-deployment-wireguard-module.md)
- [Batch Deployment Phase 4 — WireGuard VPN Server Configuration](./phase-4-batch-deployment-wireguard-vpn-server-configuration.md)
- [Azure CLI `az vm` reference](https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest)
- [Azure CLI `az network nic` reference](https://learn.microsoft.com/en-us/cli/azure/network/nic?view=azure-cli-latest)
- [Azure CLI `az disk` reference](https://learn.microsoft.com/en-us/cli/azure/disk?view=azure-cli-latest)
- [Microsoft.Compute virtual machine Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines)
- [PowerShell comparison operators](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators)