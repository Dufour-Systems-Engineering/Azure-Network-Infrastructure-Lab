# Cost Control Operations Command Library

## Overview

This document preserves commands used to review, deallocate, verify, restart, and inspect Azure lab resources during the Cost Control Operations workflow.

The cost-control workflow focuses on the TestGroup1 resource group in the westus region. Commands were used to inventory VM power states, deallocate running systems, verify deallocation, review delete behavior for disks and NICs, and restart systems when needed.

## Purpose

This document explains commands used to support cost-control operations in the Azure Network Infrastructure Lab.

The goal is to preserve the commands used in the runbook, explain what each command does, and provide reusable reference material for future lab maintenance.

## Scope

This document covers:

- Resource group and region variables
- Azure CLI VM inventory
- Azure CLI VM startup
- Az PowerShell VM deallocation
- Az PowerShell VM power-state verification
- Az PowerShell delete-option review
- Az PowerShell VM startup
- PowerShell object filtering and output formatting

This document does not include Azure Portal-only review steps such as viewing Cost Management charts or Automation Account schedules unless a command was present in the source material.

## Source Material

Commands were compiled from:

- operations/cost-control-operations.md
- Cost Control Operations screenshots
- Azure Cloud Shell PowerShell evidence

## Command Groups

1. Scope Variables
2. VM Power-State Inventory
3. VM Deallocation
4. Deallocation Verification
5. Delete Option and Cleanup Review
6. VM Restart / Rollback

---

# Scope Variables

## Set Resource Group Variable

### Classification

Administration
Configuration

### Command

$rg = "TestGroup1"

### Purpose

Stores the target Azure resource group name in a reusable PowerShell variable.

### Context Used

Used before running cost-control commands against the TestGroup1 resource group.

### Breakdown

* `$rg` = PowerShell variable name.
* `=` = assignment operator.
* `"TestGroup1"` = resource group name stored as a string.

### Common Mistakes

* Typing the wrong resource group name.
* Forgetting quotes around the string value.
* Reusing the variable later without confirming its current value.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

## Set Location Variable

### Classification

Administration
Configuration

### Command

$location = "westus"

### Purpose

Stores the Azure region name in a reusable PowerShell variable.

### Context Used

Used to filter VM inventory and verification results to the westus region.

### Breakdown

* `$location` = PowerShell variable name.
* `=` = assignment operator.
* `"westus"` = Azure region value stored as a string.

### Common Mistakes

* Using the display name `West US` instead of the Azure location value `westus`.
* Forgetting quotes around the string.
* Filtering by the wrong region.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# VM Power-State Inventory

## List VM Power States with Azure CLI

### Classification

Validation
Evidence Gathering
Administration

### Command

az vm list -g $rg -d `
  --query "[?location=='$location'].{Name:name, State:powerState, Location:location}" `
  -o table

### Purpose

Lists virtual machines in the resource group, includes power-state details, filters by region, and displays the result as a table.

### Context Used

Used before shutdown to identify which systems were running and which systems were already deallocated.

### Breakdown

* `az` = Azure CLI command-line tool.
* `vm` = Azure virtual machine command group.
* `list` = lists virtual machines.
* `-g $rg` = limits the command to the resource group stored in `$rg`.
* `-d` = includes instance details such as power state.
* `` ` `` = PowerShell line-continuation character.
* `--query` = filters and reshapes the output.
* `[?location=='$location']` = filters results to the selected region.
* `{Name:name, State:powerState, Location:location}` = selects and renames output fields.
* `-o table` = displays output as a readable table.

### Common Mistakes

* Running the command before setting `$rg` or `$location`.
* Using incorrect quote syntax inside the query.
* Forgetting the backtick line continuation in PowerShell.
* Assuming this command modifies VMs. It is read-only.

### Related Syntax

* [Azure CLI Query Syntax Reference](../syntax/azure-cli-query-syntax.md)
* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# VM Deallocation

## Deallocate a Single VM with Az PowerShell

### Classification

Administration
Maintenance
Cost Control

### Command

Stop-AzVM `
  -ResourceGroupName "TestGroup1" `
  -Name "TestClientVM1" `
  -Force

### Purpose

Stops and deallocates a specific Azure VM.

### Context Used

Used to deallocate a running lab VM so it no longer consumed active compute resources.

### Breakdown

