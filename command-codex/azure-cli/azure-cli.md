# Azure CLI Command Reference

## Overview

This document serves as the Azure CLI command reference for the Azure Network Infrastructure Lab.

Commands in this file are organized by function and are intended to explain reusable Azure CLI command patterns used across the lab. System-specific context is documented separately under `command-codex/system-specific/`.

This file begins with Azure CLI commands used during VM cost-control operations, reverse DNS migration, NSG rule configuration, and WireGuard SSH access rule maintenance.

## Purpose

The purpose of this reference is to:

* Explain Azure CLI commands used in the lab.
* Break down Azure CLI command groups, parameters, output formats, and query syntax.
* Provide reusable examples that can apply beyond a single system.
* Reduce future reliance on AI-assisted command generation.
* Support deeper understanding of Azure administration commands.

## Scope

This document currently covers commands related to:

* VM inventory and power-state review
* VM startup
* Public DNS zone inspection
* Private DNS zone inspection
* PTR record backup
* Public-to-private reverse DNS migration
* Private DNS VNet links
* PTR record restoration
* PTR record verification
* Network Security Group rule creation
* Network Security Group rule updates

---

# VM Inventory and Power State

## List VM Power States by Region

### Command

az vm list -g $rg -d `
  --query "[?location=='$location'].{Name:name, State:powerState, Location:location}" `
  -o table

### Purpose

Lists virtual machines in a resource group, includes power-state information, filters the results by region, and displays the output as a table.

### Breakdown

* `az` = Azure CLI command-line tool.
* `vm` = Azure virtual machine command group.
* `list` = lists virtual machines.
* `-g $rg` = targets the resource group stored in the `$rg` variable.
* `-d` = includes instance details such as power state.
* `` ` `` = PowerShell line-continuation character used because this Azure CLI command was run from a PowerShell session.
* `--query` = filters and reshapes the output.
* `[?location=='$location']` = filters results to VMs in the selected region.
* `{Name:name, State:powerState, Location:location}` = creates a custom output shape.
* `-o table` = displays output as a readable table.

### Used In

* Cost Control Operations

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/powershell-syntax.md`

---

# VM Startup

## Start VM with Azure CLI

### Command

az vm start `
  --resource-group TestGroup1 `
  --name TestClientVM1

### Purpose

Starts a stopped or deallocated Azure virtual machine.

### Breakdown

* `az` = Azure CLI command-line tool.
* `vm` = Azure virtual machine command group.
* `start` = starts the specified VM.
* `` ` `` = PowerShell line-continuation character used because this Azure CLI command was run from a PowerShell session.
* `--resource-group TestGroup1` = targets the resource group containing the VM.
* `--name TestClientVM1` = specifies the VM to start.

### Used In

* Cost Control Operations

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/powershell-syntax.md`

---

# DNS Zone Inspection

## Show Public DNS Zone

### Command

az network dns zone show --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --output table

### Purpose

Displays details for the public DNS reverse lookup zone.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network` = Azure networking command group.
* `dns` = Azure Public DNS command group.
* `zone` = DNS zone resource type.
* `show` = displays details for one resource.
* `--resource-group TestGroup1` = targets the resource group.
* `--name 0.0.10.in-addr.arpa` = specifies the reverse lookup zone.
* `--output table` = displays output as a readable table.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`

---

## Show Private DNS Zone

### Command

az network private-dns zone show --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --output table

### Purpose

Displays details for the private DNS reverse lookup zone.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network` = Azure networking command group.
* `private-dns` = Azure Private DNS command group.
* `zone` = private DNS zone resource type.
* `show` = displays details for one resource.
* `--resource-group TestGroup1` = targets the resource group.
* `--name 0.0.10.in-addr.arpa` = specifies the private reverse lookup zone.
* `--output table` = displays output as a readable table.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`

---

# DNS Record Backup

## Export Public PTR Records

### Command

az network dns record-set ptr list --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --output json > ptr-records-backup.json

### Purpose

