# Cost Control Operations

## Overview

This runbook documents cost-control procedures for the Azure Network Infrastructure Lab. The environment uses manually deallocated virtual machines, scheduled shutdown automation, cost analysis review, and cleanup checks to reduce unnecessary compute and storage costs.

The cost-control process focuses on the `TestGroup1` resource group in the `westus` region.

## Purpose

The purpose of this runbook is to define how lab resources are reviewed, shut down, verified, and cleaned up when they are not actively being used.

The lab includes multiple Azure virtual machines, networking resources, managed disks, and monitoring components. Because compute resources can continue generating cost when left running, the environment requires a repeatable shutdown and verification workflow.

## Business Rationale

Cost control is important in a cloud lab because unused resources can generate recurring charges even when no active testing is occurring. This runbook demonstrates operational discipline by showing that lab systems are reviewed by region, stopped when idle, verified after deallocation, and checked for leftover resources.

This process supports:

* Reduced unnecessary compute spend
* Controlled use of lab resources
* Repeatable shutdown procedures
* Verification of VM power states
* Review of scheduled shutdown automation
* Identification of cleanup exceptions such as retained disks or NICs

## Prerequisites

Before performing cost-control operations, the following are required:

* Access to the Azure subscription
* Access to the `TestGroup1` resource group
* Azure Cloud Shell or local PowerShell with Az modules installed
* Permission to view and manage virtual machines
* Permission to view Automation Account resources
* Permission to review disks and network interfaces
* Awareness of which VMs are disposable and which retain important configuration state

Primary scope:

```powershell
$rg = "TestGroup1"
$location = "westus"
```

## Procedure

### 1. Review current cost status

Open Azure Cost Management and review the current billing scope, accumulated cost, forecast, budget, and service-level cost breakdown.

In this lab, the cost analysis view was used to review the current monthly cost, forecasted cost, budget threshold, and service categories contributing to spend.

*See Evidence:* [01-resource-group-cost-overview.png](../screenshots/operations/cost-control-operations/01-resource-group-cost-overview.png)

### 2. Inventory VM power states by region

Before shutting anything down, list the virtual machines in the `westus` region and review their current power states.

Azure CLI example:

```powershell
$rg = "TestGroup1"
$location = "westus"

az vm list -g $rg -d `
  --query "[?location=='$location'].{Name:name, State:powerState, Location:location}" `
  -o table
```

This identifies which systems are running and which are already deallocated.

*See Evidence:* [02-vm-power-state-inventory.png](../screenshots/operations/cost-control-operations/02-vm-power-state-inventory.png)

### 3. Deallocate running VMs

When a VM is no longer needed, deallocate it instead of simply stopping the operating system from inside the guest. Deallocation releases the compute allocation and is the required state for controlling compute cost.

PowerShell example for a single VM:

```powershell
Stop-AzVM `
  -ResourceGroupName "TestGroup1" `
  -Name "TestClientVM1" `
  -Force
```

The command returns an operation result showing whether the action succeeded.

*See Evidence:* [03-vm-deallocation-command.png](../screenshots/operations/cost-control-operations/03-vm-deallocation-command.png)

### 4. Verify deallocation

After shutdown, verify that the VM power state changed from `VM running` to `VM deallocated`.

PowerShell verification example:

```powershell
$rg = "TestGroup1"
$location = "westus"

Get-AzVM -ResourceGroupName $rg -Status |
Where-Object { $_.Location -eq $location } |
Select-Object Name, Location, PowerState
```

Expected result:

```text
VM deallocated
```

This confirms that the VM is no longer consuming active compute resources.

*See Evidence:* [04-vms-deallocated-verification.png](../screenshots/operations/cost-control-operations/04-vms-deallocated-verification.png)

### 5. Confirm scheduled shutdown automation

The lab uses an Azure Automation Account named `AutoShutdownLab` with a runbook named `ShutdownAzureVM`.

The runbook is linked to a schedule named `Daily5PMShutdown`, which is enabled and configured to run in Pacific Time. This provides a recurring shutdown control in addition to manual deallocation.

Automation components:

| Component          | Purpose                                     |
| ------------------ | ------------------------------------------- |
| `AutoShutdownLab`  | Azure Automation Account                    |
| `ShutdownAzureVM`  | PowerShell runbook used for VM shutdown     |
| `Daily5PMShutdown` | Scheduled execution of the shutdown runbook |
| Pacific Time       | Schedule time zone                          |
| Status: On         | Confirms the schedule is enabled            |

*See Evidence:* [05-auto-shutdown-runbook-schedule.png](../screenshots/operations/cost-control-operations/05-auto-shutdown-runbook-schedule.png)

### 6. Review delete options and cleanup behavior

Cost control also includes reviewing whether deleted VMs leave behind managed disks or network interfaces.

Disposable lab VMs should generally use delete-on-removal behavior for OS disks and NICs. Persistent infrastructure VMs may intentionally retain disks or NICs depending on their role.

PowerShell example:

```powershell
$rg = "TestGroup1"
$location = "westus"