* `Stop-AzVM` = Az PowerShell cmdlet used to stop an Azure VM.
* `` ` `` = PowerShell line-continuation character.
* `-ResourceGroupName "TestGroup1"` = targets the resource group containing the VM.
* `-Name "TestClientVM1"` = targets the VM by name.
* `-Force` = skips interactive confirmation.

### Common Mistakes

* Confusing guest OS shutdown with Azure VM deallocation.
* Targeting the wrong VM name.
* Using `-Force` without checking the target first.
* Forgetting that deallocated VMs must be started again before use.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# Deallocation Verification

## Verify VM Power States with Az PowerShell

### Classification

Validation
Evidence Gathering
Administration

### Command

Get-AzVM -ResourceGroupName $rg -Status |
Where-Object { $_.Location -eq $location } |
Select-Object Name, Location, PowerState

### Purpose

Lists VM status information, filters VMs by region, and displays name, location, and power state.

### Context Used

Used after deallocation to verify that lab VMs showed the expected `VM deallocated` state.

### Breakdown

* `Get-AzVM` = gets Azure VM information.
* `-ResourceGroupName $rg` = targets the resource group stored in `$rg`.
* `-Status` = includes VM status and power-state information.
* `|` = sends output to the next command.
* `Where-Object` = filters objects.
* `{ $_.Location -eq $location }` = keeps only VMs where the Location property matches `$location`.
* `Select-Object` = selects specific properties for output.
* `Name, Location, PowerState` = properties displayed in the result.

### Common Mistakes

* Omitting `-Status`, which can prevent power-state information from appearing.
* Forgetting that PowerShell pipes objects, not just text.
* Using the wrong comparison operator.
* Filtering by the wrong region.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# Delete Option and Cleanup Review

## Review OS Disk and NIC Delete Options

### Classification

Validation
Evidence Gathering
Cleanup
Administration

### Command

Get-AzVM -ResourceGroupName $rg |
Where-Object { $_.Location -eq $location } |
Select-Object `
  Name,
  Location,
  @{Name="OSDiskDeleteOption";Expression={$_.StorageProfile.OSDisk.DeleteOption}},
  @{Name="NICDeleteOption";Expression={$_.NetworkProfile.NetworkInterfaces[0].DeleteOption}} |
Format-Table -AutoSize

### Purpose

Reviews whether VM OS disks and NICs are configured to delete or detach when a VM is deleted.

### Context Used

Used during cleanup review to identify whether disposable lab VMs would remove dependent resources automatically or leave behind disks and NICs.

### Breakdown

* `Get-AzVM` = gets Azure VM objects.
* `-ResourceGroupName $rg` = targets the selected resource group.
* `|` = passes VM objects to the next command.
* `Where-Object { $_.Location -eq $location }` = filters VMs by region.
* `Select-Object` = selects output properties.
* `` ` `` = PowerShell line-continuation character.
* `Name` = VM name.
* `Location` = Azure region.
* `@{Name="OSDiskDeleteOption";Expression={...}}` = calculated property for OS disk delete behavior.
* `$_.StorageProfile.OSDisk.DeleteOption` = reads the OS disk delete option from each VM object.
* `@{Name="NICDeleteOption";Expression={...}}` = calculated property for NIC delete behavior.
* `$_.NetworkProfile.NetworkInterfaces[0].DeleteOption` = reads the delete option for the first NIC attached to the VM.
* `Format-Table -AutoSize` = displays the output as a table sized to fit the content.

### Common Mistakes

* Assuming all VMs have the same delete behavior.
* Forgetting that infrastructure VMs may intentionally retain disks or NICs.
* Misreading `Detach` as an error when retention is intentional.
* Blindly deleting retained disks or NICs without confirming they are disposable.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# VM Restart / Rollback

## Start a VM with Az PowerShell

### Classification

Administration
Rollback
Maintenance

### Command

Start-AzVM `
  -ResourceGroupName "TestGroup1" `
  -Name "TestClientVM1"

### Purpose

Starts a previously stopped or deallocated Azure VM.

### Context Used

Used as the rollback procedure when a deallocated VM is needed again for lab work.

### Breakdown

* `Start-AzVM` = Az PowerShell cmdlet used to start an Azure VM.
* `` ` `` = PowerShell line-continuation character.
* `-ResourceGroupName "TestGroup1"` = resource group containing the VM.
* `-Name "TestClientVM1"` = VM to start.

### Common Mistakes

* Starting the wrong VM.
* Forgetting that startup may take time.
* Assuming the VM is ready immediately after the command returns.
* Not verifying power state after startup.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

## Start a VM with Azure CLI

### Classification

Administration
Rollback
Maintenance

### Command