Exports existing public DNS PTR records to a JSON backup file before the public reverse DNS zone is deleted.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network dns` = Azure Public DNS command group.
* `record-set ptr list` = lists PTR record sets.
* `--resource-group TestGroup1` = targets the resource group.
* `--zone-name 0.0.10.in-addr.arpa` = specifies the reverse lookup zone.
* `--output json` = returns output as JSON.
* `>` = redirects output to a file.
* `ptr-records-backup.json` = backup file name.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

# DNS Zone Migration

## Delete Public DNS Zone

### Command

az network dns zone delete --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --yes

### Purpose

Deletes the public DNS reverse lookup zone.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network dns zone delete` = deletes an Azure Public DNS zone.
* `--resource-group TestGroup1` = targets the resource group.
* `--name 0.0.10.in-addr.arpa` = specifies the DNS zone to delete.
* `--yes` = confirms the deletion without an interactive prompt.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`

---

## Create Private DNS Zone

### Command

az network private-dns zone create --resource-group TestGroup1 --name 0.0.10.in-addr.arpa

### Purpose

Creates a private DNS reverse lookup zone.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network private-dns zone create` = creates an Azure Private DNS zone.
* `--resource-group TestGroup1` = targets the resource group.
* `--name 0.0.10.in-addr.arpa` = specifies the reverse lookup zone name.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`

---

## Link Private DNS Zone to VNet

### Command

az network private-dns link vnet create --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --name reverse-vnet-link --virtual-network TestVNet1 --registration-enabled false

### Purpose

Links the private reverse DNS zone to the lab virtual network.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network private-dns link vnet create` = creates a VNet link for a private DNS zone.
* `--resource-group TestGroup1` = targets the resource group.
* `--zone-name 0.0.10.in-addr.arpa` = specifies the private DNS zone.
* `--name reverse-vnet-link` = names the VNet link.
* `--virtual-network TestVNet1` = links the zone to the lab VNet.
* `--registration-enabled false` = disables auto-registration.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`

---

# DNS Record Restore

## Bulk Restore Private PTR Records

### Command

jq -r '.[] | "az network private-dns record-set ptr create --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --name \(.name) --ttl 3600 && az network private-dns record-set ptr add-record --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --record-set-name \(.name) --ptrdname \(.PTRRecords[0].ptrdname)"' ptr-records-backup.json | bash

### Purpose

Reads the PTR record backup file, generates Azure CLI commands, and recreates PTR record sets inside the private DNS zone.

### Breakdown

* `jq -r` = reads JSON and outputs raw text.
* `.[]` = processes each object in the JSON array.
* `az network private-dns record-set ptr create` = creates the PTR record set.
* `--resource-group TestGroup1` = targets the resource group.
* `--zone-name 0.0.10.in-addr.arpa` = specifies the private DNS zone.
* `--name \(.name)` = inserts each record-set name from the JSON backup.
* `--ttl 3600` = sets the record time-to-live.
* `&&` = runs the next command only if the first command succeeds.
* `az network private-dns record-set ptr add-record` = adds the PTR hostname value.
* `--record-set-name \(.name)` = targets the record set that was just created.
* `--ptrdname \(.PTRRecords[0].ptrdname)` = inserts the PTR hostname from the JSON backup.
* `ptr-records-backup.json` = source backup file.
* `| bash` = sends generated command text to Bash for execution.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

# DNS Record Creation

## Failed Private PTR Record Create Attempt

### Command

az network private-dns record-set ptr create \
  --resource-group TestGroup1 \
  --zone-name 0.0.10.in-addr.arpa \
  --name 132 \
  --ptrdname NetMonVM1 \
  --ttl 3600

### Purpose

Attempted to create a private DNS PTR record set and assign the PTR hostname in one command.

### Breakdown

* `az network private-dns record-set ptr create` = creates a PTR record set in a private DNS zone.
* `\` = Bash line-continuation character.
* `--resource-group TestGroup1` = targets the resource group.
* `--zone-name 0.0.10.in-addr.arpa` = specifies the private DNS zone.
* `--name 132` = creates the PTR record set for the final octet `132`.
* `--ptrdname NetMonVM1` = attempted PTR hostname parameter.
* `--ttl 3600` = record time-to-live.

### Used In

* Reverse DNS Zone Migration
* Troubleshooting failed PTR record creation syntax

### Notes

This command was recorded as a failed attempt. The private DNS PTR create command does not accept `--ptrdname` in this form. The working process required creating the record set first, then adding the PTR record separately.

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

# DNS Verification

## List Private PTR Records

### Command

az network private-dns record-set ptr list \
  --resource-group TestGroup1 \
  --zone-name 0.0.10.in-addr.arpa \
  --query "[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}" \
  --output table

### Purpose

Lists private DNS PTR records and displays selected fields in a readable table.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network private-dns record-set ptr list` = lists PTR record sets in a private DNS zone.
* `\` = Bash line-continuation character.
* `--resource-group TestGroup1` = targets the resource group.
* `--zone-name 0.0.10.in-addr.arpa` = specifies the reverse lookup zone.
* `--query` = filters and reshapes command output.
* `[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}` = selects record name, PTR hostname, and TTL.
* `--output table` = displays output as a readable table.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

# NSG Rule Management

## Create NetMon NSG Rule

### Command

az network nsg rule create --resource-group TestGroup1 --nsg-name NetMonNSG1 \
  --name Allow-ICMP-from-VNet --priority 100 --direction Inbound \
  --source-address-prefixes VirtualNetwork --destination-port-ranges '*' \
  --protocol Icmp --access Allow

### Purpose

Creates an inbound Network Security Group rule allowing ICMP traffic from the virtual network.

### Breakdown

* `az` = Azure CLI command-line tool.
* `network nsg rule create` = creates a Network Security Group rule.
* `--resource-group TestGroup1` = targets the resource group.
* `--nsg-name NetMonNSG1` = specifies the NSG to modify.
* `\` = Bash line-continuation character.
* `--name Allow-ICMP-from-VNet` = names the rule.
* `--priority 100` = sets the rule priority.
* `--direction Inbound` = applies the rule to inbound traffic.
* `--source-address-prefixes VirtualNetwork` = allows traffic from the Azure VirtualNetwork service tag.
* `--destination-port-ranges '*'` = applies to any destination port.
* `--protocol Icmp` = applies to ICMP traffic.
* `--access Allow` = permits matching traffic.

### Used In

* NetMon NSG Rules

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

## Update WireGuard SSH NSG Rule With Current Public IP

### Command

curl -s ifconfig.me | xargs -I {} az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}

### Purpose

Retrieves the current public IP address and updates the WireGuard NSG SSH rule so SSH access is allowed from that source.

### Breakdown

* `curl -s ifconfig.me` = retrieves the current public IP address silently.
* `|` = sends the IP address to the next command.
* `xargs -I {}` = defines `{}` as a placeholder for the piped IP address.
* `az network nsg rule update` = updates an existing NSG rule.
* `\` = Bash line-continuation character.
* `--resource-group TestGroup1` = targets the resource group.
* `--nsg-name WireGuardNSG1` = specifies the NSG to modify.
* `--name SSH` = targets the SSH rule.
* `--source-address-prefixes {}` = replaces the SSH source prefix with the current public IP address.

### Used In

* WireGuard NSG and ASG Rules

### Related Syntax

* `../syntax/azure-cli-query-syntax.md`
* `../syntax/bash-syntax.md`

---

## Related Documents

* [Cost Control Operations](../../operations/cost-control-operations.md)
* [Reverse DNS Migration](../../network/private-dns-implementation.md)
* [WireGuard VPN Gateway](../../remote-access/wireguard-vpn-gateway.md)
* [Bash/Linux Command Reference](../bash-linux/bash-linux.md)
* [Azure CLI Query Syntax Reference](../syntax/azure-cli-query-syntax.md)
* [Bash Syntax Reference](../syntax/bash-syntax.md)