Get-AzVM -ResourceGroupName $rg |
Where-Object { $_.Location -eq $location } |
Select-Object `
  Name,
  Location,
  @{Name="OSDiskDeleteOption";Expression={$_.StorageProfile.OSDisk.DeleteOption}},
  @{Name="NICDeleteOption";Expression={$_.NetworkProfile.NetworkInterfaces[0].DeleteOption}} |
Format-Table -AutoSize
```

In this lab, client VMs were reviewed for delete-on-removal behavior. Infrastructure systems such as the monitoring VM, NFS server, or WireGuard gateway may require separate review because they can contain configuration state or supporting network dependencies.

*See Evidence:* [06-delete-option-and-orphan-cleanup-verification.png](../screenshots/operations/cost-control-operations/06-delete-option-and-orphan-cleanup-verification.png)

## Verification

Successful cost-control execution is confirmed when:

* Cost analysis has been reviewed for the current billing period
* VM power states have been inventoried by region
* Running lab VMs have been deallocated when not in use
* Follow-up verification shows `VM deallocated`
* Azure Automation schedule is enabled
* Delete options for VM-related resources have been reviewed
* Exceptions are identified instead of blindly deleted

Primary verification command:

```powershell
$rg = "TestGroup1"
$location = "westus"

Get-AzVM -ResourceGroupName $rg -Status |
Where-Object { $_.Location -eq $location } |
Select-Object Name, Location, PowerState
```

Expected state for idle lab systems:

```text
VM deallocated
```

## Rollback Procedure

If a VM is deallocated but later needed, restart it from the portal or with PowerShell.

PowerShell example:

```powershell
Start-AzVM `
  -ResourceGroupName "TestGroup1" `
  -Name "TestClientVM1"
```

Azure CLI example:

```powershell
az vm start `
  --resource-group TestGroup1 `
  --name TestClientVM1
```

After startup, verify the VM state:

```powershell
Get-AzVM -ResourceGroupName "TestGroup1" -Status |
Select-Object Name, Location, PowerState
```

Expected result:

```text
VM running
```

If a scheduled shutdown interferes with active testing, temporarily disable the automation schedule instead of deleting the runbook.

## Common Issues

### VM is stopped but not deallocated

A VM can appear stopped from inside the guest OS while still holding Azure compute allocation. For cost control, verify that the Azure power state is `VM deallocated`.

### Scheduled shutdown exists but is not active

A runbook alone does not prove automation is active. The schedule must be linked and enabled.

### Delete options are inconsistent

Some VMs may show different delete behavior for OS disks and NICs. This should be reviewed intentionally. Disposable test clients can usually use `Delete`, while infrastructure systems may require retention depending on their role.

### Orphaned resources remain after cleanup

Deleted VMs can leave behind disks, NICs, public IPs, or other dependent resources if delete options were not configured or if resources were manually detached. These should be reviewed separately before deletion.

### Infrastructure VMs need separate judgment

Systems such as monitoring, NFS, or VPN/jumpbox servers may contain configuration state. Their disks or NICs should not be deleted automatically unless their configuration has been backed up or the system is known to be disposable.

## Lessons Learned

Cost control is not a single shutdown command. It requires a repeatable process that includes inventory, deallocation, verification, automation, and cleanup review.

The most important operational distinction is between `VM stopped` and `VM deallocated`. Deallocation is the state that matters for compute cost control.

Automation improves consistency, but scheduled shutdown should still be verified. The schedule must be enabled, linked to the correct runbook, and reviewed periodically.

Delete-on-removal settings are useful for disposable client VMs, but infrastructure systems should be reviewed before applying automatic deletion behavior.

## Related Documents

* [VM Lifecycle Management](vm-lifecycle-management.md)
* [Administrative Command Library](administrative-command-library.md)
* [Jumpbox Administration Workflow](../remote-access/jumpbox-administration-workflow.md)