az vm start `
  --resource-group TestGroup1 `
  --name TestClientVM1

### Purpose

Starts a stopped or deallocated Azure VM using Azure CLI.

### Context Used

Provided as an Azure CLI rollback option for starting a VM after it was deallocated.

### Breakdown

* `az` = Azure CLI command-line tool.
* `vm` = Azure virtual machine command group.
* `start` = starts the specified VM.
* `` ` `` = PowerShell line-continuation character.
* `--resource-group TestGroup1` = resource group containing the VM.
* `--name TestClientVM1` = VM to start.

### Common Mistakes

* Mixing Azure CLI parameter names with Az PowerShell parameter names.
* Forgetting that the command is Azure CLI even when run from PowerShell.
* Starting the wrong VM.
* Not verifying the VM state after startup.

### Related Syntax

* [Azure CLI Query Syntax Reference](../syntax/azure-cli-query-syntax.md)
* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

## Verify Startup State

### Classification

Validation
Evidence Gathering
Administration

### Command

Get-AzVM -ResourceGroupName "TestGroup1" -Status |
Select-Object Name, Location, PowerState

### Purpose

Verifies VM power state after startup.

### Context Used

Used after restarting a VM to confirm that the expected state changed to `VM running`.

### Breakdown

* `Get-AzVM` = gets Azure VM information.
* `-ResourceGroupName "TestGroup1"` = targets the selected resource group.
* `-Status` = includes status and power-state data.
* `|` = sends objects to the next command.
* `Select-Object Name, Location, PowerState` = displays only the selected fields.

### Common Mistakes

* Omitting `-Status`.
* Assuming the VM is running without checking.
* Checking the wrong resource group.

### Related Syntax

* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

---

# Bulk Deallocation

## Deallocate Every VM in a Resource Group

### Classification

Validated Azure CLI command. Use only when every VM in the selected resource group should stop incurring compute charges.

### Command

```powershell
az vm deallocate --resource-group <RESOURCE_GROUP> --ids $(az vm list --resource-group <RESOURCE_GROUP> --query "[].id" --output tsv)
```

### Purpose

Collect the VM resource IDs in a resource group and deallocate them as one operation.

### Common Mistakes

* Running the command against a shared resource group that contains a gateway or monitoring VM that must remain available.
* Confusing a stopped guest OS with Azure's `Stopped (deallocated)` state.

---

# Targeted Client Teardown

## Select Client VMs from the Client Subnet

### Classification

Validated Phase 5 safety sequence.

### Commands

```powershell
$clientVmIds = @(
    az network nic list `
        --resource-group <RESOURCE_GROUP> `
        --query "[?contains(ipConfigurations[].subnet.id, '/subnets/<CLIENT_SUBNET>')].virtualMachine.id" `
        --output tsv
)

$clientVmIds.Count
$clientVmIds | ForEach-Object { ($_ -split '/')[-1] }
$gatewaySelected = [bool]($clientVmIds -match '/virtualMachines/<WIREGUARD_VM_NAME>$')
$gatewaySelected
```

### Purpose

Build and inspect an explicit client-VM deletion set, then verify that the WireGuard gateway is not included.

### Common Mistakes

* Treating array `-match` output as a Boolean without converting it.
* Continuing when the count or names differ from the expected client deployment.

---

## Delete the Reviewed Client VM Set

### Classification

Validated destructive command.

### Command

```powershell
az vm delete --ids $clientVmIds --yes
```

### Required Precondition

Print the selected names and verify that the gateway-selection Boolean is `False` before running the command.

---

## Verify the Teardown Result

### Classification

Validated post-deletion sequence.

### Commands

```powershell
az vm list --resource-group <RESOURCE_GROUP> --query "[].name" --output table
az network nic list --resource-group <RESOURCE_GROUP> --query "[].name" --output table
az disk list --resource-group <RESOURCE_GROUP> --query "[].name" --output table
az vm show --resource-group <RESOURCE_GROUP> --name <WIREGUARD_VM_NAME> --query "{Name:name, ProvisioningState:provisioningState}" --output table
```

### Purpose

Confirm that the client VMs are gone, identify any remaining NICs or disks, and verify that the WireGuard gateway still exists.

---

## Related Documents

* [Cost Control Operations](../../operations/cost-control-operations.md)
* [Azure CLI Command Reference](../azure-cli/azure-cli.md)
* [PowerShell Command Reference](../powershell/powershell.md)
* [Azure CLI Query Syntax Reference](../syntax/azure-cli-query-syntax.md)
* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)
